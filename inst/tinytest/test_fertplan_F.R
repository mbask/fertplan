# F tests -----------------------------------------------------------------

expect_equal(fertplan:::F_N_prev_fertilization(30, "Liquame bovino", 2), -4.5)
expect_equal(fertplan:::F_N_prev_fertilization(c(30, 30), c("Liquame suino e pollina", "Liquame bovino"), c(3, 3)), c(-1.5, -3.0))

expect_error(fertplan:::F_N_prev_fertilization(c(30, 45), "Liquame bovino", 2), "mismatch between length of vectors")
expect_error(fertplan:::F_N_prev_fertilization(30, c("Liquame bovino", "Liquame bovino"), 2), "mismatch between length of vectors")
expect_error(fertplan:::F_N_prev_fertilization(30, "Liquame bovino", c(2, 1)), "mismatch between length of vectors")

expect_equal(fertplan:::F_N_prev_fertilization(0), 0)

expect_equal(fertplan:::F_N_prev_fertilization(c(30, -10), c("Liquame bovino", "Liquame bovino"), c(2, 2)), c(-4.5, 0.0))
expect_warning(fertplan:::F_N_prev_fertilization(c(30, -10), c("Liquame bovino", "Liquame bovino"), c(2, 2)), "Nitrogen supply < 0, assuming 0")

expect_equal(fertplan:::F_N_prev_fertilization(c(30, 10), c("Liquame bovino", "Liquame bovino"), c(-2, 2)), c(-9, -1.5))
expect_warning(fertplan:::F_N_prev_fertilization(c(30, 10), c("Liquame bovino", "Liquame bovino"), c(-2, 2)), "Frequency of fertilization < 1 years, assuming 1")

expect_equal(fertplan:::F_N_prev_fertilization(c(30, 30), c("Liquame bovino", "Liquame bovino"), c(4, 3)), c(-3, -3))
expect_warning(fertplan:::F_N_prev_fertilization(c(30, 30), c("Liquame bovino", "Liquame bovino"), c(4, 3)), "Frequency of fertilization > 3 years, assuming 3")

expect_error(fertplan:::F_N_prev_fertilization(30, Bovine, 2))
expect_error(fertplan:::F_N_prev_fertilization(30, "Liquame bovini", 2))


expect_equal(fertplan:::F_K_in_soil(449, "Argilloso", 30), -976.47)
expect_equal(fertplan:::F_K_in_soil(180, "Argilloso", 30), 0)
expect_equal(fertplan:::F_K_in_soil(449, "Franco", 30), -1166.1)
expect_equal(fertplan:::F_K_in_soil(150, "Franco", 30), 0)
expect_equal(fertplan:::F_K_in_soil(100, "Franco", 40), 260)
expect_warning(fertplan:::F_K_in_soil(100, "Franco", 50), "Is soil depth > 40cm correct?")
expect_warning(fertplan:::F_K_in_soil(100, "Franco", 20), "Is soil depth < 30cm correct?")
