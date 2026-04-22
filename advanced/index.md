# Advanced Features

This lesson introduces five advanced features of SQL: views (saved queries that behave like tables), indexes (data structures that make queries faster), transactions (groups of changes that succeed or fail together), triggers (automatic actions that fire when data changes), and window functions (calculations that look across rows without collapsing them into groups).

## Views

A **view** is a saved query that can be used in other queries just like a real table. Views are useful when a query is complex, used frequently, or needs to be shared across different parts of an application.

Suppose we often need to work with penguins that weigh 4500g or more. Instead of repeating the filter in every query, we can define a view:

```sql
create view if not exists heavy_penguins as
select species, island, body_mass_g, sex
from penguins
where body_mass_g >= 4500.0;
```

Once the view exists, we can query it exactly as if it were a table:

```sql
select species, count(*) as num
from heavy_penguins
group by species;
```

The key thing to understand is that a view does not store data. Every time we query `heavy_penguins`, the database re-runs the underlying `select` statement. This means the view always reflects the current contents of `penguins`, but it also means there is no performance benefit from the view itself.

To remove a view, use `drop view`:

```sql
drop view if exists heavy_penguins;
```

<div class="callout" markdown="1">

1. Create a view called `known_sex_penguins` that contains only penguins whose `sex` is not `null`. Verify it works by querying it.

2. If we `insert` a new heavy penguin into the `penguins` table after creating `heavy_penguins`, will the new penguin appear when we query the view? Explain why or why not.

3. What is the difference between a view and a CTE? When would you prefer one over the other?

</div>

## Indexes

When a database searches a table for rows matching a `where` condition, it normally scans every row in the table. For small tables this is fine, but for large tables it is slow. An **index** is an auxiliary data structure that lets the database jump directly to matching rows, spending storage space to buy query speed.

We can see what the database plans to do using `explain query plan`:

```sql
explain query plan
select * from penguins
where island = 'Biscoe';
```

The output will show `SCAN penguins`, meaning the database reads every row. Now let's create an index on the `island` column:

```sql
create index if not exists penguins_island on penguins(island);
```

Running `explain query plan` again shows `SEARCH penguins USING INDEX penguins_island`, meaning the database will use the index instead of scanning every row. We can delete an index by dropping it:

```sql
drop index if exists penguins_island;
```

The database uses indexes automatically: we don't have to mention them in queries. The tradeoff is that indexes take up disk space and slow down `insert`, `update`, and `delete` operations because the index must be updated whenever the table data changes. A good rule of thumb is to add indexes on columns you frequently filter or join on, and not to add them speculatively.

<div class="callout" markdown="1">

1. Use `explain query plan` to check whether the `survey` database already has indexes. (Hint: run `explain query plan select * from survey where person_id = 'P001'`.)

2. Create an index on `survey.person_id` and run `explain query plan` again. What changes?

3. Would an index on `penguins.species` be useful? What kinds of queries would benefit from it, and what kinds would not?

</div>

## Transactions

By default, each SQL statement is committed (saved permanently) as soon as it runs. A **transaction** groups several statements together so that they all succeed or all fail as a unit. This protects the database from being left in an inconsistent state if something goes wrong partway through a sequence of changes.

We start a transaction with `begin transaction` and end it either with `commit` (save all changes) or `rollback` (discard all changes and return to the state before `begin`).

```sql
begin transaction;
update penguins set body_mass_g = body_mass_g + 100
where species = 'Adelie';
-- Something went wrong -- undo everything.
rollback;
```

After the `rollback`, the `penguins` table is unchanged. If we had used `commit` instead, all the Adelie mass values would have been permanently increased by 100g.

Transactions are essential any time one logical operation requires multiple SQL statements.

<div class="callout" markdown="1">

1. If the database server crashes while a transaction is open but before `commit`, what happens to the changes? Why is this the right behavior?

</div>

## Triggers

A **trigger** is a set of SQL statements that the database runs automatically before or after a specific operation (`insert`, `update`, or `delete`) on a table. Triggers are useful for enforcing rules that are too complex for a simple constraint, or for automatically maintaining derived data.

The example below keeps a running count of sightings per species. We have two tables: `sighting` (where new observations are recorded) and `sighting_count` (which stores totals). We define a trigger that fires after every insert into `sighting` and increments the appropriate count.

```sql
create table sighting (
    species text not null,
    island  text not null,
    mass_g  real
);

create table sighting_count (
    species text primary key,
    num     integer not null default 0
);

insert into sighting_count values
    ('Adelie', 0), ('Gentoo', 0), ('Chinstrap', 0);

create trigger count_sighting
after insert on sighting
begin
    update sighting_count
    set num = num + 1
    where species = new.species;
end;
```

Inside the trigger body, `new` refers to the row that was just inserted. For `delete` triggers, `old` refers to the row being removed. For `update` triggers, both `old` and `new` are available.

Now inserting a row into `sighting` automatically updates `sighting_count`:

```sql
insert into sighting values ('Adelie', 'Torgersen', 3750.0);
insert into sighting values ('Adelie', 'Dream', 3500.0);
insert into sighting values ('Gentoo', 'Biscoe', 5000.0);

select * from sighting_count;
```

Triggers add processing overhead to every operation that fires them, so use them for genuinely important invariants rather than convenience. They can also be hard to debug because they run invisibly.

<div class="callout" markdown="1">

1. Add a `delete` trigger that decrements the count in `sighting_count` when a row is deleted from `sighting`. Test it.

2. What happens if someone inserts a sighting with a species that is not in `sighting_count`? How could you fix this?

</div>

## Window Functions

Aggregation functions like `sum` and `avg` collapse a group of rows into a single result row. **Window functions** compute a value for each row using information from other rows, without collapsing the result. The set of rows a window function looks at is called its **window**, defined with an `over` clause.

The simplest window function is `row_number`, which numbers each row within a defined order:

```sql
select
    species,
    body_mass_g,
    row_number() over (order by body_mass_g) as overall_rank
from penguins
where body_mass_g is not null
order by body_mass_g
limit 10;
```

More useful is combining `over` with `partition by`, which computes the result separately within each group. The query below ranks each penguin within its species by mass:

```sql
select
    species,
    body_mass_g,
    row_number() over (
        partition by species
        order by body_mass_g
    ) as rank_in_species
from penguins
where body_mass_g is not null
order by species, body_mass_g
limit 12;
```

Notice that `row_number` resets to 1 at the start of each species, because `partition by species` creates a separate window for each species.

## Running Totals

Window functions can also compute running (cumulative) values. Using `sum` with `over` and an `order by` produces a running total:

```sql
select
    species,
    body_mass_g,
    sum(body_mass_g) over (
        partition by species
        order by body_mass_g
    ) as running_total_g
from penguins
where body_mass_g is not null
order by species, body_mass_g
limit 12;
```

Each row's `running_total_g` is the sum of all masses at or below that row's mass within the same species. This is impossible to express with a plain `group by`, which would collapse each species to a single row.

## Lead and Lag

The `lag` and `lead` functions let each row look at values in previous or following rows. This is useful for computing differences between successive values, though the syntax is convoluted even by SQL's standards:

```sql
select
    species,
    body_mass_g,
    body_mass_g - lag(body_mass_g) over (
        partition by species
        order by body_mass_g
    ) as gain_over_prev
from penguins
where body_mass_g is not null
order by species, body_mass_g
limit 12;
```

The first row within each partition has no previous row, so `lag` returns `null` there. `lead` works the same way but looks ahead rather than behind.

<div class="callout" markdown="1">

1. Use `row_number()` with `partition by island order by body_mass_g desc` to find the heaviest penguin on each island.

2. Use `lag` to find pairs of consecutive penguins (within a species, ordered by mass) where the mass difference is greater than 500g.

</div>

## Check Understanding

![concept map](./concepts.svg)
