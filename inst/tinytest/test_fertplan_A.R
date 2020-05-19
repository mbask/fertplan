# A tests -----------------------------------------------------------------

# Allegato 1 lookup tests
expect_equal(fertplan:::abs_n_coef_of("Ribes", "Pianta"), 0.4)
expect_equal(fertplan:::abs_n_coef_of("Actinidia", "Pianta"), 0.59)
expect_equal(fertplan:::rem_n_coef_of("Ribes", "Frutto"), 0.14)
expect_equal(fertplan:::rem_n_coef_of("Actinidia", "Frutto"), 0.15)
expect_equal(fertplan:::abs_n_coef_of(c("Triticale", "Lampone"), "Pianta"), c(2.54, 0.3))
expect_equal(fertplan:::abs_n_coef_of(rep("Triticale", 2), "Pianta"), rep(2.54, 2))
expect_equal(fertplan:::rem_k_coef_of("Ribes", "Frutto"), 0.44)
expect_equal(fertplan:::abs_k_coef_of(c("Ribes", "Girasole"), "Pianta"), c(1, 8.51))
expect_equal(fertplan:::rem_p_coef_of("Ribes", "Frutto"), 0.1)
expect_equal(fertplan:::abs_p_coef_of(c("Ribes", "Girasole"), "Pianta"), c(0.4, 1.9))

# Expect a warning when a lookup fails
expect_warning(fertplan:::abs_n_coef_of("Rosa purpurea del Cairo", "Pianta"), "1 crops or parts were not matched in the appropriate guidelines table")
expect_warning(fertplan:::rem_n_coef_of(c("Ribes", "Rosa purpurea del Cairo"), "Frutto"), "1 crops or parts were not matched in the appropriate guidelines table")

# Expect NA for those crop failed lookups
expect_true(is.na(fertplan:::abs_n_coef_of("Rosa purpurea del Cairo", "Pianta")))
expect_true(is.na(fertplan:::rem_n_coef_of(c("Ribes", "Rosa purpurea del Cairo"), "Frutto")[2]))

# Expect correct results
expect_equal(fertplan:::A_crop_demand(0.028, 1330), 37.24)
expect_equal(fertplan:::A_crop_demand(c(0.028, 0.1), c(1330, 2000)), c(37.24, 200.0))

# Expect errors
expect_error(fertplan:::A_crop_demand(1.1, 33), "all rates in vector should be \\[0,1\\].")
expect_error(fertplan:::A_crop_demand("0.2", 33), "vector must be of numeric type.")
expect_error(fertplan:::A_crop_demand(0.2, "33"), "vector must be of numeric type.")
# expect_error(A_crop_demand(c(0.2, 0.3), 33), "absorption rate shorter or longer than expected crop yield.")
# expect_error(A_crop_demand(0.3, c(33, 334)), "absorption rate shorter or longer than expected crop yield.")
