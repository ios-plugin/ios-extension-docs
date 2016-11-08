# CallKit


<!-- toc -->



## Introduce

* moduleName ： `CallKit`
* CallKit模块是对iOS系统CallKit的封装,提供了如下功能
	* 针对应用内的VoIP通话功能,提供了iOS系统级别的语言通话UI
	* 提供了一个extension使得用户可以从iOS电话簿中直接进入App进行VoIP通话
* CallKit模块依赖插件uexCallKit,使用CallKit的任意API前需要先调用`uex.import("CallKit")`进行加载
* CallKit要求iOS系统版本为`iOS10.0+`,在不符合要求的系统上,加载模块将会失败


## Class

* [CallManager](CallManager.md) 提供了操作系统语言通话UI的相关接口