---
title: spring配置动态数据源
date: 2017-12-25 20:24:00
tags: [java, spring, mysql, 数据源]
---

## 基本思路
运用spring的AbstractRoutingDataSource接口，实现determineCurrentLookupKey方法。
## 实现过程
1. 配置多数据源

```xml
<bean id="dataSource1" class="org.apache.tomcat.jdbc.pool.DataSource" destroy-method="close">
	<property name="driverClassName" value="com.mysql.jdbc.Driver" />
	<property name="url" value="${url}" />
	<property name="username" value="${username}" />
	<property name="password" value="${password}" />
	...
</bean>

<bean id="dataSource2" class="org.apache.tomcat.jdbc.pool.DataSource" destroy-method="close">
	<property name="driverClassName" value="com.mysql.jdbc.Driver" />
	<property name="url" value="${url}" />
	<property name="username" value="${username}" />
	<property name="password" value="${password}" />
	...
</bean>

<bean id="dataSource" class="com.xx.xx.xx.DynamicDataSource">
	<property name="targetDataSources">
		<map key-type="java.lang.String">
			<entry key="dataSource1" value-ref="dataSource1"/>
			<entry key="dataSource2" value-ref="dataSource2"/>
		</map>
	</property>
	<property name="defaultTargetDataSource" ref="dataSource1"/> <!-- 默认使用数据源 -->
</bean>
```
其中真正使用的数据源为dataSource，设置key-value来切换dataSource1和dataSource2

2. 实现DynamicDataSource类

```java
public class XADynamicDataSource extends AbstractRoutingDataSource {
    @Override
    protected Object determineCurrentLookupKey() {
        return "";//return dataSource1/dataSource2
    }
}
```
determineCurrentLookupKey的返回值就是上述xml配置中的key，做到切换数据源

## 应用场景
1. 读写分离
2. 不同类型数据源(如XA和普通数据源)切换 
3. 等等...

## 后语
这里只是提供一种比较简单的数据源切换实现过程，至于外部如何实现，有很多种方法如: 增加注解，通过SQL方法区分等等都可以。

