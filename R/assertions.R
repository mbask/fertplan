ensure_character <-
  ensurer::ensures_that(is.character(.) ~ "vector must be of character type.")

ensure_numeric <-
  ensurer::ensures_that(is.numeric(.) ~ "vector must be of numeric type.")

# ensure_is_rate <-
#   ensurer::ensures_that(. >= 0 & . <= 1 ~ "a rate range is [0,1].")

ensure_is_vector_of_rates <-
  ensurer::ensures_that(all(. >= 0 & . <= 1) ~ "all rates in vector should be [0,1].")
