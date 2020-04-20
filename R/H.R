# H -----------------------------------------------------------------------

#' K Leaching due to clay content in soil
#'
#' K Leaching is estimated by the content of clay in soil in percentage
#'
#' @param clay_pc Clay content in soil in \%
#'
#' @return        Supply of K2O in kg/ha
#' @export
#' @importFrom ensurer ensure
#' @examples
#' # Returns 60 60 60 10 30 kg/ha
#' H_K_leaching(c(0, 4, 5, 26, 13))
H_K_leaching <- function(clay_pc) `: numeric` ({
  ensurer::ensure(clay_pc, +is_numeric, +is_vector_pc)

  clean_clay_pc_v <- clay_pc
  clay_pc_low <- clay_pc_high <- k_kg_ha <- NULL
  vapply(
    X   = clean_clay_pc_v,
    FUN = function(clay_pc) {
      tables_l$H_K_leach_dt[clay_pc >= clay_pc_low & clay_pc <= clay_pc_high, k_kg_ha] },
    FUN.VALUE = vector(mode = "numeric", length = 1))
})
