---
title: freeswitch 配置连接sip服务器
date: 2017-12-21 14:19:00
tags: [freeswitch, sip]
---

## 目标
1. 部署freeswitch(以下简称fs), 实现软交换电话互通
2. 配置fs连接sip服务器，实现外部电话连通
3. 通过sipjs的webRTC实现浏览器拨打外部电话

## 安装过程
### 安装fs
在mac上有两种方式：
1. 直接brew install freeswitch
2. 源码安装，[官网地址](https://freeswitch.org/confluence/display/FREESWITCH/Installation)，下载源码后根据README提示安装即可(中途make时会需要安装很多依赖)
快速推荐使用方式1.

PS: centos6.5安装时用fs1.4版本(用1.6会提示依赖版本不够)
### 启动fs
命令行中输入freeswitch，待输出一堆信息后，出现蓝色背景的提示既是成功.
### 安装配置软交换电话软件
Mac OS上安装X-Lite，ios上安装Zoiper，在软交换中配置对应分机号(fs默认开放了1000至1019的分机号使用，初始密码是1234)
下图是X-Lite的配置，Zoiper同理
![1.jpg][1]
  [1]: http://192.168.5.101:12580/usr/uploads/2017/12/1671569006.jpg

### 拨打电话
直接打开X-Lite拨打其他已经设置的分机号即可

**到此目标1步骤完成**
---

### fs配置sip服务器
前提: 已经有现成的sip服务器已经对应的账号
1. 在fs的etc/freeswitch/sip_profiles/external路径下，新建文件名为sipprovider.xml, 内容:
```xml
  <include>
  <gateway name="sipprovider">
    <param name="username" value="8009"/>
    <param name="password" value="123456"/>
    <param name="realm" value="192.168.5.201"/>
    <param name="proxy" value="192.168.5.201"/>
    <param name="register" value="true"/>
    <param name="expire-seconds" value="600"/>
    <param name="ping" value="30" />
    <param name="sip-trace" value="true" />
  </gateway>
</include>
```
2. 重启fs或者在fs_cli中输入“sofia profile external restart”, 看到终端如下就是生效

> Added gateway 'sipprovider' to profile 'external

### fs配置sip服务到extension
1. etc/freeswitch/dialplan/default新建00_rout_to_sipprovier.xml(*用00开头是为了让fs优先读取这个配置，防止被默认配置覆盖*)
2. 内容如下

```xml
<include>
    <extension name="5_201 sipprovider Gateway">
        <condition field="destination_number"expression="^(((13[0-9])|(14[5|7])|(15([0-3]|[5-9]))|(18[0,5-9]))\\d{8})$">
            <action application="set" data="dialed_extension=$1"/>
            <action application="bridge"data="sofia/gateway/sipprovider/$1"/>
        </condition>
    </extension>
</include>
```
3. fs_cli 输入 reloadxml重启配置
4. 如果需要增加录音功能，那么继续添加xml内容中的action标签。详见[这里](https://freeswitch.org/confluence/display/FREESWITCH/mod_dptools:+record_session)

```xml
            <action application="set" data="RECORD_TITLE=Recording ${destination_number} ${caller_id_number} ${strftime(%Y-%m-%d %H:%M)}"/>
            <action application="set" data="RECORD_COPYRIGHT=(c) 1980 Factory Records, Inc."/>
            <action application="set" data="RECORD_SOFTWARE=FreeSWITCH"/>
            <action application="set" data="RECORD_ARTIST=Ian Curtis"/>
            <action application="set" data="RECORD_COMMENT=Love will tear us apart"/>
            <action application="set" data="RECORD_DATE=${strftime(%Y-%m-%d %H:%M)}"/>
            <action application="set" data="RECORD_STEREO=true"/>
            <action application="record_session" data="$${recordings_dir}/${strftime(%Y-%m-%d-%H-%M-%S)}_${destination_number}_${caller_id_number}.wav"/>
```

### 拨打电话
在X-Lite上输入外网电话即可，如我的手机1508860XXXX

**到此目标2步骤完成**
---

### 开启fs的websocket端口
在sip_profiles/internal.xml中开启ws-binding和wss-binding
```xml
    <!-- for sip over websocket support -->
    <param name="ws-binding"  value=":5066"/>

    <!-- for sip over secure websocket support -->
    <!-- You need wss.pem in $${certs_dir} for wss or one will be created for you -->
    <param name="wss-binding" value=":7443"/>
```

### 使用SipJS实现
1. 查看sipjs[官网](https://sipjs.com/)，根据文档实现
2. 我使用demo[地址](git@192.168.5.252:zuoye/sipjs-demo.git)

