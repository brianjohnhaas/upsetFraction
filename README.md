# upsetFraction

An R package to create UpSet-style plots with point size & color encoding the fraction of each set represented.

Written for me in collaboration with chatgpt and claude
    
## Installation

```r
# install.packages("devtools")
devtools::install_github("brianjohnhaas/upsetFraction")


# Example using included dataset
library(upsetFraction)

data(movies_demo)

upset_fraction_full(
  movies_demo,
  id_col = "MovieID",
  set_col = "Genre",
  top_n_intersections = 15
)
```

<img src="https://private-user-images.githubusercontent.com/7542111/489174540-75bac941-c822-4168-8f0a-26a234909d98.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTc3NzUyOTQsIm5iZiI6MTc1Nzc3NDk5NCwicGF0aCI6Ii83NTQyMTExLzQ4OTE3NDU0MC03NWJhYzk0MS1jODIyLTQxNjgtOGYwYS0yNmEyMzQ5MDlkOTgucG5nP1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQVZDT0RZTFNBNTNQUUs0WkElMkYyMDI1MDkxMyUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyNTA5MTNUMTQ0OTU0WiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9OTgwNzkyNDZlY2YwMWQxNTI5YTU1NDdiMWI2MDkyYTBkNTVmYjMyNDQ0OWIzZTZlYWViNTY0ZmUyNjgwY2Q2ZiZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QifQ.OkmXaRTzctBY1evhoqmDLeGCgY3iA_vWbXOAu3RCfts" width=600 />


Format of the input data: instance(tab)category

```
> head(movies_demo, 20)
   MovieID   Genre
1       M1 Romance
2       M1   Drama
3       M2 Romance
4       M2   Drama
5       M3 Romance
6       M3   Drama
7       M4 Romance
8       M4   Drama
9       M5 Romance
10      M5   Drama
11      M6 Romance
12      M6   Drama
13      M7 Romance
14      M7   Drama
15      M8 Romance
16      M8   Drama
17      M9 Romance
18      M9   Drama
19     M10 Romance
20     M10   DramaOB
```
