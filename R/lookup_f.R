#' Get available variable values localized in current language
#'
#' @param variable character vector pointing at the tabled variable to look up.
#' One of `r paste0("``", get_available(), "``", collapse = ", ")` or `NULL` (default).
#' @param aux      character vector useful to pass the part when variable is "crop by part group"
#' @param is_removal boolean value useful to select only crops featuring removal
#'   coefficients, for variable assuming values "crop", "crop by group", "crop by part group", and "part"
#'
#' @return a character vector of available tabled variable values, a list of
#' variable values (when `variable` is "group_crop"), or a character vector
#' of available variables to be looked up (when `variable` is `NULL`),
#' or `NULL` when no matching variables were passed.
#' @importFrom data.table  copy
#' @export
#'
#' @md
#' @examples
#' head(get_available("crop"))
#' get_available("languages")
get_available <- function(variable = NULL, aux = NULL, is_removal = FALSE) {
  avail_vars <- c(
    #variable            = table_var_name
    "crop"               = "crop",
    "crop by group"      = "crop by group",
    "crop by part group" = "crop by part",
    "crop type"          = "crop_type",
    "part"               = "part",
    "drainage"           = "drainage",
    "soil texture"       = "soil_texture",
    "organic fertilizer" = "organic_fertilizer",
    "frequency"          = "frequency",
    "previous crops"     = "crop",
    "crop class"         = "crop",
    "languages"          = "avail_langs")


  # Needs refactoring!

  if (is.null(variable)) {
    return(names(avail_vars))
  } else {
    is_character(variable)
    if (variable %in% names(avail_vars)) {
      table_var_name <- avail_vars[variable]
      if (table_var_name %in% c("crop by group", "crop by part")) {
        if (table_var_name == "crop by part") {
          # Filtered crops by part, grouped by group
          is_character(aux)
          crop_group <- crop <- part <- NULL
          if (is_removal) {
            coeff <- NULL
            tmp_dt <- data.table::copy(tables_l$all_01_dt[part == aux & coeff == "asp."])[, crop_group := factor(crop_group)][, crop := factor(crop)]
          } else {
            tmp_dt <- data.table::copy(tables_l$all_01_dt[part == aux])[, crop_group := factor(crop_group)][, crop := factor(crop)]
          }
        } else {
          # crops grouped by group
          if (is_removal) {
            coeff <- NULL
            tmp_dt <- data.table::copy(tables_l$all_01_dt[coeff == "asp.",])
          } else {
            tmp_dt <- data.table::copy(tables_l$all_01_dt)
          }
        }
        lapply(
          X   = split(tmp_dt, tmp_dt$crop_group),
          FUN = function(sg_dt) { unique(sg_dt$crop) })
      } else {
        # not (table_var_name %in% c("crop by group", "crop by part"))
        with(
          tables_l, {
            if (variable %in% c("crop", "part")) {
              if (is_removal) {
                coeff <- NULL
                tmp_dt <- data.table::copy(tables_l$all_01_dt[coeff == "asp.",])
              } else {
                tmp_dt <- data.table::copy(tables_l$all_01_dt)
              }
              return(levels(factor(tmp_dt[[table_var_name]])))
            }
            if (variable == "crop type")         return(levels(all_02_dt[[table_var_name]]))
            if (variable == "drainage")          return(levels(tab_03_dt[[table_var_name]]))
            if (variable == "soil texture")      return(levels(tab_01_wdt[[table_var_name]]))
            if (variable == "organic fertilizer") return (levels(tab_06_dt[[table_var_name]]))
            if (variable == "previous crops")    return (levels(tab_05_dt[[table_var_name]]))
            if (variable == "crop class")        return (levels(tab_10_dt[[table_var_name]]))
            if (variable == "frequency")         return (unique(tab_06_dt[[table_var_name]]))
            if (variable == "languages")         return (i18n_l$avail_langs_v)
          }
        )
      }
    } else {
      NULL
    }
  }
}


# Matches drainage rate and texture features to dt
#
# @param dt             A table from the "Disciplinare" featuring drainage and soil_texture columns
# @param drainage_rate  Rate of drainage in soil (either "fast", "normal", "slow", "no drainage")
# @param texture        Soil texture (either "Sandy", "Loam", or "Clayey")
#
# @return               A \code{data.table} matching \code{dt} by \code{drainage_rate} and \code{texture}
# @importFrom data.table data.table
#
# @examples
# # Returns a data.table:
# #    drainage soil_texture n_denitrificated_coeff
# # 1:     slow       Clayey                   0.45
# \dontrun{lookup_var_by_drainage_texture(tables_l[["tab_04_dt"]], "slow", "Clayey")}
# # Returna a data.table:
# #    drainage soil_texture n_leached_kg_ha_y
# # 1:     slow       Clayey                50
# \dontrun{lookup_var_by_drainage_texture(tables_l[["tab_03_dt"]], "slow", "Clayey")}
lookup_var_by_drainage_texture <- function(dt, drainage_rate, texture) {

  index_cols <- c("drainage", "soil_texture")

  lookup_dt <- data.table::data.table(
    drainage     = drainage_rate,
    soil_texture = texture)
  data.table::setindexv(lookup_dt, index_cols)

  dt[lookup_dt, on = index_cols]
}




lookup_var_by_crop_part <- function(dt, crop, part) {

  index_cols <- c("crop", "part")

  lookup_dt <- data.table::data.table(
    crop = crop,
    part = part)
  data.table::setindexv(lookup_dt, index_cols)

  dt[lookup_dt, on = index_cols]
}



# Matches fertilizer and frequency features to dt
#
# @param dt             A table from the "Disciplinare" featuring organic_fertilizer and frequency columns
# @param fertilizer     Character vector describing type organic fertilizer
# @param years          Frequency of fertilization
#
# @return               A \code{data.table} matching \code{dt} by \code{organic_fertilizer} and \code{frequency}
# @importFrom data.table data.table
lookup_var_by_fertilizer_year <- function(dt, fertilizer, years) {

  index_cols <- c("organic_fertilizer", "frequency")

  lookup_dt <- data.table::data.table(
    organic_fertilizer = fertilizer,
    frequency          = years)
  data.table::setindexv(lookup_dt, index_cols)

  dt[lookup_dt, on = index_cols]
}



# Matches soil texture and crop features to dt
#
# @param dt             A table from the "Disciplinare" featuring soil_texture and crop columns
# @param crop           Crop character vector describing the crop
# @param soil_texture   Soil texture (either "Sandy", "Loam", or "Clayey")
#
# @return               A \code{data.table} matching \code{dt} by \code{crop} and \code{soil_texture}
# @importFrom data.table data.table
lookup_var_by_crop_texture <- function(dt, crop, soil_texture) {

  index_cols <- c("crop", "soil_texture")

  lookup_dt <- data.table::data.table(
    crop         = crop,
    soil_texture = soil_texture)
  data.table::setindexv(lookup_dt, index_cols)

  dt[lookup_dt, on = index_cols]
}



# Matches ccrop feature to dt
#
# @param dt             A table from the "Guidelines" featuring crop column
# @param crop           Crop character vector describing the crop
#
# @return               A \code{data.table} matching \code{dt} by \code{crop}
# @importFrom data.table data.table
lookup_var_by_crop_05 <- function(dt, crop) {

  index_cols <- c("crop")

  lookup_dt <- data.table::data.table(crop = crop)
  data.table::setindexv(lookup_dt, index_cols)

  dt[lookup_dt, on = index_cols]
}



# Match elements among a vector, allowing for duplicates, return elements from a third vector
#
# Internal function, uses internally \code{pmatch}.
#
# @param x_v        the values to be matched
# @param lookup_v   the values to be matched against
# @param match_v    the values to be returned by index
#
# @return avector of same length as \code{x}
#
# @examples
# \dontrun{# Returns 10 20 10
# get_matching_values(
#   c(1,2,1),
#   c(3,6,3,7,7,3,2,1,1),
#   c(30,60,30,70,70,30,20,10,10))}
get_matching_values <- function(x_v, lookup_v, match_v) {
  row_idx <- pmatch(
    x             = x_v,
    table         = lookup_v,
    duplicates.ok = TRUE)
  match_v[row_idx]
}



# Time coefficient for organic matter mineralization
#
# Used internally by \code{\link{b2_mineralized_n}}
#
# @param crop_type Crop type for estimation of the time coefficient (Guidelines ed. year 2020 page 22 and Table 15.3 page 67)
#
# @return The time coefficient
crop_type_lookup <- function(crop_type) {
  row_idx    <- pmatch(
    x             = crop_type,
    table         = tables_l$all_02_dt[["crop_type"]],
    duplicates.ok = TRUE)
  time_coeff <- tables_l$all_02_dt[["time_coeff"]][row_idx]

  if (any(is.na(time_coeff))) {
    warning("No crop type found in 15.3 table of the 2020 guidelines, assuming time coefficient = 1 (multiannual crop)")
    time_coeff[is.na(time_coeff)] <- 1
  }
  time_coeff
}
