# D tests -----------------------------------------------------------------

expect_equal(D_N_denitrification(-30.98, "slow", "Clayey"), 13.941)
expect_equal(D_N_denitrification(c(-30.98, -25), c("normal", "slow"), c("Clayey", "Sandy")), c(9.294, 7.5))
expect_equal(D_N_denitrification(c(-25, -30.98), c("slow", "normal"), c("Sandy", "Clayey")), c(7.5, 9.294))
expect_error(D_N_denitrification(c(-30.98), c("normal", "slow"), c("Clayey", "Sandi")), "soil_texture %in% soil_textures are not all TRUE")
expect_error(D_N_denitrification(c(-30.98, -25), c("slow"), c("Clayey", "Sandy")), "length\\(drainage_rate\\) == length\\(soil_texture\\) is not TRUE")
expect_error(D_N_denitrification(c(-30.98, -25), c("normal", "slow"), c("Clayey")), "length\\(drainage_rate\\) == length\\(soil_texture\\) is not TRUE")
expect_error(D_N_denitrification(c(-30.98, "-25"), c("normal", "slow"), c("Clayey", "Clayey")), "is.numeric\\(B\\) is not TRUE")
