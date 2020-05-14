# E -----------------------------------------------------------------------
# Azoto da residui della coltura in precessione


# Supply of Nitrogen quantity in soil from previous crop
#
# This is a simple table lookup (table 05 of the "Disciplinare"). Partial matching is not allowed.
#
# Table 05 is a `data.table` with values for nitrogen quantity in kg/ha for typical crops:
# `r paste0("``", get_available("previous crops"), "``", collapse = ", ")`
#
# @param crop Previous crop as defined in table 05 of the "Disciplinare", page 26
#
# @return Nitrogen quantity in kg/ha, either positive (less N available) or negative (increased N available).
#         Note that N quantity is multipled by -1 before being returned because E has to be subtracted to the total N fertilization!
# @export
# @md
# @examples
# # Returns 0 kg/ha
# E_N_from_prev_crop("Girasole")
# # Returns 0 10 kg/ha
# E_N_from_prev_crop(c("Girasole", "Mais: stocchi asportati"))
E_N_from_prev_crop <- function(crop) `: numeric` ({
  is_character(crop)

  n_qty_dt <- lookup_var_by_crop_05(tables_l$tab_05_dt, crop)

  # row_idx <- pmatch(
  #   x             = crop,
  #   table         = tables_l$tab_05_dt[["crop"]],
  #   duplicates.ok = TRUE)

  n_qty <- n_qty_dt[["n_from_residues_kg_ha"]]

  if (any(is.na(n_qty))) {
    warning("E component: one or more crops did not uniquely match table 05 crops, returning NA...")
  }
  -n_qty
})
