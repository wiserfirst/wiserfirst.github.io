---
title: "通过API更新Google账户通讯录"
date: "2011-09-05 10:00:00 +0800"
tags: google python
---

之前用的手机是Nokia，为了保存上面的通讯录，我按照[这里](http://www.allaboutsymbian.com/news/item/8922_Google_Sync_Beta_for_SyncML_S6.php)的方法使用Google
Sync将其同步到Google帐户。然后就可以在Gmail的通讯录当中访问了。换了iPhone之后自然要把通讯录从Google帐户同步过来。

步骤如下：

1. 在设置-->邮件、通讯录、日历 中选择添加帐户
2. Microsoft Exchange
3. 填入你的Google帐户（唯一需要注意的就是服务器填m.google.com）
4. 接着在该帐户的设置中，要确认邮件、通讯录和日历这三项的同步是否要打开，这个根据自己需要处理吧。当然了，要同步通讯录的话，通讯录这项一定要打开才行
5. 邮件、通讯录、日历-->获取新数据 中打开推送（最好在有WiFi接入点时）

这样设置完成以后，稍等一小会，再打开iPhone通讯录时，就会发现Gmail通讯录里的联系人了。

到这里似乎就大功告成了，然而实际情况往往并不如意。比如我这里就出了个小问题：部分联系人一切正常；但是另一部分联系人里面没有电话号码，只是个空的联系人。经过对比iPhone通讯录和Gmail通讯录，我发现一个规律，即Gmail中的号码类型标签为`Other`的电话号码，iPhone上统统没有。

第一反应是问Google，但是一番搜索并没有发现解决方案——似乎没有人碰到这个问题……

那只能尝试着自己动手了。简单分析一下这个问题，应该是把号码标签类型从`Other`改成`Mobile`或者`Home`。登录到Gmail上手动改当然是可以了，不过偶的通讯录有200多条，一个个改太麻烦了。作为程序员，应该尝试自己写代码解决问题，Google应该有提供修改联系人的API。查一下果然有，就是这个[Google
Contacts
API](https://developers.google.com/contacts/v3)。Google提供Java、.NET及python等多种语言接口，由于正在自学python，就用它吧。下载[gdata-python-client](https://github.com/google/gdata-python-client)，然后开始研究电话号码及其标签是使用什么数据结构保存的。结果如下：

* 通讯录条目类型为`class gdata.contacts.data.ContactEntry`；
* 其中的电话号码字段名为`phone_number`，它是一个list，每个电话号码为list中一项，类型是`class gdata.data.PhoneNumber`；
* `PhoneNumber`类型的`rel`字段是一个类似于`http://schemas.google.com/g/2005#other`的字符串，保存了号码标签；而是其`text`字段是真正的电话号码，如`13526541245`，但其类型还不是string，需要对其调用`str()`才能得到字符串。

另外，经验证还发现：在Gmail的通讯录中，号码标签共有9种类型，以下六种可以正确同步到iOS设备的通讯录中

| Gmail    | iOS      |
| -------- | -------- |
| Mobile   | 移动电话 |
| Work     | 工作     |
| Work Fax | 工作传真 |
| Home     | 住宅     |
| Home Fax | 住宅传真 |
| Pager    | 传呼     |

另外3种类型（`Google Voice`, `Main`, `Custom`）不能同步到iOS设备的通讯录。注意这个`Custom`是用户自定义，也就是字段名可以是一定长度以内的任何字符串，在Gmail通讯录都可以正确保存。使用Gsync同步Nokia手机通讯录到Gmail的时候，有些手机号的标签会是`Other`，也就是一种自定义类型。就是这个导致从Nokia手机同步过来的通讯录中有些联系人名字在但是号码却是空的。

然后就开始写代码，逻辑无非就是：

```python
if 号码标签为Other:
    if 手机号:
        将号码标签改为Mobile
    else:
        将号码标签改为Work
```

真正实现这个逻辑并没有花多少时间，在Google提供的sample代码里面很容易就改出来了；倒是找表示电话号码的字段名，以及表示号码标签的字段名，花了一些时间。因为Google所提供的库中，类的定义实在是有点复杂——至少对我这个没接触过的新手而言是这样。全部理清头绪以后，回过头想想其实整个过程并不困难，如果对Google的库有些熟悉，应该很快就能搞定的。
