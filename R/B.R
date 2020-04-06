# Nitrogen ----------------------------------------------------------------
# Apporti di azoto derivanti dalla fertilità del suolo (kg/ha)

# > b1 ----------------------------------------------------------------------

#' Coefficient of supply of Nitrogen for a soil texture in table 1
#'
#' The Nitrogen coefficient has to be applied to the total Nitrogen soil content
#' percentage to get soil available Nitrogen (B1)
#'
#' @param texture Soil texture (one of "Sandy", "Loam", "Clayey", Guidelines ed. year 2020 page 21, table 2)
#'
#' @return Nitrogen coefficient
#'
#' @examples
#' \dontrun{ b1_available_n_for("Sandy") # Returns 28.4 }
b1_available_n_for <- function(texture) {
  stopifnot(!is.null(texture))

  soil_textures = levels(tables_l$tab_01_wdt$soil_texture)
  stopifnot(texture %in% soil_textures)

  row_idx <- pmatch(
    x             = texture,
    table         = tables_l$tab_01_wdt[["soil_texture"]],
    duplicates.ok = TRUE)

  tables_l$tab_01_wdt[["available_N_coeff"]][row_idx]
}




#' Estimate supply of Nitrogen in the soil for the crop (B1)
#'
#'
#' @param total_n_pc Total Nitrogen percentage in soil as appropriatly sampled
#' @param texture    Soil texture from table 1 (one of "Sandy", "Loam", "Clayey") as appropriatly sampled
#'
#' @return The available N in soil in kg/ha
#' @export
#'
#' @examples
#' b1_available_n(0.139, "Clayey")                    # Returns 3.3777 kg/ha
#' b1_available_n(c(0.139, 0.5), c("Clayey", "Loam")) # Returns  3.3777 13.0000
b1_available_n <- function(total_n_pc, texture) {
  stopifnot(!is.null(total_n_pc))
  stopifnot(is.numeric(total_n_pc))
  stopifnot(total_n_pc <= 100)
  stopifnot(total_n_pc > 0)
  stopifnot(length(total_n_pc) == length(texture))

  available_n_coeff <- b1_available_n_for(texture)
  total_n_pc * available_n_coeff
}




# > b2 ----------------------------------------------------------------------



#' Supply of Nitrogen mineralization in soil (coefficient)
#'
#' Lookup in table 2 for the coefficient of Nitrogen mineralization in soil
#'
#' @param cn_ratio    Carbon Nitrogen ratio in soil
#' @param texture     Soil texture (one of "Sandy", "Loam", "Clayey", Guidelines ed. year 2020 page 21, table 2)
#'
#' @return The coefficient of Nitrogen mineralization
mineralized_N_coeff_from <- function(cn_ratio, texture) {
  # Avoid no visible binding for global variable NOTE
  soil_texture = lower_CNr = upper_CNr = NULL

  tables_l$tab_02_wdt[soil_texture == texture & cn_ratio >= lower_CNr & cn_ratio < upper_CNr, "mineralized_N_coeff"]
  # subset(
  #   tables_l$tab_02_wdt,
  #   soil_texture == texture & cn_ratio >= lower_CNr & cn_ratio < upper_CNr,
  #   "mineralized_N_coeff")
}

#' Coefficients of Nitrogen mineralization in soil by CN ratios and soil textures
#'
#' @param cn_ratio    Carbon Nitrogen ratio in soil
#' @param texture     Soil texture (one of "Sandy", "Loam", "Clayey", Guidelines ed. year 2020 page 21, table 2)
#'
#' @return a vector of Nitrogen mineralization coefficients
b2_mineralized_n_coeff_for <- function(cn_ratio, texture) {

  mineralized_N_coeff_dt <- mapply(
    FUN      = mineralized_N_coeff_from,
    cn_ratio,
    texture,
    SIMPLIFY = FALSE)

  unlist(mineralized_N_coeff_dt)
}


#' Time coefficient for organic matter mineralization
#'
#' Used internally by \code{\link{b2_mineralized_n}}
#'
#' @param crop_type Crop type for estimation of the time coefficient (Guidelines ed. year 2020 page 22 and Table 15.3 page 67)
#'
#' @return The time coefficient
crop_type_lookup <- function(crop_type) {
  row_idx    <- pmatch(
    x             = crop_type,
    table         = tables_l$all_02_dt[["crop_type"]],
    duplicates.ok = TRUE)
  time_coeff <- tables_l$all_02_dt[["time_coeff"]][row_idx]

  if (sum(is.na(time_coeff)) > 0) {
    warning("No crop type found in 15.3 table of the 2020 guidelines, assuming time coefficient = 1 (multiannual crop)")
    time_coeff[is.na(time_coeff)] <- 1
  }
  time_coeff
}



#' Supply of Nitrogen mineralized from soil organic matter
#'
#' Note that values of soil organic matter >3% are kept constant at 3%
#'
#' @param crop_type    Crop type for estimation of the time coefficient (Guidelines ed. year 2020 page 22 and Table 15.3 page 67)
#' @param som_pc       Soil Organic Matter percentage
#' @param cn_ratio     Carbon Nitrogen ratio in soil
#' @param texture      Soil texture (one of "Sandy", "Loam", "Clayey", Guidelines ed. year 2020 page 21, table 2)
#'
#' @return Quantity of Nitrogen in kg/ha
#' @export
#'
#' @examples
#' # Returns 20.7 kg/ha
#' b2_mineralized_n("Girasole", 2.3, 9.57, "Clayey")
b2_mineralized_n <- function(crop_type, som_pc, cn_ratio, texture) {
  stopifnot(!is.null(crop_type))
  stopifnot(!is.null(som_pc))
  stopifnot(!is.null(texture))
  stopifnot(!is.null(cn_ratio))

  stopifnot(length(som_pc) == length(cn_ratio))
  stopifnot(length(cn_ratio) == length(texture))

  stopifnot(som_pc <= 100)
  stopifnot(som_pc > 0)

  soil_textures = levels(tables_l$tab_02_wdt$soil_texture)
  stopifnot(texture %in% soil_textures)

  som_pc[som_pc > 3] <- 3
  time_coeff <- crop_type_lookup(crop_type)
  n_coeff    <- b2_mineralized_n_coeff_for(cn_ratio, texture)

  unname(time_coeff * som_pc * n_coeff)
}



# > b1+b2 -------------------------------------------------------------------

#' Supply of Nitrogen from soil fertility
#'
#' This is component B of the fertilization plan equation, resulting from the available nitrogen in soil and nitrogen mineralized from soil organic matter
#'
#' @param b1 Available Nitrogen in soil, typically from function \code{b1_available_n}
#' @param b2 Mineralized Nitrogen from SOM, typically from function \code{b2_mineralized_n}
#'
#' @return Total Nitrogen in soil as the sum of available and mineralized Nitrogen
#'         Note that N supply is multipled by -1 before being returned because B has to
#'         be subtracted to the total N fertilization!
#' @export
B_N_in_soil <- function(b1, b2) {
  stopifnot(!is.null(b1))
  stopifnot(!is.null(b2))

  stopifnot(is.numeric(b1))
  stopifnot(is.numeric(b2))

  -(b1 + b2)
}



# P -----------------------------------------------------------------------

#' Supply of Phosphorus from soil fertility
#'
#' This is component B of the Phosphorus fertilization plan equation
#'
#' @param crop            One crop or more crops selected from table 10 of the 'Disciplinare' document
#' @param p_ppm           Current Phospororus concentration in soil (in ppm or mg/kg)
#' @param soil_texture    Soil texture (one of "Sandy", "Loam", "Clayey", Guidelines ed. year 2020 page 21, table 2)
#' @param soil_depth_cm   Depth of soil tillage in cm (usually 30 or 40 cm)
#'
#' @return                Total Phospohorus (P2O5) quantity in excess (negative sign) or in demand (positive sign, hence to be supplied)
#'                        due to its fertility
#' @export
#' @importFrom data.table `:=`
#' @examples
#' # Returns 44.85 kg/ha to be supplied by fertilization
#' B_P_in_soil(
#'   crop  = "Girasole",
#'   p_ppm = 10,
#'   soil_texture = "Loam",
#'   soil_depth   = 30)
#' # Returns -33.15 kg/ha soil Phosphorus in excess
#' B_P_in_soil(
#'   crop  = "Girasole",
#'   p_ppm = 30,
#'   soil_texture = "Loam",
#'   soil_depth   = 30)
#' # Keeping soil depth constant:
#' B_P_in_soil(
#'   c("Girasole", "Barbabietola"),
#'   c(20, 30),
#'   c("Loam", "Loam"),
#'   30)
B_P_in_soil <- function(crop, p_ppm, soil_texture, soil_depth_cm) {

  stopifnot(is.character(crop))
  crops = levels(tables_l$tab_10_dt$crop)
  stopifnot(crop %in% crops)

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

  stopifnot(is.numeric(p_ppm))
  stopifnot(sum(p_ppm <= 0) == 0)

  # get matching P "normal" quantities by soil texture and crop
  matched_dt <- lookup_var_by_crop_texture(tables_l$tab_10_dt, crop, soil_texture)

  # get matching apparent density by soil texture
  # appar_dns_dt <- data.table::data.table(
  #   soil_texture = soil_texture)
  # data.table::setindexv(appar_dns_dt, "soil_texture")
  # matched_s_txtrs_dt <- tables_l$B_P_appar_dns_dt[appar_dns_dt, on = "soil_texture"]
  # if (nrow(matched_dt) != nrow(matched_s_txtrs_dt)) {
  #   stop("Mismatch between matched tables in B_P_in_soil function, stopping.")
  # }

  # Match apparent density table to P quantity table
  p_dns_dt <- tables_l$B_PK_appar_dns_dt[matched_dt, on = "soil_texture"]

  p_qty_ppm <- apparent_density <- NULL

  # Compute B quantity as P x Da x Q
  # where:
  # P   = soil depth / 10
  # Da  = soil apparent density
  # Q   = "normal P quantity" - current P quantity
  p_dns_dt[
    , `:=` (q = p_qty_ppm - p_ppm)][
    , `:=` (b_kg_ha = pk_availability(soil_depth_cm, apparent_density, q))]

  p_dns_dt$b_kg_ha
}
