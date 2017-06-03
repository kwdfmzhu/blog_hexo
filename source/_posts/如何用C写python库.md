---
title: 如何用C写python库
date: 2017-06-03 16:52:18
tags: [python]
---
	
还是比较简单的，这次就权当入个门吧
1.  写好一个C函数
```cpp
#include<stdio.h>
#include<python2.7/Python.h> //默认python版本就是#include<Python.h>

static PyObject *hellozkw(PyObject *self, PyObject *args) {
    int num;
    //解析参数
    if (!PyArg_ParseTuple(args, "i", &num)) {
        return Py_BuildValue("i", -1);
    }   

    printf("hello zkw %d\n", num);                                                                                                                                                   
    return Py_BuildValue("i", NULL);
}

static PyMethodDef HMethods[] = { 
    //方法名，导出函数，参数传递方式，方法描述。
    {"hellozkw", hellozkw, METH_VARARGS, "hahahaha.... from zkw's hello"},
    {NULL, NULL, 0, NULL}
};

void inithello(void) {
    (void) Py_InitModule("hello", HMethods);
}

```

2.  准备一个setup文件
```python
#!/usr/bin/env python
# coding=utf-8

from distutils.core import setup, Extension

module = Extension('hello', sources = ['hello.c'])
                                                                                                                                                                                     
setup(name = 'hello test', version = '1.0', ext_modules = [module])
```
3. Makefile文件
```makefile
publish:
    python setup.py build
    python setup.py install                                                                                                                                                          

```
4. 运行make publush
5. 运行即可
```python
>>> import hello
>>> ret = hello.hellozkw(123)
hello zkw 123
>>> ret
0
```

