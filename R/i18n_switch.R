set_new_levels <- function(dt, dt_name, i18n_l, lang) {
  # Build a list for new language levels
  # for the current table
  new_lang_l <- sapply(i18n_l[[dt_name]], function(x) x[[lang]], simplify = FALSE)
  # eg c("crop_group", "part")
  cols_v     <- names(new_lang_l)
  # replace new language "levels" (new_lang_m[, col]) in appropriate
  # column of appropriate table (dt[[col]])
  for (col in cols_v) {
    data.table::setattr(dt[[col]], "levels", new_lang_l[[col]])
  }
}


#' Switch language
#'
#' The default guidelines are in italian language. Switching to english or other available languages aids in
#' selecting the appropriate variables values.
#'
#' @param lang Character vector, one of "it", "en"
#'
#' @return NULL
#' @export
#'
#' @importFrom ensurer ensure_that
#' @importFrom data.table setattr
#' @examples
#' head(get_available("crop"))
#' i18n_switch("en")
#' head(get_available("crop"))
i18n_switch <- function(lang) {

  ensurer::ensure_that(lang, +is_character, +is_in_avail_langs)

  # set in place new levels in tables_l
  invisible(
    mapply(
      FUN = set_new_levels,
      tables_l,
      names(tables_l),
      MoreArgs = list(i18n_l = i18n_l, lang = lang),
      SIMPLIFY = FALSE))
}

