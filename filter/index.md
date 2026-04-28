# Filtering

The previous tutorial showed how to select specific columns from a database table, and how to page through the data that a query returns. However, people almost always **filter** data based on its properties rather than on its position in a table. To see how this works, let's look at the combinations of species, island, and sex in the `penguins` table.

```sql
select distinct species, island, sex from penguins;
```

## Equality

Suppose we only want to see penguins from Dream island, regardless of their species or sex. To get this, we add a `where` clause to our query.

```sql
select distinct species, island, sex
from penguins
where island = 'Dream';
```

There are several noteworthy things in this query:

1. We don't have to use `distinct`. If we leave it out, we get *all* the penguins on Dream island. (We included it to make the output easier to read without paging.)
2. The `where` clause *must* come after the `from` clause. SQL is very picky about ordering…
3. We don't put quotation marks around `island` because it's the name of a column. We *do* put quotes around `'Dream'` because it's an actual literal piece of text.
4. We use a single equals sign `=` to check for equality. This is different from most programming languages, which use `==`.

<div class="callout" markdown="1">

1. Write a query to select all the Chinstrap penguins regardless of what island they're on.

2. Change the column name `island` to `ISLAND` and re-run the query: what happens?

3. Change the text value `'Dream'` to `'DREAM'`: what happens?

4. Change the text value `'Dream'` to `"Dream"` (with double quotes): what happens?

</div>

## Comparisons

We can do all of the usual comparisons in SQL:

| name | symbol | example |
| :--- | ------ | :------ |
| less than | `<` | `body_mass_g < 3300` |
| less than or equal | `<=` | `flipper_length_mm < 200.0` |
| equal | `=` | `species = 'Gentoo'` |
| not equal | `!=` or `<>` | `species != 'Gentoo'` |
| greater than or equal | `>=` | `flipper_length_mm >= 200.0` |
| greater than | `>` | `body_mass_g > 3300` |

Comparing numbers is straightforward. When we compare text, the comparison uses dictionary order: A is less than B, AA is than AB, and so on.

<div class="callout" markdown="1">

1. Find all the penguins that _aren't_ on Torgersen island.

2. What happens if we accidentally compare a number to text? For example, what happens if we select penguins where `species` is less than 3000, or where `body_mass_g` is greater than the letter 'M'?

</div>

## Combining Conditions

We can combine conditions using `and` and `or`. `and` is the simpler of the two: when we write `where condition_1 and condition_2`, we get the rows where *both* conditions are true.

```sql
select * from penguins
where species = 'Gentoo' and body_mass_g > 6000.0;
```

If we use `or`, we get rows where *either or both* condition is true. This is different from common English usage: if you tell a child that they can have an ice cream cone or a chocolate bar, you mean "either/or". When you use `or` in SQL, on the other hand, it means "if any of the conditions is true". For example, the query below gets all of the penguins on Biscoe island, as well as all of the Gentoo penguins. Some penguins satisfy both conditions (the Adelie penguins on Biscoe island), some satisfy just one (the Adelies on Torgersen and the Gentoos on Biscoe). Penguins that don't satisfy either, like Chinstrap penguins on Dream island, don't show up at all.

```sql
select distinct species, island from penguins
where species = 'Adelie' or island = 'Biscoe';
```

We have written our `where` conditions as we would say them. Many programmers would wrap each condition in parentheses to make them easier to read.

```sql
select distinct species, island from penguins
where (species = 'Adelie') or (island = 'Biscoe');
```

The more complex our conditions are, the more important it is to use parentheses to make sure everyone reading the query (including ourselves) understands what it means. The query below shows an example.

```sql
select distinct species, island from penguins
where ((species = 'Adelie') and (island = 'Biscoe')) or (species = 'Chinstrap');
```

<div class="callout" markdown="1">

1. Explain in simple terms what the condition in the query above is selecting.

2. We can put `not` in front of a condition to invert its meaning. Use this to write a query that fetches the same rows as one with the condition `species != 'Chinstrap'`, but which uses `=` instead of `!=`.

3. Does the expression `species not = 'Gentoo'` work?

4. Write a query to find all of the penguins whose bill length is greater than their bill depth.

5. Write another query to find all of the penguins whose bill length is less than their bill depth. What do you notice about the output of this query?

6. The previous tutorial showed how to do calculations on the fly to (for example) produce a column called `mass_kg` showing the body mass of each penguin in kilograms. Can these on-the-fly columns be used in `where` conditions? To find out, write a query that finds all of the penguins that weight more than 4.0 kg.

</div>

## Check Understanding

![concept map](./concepts.svg)
