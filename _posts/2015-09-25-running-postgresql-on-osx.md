---
title: "Running PostgreSQL on OSX"
date: "2015-09-25"
---

If you use [Homebrew](http://brew.sh/), installing PostgreSQL (and a lot of other packages) is really easy. Just type the following command in Terminal:

```bash
brew install postgresql
```

Normally you need to initialize the database with

```bash
initdb /usr/local/var/postgres
```

But again if you installed PostgreSQL with Homebrew, this is already done for you.

Next you can start PostgreSQL server with:

```bash
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
```

And stop it with:

```bash
launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
```

After knowing how to start/stop the database server, it is time to create some databases and user accounts, or roles as they are called in PostgreSQL. This part is pretty complicated, and I'll only cover a tiny little bit. For the detail, please refer to the [offical document](http://www.postgresql.org/docs/9.4/static/tutorial.html).

The installation process will also create a database named `postgres` and a role with permission to create new databases. On OSX, the new role has the same name as the current operating system user; but on Ubuntu, this role is named `postgres`. There are a few useful commands to manage databases and roles:

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

```
psql (9.4.4)
Type "help" for help.

mydb=#
```

The last line is `mydb=#`, which means you are a database superuser. For a normal database user, the last line look like this:

```
mydb=>
```

Inside `psql` prompt, you can use `\h` to get help about syntax of SQL commands, `\?` for help with `psql` commands and `\q` to quit.
