# Introduction

A [%g database "database" %] is a collection of data that can be searched and retrieved.
A [%g dbms "database management system" %] (DBMS) is a program that manages a particular kind of database.
Each DBMS stores data in its own way:
SQLite stores each database in a single file,
while PostgreSQL spreads information across many files for higher performance.
A DBMS can be a library embedded in other programs (like SQLite) or a server (like PostgreSQL).

A [%g rdbms "relational database management system" %] (RDBMS) stores data in [%g table "tables" %]
and uses SQL for queries.
Unfortunately, every RDBMS has its own dialect of SQL.
There are also [%g nosql "NoSQL databases" %] like MongoDB that don't use tables,
but we won't cover them here.

## Check Understanding

![concept map](./concepts.svg)
