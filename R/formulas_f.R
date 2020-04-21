# Internal function to compute coefficient of N leaching
#
# This is method c1 (Nitrogen loss due to Rainfall leaching effect). This is described on page 22 of the 2020 guidelines.
#
# @param rainfall Cumulative rainfall between october and january in mm
#
# @return An empirical estimate of the ration of Nitrogen leached due to rainfall
leached_n_coeff <- function(rainfall) {
  # No leaching if rainfall < 150 mm
  rainfall[rainfall < 150] <- 150
  # 100% leaching if rainfall > 250 mm
  rainfall[rainfall > 250] <- 250

  (rainfall - 150) / 100
}

# Internal function to get N from atmospehere or n-fixing bacteria
#
# Page 25 of 2020 Guidelines. Estimate is given in negative sign (ie a flow into the soil)
#
# @param coeff a simple ratio [0..1] to linearly correct the
# estimate, 1 to estimate 20 kg/ha nitrogen, 0 to estimate 0 kg/ha.
#
# @return Estimate of N from atmosphere of from bacteria in kg/ha
natural_n <- function(coeff) {
  -20 * coeff
}


# Internal function to compute P and K availability
#
# No check on function parameters is performed, this is left to
# the package function calling p_immobilization
# For this reason this function is not exported by package.
#
# Ref. Disciplinare, ed. 2020, page 31, 34
#
# @param soil_depth_cm Soil depth in cm. This is the P constant in
#                      'Disciplinare' equation, eg soil depth / 10
# @param Da            Apparent density, depends on soil texture
# @param Q             Delta between "normal" element (P or K)
#                      availability in soil and actual one
#
# @return Nutrient (P or K) supply to the soil (positive sign) or excess (negative sign)
pk_availability <- function(soil_depth_cm, Da, Q) {
  Q * soil_depth_cm / 10 * Da
}



# Internal function to compute P immobilization
#
# No check on function parameters is performed, this is left to
# the package function calling p_immobilization
# For this reason this function is not exported by package.
#
# Ref. Disciplinare, ed. 2020, page 32
#
# @param a_coeff a coefficient, depends on soil texture
# @param Ca_pc   Limestone content in soil (\%)
#
# @return Immobilization factor for Phosphorus
p_immobilization <- function(a_coeff, Ca_pc) {
  a_coeff + (0.02 * Ca_pc)
}



# Internal function to compute K immobilization
#
# No check on function parameters is performed, this is left to
# the package function calling k_immobilization
# For this reason this function is not exported by package.
#
# Ref. Disciplinare, ed. 2020, page 34
#
# @param clay_pc   Clay content in soil (\%)
#
# @return Immobilization factor for Potassium
k_immobilization <- function(clay_pc) {
  1 + (0.018 * clay_pc)
}
