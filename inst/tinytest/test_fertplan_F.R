# F tests -----------------------------------------------------------------

expect_equal(F_N_prev_fertilization(30, "Bovine manure", 2), -4.5)
expect_equal(F_N_prev_fertilization(c(30, 30), c("Swine and poultry manure", "Bovine manure"), c(3, 3)), c(-1.5, -3.0))

expect_error(F_N_prev_fertilization(c(30, 45), "Bovine manure", 2), "mismatch between length of vectors")
expect_error(F_N_prev_fertilization(30, c("Bovine manure", "Bovine manure"), 2), "mismatch between length of vectors")
expect_error(F_N_prev_fertilization(30, "Bovine manure", c(2, 1)), "mismatch between length of vectors")

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

