# Answers to Practice Questions

## Using penguins.db

### 1. Show all penguins

<details markdown="1">
<summary>Answer</summary>

```sql
select * from penguins;
```

The `*` shorthand selects every column; without an `order by` clause, rows may appear in any order.

</details>

### 2. Show species and island

<details markdown="1">
<summary>Answer</summary>

```sql
select species, island from penguins;
```

Listing column names instead of `*` controls which columns appear and in what order.

</details>

### 3. Distinct islands

<details markdown="1">
<summary>Answer</summary>

```sql
select distinct island
from penguins
order by island;
```

`distinct` removes duplicate values so each island name appears exactly once.

</details>

### 4. Lightest penguins first

<details markdown="1">
<summary>Answer</summary>

```sql
select species, island, body_mass_g
from penguins
order by body_mass_g
limit 10;
```

SQLite sorts `null` values before any real number in ascending order,
so the two penguins with unknown mass appear first.

</details>

### 5. Body mass in kilograms

<details markdown="1">
<summary>Answer</summary>

```sql
select species, sex,
    coalesce(body_mass_g / 1000.0, 'unknown') as mass_kg
from penguins;
```

`coalesce` returns its first non-`null` argument,
so when `body_mass_g` is `null` it falls through to the string `'unknown'`.

</details>

### 6. Gentoo penguins only

<details markdown="1">
<summary>Answer</summary>

```sql
select count(*) as num_gentoo
from penguins
where species = 'Gentoo';
```

The `where` clause filters rows before `count` sees them,
so only Gentoo rows are counted.

</details>

### 7. Long flippers

<details markdown="1">
<summary>Answer</summary>

```sql
select species, flipper_length_mm
from penguins
where flipper_length_mm > 210;
```

Rows where `flipper_length_mm` is `null` do not pass the `>` test and are excluded automatically.

</details>

### 8. Heavy penguins on Biscoe

<details markdown="1">
<summary>Answer</summary>

```sql
select *
from penguins
where island = 'Biscoe' and body_mass_g > 4000;
```

Both conditions must be true for a row to appear.

</details>

### 9. Chinstrap or Torgersen

<details markdown="1">
<summary>Answer</summary>

```sql
select distinct species, island
from penguins
where species = 'Chinstrap' or island = 'Torgersen';
```

`or` includes a row if either condition is true,
so Adelie penguins on Torgersen and all Chinstrap penguins (on Dream) both appear.

</details>

### 10. Summary statistics

<details markdown="1">
<summary>Answer</summary>

```sql
select
    count(*) as num_penguins,
    max(body_mass_g) as max_mass_g,
    min(body_mass_g) as min_mass_g
from penguins;
```

All three aggregation functions operate over the same set of rows
and collapse the table to a single result row.

</details>

### 11. Average mass by species

<details markdown="1">
<summary>Answer</summary>

```sql
select species, avg(body_mass_g) as avg_mass_g
from penguins
group by species
order by avg_mass_g desc;
```

`group by` creates one bucket per species.
`avg` is then applied within each bucket,
and `desc` reverses the default ascending sort.

</details>

### 12. Islands with large average flippers

<details markdown="1">
<summary>Answer</summary>

```sql
select island, avg(flipper_length_mm) as avg_flipper_mm
from penguins
group by island
having avg_flipper_mm > 195;
```

`having` filters *after* aggregation,
so only islands whose computed average exceeds 195mm appear.
Using `where` here would not work because `avg_flipper_mm` does not exist until after grouping.

</details>

### 13. Counting nulls in sex

<details markdown="1">
<summary>Answer</summary>

```sql
select count(sex) as known_sex, count(*) as total_rows
from penguins;
```

`count(column_name)` skips `null`, while `count(*)` never does.
There are 344 rows but only 333 recorded sexes,
so the 11-row difference is the number of penguins whose sex was not recorded.

</details>

### 14. Known mass, unknown sex

<details markdown="1">
<summary>Answer</summary>

```sql
select *
from penguins
where body_mass_g is not null and sex is null;
```

`is null` and `is not null` are the only reliable way to test for missing values.
Comparing with `= null` or `!= null` always produces `null`, never `true`.

</details>

## Using survey.db

### 15. Distinct machine types

<details markdown="1">
<summary>Answer</summary>

```sql
select distinct machine_type
from machine
order by machine_type;
```

Each row in `machine` has one type, so `distinct` removes any repeated type names before sorting.

</details>

### 16. Full names

<details markdown="1">
<summary>Answer</summary>

```sql
select personal || ' ' || family as full_name
from person
order by family, personal;
```

The `||` operator concatenates text.
Inserting a literal space between the two names produces a readable full name.

</details>

### 17. Surveys without an end date

<details markdown="1">
<summary>Answer</summary>

```sql
select survey_id, person_id
from survey
where end_date is null;
```

`end_date` is `null` for surveys that are still in progress or whose end was never recorded.

</details>

### 18. Survey count per person

<details markdown="1">
<summary>Answer</summary>

```sql
select person_id, count(*) as num_surveys
from survey
group by person_id
order by num_surveys desc;
```

Grouping on `person_id` puts all rows for one person into the same bucket,
and `count(*)` then counts those rows.

</details>

### 19. People and their surveys

<details markdown="1">
<summary>Answer</summary>

```sql
select
    person.personal || ' ' || person.family as full_name,
    survey.survey_id
from person inner join survey
on person.person_id = survey.person_id
order by full_name;
```

The inner join matches each survey row to its owner in `person` using the shared `person_id` column.
People with no surveys do not appear.

</details>

### 20. People with machine ratings

<details markdown="1">
<summary>Answer</summary>

```sql
select distinct person.personal || ' ' || person.family as full_name
from person inner join rating
on person.person_id = rating.person_id;
```

The join produces one row per rating entry, so `distinct` is needed to show each person only once.

</details>

### 21. Average rating by machine type

<details markdown="1">
<summary>Answer</summary>

```sql
select machine.machine_type, avg(rating.level) as avg_level
from machine inner join rating
on machine.machine_id = rating.machine_id
where rating.level is not null
group by machine.machine_type
order by avg_level desc;
```

`avg` already ignores `null` values,
but the explicit `where` makes the intent clear
and matches what would be needed if using `sum` / `count` manually.

</details>

### 22. Raters per machine type

<details markdown="1">
<summary>Answer</summary>

```sql
select machine.machine_type, count(rating.person_id) as num_raters
from machine left join rating
on machine.machine_id = rating.machine_id
group by machine.machine_type;
```

A left join keeps every machine even if no rating row matches.
`rating.person_id` is `null` for those machines, so `count(rating.person_id)` returns 0.

</details>

### 23. Done surveys and ratings

<details markdown="1">
<summary>Answer</summary>

```sql
select distinct person.personal || ' ' || person.family as full_name
from person
inner join survey on person.person_id = survey.person_id
inner join rating on person.person_id = rating.person_id;
```

Chaining two inner joins keeps only people who appear in both `survey` and `rating`.
`distinct` removes the duplicates that arise when a person has multiple surveys or ratings.

</details>

### 24. Ratings on multiple machines

<details markdown="1">
<summary>Answer</summary>

```sql
select
    person.personal || ' ' || person.family as full_name,
    count(distinct rating.machine_id) as num_machines
from person inner join rating
on person.person_id = rating.person_id
group by person.person_id
having num_machines >= 2;
```

`count(distinct ...)` counts unique machine IDs rather than rows,
so a person rated the same machine twice is not double-counted.
`having` then filters to those with at least two distinct machines.

</details>

### 25. Supervisors and their team size

<details markdown="1">
<summary>Answer</summary>

```sql
select
    sup.personal || ' ' || sup.family as supervisor,
    count(*) as num_reports
from person as sup
inner join person as rep
on sup.person_id = rep.supervisor_id
group by sup.person_id;
```

The self-join gives the `person` table two roles:
`sup` for supervisors and `rep` for the people they supervise.
The inner join naturally excludes anyone who supervises nobody,
because they have no matching rows on the right-hand side.

</details>

### 26. People who have done surveys

<details markdown="1">
<summary>Answer</summary>

```sql
select distinct person.personal || ' ' || person.family as full_name
from person
where person.person_id in (select person_id from survey)
order by person.family;
```

The subquery collects every `person_id` that appears in `survey`.
`in` then keeps only the people whose ID is in that set.
`distinct` is needed because a person appears in `person` once
but may appear many times in `survey`.

</details>

### 27. People who have never done a survey

<details markdown="1">
<summary>Answer</summary>

```sql
select person.personal || ' ' || person.family as full_name
from person
where person.person_id not in (select person_id from survey);
```

The subquery produces the set of IDs that *have* done a survey.
`not in` keeps only people whose ID is absent from that set—
the complement of question 26.

</details>

### 28. People with no machine ratings

<details markdown="1">
<summary>Answer</summary>

```sql
select person.personal || ' ' || person.family as full_name
from person
where person.person_id not in (select person_id from rating);
```

The subquery collects every `person_id` that has any row in `rating`,
regardless of whether the rating level is `null` or not.
`not in` then keeps only people who appear nowhere in `rating`.

</details>

### 29. Surveys done by supervisors

<details markdown="1">
<summary>Answer</summary>

```sql
select survey_id, start_date
from survey
where person_id in (
    select supervisor_id
    from person
    where supervisor_id is not null
)
order by start_date;
```

The subquery finds every `person_id` that is listed as someone else's supervisor.
The `where supervisor_id is not null` guard is important: without it,
`in` would include `null` in the set, which can cause unexpected results
because `null` comparisons always produce `null`, not `true`.

</details>

### 30. Machine types with no non-null ratings

<details markdown="1">
<summary>Answer</summary>

```sql
select machine_type
from machine
where machine_id not in (
    select machine_id
    from rating
    where level is not null
);
```

The subquery finds machines that have received at least one non-`null` rating.
`not in` then keeps only the machines absent from that set—
those that have either never been rated or have only `null` rating entries.

</details>
