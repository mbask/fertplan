# Compute potassium demand
#
# This is an internal function not meant to be used by the end-user
# as no checks are performed on its arguments
#
# @param soil_dt   a \code{data.table} of soil samples bound with environmental and crop-related and variables
# @param blnc_cmpt should the individual potassium components or just the nutrient balance itself be returned?
#
# @return a `data.table` object with as many rows as those in \code{soil_dt} and a unique column named `potassium`
demand_potassium <- function(soil_dt, blnc_cmpt) `: dt` ({

  flow_cmpnts_c <- paste(LETTERS[5:8], "K_kg_ha", sep = "_")

  # prevent no visible binding NOTE
  crop <- part <- expected_yield_kg_ha <- K_ppm <- texture <- soil_depth_cm <- NULL
  Clay_pc <- potassium <- E_K_kg_ha <- F_K_kg_ha <- G_K_kg_ha <- H_K_kg_ha<- NULL

  demand_dt <- soil_dt[
    , `:=` (
      E_K_kg_ha              = A_crop_demand(
        crop_abs       = rem_k_coef_of(crop, part) / 100,
        crop_exp_yield = expected_yield_kg_ha),
      F_K_kg_ha              = F_K_in_soil(
        k_ppm         = K_ppm,
        soil_texture  = texture,
        soil_depth_cm = soil_depth_cm),
      G_K_kg_ha              = G_K_immob_by_clay(Clay_pc),
      H_K_kg_ha              = H_K_leaching(Clay_pc)  )]

  fertzl_cols <- grep(
    pattern = "^[A-Z]_K_kg_ha$",
    x       = colnames(demand_dt),
    value   = TRUE)
  ensurer::ensure_that(
    fertzl_cols,
    identical(., flow_cmpnts_c) ~ "some components of potassium balance are missing.")

  if (blnc_cmpt) {
    demand_dt[, fertzl_cols, with = FALSE]
  } else {
    demand_dt[, potassium := E_K_kg_ha + (F_K_kg_ha * G_K_kg_ha) + H_K_kg_ha]
    demand_dt[, "potassium"]
  }
})

