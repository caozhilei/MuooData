package cn.datax.service.system.config;

import org.springframework.security.config.annotation.SecurityConfigurerAdapter;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.DefaultSecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Token配置器
 * 参考system-service的TokenConfigurer实现
 *
 * @author AllDataDC
 */
public class TokenConfigurer extends SecurityConfigurerAdapter<DefaultSecurityFilterChain, HttpSecurity> {

    @Override
    public void configure(HttpSecurity http) {
        TokenFilter customFilter = new TokenFilter();
        http.addFilterBefore(customFilter, UsernamePasswordAuthenticationFilter.class);
    }
}
