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


#' Switch language for variable values
#'
#' The default guidelines are in italian language. Switching to english or other available languages aids in
#' selecting the appropriate variables values.
#'
#' Currently `r length(i18n_l$avail_langs_v)` languages are supported: `r i18n_l$avail_langs_v`.
#' Further languages may be added in the future. Contributing translators are welcome, just add your
#' translation to the file `i18n.csv` in the folder `data-raw/i18n` and provide it as
#' a Pull Request on [GitHub](https://github.com/fertplan/pulls)
#'
#' @param lang Character vector, one of `r i18n_l$avail_langs_v`.
#'
#' @return silently a list
#' @export
#'
#' @importFrom ensurer ensure_that
#' @importFrom data.table setattr
#' @md
#' @examples
#' head(get_available("crop"))
#' i18n_switch("lang_en")
#' head(get_available("crop"))
i18n_switch <- function(lang) {

  ensurer::ensure_that(lang, +is_character, +is_in_avail_langs)

  # set in place new levels in tables_l
  invisible(
    mapply(
      FUN = set_new_levels,
      tables_l,
      names(tables_l),
      MoreArgs = list(
        i18n_l = i18n_l$langs_l,
        lang   = lang),
      SIMPLIFY = FALSE))
}

