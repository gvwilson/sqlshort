# Answers to Practice Questions

## Using penguins.db

### 1. Show all penguins

```sql
select * from penguins;
```

The `*` shorthand selects every column; without an `order by` clause, rows may appear in any order.

### 2. Show species and island

```sql
select species, island from penguins;
```

Listing column names instead of `*` controls which columns appear and in what order.

### 3. Distinct islands

```sql
select distinct island
from penguins
order by island;
```

`distinct` removes duplicate values so each island name appears exactly once.

### 4. Lightest penguins first

```sql
select species, island, body_mass_g
from penguins
order by body_mass_g
limit 10;
```

SQLite sorts `null` values before any real number in ascending order,
so the two penguins with unknown mass appear first.

### 5. Body mass in kilograms

```sql
select species, sex,
    coalesce(body_mass_g / 1000.0, 'unknown') as mass_kg
from penguins;
```

`coalesce` returns its first non-`null` argument,
so when `body_mass_g` is `null` it falls through to the string `'unknown'`.

### 6. Gentoo penguins only

```sql
select count(*) as num_gentoo
from penguins
where species = 'Gentoo';
```

The `where` clause filters rows before `count` sees them,
so only Gentoo rows are counted.

### 7. Long flippers

```sql
select species, flipper_length_mm
from penguins
where flipper_length_mm > 210;
```

Rows where `flipper_length_mm` is `null` do not pass the `>` test and are excluded automatically.

### 8. Heavy penguins on Biscoe

```sql
select *
from penguins
where island = 'Biscoe' and body_mass_g > 4000;
```

Both conditions must be true for a row to appear.

### 9. Chinstrap or Torgersen

```sql
select distinct species, island
from penguins
where species = 'Chinstrap' or island = 'Torgersen';
```

`or` includes a row if either condition is true,
so Adelie penguins on Torgersen and all Chinstrap penguins (on Dream) both appear.

### 10. Summary statistics

```sql
select
    count(*) as num_penguins,
    max(body_mass_g) as max_mass_g,
    min(body_mass_g) as min_mass_g
from penguins;
```

All three aggregation functions operate over the same set of rows
and collapse the table to a single result row.

### 11. Average mass by species

```sql
select species, avg(body_mass_g) as avg_mass_g
from penguins
group by species
order by avg_mass_g desc;
```

`group by` creates one bucket per species.
`avg` is then applied within each bucket,
and `desc` reverses the default ascending sort.

### 12. Islands with large average flippers

```sql
select island, avg(flipper_length_mm) as avg_flipper_mm
from penguins
group by island
having avg_flipper_mm > 195;
```

`having` filters *after* aggregation,
so only islands whose computed average exceeds 195mm appear.
Using `where` here would not work because `avg_flipper_mm` does not exist until after grouping.

### 13. Counting nulls in sex

```sql
select count(sex) as known_sex, count(*) as total_rows
from penguins;
```

`count(column_name)` skips `null`, while `count(*)` never does.
There are 344 rows but only 333 recorded sexes,
so the 11-row difference is the number of penguins whose sex was not recorded.

### 14. Known mass, unknown sex

```sql
select *
from penguins
where body_mass_g is not null and sex is null;
```

`is null` and `is not null` are the only reliable way to test for missing values.
Comparing with `= null` or `!= null` always produces `null`, never `true`.

## Using survey.db

### 15. Distinct machine types

```sql
select distinct machine_type
from machine
order by machine_type;
```

Each row in `machine` has one type, so `distinct` removes any repeated type names before sorting.

### 16. Full names

```sql
select personal || ' ' || family as full_name
from person
order by family, personal;
```

The `||` operator concatenates text.
Inserting a literal space between the two names produces a readable full name.

### 17. Surveys without an end date

```sql
select survey_id, person_id
from survey
where end_date is null;
```

`end_date` is `null` for surveys that are still in progress or whose end was never recorded.

### 18. Survey count per person

```sql
select person_id, count(*) as num_surveys
from survey
group by person_id
order by num_surveys desc;
```

Grouping on `person_id` puts all rows for one person into the same bucket,
and `count(*)` then counts those rows.

### 19. People and their surveys

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

### 20. People with machine ratings

```sql
select distinct person.personal || ' ' || person.family as full_name
from person inner join rating
on person.person_id = rating.person_id;
```

The join produces one row per rating entry, so `distinct` is needed to show each person only once.

### 21. Average rating by machine type

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

### 22. Raters per machine type

```sql
select machine.machine_type, count(rating.person_id) as num_raters
from machine left join rating
on machine.machine_id = rating.machine_id
group by machine.machine_type;
```

A left join keeps every machine even if no rating row matches.
`rating.person_id` is `null` for those machines, so `count(rating.person_id)` returns 0.

### 23. Done surveys and ratings

```sql
select distinct person.personal || ' ' || person.family as full_name
from person
inner join survey on person.person_id = survey.person_id
inner join rating on person.person_id = rating.person_id;
```

Chaining two inner joins keeps only people who appear in both `survey` and `rating`.
`distinct` removes the duplicates that arise when a person has multiple surveys or ratings.

### 24. Ratings on multiple machines

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

### 25. Supervisors and their team size

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
