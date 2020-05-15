# C tests -----------------------------------------------------------------

expect_equal(fertplan:::C_N_drain_leach("Lento", "Argilloso"), 50)
expect_equal(fertplan:::C_N_drain_leach(c("Rapido", "Lento"), c("Argilloso", "Sabbioso")), c(30, 50))
expect_equal(fertplan:::C_N_drain_leach(c("Lento", "Rapido", "Lento"), c("Sabbioso", "Argilloso", "Argilloso")), c(50, 30, 50))
expect_error(fertplan:::C_N_drain_leach(c("Rapido", "Lento"), c("Argilloso", "Sabbia")))

expect_equal(fertplan:::C_N_precip_leach(3.3777, 350), 3.3777)
expect_equal(fertplan:::C_N_precip_leach(c(3.3777, 50), c(350, 200)), c(3.3777, 25))
expect_error(fertplan:::C_N_precip_leach(c(3.3777, 50), c(350)), "mismatch between length of vectors")
expect_error(fertplan:::C_N_precip_leach("3.3777", 350), "vector must be of numeric type")
expect_warning(fertplan:::C_N_precip_leach(10, -10), "Unrealistic negative rainfall, assuming 0 mm rainfall")
expect_equal(fertplan:::C_N_precip_leach(3.3777, -350), 0)
expect_warning(fertplan:::C_N_precip_leach(c(10, 20), c(50, -10)), "Unrealistic negative rainfall, assuming 0 mm rainfall")

expect_equal(fertplan:::C_P_immob_by_Ca(92.3, "Argilloso"), 3.246)
expect_error(fertplan:::C_P_immob_by_Ca(c(56, 92.3, 93), "Argilloso"), "mismatch between length of vectors")
expect_equal(fertplan:::C_P_immob_by_Ca(c(56, 92.3, 93), c("Argilloso", "Sabbioso", "Sabbioso")), c(2.520, 3.046, 3.060))
expect_error(fertplan:::C_P_immob_by_Ca(c(56, 92.3, 93), c("Argilloso", "Sabbioso")), "mismatch between length of vectors")
# Ca_pc should be a percentage
expect_error(fertplan:::C_P_immob_by_Ca(150, "Sabbioso"), "all percentages in vector should be \\[0,100\\]")
# soil_texture not found
expect_error(fertplan:::C_P_immob_by_Ca(50, "Sabbia"), "undefined soil texture")
