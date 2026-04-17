# Missing Data

The biggest challenge people facing when using databases isn't remembering the order of clauses in a SQL query. The biggest challenge is handling missing data. This tutorial builds on the filtering introduced in the previous one to show how to manage this in our queries.

## Null

Here are all of the distinct combinations of island, species, and sex in the `penguins` table.

```sql
select distinct island, species, sex from penguins;
```

Notice the two blanks in the `sex` column, and the fact that its subtitle says there are 3 unique values. Those blanks show the special value `null`, which SQL uses to mean "I don't know". In this case, those values tell us that the scientists who collected the penguins didn't record the sex of some of the Adelie penguins on Dream and Torgersen islands.

The most important thing about **null values** is that almost any operation that involves a `null` produces `null` as an answer. For example, we can use SQL as a very complicated desk calculator and ask, "What is 1 + 2?"

```sql
select 1 + 2 as result;
```

If we ask, "What is 1 + `null`?", the answer is `null`, because one plus "I don't know" is "I don't know".

```sql
select 1 + null as result;
```

We get the same thing if we subtract `null`, multiply by it, and so on. (As the saying goes, "Garbage in, garbage out.") We also get the same thing if we do comparisons. Is `null` equal to 3? Again, the answer is `null`.

```sql
select null = 3 as result;
```

We get the same thing if we ask if `null` is *not* equal to 3, because if we don't know the value, we don't know if it *isn't* 3.

```sql
select null != 3 as result;
```

What about `null = null`? If we have two numbers, and we don't know what either is, we don't know if they're the same or not, so the answer is once again `null`, *not* `true`.

```sql
select null = null as result;
```

<div class="callout" markdown="1">

1. Where does SQL put `null` values when sorting: at the start, at the end, or somewhere else?

2. Does it follow the same rule for both numbers and text?

</div>

## Aggregating Nulls

If 1 + `null` is `null`, then 1 + 2 + `null` should be `null` as well. Continuing this line of thought, the sum of a column that includes one or more nulls ought to be `null`; so should the `max`, `min`, and so on, because if we don't know all of the inputs, we can't know the output.

SQL isn't this strict because it wouldn't be useful. Instead, its aggregation functions ignore `null` values. If we calculate a sum, for example, we get the sum of all the numbers that we actually know. If we calculate an average, we get the sum of the known values divided by the number of known values (rather than by the total number of known and unknown values), and so on.

There is one exception to this rule. If we ask for `count(sex)` in the penguins database, we get the number of penguins whose sex is known:

```sql
select count(sex) from penguins;
```

If we use `count(*)`, on the other hand, we get the total number of rows regardless of whether some values are `null` or not:

```sql
select count(*) from penguins;
```

<div class="callout" markdown="1">

1. Compare `sum(body_mass_g) / count(body_mass_g)` with `sum(body_mass_g) / count(*)` and with `avg(body_mass_g)`. Are the results consistent with the explanation above?

</div>

## Handling Nulls

There are only two things we can do with `null` that don't produce `null` as a result: ask if a value is `null`, and ask if it isn't. If we're interested in the `sex` column, the first is written `sex is null`, while the second is written `sex is not null`. Note that `is null` and `is not null` are written as multiple words, but are a single test; it's confusing, but we're stuck with it.

Let's have a look at some practical examples. If we select the distinct values of `sex` from the `penguins` table, we get `"FEMALE"`, `"MALE"`, and `null`. (The first line of output is blank, which is how Marimo shows null values.)

```sql
select distinct sex from penguins order by sex;
```

If we want to get all the rows that have a null value for `sex`, we *cannot* do this:

```sql
select sex from penguins
where (sex != 'MALE') and (sex != 'FEMALE');
```

That doesn't produce any output because the rows with null values for `sex` don't pass the test. If we want the rows with missing sex, we have to ask for them explicitly. This query gives us 11 rows.

```sql
select sex from penguins
where sex is null;
```

How many times did the scientists fail to record a penguin's mass or flipper length? The answer is "twice", and in both cases they didn't record *any* of the physical measurements.

```sql
select * from penguins
where (body_mass_g is null) or (flipper_length_mm is null);
```

<div class="callout" markdown="1">

1. Write a query to find penguins whose body mass is known but whose sex is not.

2. Write another query to find penguins whose sex is known but whose body mass is not.

3. Explain why the query shown earlier (and reproduced below) does not produce any rows:

```sql
select sex from penguins
where (sex != 'MALE') and (sex != 'FEMALE');
```

</div>

Some programmers find `null` very annoying. Instead of putting it in their tables, they use marker values like -1 or `"NA"` to signal missing data. Doing this almost always leads to problems. For example, if we are calculating the average age of people who are 17, 19, 21, and and unknown number of years old, the sensible thing to do is add the values we know (the 17, 19, and 21) and then divide by 3. As we will see in the next tutorial, SQL will do this for us automatically _if_ we have used `null` to represent the unknown age. If we use -1, on the other hand, it's all too easy to calculate (17 + 19 + 21 - 1) / 4 and get an average age of 14. We could use `where` to filter out the -1 ages before doing the sum, but (a) we'd have to know to do that and (b) we'd have to know that this programmer used -1 instead of -999999 or something else to mean "I don't know". While it takes a bit of getting used to, it's (almost) always better to use `null` when there are holes in our data.

## Ternary Logic

These tutorials avoid theory when they can, but a little bit will help understand how `null` works. In conventional logic, a statement is either true or false. If we have two statements `A` and `B`, then `A and B` is true when both are true, while `A or B` is true if either or both are true. These rules are sometimes referred to as **binary logic** (also called **Boolean logic**) because there are only two possible values.

SQL is unusual among programming languages in using **ternary logic**, in which any statement can be true, false, or null. Since `null` is not `true`, `where` drops rows if the filter expression produces `null`.

## Check Understanding

![concept map](./concepts.svg)
