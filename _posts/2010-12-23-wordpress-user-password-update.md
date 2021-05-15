---
title: "Wordpress用户密码修改"
date: "2010-12-23 10:00:00 +0800"
tags: wordpress
---

首先参考这篇文章[《WordPress用户密码算法规则》](http://www.williamlong.info/archives/1978.html)，可了解其密码设置保存的规则。可以通过如下步骤进行密码修改：

1. 计算要设置密码的MD5值。到[这里](http://www.joeswebtools.com/security/md5-hash-generator/)，输入密码字符串，点击“Generate
MD5”，得到密码的MD5值。例如要设密码为`Hello_world!`，计算出的MD5为`8522b5c3cab95bebdc2b35836207a902`
2. 使用phpMyAdmin登录MySQL数据库，查看Wordpress使用的数据库（这个是在安装LNMP时自己命名的）中存放users的表（通常是`wp_users`），在对应用户的那一行点击Edit，即那个铅笔按钮，然后将密码字段（我这里是`user_pass`）的值改为刚刚得到的MD5值，最后点击GO。

这个操作相当于运行了如下的SQL语句：

```sql
UPDATE `your_dbname`.`wp_users` SET `user_pass` =
'8522b5c3cab95bebdc2b35836207a902' WHERE `wp_users`.`ID` = 1;
```

如果足够熟悉的话也可以自己写SQL语句来执行，对上面语句稍做修改：

```sql
UPDATE `your_dbname`.`wp_users` SET `user_pass` =
'8522b5c3cab95bebdc2b35836207a902' WHERE `wp_users`.`user_login` =
`your_username`;
```

注意，其中的`your_dbname`和`your_username`要替换成你的数据库名和用户名。这样写的好处是不用去查用户名对应的ID。 到这里就已经完成了密码的修改，正如月光老师所说，我们写进去的是密码的MD5值，下次使用这个密码登录后，Wordpress会将其修改为更加安全的形式。
