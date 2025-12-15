package cn.datax.service.system.config;

import cn.datax.common.utils.JwtUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.User;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.GenericFilterBean;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.Collections;

/**
 * JWT Token过滤器
 * 解析Authorization header中的JWT token并设置SecurityContext
 * 参考system-service的TokenFilter实现
 *
 * @author AllDataDC
 */
@Slf4j
public class TokenFilter extends GenericFilterBean {

    private static final String TOKEN_HEADER = "Authorization";
    private static final String TOKEN_PREFIX = "Bearer ";

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain)
            throws IOException, ServletException {
        HttpServletRequest httpServletRequest = (HttpServletRequest) servletRequest;
        String token = resolveToken(httpServletRequest);
        
        if (StringUtils.hasText(token)) {
            try {
                // 使用JwtUtil解析token获取用户名
                String username = JwtUtil.getTokenSubjectObject(token);
                if (username != null && !username.isEmpty()) {
                    // JwtUtil.getTokenSubjectObject()返回的已经是字符串，直接使用
                    // 如果返回的是带引号的JSON字符串，去掉引号
                    String actualUsername = username;
                    if (username.startsWith("\"") && username.endsWith("\"")) {
                        actualUsername = username.substring(1, username.length() - 1);
                    }
                    
                    // 创建认证对象
                    User principal = new User(actualUsername, "******", Collections.emptyList());
                    Authentication authentication = new UsernamePasswordAuthenticationToken(
                            principal, token, Collections.emptyList());
                    // 设置到SecurityContext
                    SecurityContextHolder.getContext().setAuthentication(authentication);
                    log.debug("设置用户认证信息: {}", actualUsername);
                }
            } catch (Exception e) {
                log.warn("解析Token失败: {}", e.getMessage());
                // Token解析失败不影响请求继续，只是不设置认证信息
            }
        }
        
        filterChain.doFilter(servletRequest, servletResponse);
    }

    /**
     * 从请求头中解析Token
     *
     * @param request HTTP请求
     * @return Token字符串
     */
    private String resolveToken(HttpServletRequest request) {
        String bearerToken = request.getHeader(TOKEN_HEADER);
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith(TOKEN_PREFIX)) {
            // 去掉Bearer前缀
            return bearerToken.replace(TOKEN_PREFIX, "");
        }
        return null;
    }
}
