---
title: 记一次django部署时遇到的问题总结
date: 2017-10-16 16:52:18
tags: [django, python, centos, linux]
---

一. 大概情况
就是说有一个django服务需要部署到centos的apache上去。但是呢该centos内核版本较低，自带的python版本较低。需要自己编译一个python2.7的版本替换掉系统的。然后就开展了一场与各种配置的艰苦斗争。。。

篇幅短长，大家就当作看一个故事吧。重点的呢会加黑一下，同时也写在结论处的。

二. 斗争过程
2.1. 刚拿到这个任务时，我登陆centos找apache服务。但是居然没有找到/etc/apache2(以前接触的机器都是ubuntu和debian, 没有接触过redhat和centos)，我困惑了。。。然后查了一下才知道centos上的httpd就是apache，也就是**/etc/httpd就是我要找的apache目录**。

2.2. 知道apache目录后，我首先试着跑了一下django，采用本地启动的方式，验证采用wget ${URL}的方式，发现程序是OK的。那么就可以部署到apache上去了。apache中的conf/httpd.conf中已经有了对应的wsgi配置(已有前人的肩膀可以踩了，很happy)，看了一下**WSGIScriptAlias** 配置路径，没有问题。那么我就尝试启动了apache，启动方式为 service httpd restart。但此时查看apache的error_log，现在**提示找不到site.py错误**。

2.3. 查找相关的资料，我怀疑可能是mod_wsgi版本过低导致的。通过ldd modules/mod_wsgi.so 看到
``` bash
 linux-vdso.so.1 =>  (0x00007ffff3300000)
 libpython2.6.so.1.0 => /usr/lib64/libpython2.6.so.1.0 (0x00007f48fb4e6000)
 libpthread.so.0 => /lib64/libpthread.so.0 (0x00007f48fb2c9000)
 libdl.so.2 => /lib64/libdl.so.2 (0x00007f48fb0c4000)
 libutil.so.1 => /lib64/libutil.so.1 (0x00007f48faec1000)
 libm.so.6 => /lib64/libm.so.6 (0x00007f48fac3d000)
 libc.so.6 => /lib64/libc.so.6 (0x00007f48fa8a8000)
 /lib64/ld-linux-x86-64.so.2 (0x00007f48fbab9000)
``` 
其中很明显libpython是2.6版本的，和我自装的2.7版本对不上。此时有两种方式
  1. 修改link so文件，也就是把/usr/lib64/libpython2.6.so.1.0 做成一个软连接，link到python2.7.so上
  2. 重现编译mod_wsgi
考虑到尽量少走歪路，采用比较保险的第2中方案。

2.4. 下载mod_wsgi源码，开始编译。然后就很顺利的报错了，出错如下
```bash
/usr/bin/ld: /usr/local/lib/libpython2.7.a(abstract.o): relocation R_X86_64_32 against `.rodata.str1.8‘ can not be used when making a shared object; recompile with -fPIC
/usr/local/lib/libpython2.7.a: could not read symbols: Bad value
collect2: ld returned 1 exit status
apxs:Error: Command failed with rc=65536
```
提示还是比较明显的，程序在做link libpython2.7.a 的时候找到的是静态库(.a)不是动态库(.so)，当时看到这个错误时感觉崩溃了，这说明需要重新编译python程序啊。。。蹲墙角哭了一会，回来默默的把python删掉，重新下载python源码，**./configure时带上--enable-shared; make; make install。后再编译mod_wsgi** 就可以了。替换掉modules/mod_wsgi.so。

PS: *关于mod_wsgi，有兴趣可以看一下: http://modwsgi.readthedocs.io/en/develop/*

2.5. 安装完mod_wsgi，先喝口水缓一缓，因为我相信apache的环境应该是不会有问题了，我只要service httpd restart就ok了。果然，现实给我了一记响亮的耳光，error_log 中出现了如下错误
```python
[Fri Oct 13 13:49:42 2017] [error] [client 192.168.5.102] mod_wsgi (pid=4017): Target WSGI script '/var/www/html/attence/wsgi.py' cannot be loaded as Python module.
[Fri Oct 13 13:49:42 2017] [error] [client 192.168.5.102] mod_wsgi (pid=4017): Exception occurred processing WSGI script '/var/www/html/attence/wsgi.py'.
[Fri Oct 13 13:49:42 2017] [error] [client 192.168.5.102] Traceback (most recent call last):
[Fri Oct 13 13:49:42 2017] [error] [client 192.168.5.102]   File "/var/www/html/attence/wsgi.py", line 23, in <module>
[Fri Oct 13 13:49:42 2017] [error] [client 192.168.5.102]     from django.core.wsgi import get_wsgi_application
[Fri Oct 13 13:49:42 2017] [error] [client 192.168.5.102] ImportError: No module named django.core.wsgi
```
口中的水差点吐在屏幕上。。。怎么django没有了。。。我突然间意识到我重装了python。。。然后开始了重装各种依赖的漫漫长路。(**装完一个后，重启apache，根据错误提示No module named XXX，找对应依赖的下载地址即可**)。

2.6. 安装完django的依赖后，error_log出现了一个诡异的错误
```python
[Sun Oct 15 19:11:02 2017] [error] [client 127.0.0.1] mod_wsgi (pid=880): Target WSGI script '/var/www/html/attence/wsgi.py' cannot be loaded as Python module.
[Sun Oct 15 19:11:02 2017] [error] [client 127.0.0.1] mod_wsgi (pid=880): Exception occurred processing WSGI script '/var/www/html/attence/wsgi.py'.
//.... 省略掉中间很多错误日志
[Sun Oct 15 19:11:02 2017] [error] [client 127.0.0.1]     __import__(name)
[Sun Oct 15 19:11:02 2017] [error] [client 127.0.0.1] ImportError: No module named attence.settings
```
attence.settings是我的DJANGO_SETTINGS_MODULE，如果说找不到这个module，那么就说明整个路径配置有问题了。在这个地方我想了很久，也查了很多资料，都没什么结果。有时间就是会有灵光一现，我突然间意识到如果我手动跑/var/www/html/attence/wsgi.py这个文件会怎么样(因为我相信apache也是去运行这个文件的)。果然，也提示相同的错误，哈哈，那就方便多了呀，打开wsgi.py文件, 中间的一行代码引起了我的注意: 
```python
root = os.path.dirname(__file__)) 
sys.path.insert(0, os.path.join(root,'site-packages'))
```
很诡异的代码，我猜想可能以前的人是把工程文件放在python lib 的 site-packages下的吧。将此段代码稍作修改
```python
root = os.path.dirname(os.path.realpath(__file__))
sys.path.append(root)
```
此时，再运行wsgi文件，没有再提示错误，重启apache，不再提示这个错误，而是提示其他的依赖ImportError， 如 ImportError: No module named tablib，然后又开始了装依赖的漫漫长路。

2.7. 终于，重启apache, wget ${URL} 不再报错了，说明终于配完了，我欣喜若狂。打开浏览器，输入URL，然后页面提示： 无法访问此网站。我的心又碎了了。。。这又是为啥呢，后来发现是防火墙启动了，只开放了8080端口。。。然后我就把果断把防火墙关掉, **service iptables stop**。

2.8. 终于的终于，我在浏览器上看到了我想要的页面。我的眼泪也终于流下来了。。。。

三. 总结:
整个过程花了我挺久时间的，有自己不小心走的弯路，也有学习到自己不知道的技术。
3.1. centos下的apache叫httpd, 其他一样
3.2. WSGI相关的知识点需要再重新学习一下，其中很多地方有点印象，但又不确定，导致查询资料花费挺长时间的
3.3. django作为python最火热之一的web框架，应该能够熟练应用。
3.4. 内网正常，外网无法访问的情况下，一般看一下防火墙或者nginx的配置
3.5. 熟悉linux下的源码安装方式，包括C程序的make以及python的setup
3.6. 还有其他linux下的一些快捷方式，如通过CTRL+R来查找历史命令，很简单，但很实用，能够极大加快调查问题的速度。

有些问题事后想来还是很简单的，但当时的确困扰了我好久。但总的来说，花的时间非常值得。


