---
title: mysql 5.7 无法插入0000-00-00 00:00:00的数据
date: 2017-10-20 15:20:00
tags: [msyql]
---
起因:
  由于CRM的用户属性添加上要经过一个洗数的过程，因此online时间作为比较重要的时间戳需要保存下来。设置DEFAULT为"0000-00-00 00:00:00"。但是程序却报错
```Java
java.sql.SQLException: Cannot convert value '0000-00-00 00:00:00' from column XX to TIMESTAMP
```

解决办法:
  错误提示的很明显，但是以前做过类似的数据设计，是没有问题的。故查了以下发现mysql从5.6.X开始后，不再支持类似"0000-00-00"这种数据。如果想要规避此类问题，有几个方案
  1. 修改mysql配置文件的sql_mode，去掉 NO_ZERO_IN_DATE, NO_ZERO_DATE 两个选项。(不建议)
  2. 在数据库链接地址后加zeroDateTimeBehavior=convertToNull， 如： jdbc:mysql://192.168.5.241:3306/acrm-usercenter?zeroDateTimeBehavior=convertToNull

  zeroDateTimeBehavior可设置的值有三个:
  1. exception, 既为默认选项，就是抛出上述错误
  2. convertToNull, 转成NULL值
  3. round, 转成最近的日期"0001-01-01"

结论:
  根据需求，如果是新建的表，那么此类日期default可以设置为NULL；如果是数据库升级了，考虑到程序兼容性，可加zeroDateTimeBehavior=convertToNull


