---
title: 使用pelican和github搭建个人blog
date: 2016-04-13 16:52:18
tags: [blog, pelican, python]
---

前几日浏览网页时无意中看到Pelican，于是心血来潮想要搭建个人博客玩玩。联想到github已经提供个人域名，一切都顺利成章。简单写点用做留念
### 1.搭建环境准备
本人属于重度Linux患者，环境为Ubuntu 14.04LTS，其他环境应该类似
### 2.涉及相关技术
- Python2.7 及其相关
- Pelican
- Github
- Markdown
- And so on ...
#### 2.1. Pelican
- Pelican是一个用Python语言编写的静态网站生成器，支持使用restructuredText和Markdown写文章，配置灵活，扩展性强。同时有很多主题可以使用。
- Pelican的github地址:  https://github.com/getpelican/pelican
- Pelican 主题的github地址:  https://github.com/getpelican/pelican-themes

### 3. 使用Pelican 搭建个人静态博客
#### 3.1. 安装pelican
``` bash
aptitude install python-pelican
```
python2.7 以及相关其他依赖不做介绍
#### 3.2. 开始搭建
输入如下命令
``` bash
mkdir blog
cd blog
pelican-quickstart
```
pelican-quickstart 是pelican 自带命令，根据提示一步步输入相应的配置项，不知道如何设置的接受默认即可，后续可以通过编辑pelicanconf.py文件更改配置

结束后生成目录如下
```bash
 blog/
 ├── content              # 存放输入的Markdown文件夹
 ├── output               # 生成的输出文件
 ├── develop_server.sh    # 开启测试服务器脚本
 ├── Makefile             # 管理博客的Makefile
 ├── pelicanconf.py       # 主配置文件
 └── publishconf.py       # 主发布文件
```

####3.3. 写博客内容
 - 进入到content 目录下，用Markdown 开始编写内容。Markdown语法简单，Google即可
 - Markdown 在线编辑器推荐使用[马克飞象](https://maxiang.io/)，个人使用不错。本地编辑器使用ReText。
 - 切记在每个文件前四行输入如下
```bash
 Title: 文章标题
 Date: 2013-04-18
 Category: 文章类别
 Tag: 标签1, 标签2
```
####3.4. 预览博客
输入以下命令
``` bash
make publish
make serve
```
打开浏览器，输入127.0.0.1:8000 即可看到博客

####3.5. 选择主题
[pelican-themes](https://github.com/getpelican/pelican-themes) 上有很多主题， git clone后可以使用如下命令安装任一主题
```bash
pelican-themes -i XXXXXX
```
安装完成后在pelicanconf.py文件中修改THEME 容，如安装了pelican-bootstrap3主题，那么修改THEME ="pelican-bootstrap3"，重启即可看到主题修改

####3.6. 设置favicon.ico
favicon.ico 即Favorites Icon的缩写，其可以让浏览器除显示相应的标题外，还以图标的方式区别不同的网站。  

 1.  选择图片，生成.ico文件(可直接使用网站生成如 [在线制作ico图标](http://www.bitbug.net/))
 2.  将图片命名成favicon.ico，放置到与Makefile同级目录
 3.  修改Makefile，添加移动favicon.ico功能
```bash
FAVICONICO=$(BASEDIR)/favicon.ico

publish: clean                                                                                                                                                                                           
    $(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(PUBLISHCONF) $(PELICANOPTS)
    cp $(FAVICONICO) $(OUTPUTDIR)
```

####3.7. 设置评论系统
在[Disqus](https://disqus.com/admin/signup)上申请一个站点，记牢Shortname。 在pelicanconf.py添加
```bash
DISQUS_SITENAME = Shortname
```
设置后可以在每个blog下出现如此评论系统
![disqus_comments](http://ww3.sinaimg.cn/large/73e6e6e1gw1f1rj38tgbnj20po08yq3s.jpg)

####3.8. 添加图片图床
前两天一直在找一个简单易用的图床，终于找到一个推荐的[围脖是个好图床](https://weibotuchuang.sinaapp.com/)

1. 进入网站，选择对应的浏览器安装插件(本人安装了Chrome插件)
2. 安装完成后，打开插件，会出现提示对话框，将图片拖入即可生成对应的图片URL了

####3.X. 其他功能
其他还有很多功能如评论系统，分析系统，站内搜索可以添加，后续会更新

### 4. 使用github发布博客
原理: Github为每一个用户分配了一个二级域名username.github.io，用户为自己的二级域名创建主页很简单，只需要在Github下创建一个名为username.github.io的版本库，并向其master分支提交网站静态页面即可。

1. 登陆Github，创建一个名为username.github.io的版本库(必须如此格式)
2. 将blog/output 下的内容git到username.github.io下
3. 少等片刻，登陆http://username.github.io，会发现自己的个人博客已经生成

如此一来，一个具有Geek风格的个人博客搭建完毕。可以出去装X了...


