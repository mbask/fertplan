# Nitrogen ----------------------------------------------------------------
# Apporti di azoto derivanti dalla fertilità del suolo (kg/ha)

# > b1 ----------------------------------------------------------------------

# Coefficient of supply of Nitrogen for a soil texture in table 1
#
# The Nitrogen coefficient has to be applied to the total Nitrogen soil content
# percentage to get soil available Nitrogen (B1)
#
# @param texture Soil texture (one of `r levels(tables_l$tab_01_wdt$soil_texture)`), Guidelines ed. year 2020 page 21, table 2)
#
# @return Nitrogen coefficient
#
# @examples
# \dontrun{ b1_available_n_for("Sabbioso") # Returns 28.4 }
b1_available_n_for <- function(texture) `: numeric` ({

  row_idx <- pmatch(
    x             = texture,
    table         = tables_l$tab_01_wdt[["soil_texture"]],
    duplicates.ok = TRUE)

  tables_l$tab_01_wdt[["available_N_coeff"]][row_idx]
})




# Estimate supply of Nitrogen in the soil for the crop (B1)
#
# @param total_n_pc Total nitrogen percentage in soil
# @param texture    Soil texture (one of `r paste0("``", get_available("soil texture"), "``", collapse = ", ")`)
#
# @return The available N in soil in kg/ha
# @export
# @importFrom ensurer ensure
# @md
# @examples
# b1_available_n(0.139, "Argilloso") # Returns 3.3777 kg/ha
# b1_available_n(c(0.139, 0.5), c("Argilloso", "Franco")) # Returns  3.3777 13.0000
b1_available_n <- function(total_n_pc, texture) `: numeric` ({
  is_soil_texture(texture)
  ensure(total_n_pc, +is_numeric, +is_vector_pc)

  available_n_coeff <- b1_available_n_for(texture)
  total_n_pc * available_n_coeff
})




# > b2 ----------------------------------------------------------------------



# Supply of Nitrogen mineralization in soil (coefficient)
#
# Lookup in table 2 for the coefficient of Nitrogen mineralization in soil
#
# @param cn_ratio    Carbon Nitrogen ratio in soil
# @param texture     Soil texture (one of "Sandy", "Loam", "Clayey", Guidelines ed. year 2020 page 21, table 2)
#
# @return The coefficient of Nitrogen mineralization
mineralized_N_coeff_from <- function(cn_ratio, texture) `: numeric` ({
  # Avoid no visible binding for global variable NOTE
  soil_texture = lower_CNr = upper_CNr = NULL

  unlist(
    tables_l$tab_02_wdt[soil_texture == texture & cn_ratio >= lower_CNr & cn_ratio < upper_CNr, "mineralized_N_coeff"])
})



# Coefficients of Nitrogen mineralization in soil by CN ratios and soil textures
#
# @param cn_ratio    Carbon Nitrogen ratio in soil
# @param texture     Soil texture (one of "Sandy", "Loam", "Clayey", Guidelines ed. year 2020 page 21, table 2)
#
# @return a vector of Nitrogen mineralization coefficients
b2_mineralized_n_coeff_for <- function(cn_ratio, texture) `: numeric` ({

  mineralized_N_coeff_dt <- mapply(
    FUN      = mineralized_N_coeff_from,
    cn_ratio,
    texture,
    SIMPLIFY = FALSE)

  unlist(mineralized_N_coeff_dt)
})


# Supply of Nitrogen mineralized from soil organic matter
#
# Note that values of soil organic matter >3% are kept constant at 3%
#
# @param crop_type    Crop type for estimation of the time coefficient (Guidelines ed. year 2020 page 22 and Table 15.3 page 67)
# @param som_pc       Soil Organic Matter percentage
# @param cn_ratio     Carbon / nitrogen ratio in soil
# @param texture      Soil texture (one of `r paste0("``", get_available("soil texture"), "``", collapse = ", ")`)
#
# @return Quantity of nitrogen in kg/ha
# @export
# @importFrom ensurer ensure
# @md
# @examples
# # Returns 20.7 kg/ha
# b2_mineralized_n("Girasole", 2.3, 9.57, "Argilloso")
b2_mineralized_n <- function(crop_type, som_pc, cn_ratio, texture) `: numeric` ({

  ensurer::ensure(som_pc, +is_numeric, +is_vector_pc)
  is_soil_texture(texture)
  is_character(crop_type)
  is_same_length(c(length(som_pc), length(cn_ratio), length(texture)))

  som_pc[som_pc > 3] <- 3
  time_coeff <- crop_type_lookup(crop_type)
  n_coeff    <- b2_mineralized_n_coeff_for(cn_ratio, texture)

  unname(time_coeff * som_pc * n_coeff)
})



# > b1+b2 -------------------------------------------------------------------

# Supply of Nitrogen from soil fertility
#
# This is component B of the fertilization plan balance, resulting from the available nitrogen in soil and nitrogen mineralized from soil organic matter
#
# @param b1 Available nitrogen in soil, typically from function [b1_available_n()]
# @param b2 Mineralized nitrogen from SOM, typically from function [b2_mineralized_n()]
#
# @return Total nitrogen in soil as the sum of available and mineralized Nitrogen
#         Note that N supply is multipled by -1 before being returned because B has to
#         be subtracted to the total N fertilization!
# @export
# @md
B_N_in_soil <- function(b1, b2) `: numeric` ({
  is_numeric(b1)
  is_numeric(b2)

  -(b1 + b2)
})



# P -----------------------------------------------------------------------

# Supply of Phosphorus from soil fertility
#
# This is component B of the Phosphorus fertilization plan balance.
#
# @note Supply of P is computed by multiplying three components.
# One of the components is P "normal" concentration (mg/kg) in soil that
# is looked up in table 10 of the guidelines (page 32 as of edition 2020).
# Though the tabled concentrations
# are given as ranges per soil texture and crop `fertplan` implementation yields
# the central average value for each range, as an example the tabled normal P
# concentration range for Sunflower in loam soil is \[18,25\] whereas
# a value of 21.5 mg/kg is taken by `fertplan` for further elaboration.
#
# @param crop            One crop or more crops selected from table 10 of the 'Disciplinare' document
# @param p_ppm           Current Phospororus concentration in soil (in ppm or mg/kg)
# @param soil_texture    Soil texture (one of `r paste0("``", get_available("soil texture"), "``", collapse = ", ")`)
# @param soil_depth_cm   Depth of soil tillage in cm (usually 30 or 40 cm)
#
# @return  Total Phospohorus (P2O5) quantity in excess (negative sign) or in demand (positive sign, hence to be supplied)
#          due to its fertility
# @importFrom ensurer ensure
# @importFrom data.table `:=`
# @export
# @md
# @examples
# # Returns 44.85 kg/ha to be supplied by fertilization
# B_P_in_soil(
#   crop  = "Girasole",
#   p_ppm = 10,
#   soil_texture = "Franco",
#   soil_depth   = 30)
# # Returns -33.15 kg/ha soil Phosphorus in excess
# B_P_in_soil(
#   crop  = "Girasole",
#   p_ppm = 30,
#   soil_texture = "Franco",
#   soil_depth   = 30)
# # Keeping soil depth constant:
# B_P_in_soil(
#   c("Girasole", "Barbabietola"),
#   c(20, 30),
#   rep("Franco", 2),
#   30)
B_P_in_soil <- function(crop, p_ppm, soil_texture, soil_depth_cm) {

  ensurer::ensure(crop, +is_character, +is_crop)
  ensurer::ensure(soil_texture, +is_character, +is_soil_texture)

  ensurer::ensure(p_ppm, +is_numeric, +is_positive)
  ensurer::ensure(soil_depth_cm, +is_numeric, +is_positive)
  if (any(soil_depth_cm > 40)) {
    warning("Is soil depth > 40cm correct? Still, continuing...")
  }
  if (any(soil_depth_cm < 30)) {
    warning("Is soil depth < 30cm correct? Still, continuing...")
  }

  # get matching P "normal" quantities by soil texture and crop
  matched_dt <- lookup_var_by_crop_texture(tables_l$tab_10_dt, crop, soil_texture)

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
