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

<img src="https://private-user-images.githubusercontent.com/7542111/489174540-75bac941-c822-4168-8f0a-26a234909d98.png" />
