#' Example Movie Dataset for upsetFraction
#'
#' A toy dataset of movies with assigned genres, constructed to highlight
#' fractional representation in the UpSet-style plot. The dataset is designed
#' so that certain genres (e.g., Romance and SciFi) are heavily contained within
#' intersections, producing high fractional values (≥ 0.75).
#'
#' @format A data frame with 91 rows and 2 variables:
#' \describe{
#'   \item{MovieID}{Unique identifier for each movie (character)}
#'   \item{Genre}{Genre membership (factor/character), one row per (movie, genre)}
#' }
#'
#' @examples
#' data(movies_demo)
#' head(movies_demo)
#'
#' upset_fraction_full(
#'   movies_demo,
#'   id_col = "MovieID",
#'   set_col = "Genre",
#'   top_n_intersections = 15
#' )
"movies_demo"

