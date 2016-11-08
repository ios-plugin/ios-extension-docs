# CallKit.CallManager

<!-- toc -->

## Introduce

* CallManager 提供了操作系统语音通话UI的相关接口
* CallManager 支持用户在锁屏状态下完成整个VoIP语言通话流程
  * 由于锁屏期间应用处于后台,无法响应前台中的网页JS.因此建议此模块和`uexBackground`插件配合使用.
* 使用CallManager的相关接口,需要先在config.xml中配置后台`Audio`和`VoIP`权限


## Struct

### HandleType

* HandleType为系统标识联系人的方式,是一个String类型的枚举值
* 每一次通话会拥有一个HandleType及其对应的HandleValue
* 拥有相同HandleType及HandleValue的通话会被认为是由同一个联系人发起的
* 可选值
  * `"phoneNumber"`  
  * `"emailAddress"`



### CallInfo

* CallInfo为代表通话信息的对象,Object类型.包含的字段如下

| 字段              | 类型      | 是否必选 | 说明                             |
| --------------- | ------- | ---- | ------------------------------ |
| handleType      | String  | 是    | 本次通话的[HandleType](#handletype) |
| handleValue     | String  | 是    | 本次通话的handleValue,通话对象的标识符      |
| callerName      | String  | 否    | 本次通话对象显示的名字,不传时将显示handleValue  |
| isVideo         | Boolean | 否    | 本次通话是否为视频通话                    |
| supportsHolding | Boolean | 否    | 本次通话是否支持呼叫保持                   |

* 注意这里的handleValue仅作为通话对象的标识符使用,可为**任意字符串**

  * 比如handleType为`"phoneNumber"`时,假设 handleValue为"13901234567",为你通讯录中已经存在的联系人"A" 电话号码,那么此项通话记录会合入"A"的通话记录中
  * 但若handleValue为"qwerty0123",此值也是系统允许的,但在通话记录中会作为一个新的联系人单独存在

##  Initializer


### uex.CallKit.CallManager()

通过此接口获得CallManager对象

* 返回值: 全局的CallManager对象
* CallManager为全局的单例类,你在任何JS环境内获得的CallManager对象都对应着同一个原生实例


## Method



### initialize(options)

初始化CallManager

* options: Object CallManager的配置信息 支持以下配置

| 字段                   | 类型      | 是否必选 | 说明                | 默认值          |
| -------------------- | ------- | ---- | ----------------- | ------------ |
| name                 | String  | 是    | 系统通话界面显示的应用名      |              |
| supportedHandleTypes | Array   | 是    | 应用支持的通话Handle类型   |              |
| iconName             | String  | 否    | 系统通话界面显示的应用图标的文件名 | 不传时使用系统的默认图标 |
| ringtoneSound        | String  | 否    | 来电默认铃声的录音文件名      | 不传时使用系统的默认铃声 |
| supportsVideo        | Boolean | 否    | 应用是否支持语音通话        |              |

* supportedHandleTypes 为数组类型,其元素除了[HandleType](#handletype) 以外的值将会被忽略
* ringtoneSound 和 iconName 如何自定义,可见[Customize](#customize)章节



示例

```js
var callManager = uex.CallKit.CallManager({
  name: "AppCan语音",
  supportedHandleTypes: ["phoneNumber"],
  iconName: "voip-icon.png",
  ringtoneSound: "voip-ringtone.caf",
  supportsVideo: false
});
```



### reportIncomingCall(callInfo,callback)

向系统上报有一个播入的通话,展示相应的UI

* callInfo , [CallInfo Object](#callinfo) 必选,本次通话的基本信息
* callback, Function,可选.上报结果的回调函数,拥有一个参数error
  * error为空(null)表示上报成功,非空时通过error.desc来获取错误信息
* 返回值: String类型,此通话的uuid

示例

```js
var uuid = callManager.reportIncomingCall({
    handleType: "phoneNumber",
    handleValue: "appcan001",
    callerName: "CeriNo",
    isVideo: false,
    supportsHolding: true,
},function(error){
  if(error){
    uex.log("reportIncomingCall Error: " + error.desc);
  }else{
    uex.log("reportIncomingCall Success.");
  }
});
uex.log("reportIncomingCall uuid: " + uuid);
```

### reportOutgoingCall(callInfo,callback)

向系统上报有一个呼出的通话,展示相应的UI

- callInfo , [CallInfo Object](#callinfo) 必选,本次通话的基本信息
- callback, Function,可选.上报结果的回调函数,拥有一个参数error
  - error为空(null)表示上报成功,非空时通过error.desc来获取错误信息
- 返回值: String类型,系统分配的此通话的uuid,作为唯一标识符使用.

示例

```js
var uuid = callManager.reportOutgoingCall({
    handleType: "phoneNumber",
    handleValue: "appcan001",
    callerName: "CeriNo",
    isVideo: false,
    supportsHolding: true,
},function(error){
  if(error){
    uex.log("reportOutgoingCall Error: " + error.desc);
  }else{
    uex.log("reportOutgoingCall Success.");
  }
});
uex.log("reportOutgoingCall uuid: " + uuid);
```



### updateCall(uuid,report)

上报通话状态. 比如讲实际通话的状态上报给系统,否则系统UI不会发生变化

* uuid, String.必选,要更新的通话的uuid
* report String.必选, 要更新的报告类型 必须为以下字符串之一
  * `"connecting"`  表示语音通话正在连接中 
  * `"connected"`  表示语音通话已经连接上,开始通话 
  * `"failed"`  表示语音通话失败
  * `"unanswered"`  表示对方没有接听语音通话或者网络超时
  * `"remodeEnded"`  表示对方拒绝接听语音通话,或者语音通话被对方挂断



示例

```js
var uuid = ...//通过其他接口获得的通话uuid
callManager.updateCall(uuid,"connected");
```





### endCall(uuid)

上报通话正常结束

- uuid, String.必选,要更新的通话的uuid

示例

```js
var uuid = ...//通过其他接口获得的通话uuid
callManager.endCall(uuid,"connected");
```

### on(event,eventHandler)

系统通话事件的监听函数

* event, String, 必选 系统事件类型,为以下字符串之一

  * `"reset"`   系统reset事件
  * `"startCall"`  呼出的通话UI展示完毕的事件
  * `"answerCall"` 播入的通话UI展示完毕的事件
  * `"endCall"` 通话结束的UI展示完毕的事件
  * `"setHeld"` 用户点击通话界面内呼叫保持图标的事件
  * `"setMuted" `用户点击通话界面内静音图标的事件
  * `"dialback"` 用户从通话记录中进行回拨的事件

* eventHandler: Function,必选 系统事件的处理函数.根据不同的事件,eventHandler的参数有不同

  * `"reset"`  
    - 无参数
    - 开发者**必须**在此事件发生后**结束当前所有通话**并清理现场

  * `"startCall"` 
    - 回调参数有3个: uuid,callInfo,doneHandle
    - uuid: String,发送此事件的通话的uuid
    - callInfo:  [CallInfo Object](#callinfo) 本次通话的基本信息
    - doneHandle: Function. 事件处理完毕的回调函数
    - 开发者**必须**在此事件处理完毕后调用doneHandle(true),或者在发生错误时调用doneHandle(false)
  - `"answerCall"` 
    - 回调参数有2个: uuid,doneHandle
    - uuid: String,发送此事件的通话的uuid
    - doneHandle: Function. 事件处理完毕的回调函数
    - 开发者**必须**在此事件处理完毕后调用doneHandle(true),或者在发生错误时调用doneHandle(false)
  - `"endCall"` 
    - 回调参数有2个: uuid,doneHandle
    - uuid: String,发送此事件的通话的uuid
    - doneHandle: Function. 事件处理完毕的回调函数
    - 开发者**必须**在此事件处理完毕后调用doneHandle(true),或者在发生错误时调用doneHandle(false)
  - `"setHeld"` 
    - 回调参数有3个: uuid,isHeld,doneHandle
    - uuid: String,发送此事件的通话的uuid
    - isHeld: Boolean, 当前通话是否需要呼叫保持
    - doneHandle: Function. 事件处理完毕的回调函数
    - 开发者**必须**在此事件处理完毕后调用doneHandle(true),或者在发生错误时调用doneHandle(false)
  - `"setMuted"` 
    - 回调参数有3个: uuid,isMuted,doneHandle
    - uuid: String,发送此事件的通话的uuid
    - isMuted: Boolean, 当前通话是否需要静音
    - doneHandle: Function. 事件处理完毕的回调函数
    - 开发者**必须**在此事件处理完毕后调用doneHandle(true),或者在发生错误时调用doneHandle(false)
  - `"dialback"`
    - 回调参数有1个: callInfo
    - callInfo [CallInfo Object](#callinfo) 请求通话的基本信息,注意此CallInfo信息来自系统通信录,只包含HandleType和HandleValue属性
    - 开发者应该在此事件发送后根据handleType和handleValue发起一个语音通话,并调用CallManager的接口展示系统UI

  示例

  ```js
  callManager.on("startCall",function(uuid,callInfo,handle){
    //根据uuid和callInfo更新App内的UI
    //并调用实际的VoIP通话模块发起语音通话
    //全部完成后调用handle(true)
  });
  ```

  ​


## Customize

### 自定义VoIP通话铃声

* 开发者需自定义插件,将自定义铃声的音乐文件放入插件包的`uexGroup`文件夹内,并在初始化callManager时传入`ringtoneSound`参数,其值为音乐文件的完整文件名

### 自定义VoIP通话时的应用图标

* 开发者需自定义插件,将自定义铃声的图片文件放入插件包的`uexGroup`文件夹内,并在初始化callManager时传入iconName参数,其值为图片文件的完整文件名
* 图片文件必须是40pt*40pt的png单色图片,图片只有alpha通道会被读取,所有透明的像素会保持透明,非透明的像素都会被系统填充成同一种颜色