# Practice Questions

<p class="center">Yo, Cy - I got your homework for you</p>

## Using penguins.db

### 1. Show all penguins

Show every column of every row in the `penguins` table.

### 2. Show species and island

Show only the `species` and `island` columns from the `penguins` table.

### 3. Distinct islands

Show the distinct island names in the `penguins` table.
Order the results alphabetically.

### 4. Lightest penguins first

Show the species, island, and body mass of the lightest ten penguins.

### 5. Body mass in kilograms

Show each penguin's species, sex, and body mass in kilograms.
If the body mass is unknown, show the word `unknown`.

### 6. Gentoo penguins only

How many Gentoo penguins are there?

### 7. Long flippers

Show the species and flipper length of penguins
whose flipper length is greater than 210mm.

### 8. Heavy penguins on Biscoe

Show all columns for penguins on Biscoe island that weigh more than 4000g.

### 9. Chinstrap or Torgersen

Show the distinct species and island combinations
for penguins that are either Chinstrap
*or* found on Torgersen island (or both).

### 10. Summary statistics

Show the total number of rows in `penguins` as `num_penguins`,
the heaviest body mass as `max_mass_g`,
and the lightest body mass as `min_mass_g`.

### 11. Average mass by species

Show each species and its average body mass.
Call the average column `avg_mass_g`.
Order by `avg_mass_g` from heaviest to lightest.

### 12. Islands with large average flippers

Show each island and its average flipper length (as `avg_flipper_mm`),
but only for islands where that average is greater than 195 mm.

### 13. Counting nulls in sex

Write a query that shows two values side by side:
the number of rows where `sex` is not null (as `known_sex`)
and the total number of rows (as `total_rows`).
Explain in a comment why these two numbers differ.

### 14. Known mass, unknown sex

Show all columns for penguins whose `body_mass_g` is recorded
but whose `sex` is not recorded.

## Using survey.db

### 15. Distinct machine types

Show all distinct machine types in the `machine` table.
Order alphabetically.

### 16. Full names

Show every person's full name as `full_name`
(personal name, a space, then family name).
Order by family name and then personal name.

### 17. Surveys without an end date

Show the `survey_id` and `person_id` of every survey that has no end date.

### 18. Survey count per person

Count how many surveys each person has done.
Show `person_id` and the count as `num_surveys`.
Order by `num_surveys` from highest to lowest.

### 19. People and their surveys

Show each person's full name (as `full_name`) and the `survey_id`
of every survey they have done.
Order by full name.

### 20. People with machine ratings

Show the full name of every person who has at least one entry in the `rating` table.
Do not show duplicates.

### 21. Average rating by machine type

Show the average rating level for each machine type as `avg_level`.
Exclude rows where `level` is null.
Order by `avg_level` from highest to lowest.

### 22. Raters per machine type

Show each machine type and the number of people who have rated it (as `num_raters`).
Include machine types that no one has rated (show 0 for those).

### 23. Done surveys and ratings

Show the full name of everyone who has done at least one survey
and also has at least one entry in the `rating` table.
Do not show duplicates.

### 24. Ratings on multiple machines

Show each person's full name and the number of different machines
they have rated (as `num_machines`).
Only show people who have rated at least two different machines.

### 25. Supervisors and their team size

Show each supervisor's full name (as `supervisor`)
and the number of people they supervise (as `num_reports`).
Only show people who supervise at least one other person.

### 26. People who have done surveys

Use `in` with a subquery to show the full name of every person
who has at least one entry in the `survey` table.
Do not show duplicates. Order by family name.

### 27. People who have never done a survey

Use `not in` with a subquery to show the full name of every person
in the `person` table who has no entries in the `survey` table.

### 28. People with no machine ratings

Use `not in` with a subquery to find every person
who does not appear in the `rating` table at all.
Show their full name (as `full_name`).

### 29. Surveys done by supervisors

Use `in` with a subquery to show the `survey_id` and `start_date`
of every survey carried out by someone who supervises at least one other person.
(Hint: find the `person_id` values that appear as `supervisor_id` in the `person` table.
Be careful: some `supervisor_id` values are `null`, and including `null` in an `in` list
can cause rows to be silently dropped from the results.)

### 30. Machine types with no non-null ratings

Use `not in` with a subquery to show the `machine_type` of every machine
that has never received a non-null rating level.
