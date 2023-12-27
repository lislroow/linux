#### * `eclipse DTD`
mybatis-config.xml 의 DTD 가 eclipse `Language Server > LemMinX` 에 의해 다운로드가 되지 않을 경우 다음의 선택지를 참고합니다.
```xml
<!DOCTYPE Config PUBLIC "-//mybatis.org//DTD Config 3.0//EN" 
  "http://mybatis.org/dtd/mybatis-3-config.dtd">

<!-- DTD 를 정의하지 않고 사용함 (Document Type Definition 이 없으면 유효성 검증은 할 수 없음) -->
<!DOCTYPE configuration>
<configuration>
  <settings>
    ...
  </settings>
</configuration>

<!-- mapper 또한 같음 -->
<!DOCTYPE mapper>
<mapper>
</mapper>
```

#### * 기본 코드

```java
package spring.framework.mybatis.config;

import javax.sql.DataSource;

import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Conditional;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Configuration
@Conditional(MybatisProperties.class)
@EnableConfigurationProperties({MybatisProperties.class, DataSourceProperties.class})
@MapperScan(basePackages = "spring")
public class MybatisConfig {
  
  @Autowired
  private MybatisProperties properties;
  
  @Autowired
  private DataSourceProperties dataSourceProperties;
  
  @Bean
  DataSource dataSource() {
    HikariConfig hikariConfig = new HikariConfig();
    hikariConfig.setDriverClassName(dataSourceProperties.getDriverClassName());
    hikariConfig.setJdbcUrl(dataSourceProperties.getJdbcUrl());
    hikariConfig.setUsername(dataSourceProperties.getUsername());
    hikariConfig.setPassword(dataSourceProperties.getPassword());
    hikariConfig.setMaximumPoolSize(dataSourceProperties.getMaximumPoolSize());
    hikariConfig.setMinimumIdle(dataSourceProperties.getMinimumIdle());
    hikariConfig.setConnectionTestQuery(dataSourceProperties.getConnectionTestQuery());
    hikariConfig.setConnectionTimeout(dataSourceProperties.getConnectionTimeout());
    return new HikariDataSource(hikariConfig);
  }
  
  @Bean
  SqlSessionFactoryBean sqlSessionFactoryBean(DataSource dataSource) throws Exception {
    String configFile = properties.getConfigFile();
    String mapperLocation = properties.getMapperLocation();
    SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
    sqlSessionFactoryBean.setDataSource(dataSource);
    sqlSessionFactoryBean.setConfigLocation(
        new PathMatchingResourcePatternResolver().getResource(configFile));
    sqlSessionFactoryBean.setMapperLocations(
        new PathMatchingResourcePatternResolver().getResources(mapperLocation));
    sqlSessionFactoryBean.setTypeAliasesPackage("spring");
    return sqlSessionFactoryBean;
  }
}

// ---
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Condition;
import org.springframework.context.annotation.ConditionContext;
import org.springframework.core.type.AnnotatedTypeMetadata;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@ConfigurationProperties(prefix = "framework.mybatis")
public class MybatisProperties implements Condition {
  
  private final String ENABLED = "framework.mybatis.enabled";
  private boolean enabled;
  private String mapperLocation;
  private String configFile;
  
  @Override 
  public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
    String enabled = context.getEnvironment().getProperty(ENABLED);
    return "true".equals(enabled);
  }
  
  public boolean isEnabled() {
    return enabled;
  }
  
  public void setEnabled(boolean enabled) {
    this.enabled = enabled;
  }
  
  ...
}

// ---
import org.springframework.boot.context.properties.ConfigurationProperties;

@Slf4j
@ConfigurationProperties(prefix = "framework.mybatis.data-source")
public class DataSourceProperties {
  
  private String driverClassName;
  
  ...
}

// ---
package spring.smpl.basic;

import java.util.Date;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface BasicMapper {
  
  public Date selectNow();
  
}
```

