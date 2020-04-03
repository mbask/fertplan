fertplan introduction
================

The estimation of Nitrogen fertilization concentrations for a yearly
crop is the most complex among the ones detailed in the ‘Disciplinare’.
The Nitrogen fertilization concentration in kg/ha is estimated as the
net resultant of a N balance into the availability pool for the crop and
out of it The N balance involves 8 flux components. Fluxes that increase
N availability to the crop are \> 0 (positive sign), fluxes that deplete
soil N pool or N availability for the crop are \< 0 (negative sign).

The N flux components include:

1.  **A** Crop demand for Nitrogen on the basis of its expected yield
2.  **B** Nitrogen concentration currently in the soil due to its
    fertility. This component sums two Nitrogen pools: **b1** available
    Nitrogen to the crop, and **b2** Nitrogen supply from mineralization
    of organic matter
3.  **C** Nitrogen leached due to precipitation during latest winter
    season
4.  **D** Nitrogen loss due to denitrification
5.  **E** Residual Nitrogne from previous crop
6.  **F** Residual Nitrogen from previous organic fertilizations
7.  **G** Nitrogen supply from atmospheric depositions and from N-fixing
    bacteria

### First step: load soil analyses

Let’s begin with some minimal data from soil physical and chemical
analyses on a few sampling points in the field.

``` r
soil_dt <-  data.table::data.table(
  id = factor(x = c("11", "20", "13", "12", "17")), 
  N_pc = c(0.164, 0.146, 0.173, 0.137, 0.205), 
  CNR = c(9.75609756097561, 9.65753424657534, 9.82658959537572, 9.56204379562044, 10.0487804878049), 
  SOM_pc = c(2.76, 2.43, 2.93, 2.25, 3.56), 
  Clay_pc = c(37, 37, 38, 40, 36))
  knitr::kable(soil_dt)
```

| id | N\_pc |       CNR | SOM\_pc | Clay\_pc |
| :- | ----: | --------: | ------: | -------: |
| 11 | 0.164 |  9.756098 |    2.76 |       37 |
| 20 | 0.146 |  9.657534 |    2.43 |       37 |
| 13 | 0.173 |  9.826590 |    2.93 |       38 |
| 12 | 0.137 |  9.562044 |    2.25 |       40 |
| 17 | 0.205 | 10.048780 |    3.56 |       36 |

The table shows the soil chemical and physical status before the planned
crop sowing. The soil analyses elements that will be fed the Nitrogen
balance estimation are:

  - *N\_pc*, Total Nitrogen content in %
  - *CNR*, Carbon / Nitrogen ratio
  - *SOM\_pc*, Soil Organic Matter in %
  - *Clay\_pc*, Clay content in %

The *id* feature is not relevant to the balance estimation.

### Second step: variable configuration

A few environmental and crop-related variables need to be set. Some
variables need to match those set out in the ‘Disciplinare tables’,
while a few others have to be derived from external sources.

Matching-variables are:

  - **Crop**, this is the name of the crop to be sown and will be used
    to lookup the its Nitrogen demand in table 15.2 (page 63) of the
    ‘Disciplinare’ to contribute to **A** component. The name must
    match one of the following crop names available. Partial matching is
    allowed, provided that the partial string is unique among crop
    names. The allowed crop names is:

| x                                                                   |
| :------------------------------------------------------------------ |
| Actinidia frutti, legno e foglie                                    |
| Actinidia solo frutti                                               |
| Aglio                                                               |
| Albicocco frutti, legno e foglie                                    |
| Albicocco solo frutti                                               |
| Arancio frutti, legno e foglie                                      |
| Arancio solo frutti                                                 |
| Asparago verde (pianta intera)                                      |
| Asparago verde (turioni)                                            |
| Avena                                                               |
| Avena pianta intera                                                 |
| Barbabietola da zucchero (pianta intera)                            |
| Barbabietola da zucchero (radici)                                   |
| Basilico                                                            |
| Bietola da coste                                                    |
| Bietola da foglie                                                   |
| Broccoletto di rapa (cime di rapa)                                  |
| Broccolo                                                            |
| Canapa da fibra                                                     |
| Cappuccio                                                           |
| Carciofo                                                            |
| Cardo                                                               |
| Carota                                                              |
| Castagno solo frutti                                                |
| Cavolfiore                                                          |
| Cavolo Rapa                                                         |
| Cavolo abissino                                                     |
| Cece                                                                |
| Cetriolo                                                            |
| Cicoria                                                             |
| Ciliegio frutti, legno e foglie                                     |
| Ciliegio solo frutti                                                |
| Cipolla                                                             |
| Clementine frutti, legno e foglie                                   |
| Clementine solo frutti                                              |
| Cocomero                                                            |
| Colza                                                               |
| Colza pianta intera                                                 |
| Endivie (indivie riccia e scarola)                                  |
| Erba mazzolina                                                      |
| Erba medica                                                         |
| Erbai aut. Prim. Estivi o Prato avv. Graminacee                     |
| Erbai aut. Prim. Misti o Prato avv. Polifita                        |
| Fagiolino da industria                                              |
| Fagiolo in baccelli da sgranare                                     |
| Fagiolo secco                                                       |
| Farro                                                               |
| Farro (pianta intera)                                               |
| Fava                                                                |
| Favino                                                              |
| Festuca arundinacea                                                 |
| Fico frutti, legno e foglie                                         |
| Fico solo frutti                                                    |
| Finocchio                                                           |
| Fragola                                                             |
| Girasole (acheni)                                                   |
| Girasole (pianta intera)                                            |
| Grano duro (granella)                                               |
| Grano duro (pianta intera)                                          |
| Grano tenero (granella)                                             |
| Grano tenero (pianta intera)                                        |
| Grano tenero FF/FPS (granella)                                      |
| Grano tenero FF/FPS (pianta intera)                                 |
| Grano tenero biscottiero (granella)                                 |
| Grano tenero biscottiero pianta intera                              |
| Kaki frutti, legno e foglie                                         |
| Kaki solo frutti                                                    |
| Lampone                                                             |
| Lampone biomassa epigea                                             |
| Lattuga                                                             |
| Lattuga coltura protetta                                            |
| Lenticchia (granella)                                               |
| Limone frutti, legno e foglie                                       |
| Limone solo frutti                                                  |
| Lino fibra                                                          |
| Lino granella                                                       |
| Loglio da insilare                                                  |
| Loiessa                                                             |
| Lupino                                                              |
| Mais da granella (granella)                                         |
| Mais da granella (pianta intera)                                    |
| Mais dolce (pianta intera)                                          |
| Mais dolce (spighe)                                                 |
| Mais trinciato                                                      |
| Mandarino frutti, legno e foglie                                    |
| Mandarino solo frutti                                               |
| Mandorlo frutti, legno e foglie                                     |
| Mandorlo solo frutti                                                |
| Melanzana                                                           |
| Melo frutti, legno e foglie                                         |
| Melo solo frutti                                                    |
| Melone                                                              |
| Mirtillo                                                            |
| Mirtillo biomassa epigea                                            |
| Nespolo frutti, legno e foglie                                      |
| Nespolo solo frutti                                                 |
| Nettarine frutti, legno e foglie                                    |
| Nettarine solo frutti                                               |
| Nocciolo frutti, legno e foglie                                     |
| Nocciolo solo frutti                                                |
| Noce da frutto frutti, legno e foglie                               |
| Noce da frutto solo frutti                                          |
| Olivo olive, legno e foglie                                         |
| Olivo solo olive                                                    |
| Orzo (granella)                                                     |
| Orzo (pianta intera)                                                |
| Panico                                                              |
| Patata                                                              |
| Peperone                                                            |
| Peperone in pieno campo                                             |
| Pero frutti, legno e foglie                                         |
| Pero solo frutti                                                    |
| Pesco frutti, legno e foglie                                        |
| Pesco solo frutti                                                   |
| Pioppo                                                              |
| Pioppo da energia                                                   |
| Pisello mercato fresco                                              |
| Pisello proteico                                                    |
| Pisello proteico + paglia                                           |
| Pomodoro da industria                                               |
| Pomodoro da mensa a pieno campo                                     |
| Pomodoro da mensa in serra                                          |
| Porro                                                               |
| Prati di trifoglio                                                  |
| Prati pascoli in collina                                            |
| Prati polifiti \>50% leguminose                                     |
| Prati polifiti artificiali\_collina                                 |
| Prati stabili in pianura                                            |
| Prezzemolo                                                          |
| Radicchio                                                           |
| Rafano (da sovescio)                                                |
| Rapa                                                                |
| Ravanello                                                           |
| Ribes                                                               |
| Ribes biomassa epigea                                               |
| Riso (granella)                                                     |
| Riso (granella+paglia)                                              |
| Rovo inerme                                                         |
| Rovo inerme biomassa epigea                                         |
| Rucola,1° taglio                                                    |
| Rucola,2° taglio                                                    |
| Scalogno                                                            |
| Sedano                                                              |
| Segale                                                              |
| Segale pianta intera                                                |
| Soia (granella)                                                     |
| Soia (pianta intera)                                                |
| Sorgo da foraggio                                                   |
| Sorgo da granella (pianta intera)                                   |
| Sorgo da granella (solo granella)                                   |
| Spinacio                                                            |
| Spinacio da industria                                               |
| Spinacio da mercato fresco                                          |
| Susino frutti, legno e foglie                                       |
| Susino solo frutti                                                  |
| Tabacco Bright                                                      |
| Tabacco Bright pianta intera                                        |
| Tabacco Burley                                                      |
| Tabacco Burley pianta intera                                        |
| Triticale                                                           |
| Triticale pianta intera                                             |
| Uva da tavola grappoli, tralci e foglie                             |
| Uva da tavola solo grappoli                                         |
| Valerianella                                                        |
| Verza                                                               |
| Verza da industria                                                  |
| Vite per uva da vino (collina e montagna) grappoli, tralci e foglie |
| Vite per uva da vino (collina e montagna) solo grappoli             |
| Vite per uva da vino (pianura) grappoli, legno e foglie             |
| Vite per uva da vino (pianura) solo grappoli                        |
| Zucca                                                               |
| Zucchino da industria                                               |
| Zucchino da mercato fresco                                          |
| baby leaf generica                                                  |
| uva spina biomassa epigea                                           |

  - **Crop type**, this is the type of crop to be sown to be looked up
    in table 15.3 (page 67) of the ‘Disciplinare’. It is used to
    estimate the time coefficient, as a ratio of an year, during which
    the mineralization of Nitrogen will take place and, thus, will be
    available to the crop itself. Crop type contributes to b2
    sub-component of **B** component. Available crop types are:

| x                                  |
| :--------------------------------- |
| Arboree in produzione              |
| Colture a ciclo autunno vernino    |
| Barbabietola                       |
| Canapa                             |
| Girasole                           |
| Lino                               |
| Lupino                             |
| Mais                               |
| Riso (granella)                    |
| Soia                               |
| Sorgo                              |
| Tabacco                            |
| Erba mazzolina                     |
| Prati                              |
| Orticole                           |
| Orticole con ciclo \> di 1 anno    |
| Orticole a ciclo breve (\< 3 mesi) |

  - **Previous crop**, this is the crop present previously than the one
    that will be sown. Previous crop is look up in table 5 (page 24) of
    the ‘Disciplinare’. Previous crop contributes to **E** component.
    Available matches include:

| x                                                                  |
| :----------------------------------------------------------------- |
| Barbabietola                                                       |
| Cereali autunno-vernini: paglia asportata                          |
| Cereali autunno-vernini: paglia interrata                          |
| Colza                                                              |
| Girasole                                                           |
| Leguminose da granella (pisello, fagiolo, lenticchia, ecc          |
| Mais: stocchi asportati                                            |
| Mais: stocchi interrati                                            |
| Orticole minori a foglia                                           |
| Patata                                                             |
| Pomodoro, altre orticole (es.: cucurbitacee, crucifere e liliacee) |
| Prati: Medica in buone condizioni                                  |
| Prati: di breve durata o trifoglio                                 |
| Prati: polifita con + del 15% di leguminose o medicaio diradato    |
| Prati: polifita con leguminose dal 5 al 15%                        |
| Prati: polifita con meno del 5% di leguminose                      |
| Soia                                                               |
| Sorgo                                                              |
| Sovescio di leguminose (in copertura autunno-invernale o estiva)   |

  - **Texture**, soil texture, one of Sandy, Loam, Clayey. Soil texture
    enters in several fluxes of the Nitrogen balance.

  - **Drainage rate**, it contributes to **D** component, can be one of
    no drainage, slow, normal, fast. Drainage rate is looked up in table
    4 (page 23) of ‘Disciplinare’ together with soil texture.

Environmental and crop-related variables include:

  - **Expected yield**, it contributes to **A** component, unit of
    measure kg/ha. It can be estimated from statistical
    [estimates](http://dati.istat.it "ISTAT web site") of crop areas and
    yields at province, regional, or national level. As an example,
    wheat expected yield is 2,900 kg/ha in the province of Rome, based
    on 2019 Istat estimates.

  - **Rainfall October - January**, this is the cumulative rainfall in
    mm during 4 autumn and winter months, from October to January. It
    contributes to the **C** component where Nitrogen leaching is
    estimated as a quantity proportional to rainfall.

  - **Previous organic fertilization**, this is the supply of Nitrogen
    in kg/ha from the organic fertilization performed during previous
    crop(s). It contributes to the **F** component. No organic
    fertilization may be passed as a 0-value to this variable.

  - **Organic fertilizer**, this is the type of organic fertilizer as
    found in table 6 (page 25) of the ‘Disciplinare’: Bovine manure,
    Conditioners, Swine and poultry manure. It contributes to the **F**
    component.

  - **Years from previous organic fertilization**, this contributes to
    the **F** component, to compute the quantity of available N left in
    the soil, table 6 (page 25) of the ‘Disciplinare’. It can either be
    1,2,3 years.

  - **N from atmosphere or N-fixing bacteria**, , this contributes to
    the **G** component and takes the form of a coefficient in the range
    from 0 to 1 to be applied to the value of 20 kg/ha estimated for a
    yearly crop close to urban settlements.

Let’s now set the variables values and bind them to the soil analysis
table. Let’s suppose the values are constant among all soil samples, as
it may be the case when all sampling points come from a uniform field
that will be sown with the same crop:

``` r
soil_dt[
  , `:=` (
    crop                 = "Grano duro (granella)",
    crop_type            = "Colture a ciclo autunno vernino",
    expected_yield_kg_ha = 2900,
    prev_crop            = "Prati: polifita con meno del 5%", 
    texture              = "Loam", 
    drainage_rate        = "slow",
    oct_jan_2019_pr_mm   = 350,
    n_supply_prev_frt_kg_ha = 0,
    n_supply_atm_coeff   = 1)]
knitr::kable(soil_dt)
```

| id | N\_pc |       CNR | SOM\_pc | Clay\_pc | crop                  | crop\_type                      | expected\_yield\_kg\_ha | prev\_crop                      | texture | drainage\_rate | oct\_jan\_2019\_pr\_mm | n\_supply\_prev\_frt\_kg\_ha | n\_supply\_atm\_coeff |
| :- | ----: | --------: | ------: | -------: | :-------------------- | :------------------------------ | ----------------------: | :------------------------------ | :------ | :------------- | ---------------------: | ---------------------------: | --------------------: |
| 11 | 0.164 |  9.756098 |    2.76 |       37 | Grano duro (granella) | Colture a ciclo autunno vernino |                    2900 | Prati: polifita con meno del 5% | Loam    | slow           |                    350 |                            0 |                     1 |
| 20 | 0.146 |  9.657534 |    2.43 |       37 | Grano duro (granella) | Colture a ciclo autunno vernino |                    2900 | Prati: polifita con meno del 5% | Loam    | slow           |                    350 |                            0 |                     1 |
| 13 | 0.173 |  9.826590 |    2.93 |       38 | Grano duro (granella) | Colture a ciclo autunno vernino |                    2900 | Prati: polifita con meno del 5% | Loam    | slow           |                    350 |                            0 |                     1 |
| 12 | 0.137 |  9.562044 |    2.25 |       40 | Grano duro (granella) | Colture a ciclo autunno vernino |                    2900 | Prati: polifita con meno del 5% | Loam    | slow           |                    350 |                            0 |                     1 |
| 17 | 0.205 | 10.048780 |    3.56 |       36 | Grano duro (granella) | Colture a ciclo autunno vernino |                    2900 | Prati: polifita con meno del 5% | Loam    | slow           |                    350 |                            0 |                     1 |

### Third step: estimate the components of N balance

Let’s first estimate **b1** and **b2** sub-components that will enter
either the **B**, **C**, and **D** components:

``` r
soil_dt[
  , `:=` (
    b1_N_kg_ha             = fertplan::b1_available_n(
      total_n_pc     = N_pc, 
      texture        = texture), 
    b2_N_kg_ha             = fertplan::b2_mineralized_n(
      crop_type      = crop_type,
      som_pc         = SOM_pc, 
      cn_ratio       = CNR, 
      texture        = texture))]
knitr::kable(soil_dt[, c("id", "b1_N_kg_ha", "b2_N_kg_ha")])
```

| id | b1\_N\_kg\_ha | b2\_N\_kg\_ha |
| :- | ------------: | ------------: |
| 11 |         4.264 |        39.744 |
| 20 |         3.796 |        34.992 |
| 13 |         4.498 |        42.192 |
| 12 |         3.562 |        32.400 |
| 17 |         5.330 |        43.200 |

Now let’s proceed on estimating the **A-G** components:

``` r
soil_dt[
  , `:=` (
    A_N_kg_ha              = fertplan::A_crop_demand(
      crop_abs       = fertplan::rem_N_coef_of(crop) / 100,
      crop_exp_yield = expected_yield_kg_ha),
    B_N_kg_ha              = fertplan::B_N_in_soil(b1_N_kg_ha, b2_N_kg_ha),
    C_N_kg_ha              = fertplan::C_N_precip_leach(
      available_N      = b1_N_kg_ha, 
      rainfall_oct_jan = oct_jan_2019_pr_mm))][
  , `:=` (
    D_N_kg_ha              = fertplan::D_N_denitrification(
      B             = B_N_kg_ha,
      drainage_rate = drainage_rate,
      soil_texture  = texture),
    E_N_kg_ha              = fertplan::E_N_from_prev_crop(crop = prev_crop),
    F_N_kg_ha              = fertplan::F_N_prev_fertilization(n_supply = n_supply_prev_frt_kg_ha),
    G_N_kg_ha              = fertplan::G_N_from_atmosphere(coeff = n_supply_atm_coeff))]
```

All components were estimated, note that **B** is computed as
`(b1+b2)*-1`. Remember that positive values are demand pools of N in
soil or N flows leaving the field (such as **C** component); negative
values are current N pools in the soils that are available for
assimilation to the crop or that will be available during the time-frame
of crop growth.

``` r
fertzl_cols <- grep(
  pattern = "^[A-G]_N_kg_ha$", 
  x       = colnames(soil_dt), 
  value   = TRUE)
id_fertzl_cols <- c("id", fertzl_cols)
fertzl_dt <- soil_dt[, ..id_fertzl_cols]
knitr::kable(fertzl_dt)
```

| id | A\_N\_kg\_ha | B\_N\_kg\_ha | C\_N\_kg\_ha | D\_N\_kg\_ha | E\_N\_kg\_ha | F\_N\_kg\_ha | G\_N\_kg\_ha |
| :- | -----------: | -----------: | -----------: | -----------: | -----------: | -----------: | -----------: |
| 11 |        66.12 |     \-44.008 |        4.264 |      15.4028 |         \-15 |            0 |         \-20 |
| 20 |        66.12 |     \-38.788 |        3.796 |      13.5758 |         \-15 |            0 |         \-20 |
| 13 |        66.12 |     \-46.690 |        4.498 |      16.3415 |         \-15 |            0 |         \-20 |
| 12 |        66.12 |     \-35.962 |        3.562 |      12.5867 |         \-15 |            0 |         \-20 |
| 17 |        66.12 |     \-48.530 |        5.330 |      16.9855 |         \-15 |            0 |         \-20 |

### Fourth step: estimate the N balance

We are finally arrived to the last step of assembling all components of
the N balance. Let’s perform the actual addition of the A\_N\_kg\_ha,
B\_N\_kg\_ha, C\_N\_kg\_ha, D\_N\_kg\_ha, E\_N\_kg\_ha, F\_N\_kg\_ha,
G\_N\_kg\_ha components:

``` r
fertzl_dt[, n_demand_kg_ha := rowSums(.SD), .SDcols = fertzl_cols]
knitr::kable(fertzl_dt[, c("id", "n_demand_kg_ha")])
```

| id | n\_demand\_kg\_ha |
| :- | ----------------: |
| 11 |            6.7788 |
| 20 |            9.7038 |
| 13 |            5.2695 |
| 12 |           11.3067 |
| 17 |            4.9055 |

All sampling points end up needing a supply of Nitrogen of 7.59286 kg/ha
on average.

That’s it as far as Nitrogen fetilization plan is concerned.

Stay tuned for P and K plans…
