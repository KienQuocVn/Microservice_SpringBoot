package com.devteria.gateway.configuration;

import com.devteria.gateway.dto.ApiResponse;
import com.devteria.gateway.service.IdentityService;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.netty.handler.codec.http.HttpResponseStatus;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.experimental.NonFinal;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;
import reactor.netty.http.server.HttpServerResponse;

import java.util.Arrays;
import java.util.List;

// Filter toàn cục để xác thực JWT token cho mọi request đi qua Gateway
// Implement Ordered để đảm bảo filter này chạy trước các filter khác
@Component
@Slf4j
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PACKAGE, makeFinal = true)
public class AuthenticationFilter implements GlobalFilter, Ordered {
    IdentityService identityService;
    ObjectMapper objectMapper;

    // Các endpoint công khai không cần xác thực
    @NonFinal
    private String[] publicEndpoints = {
            "/identity/auth/.*",              // Đăng nhập
            "/identity/users/registration",   // Đăng ký user mới
            "/notification/email/send",       // Gửi email thông báo
            "/file/media/download/.*"         // Download file media
    };

    @Value("${app.api-prefix}")
    @NonFinal
    private String apiPrefix;

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        log.info("Enter authentication filter....");

        // Nếu là public endpoint thì bỏ qua xác thực, cho request đi tiếp
        if (isPublicEndpoint(exchange.getRequest()))
            return chain.filter(exchange);

        // Lấy token từ Authorization header
        List<String> authHeader = exchange.getRequest().getHeaders().get(HttpHeaders.AUTHORIZATION);

        // Không có token → trả về lỗi 401
        if (CollectionUtils.isEmpty(authHeader))
            return unauthenticated(exchange.getResponse());

        // Extract token từ "Bearer <token>"
        String token = authHeader.getFirst().replace("Bearer ", "");
        log.info("Token: {}", token);

        // Gọi Identity Service để kiểm tra token hợp lệ hay không
        return identityService.introspect(token).flatMap(introspectResponse -> {
            // Token hợp lệ → cho request đi tiếp tới service phía sau
            if (introspectResponse.getResult().isValid())
                return chain.filter(exchange);
            // Token không hợp lệ → trả 401
            else
                return unauthenticated(exchange.getResponse());
            // Nếu Identity Service lỗi → coi như chưa xác thực
        }).onErrorResume(throwable -> unauthenticated(exchange.getResponse()));
    }

    // Thiết lập độ ưu tiên cao nhất (-1) để filter này chạy đầu tiên
    @Override
    public int getOrder() {
        return -1;
    }

    // Kiểm tra request có nằm trong danh sách public endpoint không
    private boolean isPublicEndpoint(ServerHttpRequest request){
        return Arrays.stream(publicEndpoints)
                .anyMatch(s -> request.getURI().getPath().matches(apiPrefix + s));
    }

    // Trả về response 401 Unauthenticated với format JSON chuẩn
    Mono<Void> unauthenticated(ServerHttpResponse response){
        ApiResponse<?> apiResponse = ApiResponse.builder()
                .code(1401)
                .message("Unauthenticated")
                .build();

        String body = null;
        try {
            body = objectMapper.writeValueAsString(apiResponse);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }

        response.setStatusCode(HttpStatus.UNAUTHORIZED);
        response.getHeaders().add(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE);

        return response.writeWith(
                Mono.just(response.bufferFactory().wrap(body.getBytes())));
    }
}
