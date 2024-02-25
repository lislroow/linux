#### * `Hikari DBCP`

- connectionTimeout: pool에서 커넥션을 얻어오기전까지 기다리는 최대 시간, 허용가능한 wait time을 초과하면 SQLException 발생. 설정가능한 가장 작은 시간은 250ms (default: 30000 (30s))
- idleTimeout: 
- maxLifetime: 
- connectionTestQuery: JDBC4 드라이버를 지원 시 사용하지 않는 것이 좋음
- minimumIdle: 기본값은 maximumPoolSize 와 같음
- poolName: JMX 에 표시되는 이름
- initializationFailTimeout: This property controls whether the pool will “fail fast” if the pool cannot be seeded with an initial connection successfully. Any positive number is taken to be the number of milliseconds to attempt to acquire an initial connection; the application thread will be blocked during this period. If a connection cannot be acquired before this timeout occurs, an exception will be thrown. This timeout is applied after the connectionTimeout period. If the value is zero (0), HikariCP will attempt to obtain and validate a connection. If a connection is obtained, but fails validation, an exception will be thrown and the pool not started. However, if a connection cannot be obtained, the pool will start, but later efforts to obtain a connection may fail. A value less than zero will bypass any initial connection attempt, and the pool will start immediately while trying to obtain connections in the background. Consequently, later efforts to obtain a connection may fail. Default: 1
- readOnly: connection 이 read-only로 설정되어있으면 일부 query 들은 최적화 상태가됨 (default: false)
- validationTimeout: valid 쿼리를 통해 커넥션이 유효한지 검사할 때 사용되는 timeout. (default: 5000ms) >= 250ms
- maximumPoolSize: `((core_count * 2) + effective_spindle_count)`

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

