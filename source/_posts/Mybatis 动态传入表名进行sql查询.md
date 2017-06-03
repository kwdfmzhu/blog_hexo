---
title: Mybatis 动态传入表名进行sql查询
date: 2017-05-13 16:52:18
tags: [java, mybatis]
---

网上也有相关的方法，基本都为
1. 添加属性statementType="STATEMENT"
2. 用${}代替#{}。如此一来就会有sql注入的危险。

今天自己尝试了一种新的方法，如下:
#### 基本思路
利用org.apache.ibatis.annotations.Param的注解，在xml中判断传入的参数:表名用${},值用#{}。
#### 实现过程
* 定义一个mapper

```Java
public interface TestMapper{
    //统计userId的对应的数据总数
    int countByUserId(@Param("tableName") String tableName, @Param("userId") Integer userId);
}
```
* 定义xml

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="TestMapper对应路径">
    <select id="countByUserId" parameterType="hashmap" resultType="java.lang.Integer">
        SELECT
        COUNT(1)
        FROM
        ${tableName}
        WHERE
        userId = #{userId}
    </select>
</mapper>

```
如此配置，即可以实现表名的动态传入，又可以防止sql注入的危险。传入库名或者字段名同理可得。



