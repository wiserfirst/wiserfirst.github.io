---
title: "Running PostgreSQL on OSX"
date: "2015-09-25 10:00:00 +1000"
last_modified_at: 2021-05-20 21:16:00 +1000
tags: postgres macos
header:
  image: /assets/images/2021-05-20/elephant_1440_480.jpg
  image_description: "An Elephant in Kenya"
  teaser: /assets/images/2021-05-20/elephant_1440_480.jpg
  overlay_image: /assets/images/2021-05-20/elephant_1440_480.jpg
  overlay_filter: 0.2
  caption: >
    Image by [David Clode](https://unsplash.com/@davidclode)
    from [Unsplash](https://unsplash.com/photos/nyvR6wbU1ho)
excerpt: PostgreSQL is definitely a database worth knowing about
---

If you use [Homebrew][], installing PostgreSQL (and a lot of other packages) is
really easy. Just type the following command in Terminal:

```bash
brew install postgresql
```

Normally you need to initialize the database with

```bash
initdb /usr/local/var/postgres
```

But again if you installed PostgreSQL with Homebrew, this is already done for
you.

Next you can start PostgreSQL server with:

```bash
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
```

And stop it with:

```bash
launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
```

After knowing how to start/stop the database server, it is time to create some
databases and user accounts, or roles as they are called in PostgreSQL. This
part is pretty complicated, and I'll only cover a tiny little bit. For more
detail, please refer to the [offical documentation][].

The installation process will also create a database named `postgres` and a role
with permission to create new databases. On OSX, the new role has the same name
as the current operating system user; but on Ubuntu, this role is named
`postgres`. There are a few useful commands to manage databases and roles:

```bash
# create database
createdb my_db_name
# remove database
dropdb my_db_name
# create role/user
createuser username
# remove role/user
dropuser username
```

You can use the `psql` command to connect to PostgreSQL server from terminal:

```bash
psql mydb
```

If the database name is not specified, it will default to the current user name.

You can connect to the database as a different role with `-U` option:

```bash
psql -U another_role mydb
```

You'll see something like this in psql:

```bash
psql (9.4.4)
Type "help" for help.

mydb=#
```

The last line is `mydb=#`, which means you are a database superuser. For a
normal database user, the last line look like this:

```bash
mydb=>
```

Inside `psql` prompt, you can use `\h` to get help about syntax of SQL commands,
`\?` for help with `psql` commands and `\q` to quit.

[Homebrew]: http://brew.sh/
[offical documentation]: http://www.postgresql.org/docs/9.4/static/tutorial.html
