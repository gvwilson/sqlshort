# Subqueries

The [grouping and aggregation tutorial](@/aggregate_group/) explained that we can't use an aggregation function directly inside a `where` clause. For example, the query below tries to find all the penguins that are heavier than average, but is illegal in SQL:

```sql
-- This query is ILLEGAL -- you cannot use avg() in a where clause.
select * from penguins
where body_mass_g > avg(body_mass_g);
```

The reason is that SQL evaluates `where` row by row, deciding whether each row passes the test, but it can only calculate `avg(body_mass_g)` after looking at all the rows. We need a way to calculate the average first and then use that result in our filter.

## Subqueries

The solution is to write one query inside another. The inner query, called a [%g subquery "subquery" %], is evaluated first, and its result is then used by the outer query.

```sql
select species, body_mass_g
from penguins
where body_mass_g > (
    select avg(body_mass_g)
    from penguins
);
```

The database evaluates this in two steps:

1. It runs the inner query to find the average mass of all the penguins, which produces a single number.
2. It uses that number in the outer query's `where` clause to filter for penguins whose mass is greater than that value.

The parentheses around the inner query are required. Notice also that the subquery is a complete `select` [%g statement "statement" %]: it has its own `from` clause and can reference the same tables as the outer query.

Let's make the output more informative by also showing what the overall average is for comparison.

```sql
select
    species,
    body_mass_g,
    round((select avg(body_mass_g) from penguins), 1) as avg_mass_g
from penguins
where body_mass_g > (
    select avg(body_mass_g)
    from penguins
);
```

We have used the subquery in two places here: once in the `select` clause to display the average alongside each row, and once in the `where` clause to filter the rows. The database manager is smart enough to calculate the average only once, even though it appears twice.

<div class="callout" markdown="1">

1. Modify the query to find all the penguins with a flipper length greater than the average flipper length.

2. How many penguins are heavier than average? (Hint: wrap the query above in a `count(*)` or use `count(*)` with the same `where` condition.)

3. Are there more above-average-mass penguins of one species than another? Write a query to find out.

</div>

## Set Membership

Before looking at more complex uses of subqueries, it helps to understand the `in` operator. `in` checks whether a value is present in a list of values, and `not in` checks whether it is not. The list is written in parentheses and the items are separated by commas.

Recall the `job` and `work` tables from the `lab` database, which we used in the [lesson on joins](@/join/):

| name | credits |
| :--- | ------: |
| calibrate | 1.5 |
| clean | 0.5 |

| person | job |
| :----- | :-- |
| Amal | calibrate |
| Amal | clean |
| Amal | complain |
| Gita | clean |
| Gita | clean |
| Gita | complain |
| Madhi | complain |

We can find everyone who did either calibration or cleaning with `in`:

```sql
select distinct person
from work
where job in ('calibrate', 'clean');
```

And everyone who did neither with `not in`:

```sql
select distinct person
from work
where job not in ('calibrate', 'clean');
```

`in` and `not in` work the same way with numbers, but there is a catch: `3 in (1, 2, 3)` is true, but `3.0 in (1, 2, 3)` may or may not be, depending on the database (because 3.0 is a real number rather than an integer).

<div class="callout" markdown="1">

1. Use `in` to write a query that finds all the penguins from either Biscoe or Dream island.

2. Use `not in` to write a query that finds all the penguins that are not Gentoo or Chinstrap.

3. What happens if you write `where job in ()` (i.e., ask for membership in an empty list)? What do you think *should* happen?

4. Suppose `not in` didn't exist. How would you rewrite a query that used it?

</div>

## Subqueries with `not in`

Now let's combine `not in` with a subquery. Suppose we want to find everyone in the `work` table who has never done calibration. A tempting but incorrect approach is to filter directly:

```sql
-- This query is WRONG.
select distinct person
from work
where job != 'calibrate';
```

This returns Amal, Gita, and Madhi, but Amal *has* calibrated: she also cleaned and complained, and those rows pass the test `job != 'calibrate'`. The filter operates row by row, not person by person.

The right approach is to find the set of people who *have* calibrated and then select everyone who is *not* in that set.

```sql
select distinct person
from work
where person not in (
    select distinct person
    from work
    where job = 'calibrate'
);
```

The inner query returns just Amal (the only person who calibrated). The outer query then selects everyone whose name does not appear in that result, giving us Gita and Madhi. Ysing a subquery to create a set, then filtering with `not in` is one of the most common uses of subqueries.

<div class="callout" markdown="1">

1. Write a query that finds all the penguins on islands where at least one Gentoo penguin has been observed. (Hint: use a subquery to find the names of islands where Gentoo penguins live, then use `in` to find all penguins on those islands.)

2. Write a query that finds all the penguins on islands where *no* Chinstrap penguin has ever been observed.

3. In the `work` table, write a query to find all the people who have *never* complained.

</div>

## Common Table Expressions

Subqueries can be nested inside one another, but deeply nested queries are hard to read and understand. [%g common_table_expression "Common table expressions" %] (also called CTEs) give us a way to write the same logic in a more readable form. Instead of putting one query inside another, we define a named temporary table at the top of our query using `with`, and then refer to it by name.

Here is the heavier-than-average query rewritten using a CTE:

```sql
with avg_mass as (
    select avg(body_mass_g) as threshold
    from penguins
)
select
    penguins.species,
    penguins.body_mass_g,
    round(avg_mass.threshold, 1) as avg_mass_g
from penguins inner join avg_mass
where penguins.body_mass_g > avg_mass.threshold;
```

The `with avg_mass as (…)` block defines a temporary table called `avg_mass`. That table is then available in the `from` clause of the main query just like a real table. We join it to `penguins` so we can compare each penguin's mass to the threshold. The `join` is important: (almost) every use of CTEs requires at least one join to connect the temporary table(s) with the real ones.

CTEs are even more valuable when we need several intermediate results. For example, suppose we want to show each penguin's mass alongside both the average for its species and the overall average:

```sql
with
    species_avg as (
        select species, avg(body_mass_g) as avg_for_species
        from penguins
        group by species
    ),
    overall_avg as (
        select avg(body_mass_g) as avg_overall
        from penguins
    )
select
    penguins.species,
    penguins.body_mass_g,
    round(species_avg.avg_for_species, 1) as species_avg_g,
    round(overall_avg.avg_overall, 1) as overall_avg_g
from penguins
    inner join species_avg on penguins.species = species_avg.species
    inner join overall_avg
limit 10;
```

We defined two CTEs separated by a comma. The first calculates the per-species average, and the second calculates the overall average. Both are then joined into the main query. Notice that joining `overall_avg` doesn't need an `on` condition because it only has one row, so every penguin row naturally combines with it.

<div class="callout" markdown="1">

1. Rewrite the "who has never calibrated?" query from the previous section using a CTE instead of a nested subquery.

2. Write a CTE-based query that shows, for each species on each island, how many penguins were observed and what percentage of all penguins (across all species and islands) that represents. Round the percentage to one decimal place.

3. When would you choose a subquery over a CTE, and when would you choose a CTE over a subquery? Think about readability, reuse within a single query, and any trade-offs you can identify.

</div>

## Check Understanding

![concept map](./concepts.svg)
