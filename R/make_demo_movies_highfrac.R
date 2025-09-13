#' Generate a High-Fraction Demo Dataset
#'
#' Construct a synthetic movie/genre dataset with engineered intersections
#' to produce fractional values in the 0.75–1.0 range. Useful for demos.
#'
#' @return A data frame with two columns: `MovieID` and `Genre`.
#' @export
#'
#' @examples
#' set.seed(2025)
#' movies <- make_demo_movies_highfrac()
#' upset_fraction_full(
#'   movies,
#'   id_col = "MovieID",
#'   set_col = "Genre",
#'   top_n_intersections = 15
#' )
make_demo_movies_highfrac <- function() {
  genres <- c("Action", "Comedy", "Drama", "SciFi", "Romance")
  target_sizes <- c(Action = 26, Comedy = 22, Drama = 30, SciFi = 14, Romance = 18)

  forced <- list(
    "Romance;Drama"        = 14, # ~0.78 Romance inside Drama
    "Action;SciFi"         = 11, # ~0.79 SciFi inside Action
    "Comedy;Drama"         = 6,
    "Action;Comedy"        = 5,
    "Action;Drama"         = 4
  )

  id_counter <- 1L
  new_ids <- function(n) {
    ids <- paste0("M", id_counter:(id_counter + n - 1))
    id_counter <<- id_counter + n
    ids
  }

  membership <- data.frame(MovieID = character(), Genre = character(), stringsAsFactors = FALSE)

  add_combo_rows <- function(ids, gs) {
    do.call(
      rbind,
      lapply(ids, function(id) data.frame(MovieID = id, Genre = gs, stringsAsFactors = FALSE))
    )
  }

  for (key in names(forced)) {
    gs <- strsplit(key, ";")[[1]]
    n  <- forced[[key]]
    ids <- new_ids(n)
    for (id in ids) {
      membership <- rbind(membership, add_combo_rows(id, gs))
    }
  }

  current_sizes <- table(membership$Genre)
  current_sizes <- setNames(as.integer(current_sizes[genres]), genres)
  current_sizes[is.na(current_sizes)] <- 0L
  need <- pmax(target_sizes - current_sizes, 0L)

  for (g in names(need)) {
    if (need[[g]] == 0) next
    n_single <- round(0.8 * need[[g]])
    n_pair   <- need[[g]] - n_single

    if (n_single > 0) {
      ids <- new_ids(n_single)
      for (id in ids) {
        membership <- rbind(membership, add_combo_rows(id, g))
      }
    }

    if (n_pair > 0) {
      partners <- sample(setdiff(genres, g), n_pair, replace = TRUE)
      ids <- new_ids(n_pair)
      for (i in seq_along(ids)) {
        membership <- rbind(membership, add_combo_rows(ids[i], c(g, partners[i])))
      }
    }
  }

  membership
}

