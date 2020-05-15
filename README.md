Introduction to `fertplan` R package
================

## Description

The goal of the package is to provide the necessary computation
algorithm to perform a fertilization plan for the fields of a farm. It
heavily follows the agronomic guidelines for integrated agriculture,
issued by [Lazio
Region](https://www.regione.lazio.it/rl_agricoltura/?vw=contenutidettaglio&id=164 "Web-site of Lazio Region (in italian)"),
a public administration in Italy. Fertilization plans in the Lazio
region territory have to follow these agronomic guidelines with specific
attention to [attachment no.
2](http://www.regione.lazio.it/binary/rl_main/tbl_documenti/AGC_DD_G01782_24_02_2020_Allegato1.pdf "PDF file of the Attachment 2 of the guidelines")
(Assessorato Agricoltura, Promozione della Filiera e della Cultura del
Cibo, Ambiente e Risorse Naturali 2020).

The package provides a set of functions to compute the components of the
supply/demand for Nitrogen, Phosphorus \(P_2O_5\), and Potassium
\(K_2O\) nutrients to field crops.

## Installation

`fertplan` is currently in active development and not yet on CRAN, it
may be installed from this GitHub repository though:

``` r
# Install remotes package if not yet present in R library
# install.packages("remotes")

remotes::install_github("mbask/fertplan")
```

## Usage

Please check out available package vignettes for:

  - Nitrogen fertilization plan
  - Phosphorus fertilization plan
  - Potassium fertilization plan

This document will walk you through a simulation of a real fertilization
plan for nitrogen nutrient. Both `fertplan` and this document depend on
package `data.table` but its usage is not in any way mandatory.

## Nitrogen fertilization plan

The estimation of the fertilization plan strictly follow the indications
formulated in the regulation drawn up by the Italian Region of Lazio
(Assessorato Agricoltura, Promozione della Filiera e della Cultura del
Cibo, Ambiente e Risorse Naturali 2020), hereafter the *guidelines*. The
estimation of nitrogen demand for a yearly crop is the most complex
among the ones detailed in the *guidelines*.  
Nitrogen fertilization concentration in kg/ha is estimated as the net
resultant of a N balance between the nitrogen pool available for the
crops and the nitrogen losses. The N balance involves 7 main flow
components. Flows that increase N availability to the crop are \> 0
(positive sign). Flows that deplete soil N pool or N availability for
the crop are \< 0 (negative sign).

The N flow components include:

  - **\(f_{N,a}\)** Nitrogen demand of the specific crop proportional to
    its expected yield and its nitrogen absorption coefficient in
    percent. Absorption coefficients are tabled per a number of
    different crops in the *guidelines*
  - **\(f_{N,b}\)** Nitrogen supply currently in the soil due to its
    fertility. This component sums two nitrogen pools: **b1** available
    nitrogen to the crop, and **b2** nitrogen supply from mineralization
    of organic matter
  - **\(f_{N,c}\)** Nitrogen leached due to cumulative precipitation in
    the period October 1st - January 31st as described on pages 24 and
    25 of the *guidelines*. Note that there is an alternative method for
    estimating N leaching based on tabled values according to drainage
    rate and soil texture. This latter method is not exported by the
    package \# The leaching affects only the available nitrogen part
    (not total Nitrogen)
  - **\(f_{N,d}\)** Nitrogen loss due to denitrification, adsorbation,
    volatilization processes in soil based on soil texture and drainage
    rate
  - **\(f_{N,e}\)** Residual soil nitrogen from previous crop
  - **\(f_{N,f}\)** Residual nitrogen from previous organic
    fertilizations, if ever performed. If this is the case than the N
    supply in soil depends on the time since last fertilization, the
    type and quantity of organic fertilization perfomed
  - **\(f_{N,g}\)** Nitrogen supply from atmospheric depositions and
    from N-fixing bacteria. Yearly availability is estimated to be 20
    kg/ha in levelled crops close to urban settlements. This figure has
    to be appropriately adapted to each crop through a \[0,1\]
    coefficient. Note that the N estimate is given in negative sign (ie
    a flow into the soil).

The final nitrogen balance is computed as the sum of its 7 components:
\[B_N = \sum_{i=1}^{7}f_{N,i}\]

The main pathway to get to B\_N includes 4 steps.

### First step: load soil analyses

Let’s begin with some minimal data from soil physical and chemical
analyses on a few sampling points in the field.

``` r
data(soils)
soil_dt <- soils[, c("id", "N_pc", "CNR", "SOM_pc", "Clay_pc")]
knitr::kable(soil_dt)
```

| id | N\_pc |       CNR | SOM\_pc | Clay\_pc |
| -: | ----: | --------: | ------: | -------: |
|  1 | 0.139 |  9.568345 |    2.30 |       34 |
|  2 | 0.165 |  9.818182 |    2.79 |       37 |
|  3 | 0.160 |  9.750000 |    2.69 |       40 |
|  4 | 0.164 |  9.817073 |    2.77 |       34 |
|  5 | 0.122 |  9.344262 |    1.97 |       38 |
|  6 | 0.145 |  9.586207 |    2.40 |       40 |
|  7 | 0.159 |  9.748428 |    2.67 |       34 |
|  8 | 0.163 |  9.754601 |    2.73 |       34 |
|  9 | 0.143 |  9.580420 |    2.36 |       37 |
| 10 | 0.152 |  9.671053 |    2.54 |       36 |
| 11 | 0.164 |  9.756098 |    2.76 |       37 |
| 12 | 0.137 |  9.562044 |    2.25 |       40 |
| 13 | 0.173 |  9.826590 |    2.93 |       38 |
| 14 | 0.189 |  9.947090 |    3.24 |       38 |
| 15 | 0.145 |  9.586207 |    2.40 |       40 |
| 16 | 0.162 |  9.753086 |    2.73 |       34 |
| 17 | 0.205 | 10.048780 |    3.56 |       36 |
| 18 | 0.148 |  9.662162 |    2.47 |       39 |
| 19 | 0.154 |  9.675325 |    2.58 |       36 |
| 20 | 0.146 |  9.657534 |    2.43 |       37 |

The table shows the soil chemical and physical status before the planned
crop sowing. The soil analyses elements that will be fed the nitrogen
balance estimation are:

  - *N\_pc*, Total nitrogen content in %
  - *CNR*, Carbon / nitrogen ratio
  - *SOM\_pc*, Soil Organic Matter in %
  - *Clay\_pc*, Clay content in %

The *id* feature is not relevant to the balance estimation.

### Second step: variable configuration

A few environmental and crop-related variables need to be set. Some
variables need to match those set out in the *guidelines* tables, while
a few others have to be derived from external sources.

Let’s first translate the *guidelines* tables into english:

``` r
fertplan::i18n_switch("lang_en")
```

Matching-variables are:

  - **Crop**, this is the name of the crop to be sown and will be used
    to lookup its nitrogen demand in table 15.2 (page 63) of the
    *guidelines* to contribute to **\(f_{N,a}\)** component. The name
    must match one of the following crop names available. Partial
    matching is not allowed. Note that `fertplan` implemetation of the
    table has separated the crop column into two features, the actual
    “crop” and “part” (eg fruits, whole plant, and so on). The
    available crops are:

| x           |
| :---------- |
| 1           |
| 2           |
| 3           |
| 4           |
| 5           |
| 6           |
| 7           |
| 8           |
| 9           |
| 10          |
| 11          |
| 12          |
| 13          |
| 14          |
| 15          |
| 16          |
| 17          |
| 18          |
| 19          |
| 20          |
| 21          |
| 22          |
| 23          |
| 24          |
| 25          |
| 26          |
| 27          |
| 28          |
| 29          |
| 30          |
| 31          |
| 32          |
| 33          |
| 34          |
| 35          |
| 36          |
| 37          |
| 38          |
| 39          |
| 40          |
| 41          |
| 42          |
| 43          |
| 44          |
| 45          |
| 46          |
| Sunflower   |
| Durum wheat |
| Soft wheat  |
| 47          |
| 48          |
| 49          |
| 50          |
| 51          |
| 52          |
| 53          |
| 54          |
| 55          |
| 56          |
| 57          |
| 58          |
| 59          |
| 60          |
| 61          |
| 62          |
| 63          |
| 64          |
| 65          |
| 66          |
| 67          |
| 68          |
| 69          |
| 70          |
| 71          |
| 72          |
| 73          |
| 74          |
| 75          |
| 76          |
| 77          |
| 78          |
| 79          |
| 80          |
| 81          |
| 82          |
| 83          |
| 84          |
| 85          |
| 86          |
| 87          |
| 88          |
| 89          |
| 90          |
| 91          |
| 92          |
| 93          |
| 94          |
| 95          |
| 96          |
| 97          |
| 98          |
| 99          |
| 100         |
| 101         |
| 102         |
| 103         |
| 104         |
| 105         |
| 106         |
| 107         |
| 108         |
| 109         |
| 110         |
| 111         |
| 112         |
| 113         |
| 114         |
| 115         |
| 116         |
| 117         |
| 118         |
| 119         |
| 120         |
| 121         |
| 122         |
| 123         |
| 124         |
| 125         |
| 126         |
| 127         |
| 128         |
| 129         |

Crops are organized into crop types for convenience:

  - **Crop part**, this is the part of the crop to be sown that will
    contribute to **\(f_{N,a}\)** component. Note that nitrogen demand
    by crops may greatly differ upon the crop part considered. As an
    example N coefficients for “sunflower” crop are:

| crop\_group     | crop      | part        | coeff | element | coeff\_pc |
| :-------------- | :-------- | :---------- | :---- | :------ | --------: |
| herbage species | Sunflower | Fruits      | asp.  | N       |      2.80 |
| herbage species | Sunflower | Whole plant | ass.  | N       |      4.31 |

As a reference crop parts include:

| x           |
| :---------- |
|             |
| Leaves      |
| Fruits      |
| Whole plant |
| Roots       |
| Spears      |

  - **Crop type**, this is the type of crop to be sown to be looked up
    in table 15.3 (page 67) of the *guidelines*. It is used to estimate
    the time coefficient, as a ratio of an year, during which the
    mineralization of nitrogen will take place and, thus, will be
    available to the crop itself. Crop type contributes to b2
    sub-component of **\(f_{N,b}\)** component. Available crop types
    are:

| x                   |
| :------------------ |
| 1                   |
| 2                   |
| 3                   |
| Fall / winter crops |
| 5                   |
| Sunflower           |
| 7                   |
| 8                   |
| 9                   |
| 10                  |
| 11                  |
| 12                  |
| 13                  |
| 14                  |
| 15                  |
| 16                  |
| 17                  |

  - **Previous crop**, this is the name or type of the previous crop, to
    be looked up in table 5 (page 24) of the *guidelines*. Previous crop
    contributes to **\(f_{N,e}\)** component. Available matches include:

| x                       |
| :---------------------- |
| 1                       |
| 2                       |
| 3                       |
| 4                       |
| Sunflower               |
| 6                       |
| 7                       |
| 8                       |
| 9                       |
| 10                      |
| 15                      |
| 11                      |
| 12                      |
| 13                      |
| 14                      |
| Grassland, legumes \<5% |
| 16                      |
| 17                      |
| 18                      |

  - **Texture**, soil texture, one of ‘Clayey’, ‘Loam’, ‘Sandy’. Soil
    texture enters in several flows of the nitrogen balance.

  - **Drainage rate**, it contributes to **\(f_{N,d}\)** component, can
    be one of ‘No drainage’, ‘Slow’, ‘Normal’, ‘Fast’. Drainage rate is
    looked up in table 4 (page 23) of *guidelines* together with soil
    texture.

Environmental and crop-related variables include:

  - **Expected yield**, it contributes to **\(f_{N,a}\)** component,
    unit of measure kg/ha. It can be estimated from statistical
    [estimates](http://dati.istat.it "ISTAT web site") of crop areas and
    yields at province, regional, or national level. As an example,
    wheat expected yield is 2,900 kg/ha in the province of Rome, based
    on 2019 Istat estimates.

  - **Rainfall October - January**, this is the cumulative rainfall in
    mm during 4 autumn and winter months, from October to January. It
    contributes to the **C** component where nitrogen leaching is
    estimated as a quantity proportional to rainfall.

  - **Previous organic fertilization**, this is the supply of nitrogen
    in kg/ha from the organic fertilization performed during previous
    crop(s). It contributes to the **\(f_{N,f}\)** component. No organic
    fertilization may be passed as a 0-value to this variable.

  - **Organic fertilizer**, this is the type of organic fertilizer as
    found in table 6 (page 25) of the *guidelines*: ‘Conditioners’,
    ‘Bovine manure’, ‘Swine and poultry manure’. It contributes to the
    **\(f_{N,f}\)** component.

  - **Years from previous organic fertilization**, this contributes to
    the **\(f_{N,f}\)** component, to compute the quantity of available
    N left in the soil, table 6 (page 25) of the *guidelines*. It can
    either be ‘1’, ‘2’, ‘3’ years.

  - **N from atmosphere or N-fixing bacteria**, this contributes to the
    **\(f_{N,g}\)** component and takes the form of a coefficient in the
    range from 0 to 1 to be applied to the value of 20 kg/ha estimated
    for a yearly crop close to urban settlements.

Let’s now set the variables values and bind them to the soil analysis
table. Let’s suppose the values are constant among all soil samples, as
it may be the case when all sampling points come from a uniform field
that will be sown with the same crop:

``` r
soil_l <- list(
  crop                 = "Durum wheat",
  part                 = "Fruits",
  crop_type            = "Fall / winter crops",
  expected_yield_kg_ha = 2900L,
  prev_crop            = "Grassland, legumes <5%", 
  texture              = "Loam", 
  drainage_rate        = "Slow",
  oct_jan_pr_mm        = 350L,
  n_supply_prev_frt_kg_ha = 0L,
  n_supply_atm_coeff   = 1)
```

### Third step: estimate the components of N balance

Let’s compute each component of the nitrogen balance:

``` r
nutrient_dt <- demand_nutrient(
  soil_dt, 
  soil_l, 
  nutrient  = "nitrogen", 
  blnc_cmpt = TRUE)
knitr::kable(nutrient_dt)
```

| A\_N\_kg\_ha | B\_N\_kg\_ha | C\_N\_kg\_ha | D\_N\_kg\_ha | E\_N\_kg\_ha | F\_N\_kg\_ha | G\_N\_kg\_ha |
| -----------: | -----------: | -----------: | -----------: | -----------: | -----------: | -----------: |
|        66.12 |     \-36.734 |        3.614 |      12.8569 |         \-15 |            0 |         \-20 |
|        66.12 |     \-44.466 |        4.290 |      15.5631 |         \-15 |            0 |         \-20 |
|        66.12 |     \-42.896 |        4.160 |      15.0136 |         \-15 |            0 |         \-20 |
|        66.12 |     \-44.152 |        4.264 |      15.4532 |         \-15 |            0 |         \-20 |
|        66.12 |     \-31.540 |        3.172 |      11.0390 |         \-15 |            0 |         \-20 |
|        66.12 |     \-38.330 |        3.770 |      13.4155 |         \-15 |            0 |         \-20 |
|        66.12 |     \-42.582 |        4.134 |      14.9037 |         \-15 |            0 |         \-20 |
|        66.12 |     \-43.550 |        4.238 |      15.2425 |         \-15 |            0 |         \-20 |
|        66.12 |     \-37.702 |        3.718 |      13.1957 |         \-15 |            0 |         \-20 |
|        66.12 |     \-40.528 |        3.952 |      14.1848 |         \-15 |            0 |         \-20 |
|        66.12 |     \-44.008 |        4.264 |      15.4028 |         \-15 |            0 |         \-20 |
|        66.12 |     \-35.962 |        3.562 |      12.5867 |         \-15 |            0 |         \-20 |
|        66.12 |     \-46.690 |        4.498 |      16.3415 |         \-15 |            0 |         \-20 |
|        66.12 |     \-48.114 |        4.914 |      16.8399 |         \-15 |            0 |         \-20 |
|        66.12 |     \-38.330 |        3.770 |      13.4155 |         \-15 |            0 |         \-20 |
|        66.12 |     \-43.524 |        4.212 |      15.2334 |         \-15 |            0 |         \-20 |
|        66.12 |     \-48.530 |        5.330 |      16.9855 |         \-15 |            0 |         \-20 |
|        66.12 |     \-39.416 |        3.848 |      13.7956 |         \-15 |            0 |         \-20 |
|        66.12 |     \-41.156 |        4.004 |      14.4046 |         \-15 |            0 |         \-20 |
|        66.12 |     \-38.788 |        3.796 |      13.5758 |         \-15 |            0 |         \-20 |

All components were estimated, note that **\(f_{N,b}\)** is computed as
`(b1+b2)*-1`. Remember that positive values are demand pools of N in
soil or N flows leaving the field (such as **\(f_{N,c}\)** component);
negative values are current N pools in the soils that are available for
assimilation to the crop or that will be available during the time-frame
of crop growth.

``` r
fertzl_dt <- cbind(nutrient_dt, soil_dt)
fertzl_cols <- grep(
  pattern = "^[A-G]_N_kg_ha$", 
  x       = colnames(nutrient_dt), 
  value   = TRUE)
knitr::kable(fertzl_dt)
```

| A\_N\_kg\_ha | B\_N\_kg\_ha | C\_N\_kg\_ha | D\_N\_kg\_ha | E\_N\_kg\_ha | F\_N\_kg\_ha | G\_N\_kg\_ha | id | N\_pc |       CNR | SOM\_pc | Clay\_pc |
| -----------: | -----------: | -----------: | -----------: | -----------: | -----------: | -----------: | -: | ----: | --------: | ------: | -------: |
|        66.12 |     \-36.734 |        3.614 |      12.8569 |         \-15 |            0 |         \-20 |  1 | 0.139 |  9.568345 |    2.30 |       34 |
|        66.12 |     \-44.466 |        4.290 |      15.5631 |         \-15 |            0 |         \-20 |  2 | 0.165 |  9.818182 |    2.79 |       37 |
|        66.12 |     \-42.896 |        4.160 |      15.0136 |         \-15 |            0 |         \-20 |  3 | 0.160 |  9.750000 |    2.69 |       40 |
|        66.12 |     \-44.152 |        4.264 |      15.4532 |         \-15 |            0 |         \-20 |  4 | 0.164 |  9.817073 |    2.77 |       34 |
|        66.12 |     \-31.540 |        3.172 |      11.0390 |         \-15 |            0 |         \-20 |  5 | 0.122 |  9.344262 |    1.97 |       38 |
|        66.12 |     \-38.330 |        3.770 |      13.4155 |         \-15 |            0 |         \-20 |  6 | 0.145 |  9.586207 |    2.40 |       40 |
|        66.12 |     \-42.582 |        4.134 |      14.9037 |         \-15 |            0 |         \-20 |  7 | 0.159 |  9.748428 |    2.67 |       34 |
|        66.12 |     \-43.550 |        4.238 |      15.2425 |         \-15 |            0 |         \-20 |  8 | 0.163 |  9.754601 |    2.73 |       34 |
|        66.12 |     \-37.702 |        3.718 |      13.1957 |         \-15 |            0 |         \-20 |  9 | 0.143 |  9.580420 |    2.36 |       37 |
|        66.12 |     \-40.528 |        3.952 |      14.1848 |         \-15 |            0 |         \-20 | 10 | 0.152 |  9.671053 |    2.54 |       36 |
|        66.12 |     \-44.008 |        4.264 |      15.4028 |         \-15 |            0 |         \-20 | 11 | 0.164 |  9.756098 |    2.76 |       37 |
|        66.12 |     \-35.962 |        3.562 |      12.5867 |         \-15 |            0 |         \-20 | 12 | 0.137 |  9.562044 |    2.25 |       40 |
|        66.12 |     \-46.690 |        4.498 |      16.3415 |         \-15 |            0 |         \-20 | 13 | 0.173 |  9.826590 |    2.93 |       38 |
|        66.12 |     \-48.114 |        4.914 |      16.8399 |         \-15 |            0 |         \-20 | 14 | 0.189 |  9.947090 |    3.24 |       38 |
|        66.12 |     \-38.330 |        3.770 |      13.4155 |         \-15 |            0 |         \-20 | 15 | 0.145 |  9.586207 |    2.40 |       40 |
|        66.12 |     \-43.524 |        4.212 |      15.2334 |         \-15 |            0 |         \-20 | 16 | 0.162 |  9.753086 |    2.73 |       34 |
|        66.12 |     \-48.530 |        5.330 |      16.9855 |         \-15 |            0 |         \-20 | 17 | 0.205 | 10.048780 |    3.56 |       36 |
|        66.12 |     \-39.416 |        3.848 |      13.7956 |         \-15 |            0 |         \-20 | 18 | 0.148 |  9.662162 |    2.47 |       39 |
|        66.12 |     \-41.156 |        4.004 |      14.4046 |         \-15 |            0 |         \-20 | 19 | 0.154 |  9.675325 |    2.58 |       36 |
|        66.12 |     \-38.788 |        3.796 |      13.5758 |         \-15 |            0 |         \-20 | 20 | 0.146 |  9.657534 |    2.43 |       37 |

### Fourth step: estimate N demand

We are finally arrived to the last step of assembling all components of
the N balance. Let’s perform the actual addition of the A\_N\_kg\_ha,
B\_N\_kg\_ha, C\_N\_kg\_ha, D\_N\_kg\_ha, E\_N\_kg\_ha, F\_N\_kg\_ha,
G\_N\_kg\_ha components:

``` r
fertzl_dt[, n_demand_kg_ha := rowSums(.SD), .SDcols = fertzl_cols]
knitr::kable(fertzl_dt[, c("id", "n_demand_kg_ha")])
```

| id | n\_demand\_kg\_ha |
| -: | ----------------: |
|  1 |           10.8569 |
|  2 |            6.5071 |
|  3 |            7.3976 |
|  4 |            6.6852 |
|  5 |           13.7910 |
|  6 |            9.9755 |
|  7 |            7.5757 |
|  8 |            7.0505 |
|  9 |           10.3317 |
| 10 |            8.7288 |
| 11 |            6.7788 |
| 12 |           11.3067 |
| 13 |            5.2695 |
| 14 |            4.7599 |
| 15 |            9.9755 |
| 16 |            7.0414 |
| 17 |            4.9055 |
| 18 |            9.3476 |
| 19 |            8.3726 |
| 20 |            9.7038 |

All sampling points end up needing a supply of nitrogen of 8.318065
kg/ha on average.

## Alternative pathway

A more direct pathway to get to B\_N estimation is to set argument
`blnc_cmpt` of `demand_nutrient` function to `FALSE` (the default
setting). This will have the effect of returning directly B\_N instead
of its balance components thereby skipping the fourth step:

``` r
nutrient_dt <- demand_nutrient(
  soil_dt, 
  soil_l, 
  nutrient = "nitrogen", 
  blnc_cmpt = FALSE)
knitr::kable(nutrient_dt)
```

| nitrogen |
| -------: |
|  10.8569 |
|   6.5071 |
|   7.3976 |
|   6.6852 |
|  13.7910 |
|   9.9755 |
|   7.5757 |
|   7.0505 |
|  10.3317 |
|   8.7288 |
|   6.7788 |
|  11.3067 |
|   5.2695 |
|   4.7599 |
|   9.9755 |
|   7.0414 |
|   4.9055 |
|   9.3476 |
|   8.3726 |
|   9.7038 |

That’s it as far as nitrogen fetilization plan is concerned.

## References

<div id="refs" class="references hanging-indent">

<div id="ref-guidelines2020">

Assessorato Agricoltura, Promozione della Filiera e della Cultura del
Cibo, Ambiente e Risorse Naturali. 2020. “Parte Agronomica, Norme
Generali, Disciplinare Di Produzione Integrata Della Regione Lazio -
SQNPI.” Regione Lazio.
<http://www.regione.lazio.it/rl_agricoltura/?vw=documentazioneDettaglio&id=52065>.

</div>

</div>
