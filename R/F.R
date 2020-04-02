# F -----------------------------------------------------------------------
# Azoto da fertilizzazioni organiche effettuate negli anni precedenti

#' Supply of Nitrogen from previous organic fertilizatons
#'
#'
#' @param n_supply            Supply of Nitrogen in kg/ha from the organic fertilization performed
#' @param organic_fertilizer  Type of organic fertilizer as found in table 06 ("Bovine manure", "Poultry manure", "Conditioners")
#' @param years_ago           Numeric, the number of years passed from last perfored fertilization
#'
#' @return Estimate of supply of Nitrogen currently still in soil
#' @importFrom data.table `:=`
#' @export
F_N_prev_fertilization <- function(n_supply, organic_fertilizer, years_ago) {

  stopifnot(is.numeric(n_supply))

  no_n_fertln     <- n_supply <= 0
  no_n_fertln_num <- sum(no_n_fertln)

  # Do not do estimate N supply if
  # no n_supply is passed to the function
  if (no_n_fertln_num < length(n_supply)) {

    no_n_fertln     <- n_supply < 0
    no_n_fertln_num <- sum(no_n_fertln)
    if (no_n_fertln_num > 0) {
      warning("Nitrogen supply < 0, assuming 0...")
      n_supply[no_n_fertln] <- 0
    }

    stopifnot(is.numeric(years_ago))
    if (sum(years_ago < 1) > 0) {
      warning("Frequency of fertilization < 1 years, assuming 1...")
      years_ago[years_ago < 1] <- 1
    }

    max_frq <- max(tables_l$tab_06_dt$frequency)
    if (sum(years_ago > max_frq) > 0) {
      warning(paste0("Frequency of fertilization > ", max_frq, " years, assuming ", max_frq, "..."))
      years_ago[years_ago > max_frq] <- max_frq
    }

    stopifnot(is.character(organic_fertilizer))
    fertilizer_levels <- levels(tables_l$tab_06_dt$organic_fertilizer)
    stopifnot(sum(organic_fertilizer %in% fertilizer_levels) > 0)

    stopifnot(length(n_supply)           == length(organic_fertilizer))
    stopifnot(length(organic_fertilizer) == length(years_ago))

    coeff_pc <- NULL

    matched_dt <- lookup_var_by_fertilizer_year(tables_l$tab_06_dt, organic_fertilizer, years_ago)
    matched_dt[, `:=`(supply_kg_ha = -n_supply * coeff_pc / 100)]

    matched_dt$supply_kg_ha
  } else {
    # Return 0 n supply as passed to the function
    n_supply
  }
}

# K -----------------------------------------------------------------------

#' Supply of Potassium from soil fertility
#'
#' This is component F of the Potassium fertilization plan equation
#'
#' @param k_ppm           Current Potassium concentration in soil (in ppm or mg/kg)
#' @param soil_texture    Soil texture (one of "Sandy", "Loam", "Clayey", table 2, page 23 of the 'Disciplinare')
#' @param soil_depth_cm   Depth of soil tillage in cm (usually 30 or 40 cm)
#'
#' @return                Total Potassium (K2O) quantity in excess (negative sign) or in demand (positive sign, hence to be supplied)
#'                        due to its fertility
#' @export
#' @examples
#' # Returns -976.47
#' F_K_in_soil(449, "Clayey", 30)
F_K_in_soil <- function(k_ppm, soil_texture, soil_depth_cm) {
  stopifnot(is.character(soil_texture))
  soil_textures = levels(tables_l$tab_10_dt$soil_texture)
  stopifnot(soil_texture %in% soil_textures)

  stopifnot(is.numeric(soil_depth_cm))
  stopifnot(sum(soil_depth_cm <= 0) == 0)
  if (sum(soil_depth_cm > 40) > 0) {
    warning("Is soil depth > 40cm correct? Still, continuing...")
  }
  if (sum(soil_depth_cm < 30) > 0) {
    warning("Is soil depth < 30cm correct? Still, continuing...")
  }

  stopifnot(is.numeric(k_ppm))
  stopifnot(sum(k_ppm <= 0) == 0)

  apparent_density_v <- get_matching_values(
    soil_texture,
    tables_l$B_PK_appar_dns_dt[["soil_texture"]],
    tables_l$B_PK_appar_dns_dt[["apparent_density"]])

  k_qty_ppm <- get_matching_values(
    soil_texture,
    tables_l$tab_12_dt[["soil_texture"]],
    tables_l$tab_12[["k_qty_ppm"]])

  q <- k_qty_ppm - k_ppm
  pk_availability(
    soil_depth_cm = soil_depth_cm,
    Da            = apparent_density_v,
    Q             = q)
}
