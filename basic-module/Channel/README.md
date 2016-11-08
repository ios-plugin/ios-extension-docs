# Channel


<!-- toc -->



## Introduce

* moduleName ： `Channel`
* Channel模块提供了一种跨页面的JS之间进行交互的方式
* Channel模块为基础模块,可直接使用



##  Initializer

### uex.Channel\(id\)

创建一个channel对象

* id:  String. Channel通信的频道id

* 返回值: Channel对象


示例

```js
var channel = uex.Channel("myChannel");
```



## Method

### subscribe\(\)

订阅频道

* 返回值: Channel对象本身
* 只有订阅后,channel才会收到广播的消息

示例
```js
channel.subscribe();
```

### desubscribe\(\)

取消订阅频道

- 返回值: Channel对象本身
- 取消订阅后,channel不再会收到广播的消息
- 可以通过`subscribe`接口重新订阅频道

示例

```js
channel.desubscribe();
```

### broadcast(event,content)

广播一条消息,所有订阅的此频道的Channel都会收到这条消息

* event: String,消息所属的事件标识,为任意自定义字符串
* content: 消息的内容,可为以下类型之一
  * String
  * Number
  * Boolean
  * JSON Array
  * JSON Object
* 返回值: Channel对象本身

示例

```js
channel.broadcast("event1","Hello World!");
```



### on(event,handler)

收到广播消息的监听函数

* event: String,消息所属的事件标识
* handler: Function, 消息的监听回调函数,handler拥有一个参数content
  * content: 消息的内容
* 返回值: Channel对象本身

示例

```js
channel.on("event1",function(content){
  uex.log(content);
});
```



## Example

```js
var channel = uex.Channel("myChannel");
channel
  	.on("event1",function(content){
  		//注册event1的监听回调,用于接受基本类型的content
  		uex.log("event1: " + content);
  	})
	.on("event2",function(content){
  		//注册event2的监听回调,用于接受JSON Object类型的content
  		uex.log("event2: " + JSON.stringify(content));
  	})
	.broadcast("event1",111)//不会触发任何回调,因为channel本身没有被订阅
	.subscribe()//订阅频道
	.broadcast("event1",222)//LOG: event1: 222
	.broadcase("event2",{	//LOG: event2: {key: "value"}
  		key: "value"
	})
	.desubscribe()//取消订阅频道
	.broadcast("event1",333)//不会触发任何回调,因为channel本身已经被取消订阅
```

