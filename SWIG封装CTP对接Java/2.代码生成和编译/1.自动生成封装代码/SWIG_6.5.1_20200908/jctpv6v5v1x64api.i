/*
Depending on your operating system and version of Java and how you are using threads,
you might find the JVM hangs on exit. There are a couple of solutions to try out. The 
preferred solution requires jdk-1.4 and later and uses AttachCurrentThreadAsDaemon 
instead of AttachCurrentThread whenever a call into the JVM is required. This can be 
enabled by defining the SWIG_JAVA_ATTACH_CURRENT_THREAD_AS_DAEMON macro when compiling 
the C++ wrapper code.For older JVMs define SWIG_JAVA_NO_DETACH_CURRENT_THREAD instead, 
to avoid the DetachCurrentThread call but this will result in a memory leak instead. 
For further details inspect the source code in the java/director.swg library file.
*/

/*
%insert("runtime") %{
#define SWIG_JAVA_ATTACH_CURRENT_THREAD_AS_DAEMON
#define SWIG_JAVA_NO_DETACH_CURRENT_THREAD
%}
*/

%module(directors="1") jctpv6v5v1x64api
%include "various.i"
%apply char **STRING_ARRAY { char *ppInstrumentID[] }
%{ 
#include "ThostFtdcMdApi.h"
#include "ThostFtdcTraderApi.h"
#include "iconv.h"
%}

%typemap(out) char[ANY], char[] {
    if ($1) {
        iconv_t cd = iconv_open("utf-8", "gb18030");
        if (cd != reinterpret_cast<iconv_t>(-1)) {
            char buf[4096] = {};
            char **in = &$1;
            char *out = buf;
            size_t inlen = strlen($1), outlen = 4096;

            if (iconv(cd, in, &inlen, &out, &outlen) != static_cast<size_t>(-1))
                $result = JCALL1(NewStringUTF, jenv, (const char *)buf);
            iconv_close(cd);
        }
    }
}

%feature("director") CThostFtdcMdSpi;
%ignore THOST_FTDC_VTC_BankBankToFuture;
%ignore THOST_FTDC_VTC_BankFutureToBank;
%ignore THOST_FTDC_VTC_FutureBankToFuture;
%ignore THOST_FTDC_VTC_FutureFutureToBank;
%ignore THOST_FTDC_FTC_BankLaunchBankToBroker;
%ignore THOST_FTDC_FTC_BrokerLaunchBankToBroker;
%ignore THOST_FTDC_FTC_BankLaunchBrokerToBank;
%ignore THOST_FTDC_FTC_BrokerLaunchBrokerToBank;

%include "ThostFtdcUserApiDataType.h"
%include "ThostFtdcUserApiStruct.h" 
%include "ThostFtdcMdApi.h"
%feature("director") CThostFtdcTraderSpi;
%include "ThostFtdcTraderApi.h"