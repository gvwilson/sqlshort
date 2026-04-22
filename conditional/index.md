# Conditionals and Pattern Matching

This lesson shows how to classify data on the fly using conditional expressions, and how to filter rows based on patterns in text.

## If/Else

Suppose we want to label each penguin as either `'heavy'` or `'light'` based on its body mass. We can do this with the `iif` function, which takes three arguments: a condition, the value to return when the condition is true, and the value to return when it is false:

```sql
select
    species,
    body_mass_g,
    iif(body_mass_g >= 4000.0, 'heavy', 'light') as category
from penguins
where body_mass_g is not null
limit 10;
```

Note the spelling: `iif` has two i's. Also note that `iif` produces a value that we can use like any other. This means that we can combine it with aggregation to find out how many heavy and light penguins there are:

```sql
select
    iif(body_mass_g >= 4000.0, 'heavy', 'light') as category,
    count(*) as num
from penguins
where body_mass_g is not null
group by category;
```

<div class="callout" markdown="1">

1. Modify the query above to use a threshold of 3500g instead of 4000g. How does the split change?

2. Write a query that labels each penguin's flipper as `'long'` if is 200mm long or more and `'short'` otherwise. How many long-flippered penguins are there in each species?

3. Can the value produced by `iif` be used in a `where` clause? Try it and explain the result.

</div>

## Selecting a Case

`iif` works well when there are exactly two categories, but what if we want three or more? Nesting `iif` inside `iif` quickly becomes unreadable, SQL lets us use a `case` expression instead:

```sql
select
    species,
    body_mass_g,
    case
        when body_mass_g < 3500 then 'small'
        when body_mass_g < 4500 then 'medium'
        else 'large'
    end as size
from penguins
where body_mass_g is not null
limit 10;
```

SQL evaluates the `when` conditions in order and uses the result from the first one that is true. If no condition is true, the `else` branch is used; if there is no `else` and no condition is true, the result is `null`. The `end` keyword closes the `case` expression.

We can combine `case` with `group by` to count how many penguins fall into each size category within each species:

```sql
select
    species,
    case
        when body_mass_g < 3500 then 'small'
        when body_mass_g < 4500 then 'medium'
        else 'large'
    end as size,
    count(*) as num
from penguins
where body_mass_g is not null
group by species, size
order by species, size;
```

<div class="callout" markdown="1">

1. What happens to the rows where `body_mass_g` is `null` in the query above? Where do those penguins go?

2. Modify the query to add a fourth category: `'unknown'` for penguins whose body mass is not recorded.

3. Write a query that uses `case` to label each penguin's bill as `'stubby'` (bill length less than 40mm), `'average'` (40mm to 50mm), or `'long'` (more than 50mm). Count how many penguins fall into each category.

</div>

## Checking a Range

Checking whether a value falls within a range is common enough that SQL provides a shorthand: `between`. The expression `body_mass_g between 3500 and 4500` is equivalent to `body_mass_g >= 3500 and body_mass_g <= 4500`. Both endpoints are included.

```sql
select species, island, body_mass_g
from penguins
where body_mass_g between 3500 and 4500
order by body_mass_g;
```

`between` works with text as well as numbers, using dictionary order. The query below finds penguins whose species name falls alphabetically between `'Adelie'` and `'Chinstrap'` inclusive.

```sql
select distinct species
from penguins
where species between 'Adelie' and 'Chinstrap';
```

<div class="callout" markdown="1">

1. Use `between` inside a `case` expression to classify each penguin as `'light'` (under 3500g), `'normal'` (3500g to 5000g), or `'heavy'` (over 5000g).

2. `between` always includes both endpoints. How would you rewrite `x between 3500 and 4500` to exclude one or both endpoints?

3. What happens if you write `between 4500 and 3500` (high value first)? Is the result what you expect?

</div>

## Pattern Matching with `like`

Sometimes we want to filter rows based on whether a piece of text matches a pattern rather than an exact value. The `like` operator supports two wildcards: `%` matches any sequence of zero or more characters, and `_` matches exactly one character.

The `survey` database has a `machine` table with machine types. We can find all machines whose type contains the word `'generator'` like this:

```sql
select machine_id, machine_type
from machine
where machine_type like '%generator%';
```

The `%` on both sides of `'generator'` means "anything before, anything after". We can also anchor patterns to the start or end of a value:

```sql
-- Machines whose type starts with 'hydraulic'
select machine_id, machine_type
from machine
where machine_type like 'hydraulic%';
```

```sql
-- People whose family name is exactly five characters long
select personal, family
from person
where family like '_____';
```

`like` is case-insensitive by default in SQLite for ASCII letters, so `like 'H%'` and `like 'h%'` produce the same results.

<div class="callout" markdown="1">

1. Write a query that finds all people in the `person` table whose personal name contains the letter `'a'` (upper or lower case).

2. Write a query that finds all machine types in the `machine` table that end with the word `'press'`.

</div>

## Pattern Matching with `glob`

SQLite also supports `glob`, which uses Unix-style wildcards: `*` matches any sequence of characters (like `%` in `like`), and `?` matches exactly one character (like `_` in `like`). Unlike `like`, `glob` is case-sensitive.

```sql
select machine_id, machine_type
from machine
where machine_type glob '*generator*';
```

```sql
-- Case-sensitive: finds 'hydraulic' but not 'Hydraulic'
select machine_id, machine_type
from machine
where machine_type glob 'hydraulic*';
```

`glob` also supports character classes in square brackets, so `glob '[Hh]ydraulic*'` would match both `'hydraulic'` and `'Hydraulic'`. For most purposes, `like` is simpler and more portable; `glob` is useful when case-sensitivity matters or when you are already familiar with Unix shell patterns.

<div class="callout" markdown="1">

1. Rewrite the query that finds machines containing `'generator'` using `glob` instead of `like`.

2. Write a query using `glob` that finds all people in `person` whose family name starts with a capital letter between `'A'` and `'M'`. (Hint: `[A-M]` is a valid glob character class.)

</div>

## Check Understanding

![concept map](./concepts.svg)
