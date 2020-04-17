ensure_character <-
  ensurer::ensures_that(is.character(.) ~ "vector must be of character type.")

ensure_numeric <-
  ensurer::ensures_that(is.numeric(.) ~ "vector must be of numeric type.")

`: numeric` <-
  ensurer::ensures_that(is.numeric(.) ~ "this function should return a vector numeric type.")

`: function` <-
  ensurer::ensures_that(is.function(.) ~ "this function should return a function.")


ensure_vector_rates <-
  ensurer::ensures_that(all(. >= 0 & . <= 1) ~ "all rates in vector should be [0,1].")
