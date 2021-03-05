## Visual Studio IDE 构建项目

+ 新建dll项目

+ 复制JDK目录中的jni.h jni_md.h 到编译器目录(例如 C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\include\jni.h)。可以不做这一步通过第二步替代

+ 复制到项目路径，并修改cpp中这两个头文件的查找方式，由`<>`改为`""`。如果做了第一步这一步可以不做。

+ 项目属性->配置属性->C/C++->代码生成->运行库 选择：多线程（/MT）

+ 项目属性->配置属性->常规->平台工具集 请根据实际需要选择,对应编译器目录应有步骤一中复制后的JDK头文件

+ 项目属性->配置属性->C/C++->预编译头->预编译头 不使用编译头

+ 项目属性->配置管理器（右上角）->全改为Release x64（默认64位环境）

+ (非必要)项目属性->配置属性->C/C++->预处理器->预处理器定义->编辑 在新的一行加上 _CRT_SECURE_NO_WARNINGS


## iconv.h头文件来源
+ Windows
	来自项目libiconv-1.15-for-windows-vs2017-project
+ Linux
	iconv.h头文件来自libiconv-1.15.tar.gz
	
>编译略有区别，但函数定义一致,因此通过SWIG生成的C++代码跨平台，无需修改

## 结算单乱码的解决方案
结算单乱码的主要原因是分段按byte截断传输，不考虑unicode可能多个byte的情况，因此中途转码会丢失数据，一个简单的解决方案，在Java中还原为byte[] 拼接，然后再new String ，使用编码GB18030(兼容GBK,GB2312),此问题便解决

在生成的CPP中搜索 `CThostFtdcSettlementInfoField_1Content_1get`
将返回类型改为`jbyteArray `
将函数内容替换为

    jbyteArray jresult = 0 ;
    CThostFtdcSettlementInfoField *arg1 = (CThostFtdcSettlementInfoField *) 0 ;
    char *result = 0 ;

    (void)jenv;
    (void)jcls;
    (void)jarg1_;
    arg1 = *(CThostFtdcSettlementInfoField **)&jarg1;
    result = (char *) ((arg1)->Content);
    {
    	if (result) {
    		jresult = jenv->NewByteArray( strlen(result));
    		jenv->SetByteArrayRegion(jresult, 0, strlen(result), (jbyte*)result);
    	}
    }
    return jresult;



最终结果例如：

	SWIGEXPORT jbyteArray JNICALL Java_xyz_redtorch_gateway_ctp_x64v6v3v15v_api_jctpv6v3v15x64apiJNI_CThostFtdcSettlementInfoField_1Content_1get(JNIEnv *jenv, jclass jcls, jlong jarg1, jobject jarg1_) {
		jbyteArray jresult = 0;
		CThostFtdcSettlementInfoField *arg1 = (CThostFtdcSettlementInfoField *)0;
		char *result = 0;

		(void)jenv;
		(void)jcls;
		(void)jarg1_;
		arg1 = *(CThostFtdcSettlementInfoField **)&jarg1;
		result = (char *)((arg1)->Content);
		{
			if (result) {
				jresult = jenv->NewByteArray(strlen(result));
				jenv->SetByteArrayRegion(jresult, 0, strlen(result), (jbyte*)result);
			}

		}
		return jresult;
	}

** 请不要直接复制上段函数代码，注意函数名一致性 **

手动将`CThostFtdcSettlementInfoField.java`文件中的函数 `getContent()`方法的返回类型改为`byte[]`,将其调用的其他类的方法的返回类型也改为`byte[]`直到无错为止

在java中，在没有返回last标记之前，存储所有`byte[]`,返回标记之后拼接为一个大`byte[] `使用`new String(contentBytes,"GB18030")`，便可得到完全正确的结算单

