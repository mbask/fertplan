# D tests -----------------------------------------------------------------

expect_equal(fertplan:::D_N_denitrification(-30.98, "Lento", "Argilloso"), 13.941)
expect_equal(fertplan:::D_N_denitrification(c(-30.98, -25), c("Normale", "Lento"), c("Argilloso", "Sabbioso")), c(9.294, 7.5))
expect_equal(fertplan:::D_N_denitrification(c(-25, -30.98), c("Lento", "Normale"), c("Sabbioso", "Argilloso")), c(7.5, 9.294))
expect_error(fertplan:::D_N_denitrification(c(-30.98), c("Normale", "Lento"), c("Argilloso", "Sandi")), "undefined soil texture")
expect_error(fertplan:::D_N_denitrification(c(-30.98, -25), c("Lento"), c("Argilloso", "Sabbioso")), "mismatch between length of vectors")
expect_error(fertplan:::D_N_denitrification(c(-30.98, -25), c("Normale", "Lento"), c("Argilloso")), "mismatch between length of vectors")
expect_error(fertplan:::D_N_denitrification(c(-30.98, "-25"), c("Normale", "Lento"), c("Argilloso", "Argilloso")), "vector must be of numeric type")
