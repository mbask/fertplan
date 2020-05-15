# B tests -----------------------------------------------------------------

expect_equal(fertplan:::b1_available_n(0.139, "Argilloso"), 3.3777)
expect_equal(fertplan:::b1_available_n(c(0.139, 0.165), c("Argilloso", "Argilloso")), c(3.3777, 4.0095))
expect_equal(fertplan:::b1_available_n(c(0.139, 1), c("Argilloso", "Sabbioso")), c(3.3777, 28.4000))
expect_equal(fertplan:::b1_available_n(c(1, 0.139), c("Sabbioso", "Argilloso")), c(28.4000, 3.3777))
expect_error(fertplan:::b1_available_n("2"))
expect_error(fertplan:::b1_available_n(102))
expect_error(fertplan:::b1_available_n("Sabbioso"))

expect_warning(fertplan:::b2_mineralized_n("Girasolee", 2.3, 9.57, "Argilloso"), "No crop type found")
expect_equal(fertplan:::b2_mineralized_n("Girasolee", 2.3, 9.57, "Argilloso"), 27.6)
expect_equal(fertplan:::b2_mineralized_n("Girasole", 2.3, 9.57, "Argilloso"), 20.7)
expect_warning(fertplan:::b2_mineralized_n(c("Girasole", "Girasolee"), c(2.3, 2.3), c(9.57, 9.57), c("Argilloso", "Argilloso")), "No crop type found")
expect_equal(fertplan:::b2_mineralized_n(c("Girasole", "Girasolee"), c(2.3, 2.3), c(9.57, 9.57), c("Argilloso", "Argilloso")), c(20.7, 27.6))

expect_equal(fertplan:::B_N_in_soil(3.3777, 20.7), -24.0777)
expect_error(fertplan:::B_N_in_soil("2", 20.7), "vector must be of numeric type")
expect_error(fertplan:::B_N_in_soil(2, "20.7"), "vector must be of numeric type")
expect_error(fertplan:::B_N_in_soil(NA, 20.7), "vector must be of numeric type")

expect_equal(fertplan:::B_P_in_soil("Girasole", 30, "Franco", 30), -33.15)
expect_equal(fertplan:::B_P_in_soil(c("Girasole", "Barbabietola"), c(30, 30), rep("Franco", 2), 30), c(-33.15, 17.55))
expect_equal(fertplan:::B_P_in_soil(c("Barbabietola", "Girasole"), c(30, 30), c("Franco", "Argilloso"), 30), c(17.55, -12.705))
expect_equal(fertplan:::B_P_in_soil(c("Girasole", "Barbabietola", "Arboree"), c(30, 30, 40), c("Franco", "Franco", "Argilloso"), c(30, 30, 40)), c(-33.15, 17.55, -16.94))

expect_error(fertplan:::B_P_in_soil("Girasolee", 30, "Franco", 30))
expect_error(fertplan:::B_P_in_soil("Girasole", 30, "Francoy", 30))
expect_error(fertplan:::B_P_in_soil("Girasole", 0, "Argilloso", 30))
expect_error(fertplan:::B_P_in_soil("Girasole", 20, "Argilloso", 0))
expect_warning(fertplan:::B_P_in_soil("Girasole", 30, "Franco", 50), "Is soil depth > 40cm correct?")
expect_warning(fertplan:::B_P_in_soil("Girasole", 30, "Franco", 20), "Is soil depth < 30cm correct?")
