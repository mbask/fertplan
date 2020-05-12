load("R/sysdata.rda")

# A -----------------------------------------------------------------------
# Fabbisogni colturali (kg/ha)


# Look for a crop fertilization absorption or removal of a specific fertilizer
#
# The function does not perform any actual lookup but merely returns a function
# that performs the search on a subset of the Allegato 1 table.
#
# @param abs_or_removal Either "ass." for absorption or "ass." for removal
# @param nutrient       Either "N", "P2OS", or "K2O"
# @return               function
# @importFrom ensurer ensure_that
coef_maker <- function(abs_or_removal, nutrient) {

  correct_ranges_l <- list(
    abs_or_removal     = levels(tables_l$all_01_dt$coeff),
    available_elements = levels(tables_l$all_01_dt$element))

  ensurer::ensure_that(abs_or_removal, . %in% correct_ranges_l$abs_or_removal ~ "incorrect coefficient.")
  ensurer::ensure_that(nutrient, . %in% correct_ranges_l$available_elements ~ "incorrect nutrient.")

  # Avoid no visible binding for global variable NOTE
  element = coeff = NULL

  crop_col_name <- "crop"
  crop_part_col_name <- "part"
  coef_col_name <- "coeff_pc"
  cols_name     <- c(crop_col_name, crop_part_col_name, coef_col_name)

  element_coeff_dt <- subset(
    tables_l$all_01_dt,
    element == nutrient & coeff == abs_or_removal,
    cols_name)

  data.table::setkeyv(
    element_coeff_dt,
    c(crop_col_name, crop_part_col_name))


  function(crops, parts) `: numeric` ({
    is_character(crops)
    is_character(parts)

    coeff_dt <- lookup_var_by_crop_part(element_coeff_dt, crops, parts)

    unmatched_crops_n <- is.na(coeff_dt[[coef_col_name]])
    if (any(unmatched_crops_n)) {
      warning(paste0(sum(unmatched_crops_n), " crops or parts were not matched in the appropriate guidelines table."))
    }
    coeff_dt[[coef_col_name]]
  })
}



#' Demand for the crop (either Nitrogen, and Phosphorus)
#'
#' N and P are estimated from expected yield and crop absorption rate
#'
#' This is component A of the Nitrogen and P2O5 fertilization plan equation
#' resulting as the crop expected yield times crop absorption rate.
#'
#' @param crop_abs        the absorption rate in [0..1] range. It can be looked up as absorption coefficient in the Allegato 1 table and also by using \code{abs_n_coef_of} function for Nitrogen or other similar functions for other nutrients.
#' @param crop_exp_yield  the expected crop yield
#' @return The crop demand in the same unit as \code{crop_exp_yield}, usually kg/ha.
#' @export
#' @importFrom ensurer ensure
#' @examples
#' A_crop_demand(0.4, 1330)
A_crop_demand <- function(crop_abs, crop_exp_yield) `: numeric` ({
  ensurer::ensure(crop_abs, +is_numeric, +is_vector_rates)
  is_numeric(crop_exp_yield)
  # is_same_length(c(length(crop_abs), length(crop_exp_yield)))

  crop_abs * crop_exp_yield
})



# > N ---------------------------------------------------------------------

#' A function to get the Nitrogen absorption coefficient
#'
#' This closure function will use the absorption and removal table
#' to extract the N coefficient for `crops` and `parts` arguments
#'
#' @param crops a character vector of crop names to be looked up
#' @param parts a character vector of crop part names to be looked up. `R` recycling rules apply if number of parts is lower than number of crops
#'
#' @return a real number representing a percentage absorption of Nitrogen for the specific crop or \code{NA_real_} when no match is found or more than one match exists for the given \code{crop}, element and coefficient.
#'
#' @export
#' @md
#' @examples
#' abs_N_coef_of("Ribes", "Pianta")                      # Returns 0.4
#' abs_N_coef_of(c("Ribes", "Girasole"), "Pianta") / 100 # Returns 0.0040 0.0431
abs_N_coef_of <- coef_maker("ass.", "N")


#' A function to get the Nitrogen removal coefficient
#'
#' This closure function will use the absorption and removal table
#' to extract the N coefficient for `crops` and `parts` arguments
#'
#' @param crops a character vector of crop names to be looked up
#' @param parts a character vector of crop part names to be looked up. `R` recycling rules apply if number of parts is lower than number of crops
#'
#' @return a real number representing a percentage removal of Nitrogen for the specific crop or \code{NA_real_} when no match is found or more than one match exists for the given \code{crop}, element and coefficient.
#'
#' @export
#' @md
#' @examples
#' rem_N_coef_of("Ribes", "Frutti")                      # Returns 0.14
#' rem_N_coef_of(c("Ribes", "Girasole"), "Frutti") / 100 # Returns 0.0014 0.0280
rem_N_coef_of <- coef_maker("asp.", "N")




# > K ---------------------------------------------------------------------

#' A function to get the Potassium absorption coefficient
#'
#' This closure function will use the absorption and removal table
#' to extract the K coefficient for `crops` and `parts` arguments
#'
#' @param crops a character vector of crop names to be looked up
#' @param parts a character vector of crop part names to be looked up. `R` recycling rules apply if number of parts is lower than number of crops
#'
#' @return a real number representing a percentage absorption of Potassium for the specific crop or \code{NA_real_} when no match is found or more than one match exists for the given \code{crop}, element and coefficient.
#'
#' @export
#' @md
#' @examples
#' # Returns 1
#' abs_K_coef_of("Ribes", "Pianta")
#' # Returns 0.0100 0.0851
#' abs_K_coef_of(c("Ribes", "Girasole"), "Pianta") / 100
abs_K_coef_of <- coef_maker("ass.", "K2O")


#' A function to get the Potassium removal coefficient
#'
#' This closure function will use the absorption and removal table
#' to extract the N coefficient for `crops` and `parts` arguments
#'
#' @param crops a character vector of crop names to be looked up
#' @param parts a character vector of crop part names to be looked up. `R` recycling rules apply if number of parts is lower than number of crops
#'
#' @return a real number representing a percentage removal of Potassium for the specific crop or \code{NA_real_} when no match is found or more than one match exists for the given \code{crop}, element and coefficient.
#'
#' @export
#' @md
#' @examples
#' # Returns 0.44
#' rem_K_coef_of("Ribes", "Frutti")
#' # Returns 0.0044 0.0115
#' rem_K_coef_of(c("Ribes", "Girasole"), "Frutti") / 100
rem_K_coef_of <- coef_maker("asp.", "K2O")




# > P ---------------------------------------------------------------------

#' A function to get the Phosphorus absorption coefficient
#'
#' This closure function will use the absorption and removal table
#' to extract the N coefficient for `crops` and `parts` arguments
#'
#' @param crops a character vector of crop names to be looked up
#' @param parts a character vector of crop part names to be looked up. `R` recycling rules apply if number of parts is lower than number of crops
#'
#' @return a real number representing a percentage absorption of Phosphorus for the specific crop or \code{NA_real_} when no match is found or more than one match exists for the given \code{crop}, element and coefficient.
#'
#' @export
#' @md
#' @examples
#' # Returns 0.44
#' rem_K_coef_of("Ribes", "Frutti")
#' # Returns 0.0044 0.0115
#' rem_K_coef_of(c("Ribes", "Girasole"), "Frutti") / 100
#' @examples
#' # Returns 0.4
#' abs_P_coef_of("Ribes", "Pianta")
#' # Returns 0.0040 0.0019
#' abs_P_coef_of(c("Ribes", "Girasole"), "Pianta") / 100
abs_P_coef_of <- coef_maker("ass.", "P2O5")


#' A function to get the Phosphorus removal coefficient
#'
#' This closure function will use the absorption and removal table
#' to extract the N coefficient for `crops` and `parts` arguments
#'
#' @param crops a character vector of crop names to be looked up
#' @param parts a character vector of crop part names to be looked up. `R` recycling rules apply if number of parts is lower than number of crops
#'
#' @return a real number representing a percentage removal of Phosphorus for the specific crop or \code{NA_real_} when no match is found or more than one match exists for the given \code{crop}, element and coefficient.
#'
#' @export
#' @md
#' @examples
#' # Returns 0.1
#' rem_P_coef_of("Ribes", "Frutti")
#' # Returns 0.0010 0.0124
#' rem_P_coef_of(c("Ribes", "Girasole"), "Frutti") / 100
rem_P_coef_of <- coef_maker("asp.", "P2O5")
