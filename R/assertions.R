# Type-safe assertions ----------------------------------------------------

is_character <-
  ensurer::ensures_that(is.character(.) ~ "vector must be of character type.")

is_numeric <-
  ensurer::ensures_that(is.numeric(.) ~ "vector must be of numeric type.")

is_logical <-
  ensurer::ensures_that(is.logical(.) ~ "expecting a `TRUE` / `FALSE` variable.")

is_list <-
  ensurer::ensures_that(is.list(.) ~ "expecting a list type.")

is_df <-
  ensurer::ensures_that(is.data.frame(.) ~ "table must be a proper data.frame object.")

`: numeric` <-
  ensurer::ensures_that(is.numeric(.) ~ "this function should return a vector numeric type.")

`: function` <-
  ensurer::ensures_that(is.function(.) ~ "this function should return a function.")

`: dt` <-
  ensurer::ensures_that(is.data.table(.) ~ "this function should return a data.table type.")

are_obs_in_table <-
  ensurer::ensures_that(nrow(.) > 0 ~ "table has no observations.")



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


# Nutrient ----------------------------------------------------------------

is_nutrient <-
  ensurer::ensures_that(. %in% c("nitrogen", "phosphorus", "potassium"))



# Ensure a table conforms to a table template ----------------------------

# Check that a \code{data.frame} or \code{data.table} has specific columns,
# types, etc, given in a template. If it does not stop program execution with an error.
#
# \code{ensure_as_template} uses \code{ensurer::ensure_that} in the
# background to ensure conditions for a value "on the fly"
#
# @param x   a \code{data.frame} or \code{data.table} to be checked
# @param tpl a \code{data.frame} as  templated to be used to check \code{x}
#
# @return    the \code{x} value itself on success
ensure_as_template <- function(x, tpl) {
  . <- NULL
  ensurer::ensure_that(
    x,
    is.data.frame(.),
    identical(class(.), class(tpl)),
    identical(sapply(., class), sapply(tpl, class)),
    identical(sapply(., levels), sapply(tpl, levels)),
    err_desc = "inconsistent format, one or more variables do not match the proper type (eg, an integer value required but a numeric given!)")
}


