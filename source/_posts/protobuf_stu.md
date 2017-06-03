---
title: protobuf 的简单介绍
date: 2016-02-29 16:52:18
---

### protobuf 是什么
protobuf 全称 Google Protocol Buffers，是Google公司内部的混合语言数据标准。在2008年7月7号将其作为开源项目对外公布。

protobuf 是一种轻便高效的结构化数据存储格式，可以用于结构化数据串行化，很适合做数据存储或 RPC 数据交换格式。它可用于通讯协议、数据存储等领域的语言无关、平台无关、可扩展的序列化结构数据格式。

protobuf的[源码](https://github.com/google/protobuf)，protobuf的[官方文档](https://developers.google.com/protocol-buffers/docs/overview)， 有兴趣的同学可以深入研究一下


### 为什么要使用 protobuf
protobuf是一种结构化数据存储格式，类似的比较常见的有xml和json。那么和他们比较，protobuf又有什么优点？
  
  * 后台硬，有Google开发且开源，已经在Google内部久经考验 
  * 可通过解析器生成数据访问类，在编程中更容易使用
  * 性能好/效率高。鉴于Google对于性能的偏执，protobuf的性能自不必说。但网上相关数据已有很多，我取了这个[例子](http://www.webrube.com/json-protobuf-web_rube/5858)
  
    > 100个logs， 序列化5000次所需时间（秒）. 越小越好
   
    | Language        | Protobuf           | Json  |
    | ------------- |:-------------:| -----:|
    | Python      | 15.13 | 0.88 |
    | CSharp      | 0.23      |   1.80  |
    
    > 100个logs， 反序列化5000次所需时间（秒）. 越小越好
   
    | Language        | Protobuf           | Json  |
    | ------------- |:-------------:| -----:|
    | Python      |   8.14    |  1.40  |
    | CSharp      | 0.47    |  4.37  |

### 怎么样使用 protobuf
目前protobuf的官方教程支持C++，C#，Go，Java以及Python。官方自带的example也比较详细
#### 查看github上的example
1. 首先安装protobuf， 有多种方案，我选择从github上下载源码后编译安装
1. 根据源码中的README.txt 运行./autogen.sh， 随后./configure;  make;  make install (可能会缺少一些依赖，根据提示安装即可)
1. cd example, 根据需要的cpp java python对应的make即可看到例子。

#### 以cpp为例子
-  先写一个.proto后缀的文件
``` java
message Person {
    string name = 1;
    int32 id = 2; 
    string email = 3;
}
``` 
-  使用protoc 命令生成对应的.h和.cc文件(这里的.cc即.c文件， 如其他的语言也会生成对应的文件，查看github example)
``` bash
 protoc --cpp_out=$DIR  ${xxxx}.proto
``` 
- 编写写和读的程序
序列化写入文件的代码
``` cpp
#include <iostream>                                                                                                                                                                                          
#include <fstream>
#include <string>
#include "person.pb.h"
using namespace std;

void PromptForPerson(mytest::Person* person) {
  cout << "Enter person ID number: ";
  int id; 
  cin >> id; 
  person->set_id(id);
  cin.ignore(256, '\n');

  cout << "Enter name: ";
  getline(cin, *person->mutable_name());
}

int main(int argc, char* argv[]) {
  if (argc != 2) {
    cerr << "Usage:  " << argv[0] << " FILE" << endl;
    return -1; 
  }

  mytest::Person person;

  {
    fstream input(argv[1], ios::in | ios::binary);
    if (!input) {
      cout << argv[1] << ": File not found.  Creating a new file." << endl;
    } else if (!person.ParseFromIstream(&input)) {
      cerr << "Failed to parse address book." << endl;
      return -1; 
    }   
  }

  PromptForPerson(&person);

  {
    fstream output(argv[1], ios::out | ios::trunc | ios::binary);
    if (!person.SerializeToOstream(&output)) {
      cerr << "Failed to write address book." << endl;
      return -1; 
    }   
  }

  google::protobuf::ShutdownProtobufLibrary();

  return 0;
}
```
反序列化读取文件的代码

``` cpp
#include <iostream>
#include <fstream>
#include <string>
#include "person.pb.h"
using namespace std;

void ListPeople(const mytest::Person& person) {
    cout << "Person ID: " << person.id() << endl;
    cout << "Name: " << person.name() << endl;
}

int main(int argc, char* argv[]) {
  if (argc != 2) {                                                                                                                                                                                           
    cerr << "Usage:  " << argv[0] << " ADDRESS_BOOK_FILE" << endl;
    return -1; 
  }

  mytest::Person person;

  {
    fstream input(argv[1], ios::in | ios::binary);
    if (!person.ParseFromIstream(&input)) {
      cerr << "Failed to parse address book." << endl;
      return -1; 
    }   
  }

  ListPeople(person);

  google::protobuf::ShutdownProtobufLibrary();

  return 0;
}
```
- 编译程序
``` bash
g++ add_person.cc person.pb.cc -o add_person -pthread -I/usr/local/include  -pthread -L/usr/local/lib -lprotobuf -lpthread
g++ list_person.cc person.pb.cc -o list_person -pthread -I/usr/local/include  -pthread -L/usr/local/lib -lprotobuf -lpthread
``` 
- 运行程序
``` bash
./add_person file_name
./list_person file_name
```
- 与json文件比较
``` bash
zhu_kewei@PC0247:~/work/test/protobuf/examples/mytest$ ls -l xx*
-rw-rw-r-- 1 zhu_kewei zhu_kewei  7  3月  4 14:12 xx
-rw-rw-r-- 1 zhu_kewei zhu_kewei 27  3月  4 14:16 xx.json
```
- 可以看到用proto序列化后比json文件小


