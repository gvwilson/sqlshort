# Modifying Data

The lessons so far have read data from tables that already exist. This lesson shows how to create, update, and delete data.

## Creating Tables

The `create table` statement defines a table's name and its columns. Each column has a name and a **data type**, and we can add constraints that the database will enforce.

```sql
create table sighting (
    species  text not null,
    island   text not null,
    mass_g   real,
    observed text not null
);
```

The most common data types in SQLite are `text` (strings), `real` (floating-point numbers), and `integer` (whole numbers). The `not null` constraint means the database will refuse to store a row that is missing a value for that column; columns without `not null` allow `null` values. Notice that `mass_g` has no `not null` constraint, because a sighting might be recorded without a mass measurement.

If we try to create a table that already exists, we get an error. To avoid this, we can use `create table if not exists`:

```sql
create table if not exists sighting (
    species  text not null,
    island   text not null,
    mass_g   real,
    observed text not null
);
```

<div class="callout" markdown="1">

1. What happens if you omit the data type from a column definition, writing just `species not null` instead of `species text not null`? Does SQLite accept it?

2. Design a table called `researcher` to store a researcher's name, their institution, and the year they started working at that institution. Which columns should be `not null`? Are there any columns where `null` would be a reasonable default?

3. What happens if you try to create a table with two columns that have the same name?

</div>

## Inserting Data

The `insert into` statement adds rows to a table. We list the columns we are providing values for, and then supply the values themselves. The values must match the columns in order.

```sql
insert into sighting (species, island, mass_g, observed) values
    ('Adelie',    'Torgersen', 3750.0, '2025-09-01'),
    ('Gentoo',    'Biscoe',    5000.0, '2025-09-01'),
    ('Chinstrap', 'Dream',     3500.0, '2025-09-02');
```

We can insert multiple rows in a single statement by separating them with commas, as shown above. We can also omit the column list if we are providing values for every column in the order they were defined. *Don't do this.* Including the column list makes the query easier to read, and more importantly, protects against errors if the table structure changes later.

To insert a row without a value for a nullable column, we either omit it from the column list or explicitly write `null`:

```sql
insert into sighting (species, island, observed) values
    ('Adelie', 'Dream', '2025-09-03');
```

This row will have `null` for `mass_g` because we didn't supply a value.

<div class="callout" markdown="1">

1. Write an `insert` statement that adds three researchers to the `researcher` table you designed in the previous exercise.

2. What happens if you try to insert a row without providing a value for a `not null` column?

3. What happens if you provide more values than columns?

</div>

## Updating Rows

The `update` statement changes values in existing rows. We specify the table, the new values using `set`, and (almost always) a `where` clause to specify which rows are changed:

```sql
update sighting
set mass_g = 5200.0
where species = 'Gentoo' and island = 'Biscoe';
```

We can update multiple columns in one statement by separating them with commas:

```sql
update sighting
set mass_g = 3600.0, observed = '2025-09-04'
where species = 'Chinstrap';
```

The `where` clause in `update` works exactly like the `where` clause in `select`. If you omit it, the update applies to every row in the table, which is almost never what you want. For example:

```sql
-- WARNING: this updates every row.
update sighting set mass_g = 0.0;
```

<div class="callout" markdown="1">

1. Write a query to verify the current contents of `sighting` before and after an update so that you can confirm the change had the intended effect.

2. What happens if the `where` clause in an `update` matches no rows? Is an error produced?

3. Update the `researcher` table from earlier: change the institution of one of your researchers to a new institution.

</div>

## Deleting Rows

The `delete from` statement removes rows from a table. Like `update`, it almost always needs a `where` clause:

```sql
delete from sighting
where species = 'Chinstrap';
```

If we omit the `where`, all rows are deleted.
The table structure remains, but it is empty:

```sql
-- WARNING: this deletes every row.
delete from sighting;
```

There is no `undo` for `delete`, so it is always worth double-checking with a `select` using the same `where` condition first.

<div class="callout" markdown="1">

1. Delete all sightings from `'Torgersen'` island. Verify the result with a `select`.

2. What happens if you delete a row that doesn't exist (e.g., `delete from sighting where species = 'Emperor'`)?

</div>

## Dropping Tables

`drop table` removes a table and all of its data permanently. This is irreversible, so use it with care.

```sql
drop table sighting;
```

Just as `create table if not exists` avoids an error when the table already exists, `drop table if exists` avoids an error when the table doesn't exist:

```sql
drop table if exists sighting;
```

A common pattern when rebuilding a table from scratch is to drop it first (if it exists) and then recreate it:

```sql
drop table if exists sighting;

create table sighting (
    species  text not null,
    island   text not null,
    mass_g   real,
    observed text not null
);
```

This approach is useful in scripts that need to be run repeatedly, such as scripts that load data from files.

<div class="callout" markdown="1">

1. What is the difference between `delete from sighting` (without a `where` clause) and `drop table sighting`? When would you use each?

2. What happens if you try to drop a table that other tables reference through a foreign key? (If you have `survey.db` handy, try dropping the `person` table and observe the result.)

3. Write a short SQL script (three or four statements) that drops the `researcher` table if it exists, recreates it, and inserts two rows. Running the script twice in a row should produce the same result each time.

</div>

## Check Understanding

![concept map](./concepts.svg)
