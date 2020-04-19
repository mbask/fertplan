
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
