# Introduction

A **database** is a collection of data that can be searched and retrieved.
A **database management system** (DBMS) is a program that manages a particular kind of database.
Each DBMS stores data in its own way:
SQLite stores each database in a single file,
while PostgreSQL spreads information across many files for higher performance.
A DBMS can be a library embedded in other programs (like SQLite) or a server (like PostgreSQL).

A **relational database management system** (RDBMS) stores data in **tables**
and uses SQL for queries.
Unfortunately, every RDBMS has its own dialect of SQL.
There are also **NoSQL databases** like MongoDB that don't use tables,
but we won't cover them here.

## Check Understanding

![concept map](./concepts.svg)
