# D ----------------------------------------------------------------------
# Perdite per immobilizzazione e dispersione

#' Loss of Nitrogen with denitrification, adsorbation, volatilization
#'
#' Coefficient of Nitrogen denitrification, adsorbation, volatilization processes in soil,
#' as found in page 25 of the "Disciplinare".
#'
#' @param B              Nitrogen supply from soil fertility estimate, usually derived with function \code{\link{B_N_in_soil}}
#' @param drainage_rate  Rate of drainage in soil (either "fast", "normal", "slow", "no drainage")
#' @param soil_texture   Soil texture (either "Sandy", "Loam", or "Clayey")
#'
#' @return Nitrogen denitrification coefficient
#'
#' @export
#' @examples
#' \dontrun{ D_N_denitrification(30.98, "slow", "Clayey")  # Returns 13.941 }
D_N_denitrification <- function(B, drainage_rate, soil_texture) {

  stopifnot(is.numeric(B))
  stopifnot(is.character(drainage_rate))

  stopifnot(is.character(soil_texture))
  soil_textures = levels(tables_l$tab_04_dt$soil_texture)
  stopifnot(soil_texture %in% soil_textures)

  stopifnot(length(drainage_rate) == length(soil_texture))
  stopifnot(length(drainage_rate) == length(B))

  match_dt <- lookup_var_by_drainage_texture(
    tables_l[["tab_04_dt"]],
    drainage_rate,
    soil_texture)

  if (sum(is.na(match_dt[["n_denitrificated_coeff"]]))) {
    warning("One or more drainage/soil_texture pairs did not match table 04 (N denitrification), returning NA value")
  }

  # note that B has sign inverted
  -B * match_dt[["n_denitrificated_coeff"]]
}