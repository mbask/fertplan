# G -----------------------------------------------------------------------
# Azoto da apporti naturali

#' Supply of Nitrogen from atmosphere or from nitrogen-fixing bacteria
#'
#' Yearly availability is estimated to be 20 kg/ha in levelled crops close
#' to urban settlements. This figure has to be appropriately adapted
#' to each crop through a [0..1] coefficient. Page 25 of 2020 Guidelines.
#' Note that the N estimate is given in negative sign (ie a flow into the soil).
#'
#'
#' @param coeff a simple ratio [0..1] to linearly correct the
#' estimate, 1 to estimate 20 kg/ha nitrogen, 0 to estimate 0 kg/ha.
#'
#' @return Estimate of N from atmosphere of from bacteria in kg/ha
#' @export
#' @importFrom ensurer ensure
#' @examples
#' # Returns -10 kg/ha
#' G_N_from_atmosphere(0.5)
G_N_from_atmosphere <- function(coeff) `: numeric` ({
  ensurer::ensure(coeff, +is_numeric, +is_vector_rates)
  natural_n(coeff)
})



# Potassium (K) --------------------------------------------------------------
# Immobilizzazione

#' Loss of Potassium due to immobilization from Limestone content
#'
#' Supply of Potassium (K2O) in kg per hactare to counteract immobilization due to Clay
#'
#' @param clay_pc     Clay content in soil in \%
#'
#' @return Potassium (K2O) to be supplied (positive sign) to soil in kg/ha. This is a
#' correction factor that takes into account the unavailable K quantity due to clay content
#' @export
#' @importFrom ensurer ensure
#' @examples
#' # Returns 1.72 kg/ha
#' G_K_immob_by_clay(40)
G_K_immob_by_clay <- function(clay_pc) `: numeric` ({
  ensurer::ensure(clay_pc, +is_numeric, +is_vector_pc)
  k_immobilization(clay_pc)
})
