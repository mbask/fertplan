data("soils")
data("soils_spatial")
soil_vars <- list(
  crop                 = "Girasole",
  part                 = "Seme",
  expected_yield_kg_ha = 1330L,
  texture              = "Franco",
  crop_type            = "Girasole",
  prev_crop            = "Prati: polifita con meno del 5% di leguminose",
  drainage_rate        = "Lento",
  oct_jan_pr_mm        = 350L,
  n_supply_prev_frt_kg_ha = 0L,
  n_supply_atm_coeff   = 1,
  soil_depth_cm        = 30L,
  crop_class           = "Girasole")

results_l <- list(
  n = c(-23.4051,-28.9015,-27.777,-28.6766,-19.6988,-24.5205,-27.5521,-28.2177,-24.0707,-26.0948,-28.5596,-22.8383,-30.4667,-31.1401,-24.5205,-28.2268,-30.9945,-25.3122,-26.5446,-24.8624),
  p = c(83.9776, 60.0745, 61.654, 60.5425, 19.0504, 58.2025, 59.6065, 56.2408, 60.0745, 74.5864, 60.5425, 74.0677, 74.29, 55.4803, 61.5097, 48.7957, 25.4893, 68.7325, 74.29, 59.3725),
  k = c(-1854.4582, -1332.6616, -1638.289, -2124.7906, -1268.5222, -1168.729, -1263.499, -1609.273, -1228.7032, -1542.9418, -1105.2526, -960.781, -1603.4698, -986.1154, -907.117, -1238.3518, -2069.9722, -1335.454, -1266.5722, -851.854))

# Use soils_spatial dataset to check demand_nutrient output
expect_equal(demand_nutrient(soils, soil_vars, nutrient = "nitrogen")$nitrogen, results_l$n)
expect_equal(demand_nutrient(soils, soil_vars, nutrient = "phosphorus")$phosphorus, results_l$p)
expect_equal(demand_nutrient(soils, soil_vars, nutrient = "potassium")$potassium, results_l$k)

# A variable is missing only for a specific nutrient (phosphorus)
soil_vars$crop_class <- NULL
expect_error(demand_nutrient(soils, soil_vars), "column names: \\[crop_class\\]")
# A basic variable is missing
soil_vars$texture <- NULL
expect_error(demand_nutrient(soils, soil_vars), "column names: \\[texture\\]")
# A soil feature is missing (carbon nitrogen ratio)
soil_vars$texture <- "Franco"
soils[, CNR := NULL]
expect_error(demand_nutrient(soils, soil_vars), "column names: \\[CNR\\]")
# No nutrient given
expect_warning(demand_nutrient(soils, soil_vars, "nitro"), "No nutrient demand to compute")
# At least one correct nutrient name is passed (potassium)
expect_equal(demand_nutrient(soils, soil_vars, c("nitro", "potassium"))$potassium, results_l$k)
