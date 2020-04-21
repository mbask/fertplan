# Type-safe assertions ----------------------------------------------------

is_character <-
  ensurer::ensures_that(is.character(.) ~ "vector must be of character type.")

is_numeric <-
  ensurer::ensures_that(is.numeric(.) ~ "vector must be of numeric type.")

`: numeric` <-
  ensurer::ensures_that(is.numeric(.) ~ "this function should return a vector numeric type.")

`: function` <-
  ensurer::ensures_that(is.function(.) ~ "this function should return a function.")



# Package-wide assertions -------------------------------------------------

# > [0,1] rate ------------------------------------------------------------

is_vector_rates <-
  ensurer::ensures_that(all(. >= 0 & . <= 1) ~ "all rates in vector should be [0,1].")



# > [0,100] percentage -----------------------------------------------------

is_vector_pc <-
  ensurer::ensures_that(all(. >= 0 & . <= 100) ~ "all percentages in vector should be [0,100].")



# > Soil texture ----------------------------------------------------------

is_soil_texture <-
  ensurer::ensures_that(all(. %in% assert_params_l$soil_textures) ~ "undefined soil texture.")



# > Fertilizers ----------------------------------------------------------

is_fertilizer <-
  ensurer::ensures_that(all(. %in% assert_params_l$fertilizers) ~ "undefined organic fertilizer.")



# > Crops -----------------------------------------------------------------

is_crop <-
  ensurer::ensures_that(all(. %in% assert_params_l$crops) ~ "undefined crop.")



# > Drainage rates -----------------------------------------------------------

is_drainage_rate <-
  ensurer::ensures_that(all(. %in% assert_params_l$drainage_rates) ~ "undefined crop.")



# Positive numeric --------------------------------------------------------

is_positive <-
  ensurer::ensures_that(all(. > 0) ~ "all values in vector should be > 0.")



# Vectors of same length --------------------------------------------------

is_same_length <-
  ensurer::ensures_that(rle(.)$lengths[1] == length(.) ~ "mismatch between length of vectors.")
