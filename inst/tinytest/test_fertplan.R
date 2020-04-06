
# A tests -----------------------------------------------------------------

# Allegato 1 lookup tests
expect_equal(abs_N_coef_of("Ribes"), 0.4)
expect_equal(abs_N_coef_of("Actinidia"), 0.59)
expect_equal(rem_N_coef_of("Ribes"), 0.14)
expect_equal(rem_N_coef_of("Actinidia"), 0.15)
expect_equal(abs_N_coef_of(c("Triticale pianta intera", "Lampone biomassa epigea")), c(2.54, 0.3))
expect_equal(abs_N_coef_of(c("Triticale pianta intera", "Triticale pianta intera")), c(2.54, 2.54))
expect_equal(rem_K_coef_of("Ribes"), 0.44)
expect_equal(abs_K_coef_of(c("Ribes", "Girasole")), c(1, 8.51))
expect_equal(rem_P_coef_of("Ribes"), 0.1)
expect_equal(abs_P_coef_of(c("Ribes", "Girasole")), c(0.4, 1.9))

# Expect a warning when a lookup fails
expect_warning(abs_N_coef_of("Rosa purpurea del Cairo"), "Crop not found in Allegato 1")
expect_warning(rem_N_coef_of(c("Ribes", "Rosa purpurea del Cairo")), "Crop not found in Allegato 1")

# Expect NA for those crop failed lookups
expect_true(is.na(abs_N_coef_of("Rosa purpurea del Cairo")))
expect_true(is.na(rem_N_coef_of(c("Ribes", "Rosa purpurea del Cairo"))[2]))

# Expect correct results
expect_equal(A_crop_demand(0.028, 1330), 37.24)
expect_equal(A_crop_demand(c(0.028, 0.1), c(1330, 2000)), c(37.24, 200.0))

# Expect errors
expect_error(A_crop_demand(1.1, 33), "crop_abs >= 0 & crop_abs <= 1")
expect_error(A_crop_demand("0.2", 33), "is.numeric\\(crop_abs\\)")
expect_error(A_crop_demand(0.2, "33"), "is.numeric\\(crop_exp_yield\\)")
expect_error(A_crop_demand(c(0.2, 0.3), 33))
expect_error(A_crop_demand(0.3, c(33, 334)))



# B tests -----------------------------------------------------------------

expect_equal(b1_available_n(0.139, "Clayey"), 3.3777)
expect_equal(b1_available_n(c(0.139, 0.165), c("Clayey", "Clayey")), c(3.3777, 4.0095))
expect_equal(b1_available_n(c(0.139, 1), c("Clayey", "Sandy")), c(3.3777, 28.4000))
expect_equal(b1_available_n(c(1, 0.139), c("Sandy", "Clayey")), c(28.4000, 3.3777))
expect_error(b1_available_n("2"))
expect_error(b1_available_n(102))
expect_error(b1_available_n("Sandy"))

expect_warning(b2_mineralized_n("Girasolee", 2.3, 9.57, "Clayey"), "No crop type found")
expect_equal(b2_mineralized_n("Girasolee", 2.3, 9.57, "Clayey"), 27.6)
expect_equal(b2_mineralized_n("Girasole", 2.3, 9.57, "Clayey"), 20.7)
expect_warning(b2_mineralized_n(c("Girasole", "Girasolee"), c(2.3, 2.3), c(9.57, 9.57), c("Clayey", "Clayey")), "No crop type found")
expect_equal(b2_mineralized_n(c("Girasole", "Girasolee"), c(2.3, 2.3), c(9.57, 9.57), c("Clayey", "Clayey")), c(20.7, 27.6))

expect_equal(B_N_in_soil(3.3777, 20.7), -24.0777)
expect_error(B_N_in_soil("2", 20.7), "is.numeric\\(b1\\)")
expect_error(B_N_in_soil(2, "20.7"), "is.numeric\\(b2\\)")
expect_error(B_N_in_soil(NA, 20.7), "is.numeric\\(b1\\)")

expect_equal(B_P_in_soil("Girasole", 30, "Loam", 30), -33.15)
expect_equal(B_P_in_soil(c("Girasole", "Barbabietola"), c(30, 30), c("Loam", "Loam"), 30), c(-33.15, 17.55))
expect_equal(B_P_in_soil(c("Barbabietola", "Girasole"), c(30, 30), c("Loam", "Clayey"), 30), c(17.55, -12.705))
expect_equal(B_P_in_soil(c("Girasole", "Barbabietola", "Arboree"), c(30, 30, 40), c("Loam", "Loam", "Clayey"), c(30, 30, 40)), c(-33.15, 17.55, -16.94))

expect_error(B_P_in_soil("Girasolee", 30, "Loam", 30))
expect_error(B_P_in_soil("Girasole", 30, "Loamy", 30))
expect_error(B_P_in_soil("Girasole", 0, "Clayey", 30))
expect_error(B_P_in_soil("Girasole", 20, "Clayey", 0))
expect_warning(B_P_in_soil("Girasole", 30, "Loam", 50), "Is soil depth > 40cm correct?")
expect_warning(B_P_in_soil("Girasole", 30, "Loam", 20), "Is soil depth < 30cm correct?")



# C tests -----------------------------------------------------------------

expect_equal(C_N_drain_leach("slow", "Clayey"), 50)
expect_equal(C_N_drain_leach(c("fast", "slow"), c("Clayey", "Sandy")), c(30, 50))
expect_equal(C_N_drain_leach(c("slow", "fast", "slow"), c("Sandy", "Clayey", "Clayey")), c(50, 30, 50))
expect_error(C_N_drain_leach(c("fast", "slow"), c("Clayey", "Sandi")))

expect_equal(C_N_precip_leach(3.3777, 350), 3.3777)
expect_equal(C_N_precip_leach(c(3.3777, 50), c(350, 200)), c(3.3777, 25))
expect_error(C_N_precip_leach(c(3.3777, 50), c(350)), "length\\(available_n\\) == length\\(rainfall_oct_jan\\) is not TRUE")
expect_error(C_N_precip_leach("3.3777", 350), "is.numeric\\(available_n\\) is not TRUE")
expect_warning(C_N_precip_leach(10, -10), "Unrealistic negative rainfall, assuming 0 mm rainfall")
expect_equal(C_N_precip_leach(3.3777, -350), 0)
expect_warning(C_N_precip_leach(c(10, 20), c(50, -10)), "Unrealistic negative rainfall, assuming 0 mm rainfall")

expect_equal(C_P_immob_by_Ca(92.3, "Clayey"), 3.246)
expect_equal(C_P_immob_by_Ca(c(56, 92.3, 93), "Clayey"), c(2.520, 3.246, 3.260))
expect_equal(C_P_immob_by_Ca(c(56, 92.3, 93), c("Clayey", "Sandy", "Sandy")), c(2.520, 3.046, 3.060))
# soil_texture is recycled with warning
expect_equal(C_P_immob_by_Ca(c(56, 92.3, 93), c("Clayey", "Sandy")), c(2.520, 3.046, 3.260))
expect_warning(C_P_immob_by_Ca(c(56, 92.3, 93), c("Clayey", "Sandy")), "longer object length is not a multiple of shorter object length")
# Ca_pc should be a percentage
expect_error(C_P_immob_by_Ca(150, "Sandy"), "sum\\(Ca_pc > 100\\) == 0 is not TRUE")
# soil_texture not found
expect_error(C_P_immob_by_Ca(50, "Sandi"), "soil_texture %in% soil_textures is not TRUE")



# D tests -----------------------------------------------------------------

expect_equal(D_N_denitrification(-30.98, "slow", "Clayey"), 13.941)
expect_equal(D_N_denitrification(c(-30.98, -25), c("normal", "slow"), c("Clayey", "Sandy")), c(9.294, 7.5))
expect_equal(D_N_denitrification(c(-25, -30.98), c("slow", "normal"), c("Sandy", "Clayey")), c(7.5, 9.294))
expect_error(D_N_denitrification(c(-30.98), c("normal", "slow"), c("Clayey", "Sandi")), "soil_texture %in% soil_textures are not all TRUE")
expect_error(D_N_denitrification(c(-30.98, -25), c("slow"), c("Clayey", "Sandy")), "length\\(drainage_rate\\) == length\\(soil_texture\\) is not TRUE")
expect_error(D_N_denitrification(c(-30.98, -25), c("normal", "slow"), c("Clayey")), "length\\(drainage_rate\\) == length\\(soil_texture\\) is not TRUE")
expect_error(D_N_denitrification(c(-30.98, "-25"), c("normal", "slow"), c("Clayey", "Clayey")), "is.numeric\\(B\\) is not TRUE")



# E tests -----------------------------------------------------------------

expect_equal(E_N_from_prev_crop("Girasole"), 0)
expect_error(E_N_from_prev_crop(Girasole), "object 'Girasole' not found")
expect_equal(E_N_from_prev_crop(c("Girasole", "Patata")), c(0, -35))
expect_equal(E_N_from_prev_crop(c("Gira", "Pata")), c(0, -35))
expect_equal(E_N_from_prev_crop(c("Gira", "Prati")), c(0, NA))
expect_warning(E_N_from_prev_crop(c("Gira", "Prati")), "one or more crops did not uniquely match table 05 crops")



# F tests -----------------------------------------------------------------

expect_equal(F_N_prev_fertilization(30, "Bovine manure", 2), -4.5)
expect_equal(F_N_prev_fertilization(c(30, 30), c("Swine and poultry manure", "Bovine manure"), c(3, 3)), c(-1.5, -3.0))

expect_error(F_N_prev_fertilization(c(30, 45), "Bovine manure", 2), "length\\(n_supply\\) == length\\(organic_fertilizer\\) is not TRUE")
expect_error(F_N_prev_fertilization(30, c("Bovine manure", "Bovine manure"), 2), "length\\(n_supply\\) == length\\(organic_fertilizer\\) is not TRUE")
expect_error(F_N_prev_fertilization(30, "Bovine manure", c(2, 1)), "length\\(organic_fertilizer\\) == length\\(years_ago\\) is not TRUE")

expect_equal(F_N_prev_fertilization(0), 0)

expect_equal(F_N_prev_fertilization(c(30, -10), c("Bovine manure", "Bovine manure"), c(2, 2)), c(-4.5, 0.0))
expect_warning(F_N_prev_fertilization(c(30, -10), c("Bovine manure", "Bovine manure"), c(2, 2)), "Nitrogen supply < 0, assuming 0")

expect_equal(F_N_prev_fertilization(c(30, 10), c("Bovine manure", "Bovine manure"), c(-2, 2)), c(-9, -1.5))
expect_warning(F_N_prev_fertilization(c(30, 10), c("Bovine manure", "Bovine manure"), c(-2, 2)), "Frequency of fertilization < 1 years, assuming 1")

expect_equal(F_N_prev_fertilization(c(30, 30), c("Bovine manure", "Bovine manure"), c(4, 3)), c(-3, -3))
expect_warning(F_N_prev_fertilization(c(30, 30), c("Bovine manure", "Bovine manure"), c(4, 3)), "Frequency of fertilization > 3 years, assuming 3")

expect_error(F_N_prev_fertilization(30, Bovine, 2))
expect_error(F_N_prev_fertilization(30, "Bovina manure", 2))


expect_equal(F_K_in_soil(449, "Clayey", 30), -976.47)
expect_equal(F_K_in_soil(180, "Clayey", 30), 0)
expect_equal(F_K_in_soil(449, "Loam", 30), -1166.1)
expect_equal(F_K_in_soil(150, "Loam", 30), 0)
expect_equal(F_K_in_soil(100, "Loam", 40), 260)
expect_warning(F_K_in_soil(100, "Loam", 50), "Is soil depth > 40cm correct?")
expect_warning(F_K_in_soil(100, "Loam", 20), "Is soil depth < 30cm correct?")


# G tests -----------------------------------------------------------------

expect_equal(G_N_from_atmosphere(0.5), -10)
expect_error(G_N_from_atmosphere(5), "coeff <= 1 is not TRUE")
expect_error(G_N_from_atmosphere(-1), "coeff >= 0 is not TRUE")

expect_equal(G_K_immob_by_clay(40), 1.72)
expect_error(G_K_immob_by_clay(140), "sum\\(clay_pc > 100\\) == 0 is not TRUE")
expect_error(G_K_immob_by_clay(-140), "sum\\(clay_pc < 0\\) == 0 is not TRUE")



# H tests -----------------------------------------------------------------

expect_equal(H_K_leaching(100), 10)
expect_equal(H_K_leaching(c(0, 4, 5, 10, 26)), c(60, 60, 60, 30, 10))
expect_error(H_K_leaching(150), "sum\\(clay_pc > 100\\) == 0 is not TRUE")
expect_error(H_K_leaching(c(0, 4, 5, 190, 26)), "sum\\(clay_pc > 100\\) == 0 is not TRUE")
expect_error(H_K_leaching(-8), "sum\\(clay_pc < 0\\) == 0 is not TRUE")
