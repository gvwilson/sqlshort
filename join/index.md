# Combining Tables

Relational databases get their name from the fact that they store the relations between tables. This tutorial shows how to connect and combine information from multiple tables. We will save most of the exercises for the next tutorial, where we start working with our first complex database.

## Basic Joins

The `jobs` database has two tables. The first, called `job`, shows the credits that students can earn doing different kinds of jobs. The other table, `work`, keeps track of who has done which jobs:

<div class="row" markdown="1">
<div class="col-6" markdown="1">

<p class="center"><strong>job</strong></p>

| name | credits |
| :--- | ------: |
| calibrate | 1.5 |
| clean | 0.5 |

</div>
<div class="col-6" markdown="1">

<p class="center"><strong>work</strong></p>

| person | job |
| :----- | :-- |
| Amal | calibrate |
| Amal | clean |
| Amal | complain |
| Gita | clean |
| Gita | clean |
| Gita | complain |
| Madhi | complain |

</div>
</div>

We want to know how many credits each student has earned. The first step in answering this is to **join** the tables together.

```sql
select *
from job join work;
```

The `join` operation creates a temporary table in memory by combining every row of `job` with every row of `work`. Since `job` has two rows and `work` has seven, the temporary table has 2×7=14 rows.

Some of these rows are useful: the first, for example, tells us that Amal did some calibration, and that calibrating is worth 1.5 credits. The second, however, combines information about calibrating with the fact that Amal did some cleaning. We can get rid of the rows that aren't useful by filtering with `where`.

```sql
select *
from job join work
where job.name = work.job;
```

This query demonstrates two things:

1. When we are working with two or more tables, we refer to columns using `table_name.column_name`, as in `job.name` or `work.job`. We don't absolutely need to do this in this query, since columns' names are all unique, but it's very common to have columns with the same names in different tables. In those cases the two-part names are required to avoid ambiguity; it is therefore good practice to *always* use two-part names when working with multiple tables.
2. There isn't an entry in `job` for `complain`, so `job.name = work.job` isn't true for any of the combined rows that involve complaining. On the other hand, Gita cleaned up the lab twice, so there are two records in the result for that. This shows that `join` doesn't automatically remove duplicates.

While we can use `where`, the SQL standard encourages us to use a different keyword `on`:

```sql
select *
from job join work
on job.name = work.job;
```

Many years ago, using `on` sometimes gave slightly higher performance. Today, though, the two forms are equivalent from the database manager's point of view. Many people still prefer `on` for readability: it shows how the rows are being combined, while `where` shows how combined rows are being filtered. As with almost everything in programming, what matters most is to pick one and stick to it so that your queries are consistent.

The standard also encourages us to write our join as `inner join`, because as we will see in a moment, other kinds of joins exist. People often skip this and just write `join`, or even use a simple comma between the table names, but from now on we will be pedantic to make what we're doing clearer.

We are now able to answer our original question: how many credits has each student earned?

```sql
 -- add up the credits for each person
select work.person, sum(job.credits) as total

-- only combine rows that refer to the same thing
from job inner join work
on job.name = work.job

-- put all the credits for each person into a separate bucket
group by work.person;
```

## Left Joins

The query above shows us how many credits Amal and Gita have earned, but doesn't show anything for Madhi. Ideally, we'd like a row showing that she has earned zero credits. To get this, we need to use a different kind of join called a **left join**. A left join is created by following these rules:

1. If the row from the left-hand table matches one or more rows from the right-hand table, combine them as an inner join would.
2. If the row from the left-hand table _doesn't_ match any rows from the right-hand table, create one row in the result with the values from the left row and `null` where the values from the right-hand table would be.

An example will make this clearer.

```sql
select *
from work left join job
on work.job = job.name;
```

Let's trace this query's execution step by step:

1. The `(Amal, calibrate)` row from `work` matches the `(calibrate, 1.5)` row from `job`, so that is the first row of output.
2. Similarly, the `(Amal, clean)` row matches the `(clean, 0.5)` row, so we get the second row of output.
3. But `(Amal, complain)` _doesn't_ match anything from `job`, so we get a row with the values from the left table (`Amal` and `complain`) and `null` for `name` and `work`.
4. We then get two rows for Gita cleaning because there's a match…
5. …and two rows with `null` values for Gita and Madhi complaining because there isn't.

<div class="callout" markdown="1">

1. What do we get if we invert the order of the tables, i.e., do `job left join work`? Why?

</div>

## Coalesce

We can now sum up everyone's credits:

```sql
select work.person, sum(job.credits) as total
from work left join job
on work.job = job.name
group by work.person;
```

This is *almost* what we want: we have a row for Madhi, but her `total` is `null` because that's what `sum` produces when all of the values it's adding up are `null`. We can fix this using a built-in SQL function called `coalesce`:

```sql
select
    work.person,
    coalesce(sum(job.credits), 0) as total
from
    work left join job
on
    work.job = job.name
group by
    work.person;
```

`coalesce` takes two inputs. If the first is not `null`, `coalesce` returns that. If the first value *is* `null`, on the other hand, `coalesce` returns its second input. In simpler terms, it gives us a value or a default if the value is `null`.

Note that we have split this query across several lines with the keywords at the left margin and the parts of the query that belong to them indented below them. As our queries become more complex, this style makes them easier to read. As with `join` versus `inner join`, the most important thing is to be consistent so that the reader isn't distracted by stylistic differences.

## Check Understanding

![concept map](./concepts.svg)
