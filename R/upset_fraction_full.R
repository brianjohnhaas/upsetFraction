#' @importFrom dplyr select distinct mutate arrange summarise group_by filter left_join n row_number slice_head pull rename
#' @importFrom tidyr pivot_longer pivot_wider
#' @importFrom rlang sym
#' @importFrom ggplot2 ggplot aes geom_col geom_point geom_text geom_segment expansion 
#' @importFrom ggplot2 scale_x_continuous scale_y_continuous scale_y_discrete scale_x_reverse
#' @importFrom ggplot2 scale_color_viridis_c scale_size_continuous labs theme_minimal theme
#' @importFrom ggplot2 element_blank theme_void
#' @importFrom ggplot2 guides guide_legend
#' @importFrom cowplot plot_grid get_legend
#' @importFrom dplyr %>%
NULL
#' upset_fraction_fullAOA
#'
#' Create an UpSet-style visualization showing how set membership 
#' distributes across intersections, with point size & color encoding 
#' the fraction of each set represented.
#'
#' @param df A data frame containing at least two columns:
#'   - `id_col`: unique element IDs (e.g., FusionName)
#'   - `set_col`: categorical set membership (e.g., max_candidates)
#' @param id_col Column name (string) for unique IDs (default: "FusionName").
#' @param set_col Column name (string) for set labels (default: "max_candidates").
#' @param top_n_intersections Number of top intersections to show (default: 40).
#'
#' @return A ggplot/cowplot object.
#' @export
#'
#' @examples
#' \dontrun{
#' df <- data.frame(
#'   FusionName = paste0("F", 1:100),
#'   max_candidates = sample(c("500","1000","2500"), 100, replace=TRUE)
#' )
#' upset_fraction_full(df)
#' }
upset_fraction_full <- function(df,
                                id_col,
                                set_col,
                                top_n_intersections = 40) {



  # --- Prepare data ---
  df1 <- df %>% select(all_of(c(id_col, set_col))) %>% distinct()

  wide <- df1 %>%
    mutate(value = 1) %>%
    pivot_wider(names_from = !!sym(set_col), values_from = value,
                values_fill = 0, id_cols = !!sym(id_col))

  set_cols <- setdiff(names(wide), id_col)

  combos <- wide %>%
    select(all_of(set_cols)) %>%
    group_by(across(everything())) %>%
    summarise(count = n(), .groups = "drop") %>%
    arrange(desc(count)) %>%
    mutate(intersection_id = row_number())

  if (!is.null(top_n_intersections)) {
    combos <- combos %>% slice_head(n = top_n_intersections)
  }

  memb_long <- combos %>%
    pivot_longer(cols = all_of(set_cols),
                 names_to = "set", values_to = "present")

  set_sizes <- wide %>%
    summarise(across(all_of(set_cols), ~ sum(.))) %>%
    pivot_longer(everything(), names_to = "set", values_to = "set_size")

  present_long <- memb_long %>%
    filter(present == 1) %>%
    left_join(set_sizes, by = "set") %>%
    left_join(
      combos %>% select(intersection_id, intersection_count = count),
      by = "intersection_id"
    ) %>%
    mutate(fraction = intersection_count / set_size)

  # --- Ordering ---
  set_order <- set_sizes %>% arrange(desc(set_size)) %>% pull(set)
  memb_long$set    <- factor(memb_long$set, levels = set_order)
  present_long$set <- factor(present_long$set, levels = set_order)
  set_sizes$set    <- factor(set_sizes$set, levels = set_order)

  # --- Helper datasets ---
  lines_df <- memb_long %>%
    filter(present == 1) %>%
    group_by(intersection_id) %>%
    summarise(ymin = min(as.numeric(set)),
              ymax = max(as.numeric(set)), .groups = "drop")

  bg <- memb_long %>% filter(present == 0)

  # --- Shared scales ---
  x_scale <- scale_x_continuous(
    breaks = combos$intersection_id,
    expand = expansion(add = 0.5)
  )
  y_scale <- scale_y_discrete(
    limits = set_order,
    expand = expansion(add = 0.5)
  )

  # --- Shared theme cleanup ---
  no_legend_theme <- theme(
    legend.position = "none",
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank()
  )

  # --- (A) Intersection size barplot (top-right) ---
  p_top <- ggplot(combos, aes(x = intersection_id, y = count)) +
    geom_col(fill = "grey40") +
    geom_text(aes(label = count), vjust = -0.3, size = 2.5) +
    x_scale +
    scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
    theme_minimal() +
    labs(y = "Intersection size", x = NULL) +
    theme(axis.text.x = element_blank(),
          axis.ticks.x = element_blank()) +
    no_legend_theme

  # --- (B) Matrix (bottom-right) ---
  p_matrix <- ggplot() +
    geom_point(data = bg,
               aes(x = intersection_id, y = set),
               color = "grey85", size = 1.6) +
    geom_segment(data = lines_df,
                 aes(x = intersection_id, xend = intersection_id,
                     y = ymin, yend = ymax),
                 linewidth = 0.6, color = "grey40") +
    geom_point(data = present_long,
               aes(x = intersection_id, y = set,
                   color = fraction, size = fraction)) +
    scale_color_viridis_c(limits = c(0,1)) +
    scale_size_continuous(limits = c(0,1), range = c(1.8,6)) +
    x_scale + y_scale +
    labs(x = "Intersections", y = NULL) +
    theme_minimal() +
    no_legend_theme

  # --- (C) Set size barplot (bottom-left) ---
  p_side <- ggplot(set_sizes, aes(x = set_size, y = set)) +
    geom_col(fill = "grey40") +
    geom_text(aes(label = set_size), hjust = -0.2, size = 3) +
    scale_x_reverse(expand = expansion(mult = c(0,0.1))) +
    y_scale +
    theme_minimal() +
    labs(x = "Set size", y = NULL) +
    theme(axis.text.x = element_blank(),
          axis.ticks.x = element_blank()) +
    no_legend_theme

  # --- Empty plot (top-left) ---
  p_empty <- ggplot() + theme_void()

  # --- Extract single merged legend ---
  legend_plot <- ggplot() +
    geom_point(data = present_long,
               aes(x = intersection_id, y = set,
                   color = fraction, size = fraction)) +
    scale_color_viridis_c(limits = c(0,1)) +
    scale_size_continuous(limits = c(0,1), range = c(1.8,6)) +
    labs(color = "Fraction of set", size = "Fraction of set") +
    guides(
      color = guide_legend(title = "Fraction of set"),
      size  = guide_legend(title = "Fraction of set")
    ) +
    theme_minimal()
  legend <- get_legend(legend_plot)

  # --- Assemble layout stepwise ---
  top_row <- plot_grid(p_empty, p_top,
                       ncol = 2, rel_widths = c(1,3),
                       align = "h", axis = "b")
  bottom_row <- plot_grid(p_side, p_matrix,
                          ncol = 2, rel_widths = c(1,3),
                          align = "h", axis = "b")

  final_plot <- plot_grid(top_row, bottom_row,
                          nrow = 2, rel_heights = c(1,3),
                          align = "v", axis = "l")

  final_with_legend <- plot_grid(final_plot, legend,
                                 ncol = 2, rel_widths = c(4,1))

  return(final_with_legend)

        
}
