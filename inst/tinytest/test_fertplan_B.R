# B tests -----------------------------------------------------------------

expect_equal(b1_available_n(0.139, "Clayey"), 3.3777)
expect_equal(b1_available_n(c(0.139, 0.165), c("Clayey", "Clayey")), c(3.3777, 4.0095))
expect_equal(b1_available_n(c(0.139, 1), c("Clayey", "Sandy")), c(3.3777, 28.4000))
expect_equal(b1_available_n(c(1, 0.139), c("Sandy", "Clayey")), c(28.4000, 3.3777))
expect_error(b1_available_n("2"))
expect_error(b1_available_n(102))
expect_error(b1_available_n("Sandy"))

expect_warning(b2_mineralized_n("Girasolee", 2.3, 9.57, "Clayey"), "No crop type found")
expect_equal(b2_mineralized_n("Girasolee", 2.3, 9.57, "Clayey"), 27.6)
expect_equal(b2_mineralized_n("Girasole", 2.3, 9.57, "Clayey"), 20.7)
expect_warning(b2_mineralized_n(c("Girasole", "Girasolee"), c(2.3, 2.3), c(9.57, 9.57), c("Clayey", "Clayey")), "No crop type found")
expect_equal(b2_mineralized_n(c("Girasole", "Girasolee"), c(2.3, 2.3), c(9.57, 9.57), c("Clayey", "Clayey")), c(20.7, 27.6))

expect_equal(B_N_in_soil(3.3777, 20.7), -24.0777)
expect_error(B_N_in_soil("2", 20.7), "is.numeric\\(b1\\)")
expect_error(B_N_in_soil(2, "20.7"), "is.numeric\\(b2\\)")
expect_error(B_N_in_soil(NA, 20.7), "is.numeric\\(b1\\)")

expect_equal(B_P_in_soil("Girasole", 30, "Loam", 30), -33.15)
expect_equal(B_P_in_soil(c("Girasole", "Barbabietola"), c(30, 30), c("Loam", "Loam"), 30), c(-33.15, 17.55))
expect_equal(B_P_in_soil(c("Barbabietola", "Girasole"), c(30, 30), c("Loam", "Clayey"), 30), c(17.55, -12.705))
expect_equal(B_P_in_soil(c("Girasole", "Barbabietola", "Arboree"), c(30, 30, 40), c("Loam", "Loam", "Clayey"), c(30, 30, 40)), c(-33.15, 17.55, -16.94))

expect_error(B_P_in_soil("Girasolee", 30, "Loam", 30))
expect_error(B_P_in_soil("Girasole", 30, "Loamy", 30))
expect_error(B_P_in_soil("Girasole", 0, "Clayey", 30))
expect_error(B_P_in_soil("Girasole", 20, "Clayey", 0))
expect_warning(B_P_in_soil("Girasole", 30, "Loam", 50), "Is soil depth > 40cm correct?")
expect_warning(B_P_in_soil("Girasole", 30, "Loam", 20), "Is soil depth < 30cm correct?")



