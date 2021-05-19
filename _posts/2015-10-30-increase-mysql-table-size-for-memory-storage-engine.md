---
title: "How to Increase MySQL Table Size for Memory Storage Engine"
date: "2015-10-30 10:00:00 +1100"
last_modified_at: 2021-05-19 21:40:00 +1000
tags: mysql CakePHP InnoDB
header:
  image: /assets/images/2021-05-19/data_center_1440_400.jpg
  image_description: "Data Center"
  teaser: /assets/images/2021-05-19/data_center_1440_400.jpg
  overlay_image: /assets/images/2021-05-19/data_center_1440_400.jpg
  overlay_filter: 0.5
  caption: >
    Image by [Taylor Vick](https://unsplash.com/@tvick)
    from [Unsplash](https://unsplash.com/photos/aWslrFhs1w4)
excerpt: >
  It is only reasonable to assume that different storage engines work
  differently
---

Today while trying to test a database related behavior in CakePHP, I created a
fixture which imports the 16k records from a existing table. After a painful
long wait, MySQL gave a table full error.

So I've got a problem to solve. Connect to the test database, check the table
size, which is 16M; but in development database, with InnoDB engine, that table
is just 1.5M. Then I noticed the storage engine of the test db was Memory. After
some Googling, I found the relevant section [The MEMORY Storage Engine] in MySQL
document.

> The maximum size of MEMORY tables is limited by the `max_heap_table_size`
> system variable, which has a default value of 16MB.

That makes a lot of sense. This option doesn't yet exist in my
`/etc/mysql/my.cnf`. Let's add it to the bottom of the configuration file (I've
made a mistake without realising it):

```bash
max_heap_table_size=128M
```

Restart MySQL server by running:

```bash
sudo service mysql restart
```

And then try again, and ... still doesn't work. Go back to MySQL document and
look again at the section for option `max_heap_table_size`:

> This variable is also used in conjunction with `tmp_table_size` to limit the
> size of internal in-memory tables.

OK, let's add this option as well:

```bash
tmp_table_size=128M
```

And restart MySQL and try again, and ... it still doesn't work. After some more
Googling, I found [this thread] on StackOverflow, which says

> Add this to `/etc/my.cnf`
>
> ```bash
> [mysqld]
> tmp_table_size=2G
> max_heap_table_size=2G
> ```
>
> this will cover mysql restarts.

OK. So I've added the correct options, but to the wrong location. Those options
must be added under the `[mysqld]` section in the configuration file. After
moving them to the correct section in `/etc/mysql/my.cnf` and restarting MySQL
server, my new test finally works as expected (but still very slow).

## Retrospect

I realised a few things, after spending an hour tackling this issue:

1. Setting up test fixture with existing records may not be the best way to do
   it.
2. CakePHP uses memory storage engine for its test database on MySQL.
3. The memory storage engine probably doesn't have compression as InnoDB does,
   since it consumes a lot more space for the same table.
4. In MySQL configuration file, different sections control different parts of
   MySQL, which is why adding the options to the bottom wouldn't work.

[The MEMORY Storage Engine]: https://dev.mysql.com/doc/refman/5.6/en/memory-storage-engine.html
[this thread]: http://stackoverflow.com/questions/9842720/how-to-make-the-mysql-memory-engine-store-more-data
