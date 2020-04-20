# H tests -----------------------------------------------------------------

expect_equal(H_K_leaching(100), 10)
expect_equal(H_K_leaching(c(0, 4, 5, 10, 26)), c(60, 60, 60, 30, 10))
expect_error(H_K_leaching(150), "sum\\(clay_pc > 100\\) == 0 is not TRUE")
expect_error(H_K_leaching(c(0, 4, 5, 190, 26)), "sum\\(clay_pc > 100\\) == 0 is not TRUE")
expect_error(H_K_leaching(-8), "sum\\(clay_pc < 0\\) == 0 is not TRUE")
