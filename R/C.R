# Nitrogen ----------------------------------------------------------------
# Perdite per lisciviazione

# > c1 ----------------------------------------------------------------------
# Metodo in base alle precipitazioni

#' Loss of Nitrogen leached by precipitation
#'
#' Estimates Nitrogen leached by using cumulative precipitation in the period
#' October 1st - January 31st as described on pages 24 and 25 of the "Disciplinare".
#' This is one of two mutually exclusive methods (c1 and c2) to compute Nitrogen leaching,
#' the other being c1 "Metodo in base alla facilità di drenaggio"
#' The leaching affects only the available Nitrogen part (not total Nitrogen)
#'
#' @param available_n      available Nitrogen for the crop, usually returned by \code{\link{b1_available_n}}
#' @param rainfall_oct_jan cumulative precipitation in mm in the 4 months-period October - January
#'
#' @return Nitrogen leaching from soil in the year the precipitation figure is collected, in kg/ha
#' @export
#'
#' @examples
#' # Returns 3.3777 i.e. all available Nitrogen was leached
#' C_N_precip_leach(3.3777, 350)
C_N_precip_leach <- function(available_n, rainfall_oct_jan) {

  stopifnot(is.numeric(available_n))
  stopifnot(length(available_n) == length(rainfall_oct_jan))

  stopifnot(is.numeric(rainfall_oct_jan))

  is_neg_rainfall <- rainfall_oct_jan < 0
  if (sum(is_neg_rainfall > 0)) {
    warning("Unrealistic negative rainfall, assuming 0 mm rainfall")
    rainfall_oct_jan[is_neg_rainfall] <- 0
  }

  n_leached_pc <- leached_n_coeff(rainfall_oct_jan)

  available_n * n_leached_pc
}



# > c2 ----------------------------------------------------------------------
# Metodo in base alla facilità di drenaggio

#' Loss of Nitrogen leached yearly by soil drainage rate and texture
#'
#' Rate of Nitrogren in kg per hactare per year, as in table 3, page 25 of the 'Disciplinare'.
#' This is one of two mutually exclusive methods (c1 and c2) to compute Nitrogen leaching,
#' the other being c1 "Metodo in base alle precipitazioni"
#'
#' @param drainage_rate  Rate of drainage in soil (either "fast", "normal", "slow", "no drainage")
#' @param soil_texture   Soil texture (either "Sandy", "Loam", or "Clayey")
#'
#' @return Nitrogen leaching from soil in kg/ha/y
#' @export
#'
#' @examples
#' # Returns 30 50
#' C_N_drain_leach(c("fast", "slow"), c("Clayey", "Sandy"))
C_N_drain_leach <- function(drainage_rate, soil_texture) {

  stopifnot(is.character(drainage_rate))

  stopifnot(is.character(soil_texture))
  soil_textures = levels(tables_l$tab_03_dt$soil_texture)
  stopifnot(soil_texture %in% soil_textures)

  stopifnot(length(drainage_rate) == length(soil_texture))

  match_dt <- lookup_var_by_drainage_texture(
    tables_l[["tab_03_dt"]],
    drainage_rate,
    soil_texture)

  match_dt$n_leached_kg_ha_y
}



# Phosphorus (P) --------------------------------------------------------------
# Immobilizzazione (C)

#' Loss of Phosphorus due to immobilization from Limestone content
#'
#' Supply of Phosphorus (P2O5) in kg per hactare to counteract immobilization due to limestone
#'
#' @param Ca_pc          Limestone soil content in \% of Cation-exchange capacity
#' @param soil_texture   Soil texture (either "Sandy", "Loam", or "Clayey")
#'
#' @return Phosphorus (P2O5) to be supplied (positive sign) to soil in kg/ha. This is a
#' correction factor that takes into account the unavailable P quantity due to limestone content
#' @export
#'
#' @examples
#' # Returns 3.246
#' C_P_immob_by_Ca(92.3, "Clayey")
C_P_immob_by_Ca <- function(Ca_pc, soil_texture) {
  stopifnot(is.numeric(Ca_pc))
  stopifnot(sum(Ca_pc > 100) == 0)
  stopifnot(sum(Ca_pc <   0) == 0)

  stopifnot(is.character(soil_texture))
  soil_textures = levels(tables_l$C_P_a_coeff_dt$soil_texture)
  stopifnot(soil_texture %in% soil_textures)

  row_idx <- pmatch(
    x             = soil_texture,
    table         = tables_l$C_P_a_coeff_dt[["soil_texture"]],
    duplicates.ok = TRUE)

  a_coeff <- tables_l$C_P_a_coeff_dt[["a_coeff"]][row_idx]
  p_immobilization(a_coeff, Ca_pc)
}
