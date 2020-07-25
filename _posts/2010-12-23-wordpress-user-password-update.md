---
title: "Wordpress用户密码修改"
date: "2010-12-23"
---

首先参考这篇文章[《WordPress用户密码算法规则》](http://www.williamlong.info/archives/1978.html)，可了解其密码设置保存的规则。 可以通过如下步骤进行密码修改：

1 计算要设置密码的MD5值。 到[这里](http://www.joeswebtools.com/security/md5-hash-generator/)，输入密码字符串，点击“Generate MD5”，得到密码的MD5值。例如要设密码为“Hello\_world!”，计算出的MD5为“8522b5c3cab95bebdc2b35836207a902”

2 使用phpMyAdmin登录MySQL数据库，查看Wordpress使用的数据库（这个是在安装LNMP时自己命名的）中存放users的表（通常是wp\_users），在对应用户的那一行点击Edit，即那个铅笔按钮，然后将密码字段（我这里是user\_pass）的值改为刚刚得到的MD5值，最后点击GO。

这个操作相当于运行了如下的SQL语句：

> UPDATE \`your\_dbname\`.\`wp\_users\` SET \`user\_pass\` = '8522b5c3cab95bebdc2b35836207a902' WHERE \`wp\_users\`.\`ID\` =1;

如果足够熟悉的话也可以自己写SQL语句来执行，对上面语句稍做修改：

> UPDATE \`your\_dbname\`.\`wp\_users\` SET \`user\_pass\` = '8522b5c3cab95bebdc2b35836207a902' WHERE \`wp\_users\`.\`user\_login\` =‘your\_username’;

注意，其中的your\_dbname和your\_username要替换成你的数据库名和用户名。这样写的好处是不用去查用户名对应的ID。 到这里就已经完成了密码的修改，正如月光老师所说，我们写进去的是密码的MD5值，下次使用这个密码登录后，Wordpress会将其修改为更加安全的形式。
