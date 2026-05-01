# Aggregating and Grouping

The queries we wrote in the previous two tutorials operated on each row separately. We often want to ask questions about [%g group "groups" %] of rows, such as "how heavy is the largest penguin we weighed?" or "how many Gentoo penguins did we see?" This tutorial looks first at how to write queries that [%g aggregation "aggregate" %] data, and then at how to calculate aggregate values for several subsets of our data simultaneously.

## Aggregation

Let's start by finding out how heavy the heaviest penguin in our dataset is. To do this, we use a function called `max`, and give it the name of the column it is to get data from. To make the result more readable, we will use `as` to call the result `heaviest`.

```sql
select max(body_mass_g) as heaviest from penguins;
```

The query below shows the six most commonly used [%g aggregation_func "aggregation functions" %] in SQL applied to different columns of the penguins data.

```sql
select
    avg(flipper_length_mm) as averagest,
    count(species) as num_penguins,
    max(body_mass_g) as heaviest,
    min(flipper_length_mm) as shortest,
    sum(body_mass_g) as total_mass
from penguins;
```

<div class="callout" markdown="1">

1. How much do the penguins weigh in total?

2. The function `length` calculates the number of characters in a piece of text. Write a query that returns the length of the longest island name in the database.

3. The function `round` rounds off a number, e.g., `round(1.234, 1)` produces `1.2`. Use this to display the average flipper length of all the penguins rounded to one decimal place.

</div>

Note: rather than writing `count(species)` or `count(island)`, we often write `count(*)` to count the total number of rows. However, as we will see in the next tutorial `count(species)` and `count(*)` can sometimes produce slightly different answers.

## Grouping

The query shown above applies the aggregation function to all of the rows in the table. If we want, we can apply it to just the first ten.

```sql
select avg(body_mass_g) as avg_mass
from penguins
limit 10;
```

The order of operations here is important. We aren't asking SQL to calculate an average and then give us the first ten rows of the result. Instead, we are asking it to get the first ten rows and *then* calculate the average of those. This matters more when we use `where` to filter the data: the filtering happens before SQL applies the function, which lets us do things like calculate the average mass of all the Gentoo penguins.

```sql
select avg(body_mass_g) as avg_mass
from penguins
where species = 'Gentoo';
```

But what if we want to calculate the average mass for all of the species? We could write three queries, one for each species, but (a) that would be annoying and (b) if someone adds Emperor penguins to the data and we don't remember to update our query, we won't get the full picture.

What we should do instead is tell SQL to group the data based on the values in one or more columns, and then calculate the aggregate value within each group.

```sql
select avg(body_mass_g) as avg_mass
from penguins
group by species;
```

Since there are three species, we get three rows of output. Unfortunately, we don't know which average corresponds to which species. To get that, we add the `species` column to the `select` clause.

```sql
select species, avg(body_mass_g) as avg_mass
from penguins
group by species;
```

And just as we can order data by multiple columns at once, we can group by multiple columns. When we do, we get one bucket for each unique combination of grouping values.

```sql
select species, sex, avg(body_mass_g) as avg_mass
from penguins
group by species, sex;
```

We will explain what the blanks in the `sex` column mean in the next tutorial.

<div class="callout" markdown="1">

1. How many penguins of each sex were found on each island?

2. What is difference in weight between the heaviest female penguin and the lightest female penguin within each species?

3. Explain what the query below is calculating, and when its result would be useful.

```sql
select round(body_mass_g/1000, 1) as weight, count(*)
from penguins
group by weight;
```

</div>

## Arbitrary Choice in Aggregation

The query shown below is legal SQL, but probably not what anyone would want.

```sql
select sex, species, body_mass_g
from penguins
group by species;
```

The rule that SQL follows is this: if we have created groups using `group by`, and we _don't_ specify how to combine the values in a group for a particular column, then the database picks one of the values for that column in that group arbitrarily. For example, since we only grouped by `species`, but we're asking to show `sex`, the result shows one of the values for `sex` for each species. Similarly, since we didn't specify how to combine the various body masses for each species, the three values shown each come from a penguin of that species, but we don't know (and can't control) which one.

We used this behavior earlier when we selected `species` and `avg(body_mass_g)` after grouping by `species`. Since all of the penguins within a group are of the same species, it doesn't matter which `species` value the database shows us for that group: they're all the same. If we forget to choose an aggregation function by accident, though, the answer will be plausible (because it's an actual value) but wrong.

## Filtering After Aggregation

Just as we can use `where` to filter individual rows before aggregating (or if we're not aggregating at all), we can use `having` to filter aggregated values. For example, the query below finds those combinations of sex and species whose average weight is 4kg or more.

```sql
select sex, species, avg(body_mass_g) as avg_mass
from penguins
group by sex, species
having avg_mass >= 4000.0;
```

<div class="callout" markdown="1">

1. Explain what the query below is calculating.

```sql
select max(flipper_length_mm) as long_flipper, species, sex
from penguins
where sex = 'FEMALE'
group by species, sex
having long_flipper > 210.0;
```

</div>

What we *can't* do with the tools we've seen so far is compare individual values to aggregates. For example, we can't use a query like the one below to find penguins that are heavier than average.

```sql
select * from penguins
where body_mass_g > avg(body_mass_g);
```

We will see how to write this query in a couple of tutorials.

## Check Understanding

![concept map](./concepts.svg)
