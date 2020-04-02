# E -----------------------------------------------------------------------
# Azoto da residui della coltura in precessione


#' Supply of Nitrogen quantity in soil from previous crop
#'
#' This is a simple table lookup (table 05 of the "Disciplinare"). Partial matching is respected so that
#' \code{E_n_from_prev_crop("Gira")} is matched to "Girasole" and the function returns 0 but
#' \code{E_n_from_prev_crop("Prati")} does not match a unique record so that the function returns NA with a warning.
#'
#' Table 05 is a \code{data.table} with values for Nitrogen quantity in kg/ha of `r nrows(tables_l$tab_05_dt)` typical crops:
#' `r tables_l$tab_05_dt`
#'
#' @param crop Previous crop as defined in table 05 of the "Disciplinare", page 26
#'
#' @return Nitrogen quantity in kg/ha, either positive (less N available) or negative (increased N available).
#'         Note that N quantity is multipled by -1 before being returned because E has to be subtracted to the total N fertilization!
#' @export
#'
#' @examples
#' # Returns 0 kg/ha
#' E_N_from_prev_crop("Girasole")
#' # Returns 0 10 kg/ha
#' E_N_from_prev_crop(c("Girasole", "Mais: stocchi asp"))
E_N_from_prev_crop <- function(crop) {
  stopifnot(is.character(crop))

  row_idx <- pmatch(
    x             = crop,
    table         = tables_l$tab_05_dt[["crop"]],
    duplicates.ok = TRUE)

  n_qty <- tables_l$tab_05_dt[["n_from_residues_kg_ha"]][row_idx]
  if (sum(is.na(n_qty)) > 0) {
    warning("E component: one or more crops did not uniquely match table 05 crops, returning NA...")
  }
  -n_qty
}
