package cn.datax.service.quartz.config;

import cn.datax.service.quartz.api.entity.QrtzJobEntity;
import cn.datax.service.quartz.quartz.utils.ScheduleUtil;
import cn.datax.service.quartz.service.QrtzJobService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Component
@RequiredArgsConstructor
public class StartedUpRunner implements ApplicationRunner {

    private final ConfigurableApplicationContext context;
    private final Environment environment;

    @Autowired
    private QrtzJobService qrtzJobService;

    @Override
    public void run(ApplicationArguments args) {
        if (context.isActive()) {
            String banner = "-----------------------------------------\n" +
                    "服务启动成功，时间：" + DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss").format(LocalDateTime.now()) + "\n" +
                    "服务名称：" + environment.getProperty("spring.application.name") + "\n" +
                    "端口号：" + environment.getProperty("server.port") + "\n" +
                    "-----------------------------------------";
            System.out.println(banner);

            // 项目启动时，初始化定时器
            try {
                List<QrtzJobEntity> list = qrtzJobService.list();
                ScheduleUtil.init(list);
            } catch (Exception e) {
                // 如果 Quartz 数据库表未初始化，记录警告但不阻止服务启动
                System.err.println("警告: 定时任务初始化失败，可能 Quartz 数据库表未创建: " + e.getMessage());
                System.err.println("请执行 install/sql/alldata-v0.6.2.sql 中的 Quartz 表创建脚本");
            }
        }
    }
}
