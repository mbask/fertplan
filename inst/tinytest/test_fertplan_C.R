# C tests -----------------------------------------------------------------

expect_equal(C_N_drain_leach("slow", "Clayey"), 50)
expect_equal(C_N_drain_leach(c("fast", "slow"), c("Clayey", "Sandy")), c(30, 50))
expect_equal(C_N_drain_leach(c("slow", "fast", "slow"), c("Sandy", "Clayey", "Clayey")), c(50, 30, 50))
expect_error(C_N_drain_leach(c("fast", "slow"), c("Clayey", "Sandi")))

expect_equal(C_N_precip_leach(3.3777, 350), 3.3777)
expect_equal(C_N_precip_leach(c(3.3777, 50), c(350, 200)), c(3.3777, 25))
expect_error(C_N_precip_leach(c(3.3777, 50), c(350)), "mismatch between length of vectors")
expect_error(C_N_precip_leach("3.3777", 350), "vector must be of numeric type")
expect_warning(C_N_precip_leach(10, -10), "Unrealistic negative rainfall, assuming 0 mm rainfall")
expect_equal(C_N_precip_leach(3.3777, -350), 0)
expect_warning(C_N_precip_leach(c(10, 20), c(50, -10)), "Unrealistic negative rainfall, assuming 0 mm rainfall")

expect_equal(C_P_immob_by_Ca(92.3, "Clayey"), 3.246)
expect_error(C_P_immob_by_Ca(c(56, 92.3, 93), "Clayey"), "mismatch between length of vectors")
expect_equal(C_P_immob_by_Ca(c(56, 92.3, 93), c("Clayey", "Sandy", "Sandy")), c(2.520, 3.046, 3.060))
expect_error(C_P_immob_by_Ca(c(56, 92.3, 93), c("Clayey", "Sandy")), "mismatch between length of vectors")
# Ca_pc should be a percentage
expect_error(C_P_immob_by_Ca(150, "Sandy"), "all percentages in vector should be \\[0,100\\]")
# soil_texture not found
expect_error(C_P_immob_by_Ca(50, "Sandi"), "undefined soil texture")
