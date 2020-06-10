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
    matching is not allowed. Note that `fertplan` implementation of the
    table has separated the crop column into two features, the actual
    “crop” and “part” (eg fruits, whole plant, and so on). The
    available crops are:

| x                                                     |
| :---------------------------------------------------- |
| Kiwifruit                                             |
| Garlic                                                |
| Apricot                                               |
| Orange                                                |
| Green asparagus                                       |
| Oat                                                   |
| Baby leaf                                             |
| Sugar beet                                            |
| Basil                                                 |
| Chard ribs                                            |
| Chard leaves                                          |
| Turnip broccoli                                       |
| Romanesco broccoli                                    |
| Fibre hemp                                            |
| White cabbage                                         |
| Artichoke                                             |
| Cardoon, Thistle                                      |
| Carrot                                                |
| Chestnut tree                                         |
| Cauliflower                                           |
| Cabbage                                               |
| Ethiopian rape, Ethiopian mustard, Abyssinian mustard |
| Kohlrabi or German turnip                             |
| Chickpea                                              |
| Cucumber                                              |
| Chicory                                               |
| Wild cherry, sweet cherry                             |
| Turnip greens                                         |
| Onion                                                 |
| Clementine                                            |
| Watermelon                                            |
| Rapeseed                                              |
| Endive and escarole                                   |
| Cock’s-foot, orchard grass, cat grass                 |
| Alfalfa                                               |
| Winter or summer herbage or temporary grassland       |
| Mixed winter or summer herbage or temporary grassland |
| Green bean                                            |
| Bean                                                  |
| Dried bean                                            |
| Spelt or spelled                                      |
| Broad bean, fava bean, or faba bean                   |
| Field bean                                            |
| Festuca arundinacea                                   |
| Common fig                                            |
| Fennel                                                |
| Strawberry                                            |
| Sunflower                                             |
| Durum wheat                                           |
| Common wheat, bread wheat                             |
| Common wheat, bread wheat (biscuits)                  |
| Strength Wheat or Superior Breadmaking Wheat          |
| Endive                                                |
| Kaki                                                  |
| Raspberry                                             |
| Head lettuce                                          |
| Head lettuce (protected cultivation)                  |
| Lentil (grain)                                        |
| Lemon                                                 |
| Flax (fibre)                                          |
| Flax (grain)                                          |
| Ryegrass (Lolium) for silage                          |
| Italian ryegrass                                      |
| White lupin                                           |
| Maize                                                 |
| Sweet maize                                           |
| Silage maize                                          |
| Mandarin orange                                       |
| Almond                                                |
| Eggplant                                              |
| Apple                                                 |
| Melon, cantalupe, winter melon                        |
| Cranberry                                             |
| Medlar and Loquat                                     |
| Nectarins                                             |
| Hazelnut                                              |
| Common walnut                                         |
| Olive                                                 |
| Barley                                                |
| Foxtail millet                                        |
| Potato                                                |
| Pepper (bell pepper, sweet pepper)                    |
| Pear                                                  |
| Peach                                                 |
| Poplar                                                |
| Poplar for biomass                                    |
| Pea (fresh)                                           |
| Protein pea (with straw)                              |
| Protein pea (without straw)                           |
| Pistachio                                             |
| Tomato for processing                                 |
| Tomato for fresh market (field)                       |
| Tomato for fresh market (greenhouse)                  |
| Leek                                                  |
| Clover meadow                                         |
| Hill meadow-pasture                                   |
| Polyphite meadows \> 50 % legumes                     |
| Hill polyphite cultivated meadows                     |
| Plain permanent meadows                               |
| Parsley                                               |
| Radicchio (red chicory)                               |
| Horseradish                                           |
| Turnip                                                |
| Radish                                                |
| Ribes                                                 |
| Rice                                                  |
| Blueberry                                             |
| Rocket or Arucula (first cut)                         |
| Rocket or Arucula (second cut)                        |
| Shallot                                               |
| Escarole                                              |
| Celery                                                |
| Rye                                                   |
| Soybean                                               |
| Sorghum                                               |
| Sorghum grain                                         |
| Spinach                                               |
| Spinach (for processing)                              |
| European plum                                         |
| Tobacco Bright                                        |
| Tobacco Bright (whole plant)                          |
| Tobacco Burley                                        |
| Tobacco Burley (whole plant)                          |
| Triticale                                             |
| Table grape                                           |
| Gooseberry                                            |
| Valerianella                                          |
| Savoy cabbage                                         |
| Savoy cabbage (for processing)                        |
| Grapes                                                |
| Pumpkin                                               |
| Zucchini (for processing)                             |
| Zucchini (for fresh market)                           |

Crops are organized into crop types for convenience:

  - **Crop part**, this is the part of the crop to be sown that will
    contribute to **\(f_{N,a}\)** component. Note that nitrogen demand
    by crops may greatly differ upon the crop part considered. As an
    example N coefficients for “Durum wheat” crop are:

| crop\_group     | crop        | part  | coeff | element | coeff\_pc |
| :-------------- | :---------- | :---- | :---- | :------ | --------: |
| Herbaceous crop | Durum wheat | Plant | ass.  | N       |      3.11 |
| Herbaceous crop | Durum wheat | Seed  | asp.  | N       |      2.42 |

As a reference crop parts include:

| x               |
| :-------------- |
| Flower-head     |
| Head of salad   |
| Ribs            |
| Leaves          |
| Fruit           |
| Flower + Leaves |
| Plant           |
| Root + Plant    |
| Root            |
| Seed            |
| Tuber           |
| Spear           |

  - **Crop type**, this is the type of crop to be sown to be looked up
    in table 15.3 (page 67) of the *guidelines*. It is used to estimate
    the time coefficient, as a ratio of an year, during which the
    mineralization of nitrogen will take place and, thus, will be
    available to the crop itself. Crop type contributes to b2
    sub-component of **\(f_{N,b}\)** component. Available crop types
    are:

| x                                   |
| :---------------------------------- |
| Orchards in production              |
| Sugar beet                          |
| Hemp                                |
| Fall / winter crops                 |
| Cocksfoot                           |
| Sunflower                           |
| Flax                                |
| White lupin                         |
| Maize                               |
| Vegetables                          |
| Short-cycle vegetables (\<3 months) |
| Long-cycle vegetables (\>1 year)    |
| Meadows                             |
| Rice                                |
| Soybean                             |
| Sorghum                             |
| Tobacco                             |

  - **Previous crop**, this is the name or type of the previous crop, to
    be looked up in table 5 (page 24) of the *guidelines*. Previous crop
    contributes to **\(f_{N,e}\)** component. Available matches include:

| x                                                                       |
| :---------------------------------------------------------------------- |
| Sugar beet                                                              |
| Fall-Winter cereals: straw is removed                                   |
| Fall-Winter cereals: straw is buried                                    |
| Rapeseed                                                                |
| Sunflower                                                               |
| Grain legumes (pea, bean, lentil, etc.)                                 |
| Maize (o corn): stalks asported                                         |
| Maize (o corn): buried stalks                                           |
| Minor leaf vegetables                                                   |
| Potato                                                                  |
| Tomatoes, other vegetables (e.g. cucurbits, cruciferous and liliaceous) |
| Meadows: short-lived or clover                                          |
| Meadows: alfalfa in good condition                                      |
| Meadows: polyphite \>15% legumes                                        |
| Meadows: polyphyte 5-15% fodder legumes                                 |
| Meadows: polyphyte \<5% fodder legumes                                  |
| Soybean                                                                 |
| Sorghum                                                                 |
| Green manure of leguminous plants (in autumn-winter or summer coverage) |

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
    found in table 6 (page 25) of the *guidelines*: ‘Amendments’,
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
  part                 = "Seed",
  crop_type            = "Fall / winter crops",
  expected_yield_kg_ha = 2900L,
  prev_crop            = "Meadows: polyphyte <5% fodder legumes", 
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
|        70.18 |     \-36.734 |        3.614 |      12.8569 |         \-15 |            0 |         \-20 |
|        70.18 |     \-44.466 |        4.290 |      15.5631 |         \-15 |            0 |         \-20 |
|        70.18 |     \-42.896 |        4.160 |      15.0136 |         \-15 |            0 |         \-20 |
|        70.18 |     \-44.152 |        4.264 |      15.4532 |         \-15 |            0 |         \-20 |
|        70.18 |     \-31.540 |        3.172 |      11.0390 |         \-15 |            0 |         \-20 |
|        70.18 |     \-38.330 |        3.770 |      13.4155 |         \-15 |            0 |         \-20 |
|        70.18 |     \-42.582 |        4.134 |      14.9037 |         \-15 |            0 |         \-20 |
|        70.18 |     \-43.550 |        4.238 |      15.2425 |         \-15 |            0 |         \-20 |
|        70.18 |     \-37.702 |        3.718 |      13.1957 |         \-15 |            0 |         \-20 |
|        70.18 |     \-40.528 |        3.952 |      14.1848 |         \-15 |            0 |         \-20 |
|        70.18 |     \-44.008 |        4.264 |      15.4028 |         \-15 |            0 |         \-20 |
|        70.18 |     \-35.962 |        3.562 |      12.5867 |         \-15 |            0 |         \-20 |
|        70.18 |     \-46.690 |        4.498 |      16.3415 |         \-15 |            0 |         \-20 |
|        70.18 |     \-48.114 |        4.914 |      16.8399 |         \-15 |            0 |         \-20 |
|        70.18 |     \-38.330 |        3.770 |      13.4155 |         \-15 |            0 |         \-20 |
|        70.18 |     \-43.524 |        4.212 |      15.2334 |         \-15 |            0 |         \-20 |
|        70.18 |     \-48.530 |        5.330 |      16.9855 |         \-15 |            0 |         \-20 |
|        70.18 |     \-39.416 |        3.848 |      13.7956 |         \-15 |            0 |         \-20 |
|        70.18 |     \-41.156 |        4.004 |      14.4046 |         \-15 |            0 |         \-20 |
|        70.18 |     \-38.788 |        3.796 |      13.5758 |         \-15 |            0 |         \-20 |

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
|        70.18 |     \-36.734 |        3.614 |      12.8569 |         \-15 |            0 |         \-20 |  1 | 0.139 |  9.568345 |    2.30 |       34 |
|        70.18 |     \-44.466 |        4.290 |      15.5631 |         \-15 |            0 |         \-20 |  2 | 0.165 |  9.818182 |    2.79 |       37 |
|        70.18 |     \-42.896 |        4.160 |      15.0136 |         \-15 |            0 |         \-20 |  3 | 0.160 |  9.750000 |    2.69 |       40 |
|        70.18 |     \-44.152 |        4.264 |      15.4532 |         \-15 |            0 |         \-20 |  4 | 0.164 |  9.817073 |    2.77 |       34 |
|        70.18 |     \-31.540 |        3.172 |      11.0390 |         \-15 |            0 |         \-20 |  5 | 0.122 |  9.344262 |    1.97 |       38 |
|        70.18 |     \-38.330 |        3.770 |      13.4155 |         \-15 |            0 |         \-20 |  6 | 0.145 |  9.586207 |    2.40 |       40 |
|        70.18 |     \-42.582 |        4.134 |      14.9037 |         \-15 |            0 |         \-20 |  7 | 0.159 |  9.748428 |    2.67 |       34 |
|        70.18 |     \-43.550 |        4.238 |      15.2425 |         \-15 |            0 |         \-20 |  8 | 0.163 |  9.754601 |    2.73 |       34 |
|        70.18 |     \-37.702 |        3.718 |      13.1957 |         \-15 |            0 |         \-20 |  9 | 0.143 |  9.580420 |    2.36 |       37 |
|        70.18 |     \-40.528 |        3.952 |      14.1848 |         \-15 |            0 |         \-20 | 10 | 0.152 |  9.671053 |    2.54 |       36 |
|        70.18 |     \-44.008 |        4.264 |      15.4028 |         \-15 |            0 |         \-20 | 11 | 0.164 |  9.756098 |    2.76 |       37 |
|        70.18 |     \-35.962 |        3.562 |      12.5867 |         \-15 |            0 |         \-20 | 12 | 0.137 |  9.562044 |    2.25 |       40 |
|        70.18 |     \-46.690 |        4.498 |      16.3415 |         \-15 |            0 |         \-20 | 13 | 0.173 |  9.826590 |    2.93 |       38 |
|        70.18 |     \-48.114 |        4.914 |      16.8399 |         \-15 |            0 |         \-20 | 14 | 0.189 |  9.947090 |    3.24 |       38 |
|        70.18 |     \-38.330 |        3.770 |      13.4155 |         \-15 |            0 |         \-20 | 15 | 0.145 |  9.586207 |    2.40 |       40 |
|        70.18 |     \-43.524 |        4.212 |      15.2334 |         \-15 |            0 |         \-20 | 16 | 0.162 |  9.753086 |    2.73 |       34 |
|        70.18 |     \-48.530 |        5.330 |      16.9855 |         \-15 |            0 |         \-20 | 17 | 0.205 | 10.048780 |    3.56 |       36 |
|        70.18 |     \-39.416 |        3.848 |      13.7956 |         \-15 |            0 |         \-20 | 18 | 0.148 |  9.662162 |    2.47 |       39 |
|        70.18 |     \-41.156 |        4.004 |      14.4046 |         \-15 |            0 |         \-20 | 19 | 0.154 |  9.675325 |    2.58 |       36 |
|        70.18 |     \-38.788 |        3.796 |      13.5758 |         \-15 |            0 |         \-20 | 20 | 0.146 |  9.657534 |    2.43 |       37 |

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
|  1 |           14.9169 |
|  2 |           10.5671 |
|  3 |           11.4576 |
|  4 |           10.7452 |
|  5 |           17.8510 |
|  6 |           14.0355 |
|  7 |           11.6357 |
|  8 |           11.1105 |
|  9 |           14.3917 |
| 10 |           12.7888 |
| 11 |           10.8388 |
| 12 |           15.3667 |
| 13 |            9.3295 |
| 14 |            8.8199 |
| 15 |           14.0355 |
| 16 |           11.1014 |
| 17 |            8.9655 |
| 18 |           13.4076 |
| 19 |           12.4326 |
| 20 |           13.7638 |

All sampling points end up needing a supply of nitrogen of 12.378065
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
|  14.9169 |
|  10.5671 |
|  11.4576 |
|  10.7452 |
|  17.8510 |
|  14.0355 |
|  11.6357 |
|  11.1105 |
|  14.3917 |
|  12.7888 |
|  10.8388 |
|  15.3667 |
|   9.3295 |
|   8.8199 |
|  14.0355 |
|  11.1014 |
|   8.9655 |
|  13.4076 |
|  12.4326 |
|  13.7638 |

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
