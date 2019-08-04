解决方案jctpapi.zip使用vs2017构建，但编译平台选择的是v140，也就是vs2015，x64 Relase版本
请先将JDK安装目录下的jni.h jni_md.h复制到VS相关目录，例如从
C:\Program Files\Java\jdk1.8.0_131\include
复制到
C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\include

请根据实际情况。
也可以通过其他方式引用