# G tests -----------------------------------------------------------------

expect_equal(G_N_from_atmosphere(0.5), -10)
expect_error(G_N_from_atmosphere(5), "coeff <= 1 is not TRUE")
expect_error(G_N_from_atmosphere(-1), "coeff >= 0 is not TRUE")

expect_equal(G_K_immob_by_clay(40), 1.72)
expect_error(G_K_immob_by_clay(140), "sum\\(clay_pc > 100\\) == 0 is not TRUE")
expect_error(G_K_immob_by_clay(-140), "sum\\(clay_pc < 0\\) == 0 is not TRUE")
