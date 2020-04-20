# G tests -----------------------------------------------------------------

expect_equal(G_N_from_atmosphere(0.5), -10)
expect_error(G_N_from_atmosphere(5), "all rates in vector should be \\[0,1\\]")
expect_error(G_N_from_atmosphere(-1), "all rates in vector should be \\[0,1\\]")

expect_equal(G_K_immob_by_clay(40), 1.72)
expect_error(G_K_immob_by_clay(140), "all percentages in vector should be \\[0,100\\]")
expect_error(G_K_immob_by_clay(-140), "all percentages in vector should be \\[0,100\\]")
