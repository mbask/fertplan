# E tests -----------------------------------------------------------------

expect_equal(fertplan:::E_N_from_prev_crop("Girasole"), 0)
expect_error(fertplan:::E_N_from_prev_crop(Girasole), "object 'Girasole' not found")
expect_equal(fertplan:::E_N_from_prev_crop(c("Girasole", "Patata")), c(0, -35))
expect_warning(fertplan:::E_N_from_prev_crop(c("Gira", "Prati")), "one or more crops did not uniquely match table 05 crops")
