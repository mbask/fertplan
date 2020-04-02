load("R/sysdata.rda")

# A -----------------------------------------------------------------------
# Fabbisogni colturali (kg/ha)

#' Look for a crop fertilization absorption or removal of a specific fertilizer
#'
#' The function does not perform any actual lookup but merely returns a function
#' that performs the search on a subset of the Allegato 1 table.
#'
#' @param abs_or_removal Either "ass." for absorption or "ass." for removal
#' @param nutrient       Either "N", "P2OS", or "K2O"
#' @return               function
coef_maker <- function(abs_or_removal, nutrient) {

  # Avoid no visible binding for global variable NOTE
  element = coeff = NULL

  correct_ranges_l <- list(
    abs_or_removal     = levels(tables_l$all_01_dt$coeff),
    available_elements = levels(tables_l$all_01_dt$element))

  stopifnot(abs_or_removal %in% correct_ranges_l$abs_or_removal)
  stopifnot(nutrient       %in% correct_ranges_l$available_elements)

  crop_col_name <- "crop"
  coef_col_name <- "coeff_pc"
  cols_name     <- c(crop_col_name, coef_col_name)

  element_coeff_dt <- subset(
    tables_l$all_01_dt,
    element == nutrient & coeff == abs_or_removal,
    cols_name)

  # Typical table in element_coeff_dt
  #                                                                    crop coeff_pc
  # 1:                                     Actinidia frutti, legno e foglie     0.59
  # 2:                                     Albicocco frutti, legno e foglie     0.55
  # 3:                                       Arancio frutti, legno e foglie     0.28
  # 4:                                       Asparago verde (pianta intera)     2.56
  # 5:                                                  Avena pianta intera     2.12
  # 6:                                      Ciliegio frutti, legno e foglie     0.67
  # 7:                                    Clementine frutti, legno e foglie     0.28
  # 8:                                                  Colza pianta intera     6.21
  # 9:                                                Farro (pianta intera)     2.70
  # 10:                                                              Favino     4.30
  # 11:                                         Fico frutti, legno e foglie     1.14
  # 12:                                            Girasole (pianta intera)     4.31

  function(crop) {
    stopifnot(!is.null(crop))

    row_idx <- pmatch(
      x             = crop,
      table         = element_coeff_dt[[crop_col_name]],
      duplicates.ok = TRUE)

    if (sum(is.na(row_idx)) > 0) {
      warning("Crop not found in Allegato 1")
    }
    element_coeff_dt[[coef_col_name]][row_idx]
  }
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
#' @examples
#' A_crop_demand(0.4, 1330)
A_crop_demand <- function(crop_abs, crop_exp_yield) {
  stopifnot(!is.null(crop_abs))
  stopifnot(!is.null(crop_exp_yield))

  stopifnot(length(crop_abs) == length(crop_exp_yield))


  stopifnot(is.numeric(crop_abs))
  stopifnot(is.numeric(crop_exp_yield))

  stopifnot(crop_abs >= 0 & crop_abs <= 1)

  crop_abs * crop_exp_yield
}



# > N ---------------------------------------------------------------------



#' A function to get the Nitrogen absorption coefficient
#'
#' function abs_N_coef_of
#'
#' This closure function will use the subset Allegato 1 table
#' to perform a partial matching of its "crop" argument
#'
#' @param crop the crop to be looked up
#'
#' @return a real number representing a percentage absorption of Nitrogen for the specific crop or \code{NA_real_} when no match is found or more than one match exists for the given \code{crop}, element and coefficient.
#'
#' @export
#' @examples
#' abs_N_coef_of("Ribes")                      # Returns 0.4
#' abs_N_coef_of(c("Ribes", "Girasole")) / 100 # Returns 0.0040 0.0431
abs_N_coef_of <- coef_maker("ass.", "N")


#' A function to get the Nitrogen removal coefficient
#'
#' function rem_N_coef_of
#'
#' This closure function will use the subset Allegato 1 table
#' to perform a partial matching of its "crop" argument
#'
#' @param crop the crop to be looked up
#'
#' @return a real number representing a percentage removal of Nitrogen for the specific crop or \code{NA_real_} when no match is found or more than one match exists for the given \code{crop}, element and coefficient.
#'
#' @export
#' @examples
#' rem_N_coef_of("Ribes")                      # Returns 0.14
#' rem_N_coef_of(c("Ribes", "Girasole")) / 100 # Returns 0.0014 0.0280
rem_N_coef_of <- coef_maker("asp.", "N")




# > K ---------------------------------------------------------------------

#' A function to get the Potassium absorption coefficient
#'
#' function abs_K_coef_of
#'
#' This closure function will use the subset Allegato 1 table
#' to perform a partial matching of its "crop" argument
#'
#' @param crop the crop to be looked up
#'
#' @return a real number representing a percentage absorption of Potassium (K2O) for the specific crop or \code{NA_real_} when no match is found or more than one match exists for the given \code{crop}, element and coefficient.
#'
#' @export
#' @examples
#' # Returns 1
#' abs_K_coef_of("Ribes")
#' # Returns 0.0100 0.0851
#' abs_K_coef_of(c("Ribes", "Girasole")) / 100
abs_K_coef_of <- coef_maker("ass.", "K2O")


#' A function to get the Potassium removal coefficient
#'
#' function rem_K_coef_of
#'
#' This closure function will use the subset Allegato 1 table
#' to perform a partial matching of its "crop" argument
#'
#' @param crop the crop to be looked up
#'
#' @return a real number representing a percentage removal of Potassium (K2O) for the specific crop or \code{NA_real_} when no match is found or more than one match exists for the given \code{crop}, element and coefficient.
#'
#' @export
#' @examples
#' # Returns 0.44
#' rem_K_coef_of("Ribes")
#' # Returns 0.0044 0.0115
#' rem_K_coef_of(c("Ribes", "Girasole")) / 100
rem_K_coef_of <- coef_maker("asp.", "K2O")




# > P ---------------------------------------------------------------------

#' A function to get the Phosphorus absorption coefficient
#'
#' function abs_P_coef_of
#'
#' This closure function will use the subset Allegato 1 table
#' to perform a partial matching of its "crop" argument
#'
#' @param crop the crop to be looked up
#'
#' @return a real number representing a percentage absorption of Phosphorus (P2O5) for the specific crop or \code{NA_real_} when no match is found or more than one match exists for the given \code{crop}, element and coefficient.
#'
#' @export
#' @examples
#' # Returns 0.4
#' abs_P_coef_of("Ribes")
#' # Returns 0.0040 0.0019
#' abs_P_coef_of(c("Ribes", "Girasole")) / 100
abs_P_coef_of <- coef_maker("ass.", "P2O5")


#' A function to get the Phosphorus removal coefficient
#'
#' function rem_P_coef_of
#'
#' This closure function will use the subset Allegato 1 table
#' to perform a partial matching of its "crop" argument
#'
#' @param crop the crop to be looked up
#'
#' @return a real number representing a percentage removal of Phosphorus (P2O5) for the specific crop or \code{NA_real_} when no match is found or more than one match exists for the given \code{crop}, element and coefficient.
#'
#' @export
#' @examples
#' # Returns 0.1
#' rem_P_coef_of("Ribes")
#' # Returns 0.0010 0.0124
#' rem_P_coef_of(c("Ribes", "Girasole")) / 100
rem_P_coef_of <- coef_maker("asp.", "P2O5")



