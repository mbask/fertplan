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
expect_error(A_crop_demand(1.1, 33), "all rates in vector should be \\[0,1\\].")
expect_error(A_crop_demand("0.2", 33), "vector must be of numeric type.")
expect_error(A_crop_demand(0.2, "33"), "vector must be of numeric type.")
# expect_error(A_crop_demand(c(0.2, 0.3), 33), "absorption rate shorter or longer than expected crop yield.")
# expect_error(A_crop_demand(0.3, c(33, 334)), "absorption rate shorter or longer than expected crop yield.")
