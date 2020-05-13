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


# Available languages -----------------------------------------------------

is_in_avail_langs <-
  ensurer::ensures_that(. %in% i18n_l$avail_langs_v ~"unsupported language.")



# > [0,1] rate ------------------------------------------------------------

is_vector_rates <-
  ensurer::ensures_that(all(. >= 0 & . <= 1) ~ "all rates in vector should be [0,1].")



# > [0,100] percentage -----------------------------------------------------

is_vector_pc <-
  ensurer::ensures_that(all(. >= 0 & . <= 100) ~ "all percentages in vector should be [0,100].")



# > Soil texture ----------------------------------------------------------

is_soil_texture <-
  ensurer::ensures_that(all(. %in% levels(tables_l$tab_01_wdt$soil_texture)) ~ "undefined soil texture.")



# > Fertilizers ----------------------------------------------------------

is_fertilizer <-
  ensurer::ensures_that(all(. %in% levels(tables_l$tab_06_dt$organic_fertilizer)) ~ "undefined organic fertilizer.")



# > Crops -----------------------------------------------------------------

is_crop <-
  ensurer::ensures_that(all(. %in% levels(tables_l$tab_10_dt$crop)) ~ "undefined crop.")



# > Drainage rates -----------------------------------------------------------

is_drainage_rate <-
  ensurer::ensures_that(all(. %in% levels(tables_l$tab_03_dt$drainage)) ~ "undefined crop.")



# Positive numeric --------------------------------------------------------

is_positive <-
  ensurer::ensures_that(all(. > 0) ~ "all values in vector should be > 0.")



# Vectors of same length --------------------------------------------------

is_same_length <-
  ensurer::ensures_that(rle(.)$lengths[1] == length(.) ~ "mismatch between length of vectors.")