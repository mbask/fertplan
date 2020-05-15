# H tests -----------------------------------------------------------------

expect_equal(fertplan:::H_K_leaching(100), 10)
expect_equal(fertplan:::H_K_leaching(c(0, 4, 5, 10, 26)), c(60, 60, 60, 30, 10))
expect_error(fertplan:::H_K_leaching(150), "all percentages in vector should be \\[0,100\\]")
expect_error(fertplan:::H_K_leaching(c(0, 4, 5, 190, 26)), "all percentages in vector should be \\[0,100\\]")
expect_error(fertplan:::H_K_leaching(-8), "all percentages in vector should be \\[0,100\\]")
