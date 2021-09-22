cd "C:\Users\sherr\Dropbox\CurrentSubmission\Yield\2021\data"

import delimited prod_region.csv, clear
keep areacode area itemcode item year value
rename value prod
rename areacodefao regioncode
rename area region
rename itemcodefao itemcode
egen id = concat(regioncode itemcode year)
save prod_region.dta, replace


import delimited area_region.csv, clear
keep areacode area itemcode item year value
rename area region
rename areacodefao regioncode
rename itemcodefao itemcode
rename value area
egen id = concat(regioncode itemcode year)
save area_region.dta, replace

merge 1:1 id using prod_region




drop _merge
save data_all.dta, replace


import excel "calorie.xlsx", sheet("FAOSTAT_data_5-28-2020") firstrow clear

rename ItemCode itemcode
rename D calorie_original_item

merge 1:m itemcode using data_all



sort regioncode itemcode year
order id regioncode region, first
order G, last

list if _merge<3

* drop palm kernels and palm oil since we will just use plam fruit data
drop if item=="Palm kernels" | item=="Oil, palm"

/* The calorie for Kapok fruit is for Kapok oil. 27.5% of kapok seeds is kapok oil. 
* Use the Kapok seeds production data instead of the Kapok fruit data
* Area is still the area for Kapok fruit

replace prod = prod[_n+59] if Item == "Kapok fruit"
drop if item == "Kapokseed in shell" 2019 update removed the Kapokseed in shell item*/


/* Area data for cottonseed missining, using the area for seed cotton
replace area = area[_n-59] if Item == "Cottonseed" 
replace area = area[_n-27] if Item == "Cottonseed" & region =="Central Asia"
drop if item == "Seed cotton" 2019 update removed the cottonseed item*/

* The calorie data for "Vegetables, leguminous nes" is the average of "beans green, peas greem, broad breans green, string beans"
replace calorie_original_item =" avg of beans, peas, broad, string beans" if item == "Vegetables, leguminous nes"


*drop cotton lint, Kapok fibre, Coir not for human consumption. Cottonseed, Kapok oil   * and Coconut already counted.

drop if item == "Cotton lint" 
drop if item == "Kapok fibre" 

drop if item =="Coir"

* Now these are the items with both production and area info, but they are not for human * consumption
drop if item == "Jute" 
drop if item == "Bastfibres, other"
drop if item == "Ramie"
drop if item == "Flax fibre and tow"
drop if item == "Hemp tow waste"
drop if item == "Sisal"
drop if item == "Agave fibres nes"
drop if item == "Manila fibre (abaca)"
drop if item == "Fibre crops nes"
drop if item == "Tobacco, unmanufactured"
drop if item == "Rubber, natural"
drop if item == "Gums, natural" //production data not available
drop if item == "Pyrethrum, dried"
drop if item == "Jojoba seed" // mostly used for personal care products
drop if item == "Tallowtree seed" //seeds and fruit of the tree are poisonous to humans. Not for human consumption?
drop if item == "Hops" //hops are added to provide a bitter flavour to beer, no calorie

drop if item == "Rice, paddy (rice milled equivalent)"

drop _merge

replace Conversionfactor=1 if Conversionfactor==.

list if prod == . & area !=.
list if prod != . & area ==.
list if Calorieperton ==.

* drop if prod == . & area !=.
* drop if prod != . & area ==.
drop if regioncode==.

* check consistency with the aggregate data

drop C G
gen calorie = prod * Calorieperton * Conversionfactor
format calorie %20.7g

save regiondataall.dta, replace

***********************************************************************************
*  Now generate regional aggregate index
***********************************************************************************
use regiondataall.dta, clear


/* Region code
5101 Eastern Africa
5102 Middle Africa	
5103 Northern Africa	
5104  Southern Africa
5105  Western Africa
5203  Northern America
5204 Central America 
5206  Caribbean
5207 South America
5301 Central Asia
5401 Eastern Europe
5302 Eastern Asia
5303 Southern Asia
5304 South-eastern Asia
5305 Western Asia
5402 Northern Europe
5403 Southern Europe
5404 Western Europe
5500 Oceania */




sort year regioncode itemcode
gen group = "EECA" if region=="Eastern Europe" | region == "Central Asia"
replace group = "SEAO" if region=="Southern Asia" | region == "Eastern Asia" | region == "Oceania" | region=="South-eastern Asia"
replace group = "SSA" if region=="Eastern Africa" | region == "Middle Africa" | region == "Southern Africa" | region == "Western Africa"
replace group = "MENA" if region=="Northern Africa" | region == "Western Asia" 
replace group ="LAC" if region=="Central America" | region == "Caribbean" | region == "South America" 
replace group = "High" if region=="Northern Europe" | region == "Southern Europe" | region=="Western Europe" | region == "Northern America" 


input str213 group1
"EECA"
"SEAO"
"SSA" 
"MENA"
"LAC"
"High"
end


  

levelsof group1, local(levels)
foreach i of local levels {
	di "`i'"
    preserve
    keep if group == "`i'" 
	by year: egen area`i' = total(area) 
    by year: egen calorie`i' = total(calorie) 
    format area`i' calorie`i' %20.0g
    gen `i' = calorie`i'/area`i'
	
	if "`i'"=="EECA"{
	  keep if region=="Eastern Europe"
	  sort regioncode itemcode year
	  keep year calorie`i' area`i' `i'
	  keep in 1/59
	  save cyield_region.dta, replace
	}
	else{
	  sort regioncode itemcode year
	  keep year calorie`i' area`i' `i'
	  keep in 1/59
	  merge 1:1 year using cyield_region.dta
	  drop _merge
	save cyield_region.dta, replace
	}
	restore
}

preserve
by year: egen areaLow = total(area) if group=="EECA" | group=="SEAO" | group=="SSA" | group=="MENA" | group=="LAC"
by year: egen calorieLow = total(calorie) if group=="EECA" | group=="SEAO" | group=="SSA" | group=="MENA" | group=="LAC"
format areaLow calorieLow %20.0g

keep if group=="EECA" | group=="SEAO" | group=="SSA" | group=="MENA" | group=="LAC"
gen Low = calorieLow/areaLow

sort regioncode itemcode year
keep year calorieLow areaLow Low
keep in 1/59
merge 1:1 year using cyield_region.dta
drop _merge
save cyield_region.dta, replace	  
	  


use cyield_region.dta, clear
gen caloireAll = calorieLow + calorieHigh
gen areaAll = areaLow + areaHigh
gen yieldAll = caloireAll/areaAll
format caloireAll areaAll %20.0g

save cyield_region.dta, replace



**********************************
use cyield_region.dta, clear


 export excel using "C:\Users\sherr\Dropbox\CurrentSubmission\Yield\2021\data\YieldIndex.xlsx", sheet("region") firstrow(variables) 




*************************************************************************************
*===================================================================================
* Now do robustness check by deleting all missing values
*================================================================================

use regiondataall.dta, clear

preserve
keep if area==0 | area==.
restore


drop if area==0 | area==.


sort year regioncode itemcode
gen group = "EECA" if region=="Eastern Europe" | region == "Central Asia"
replace group = "SEAO" if region=="Southern Asia" | region == "Eastern Asia" | region == "Oceania" | region=="South-eastern Asia"
replace group = "SSA" if region=="Eastern Africa" | region == "Middle Africa" | region == "Southern Africa" | region == "Western Africa"
replace group = "MENA" if region=="Northern Africa" | region == "Western Asia" 
replace group ="LAC" if region=="Central America" | region == "Caribbean" | region == "South America" 
replace group = "High" if region=="Northern Europe" | region == "Southern Europe" | region=="Western Europe" | region == "Northern America" 


input str213 group1
"EECA"
"SEAO"
"SSA" 
"MENA"
"LAC"
"High"
end


levelsof group1, local(levels)
foreach i of local levels {
	di "`i'"
    preserve
    keep if group == "`i'" 
	by year: egen area`i' = total(area) 
    by year: egen calorie`i' = total(calorie) 
    format area`i' calorie`i' %20.0g
    gen `i' = calorie`i'/area`i'
	
	if "`i'"=="EECA"{
	  keep if region=="Eastern Europe"
	  sort regioncode itemcode year
	  keep year calorie`i' area`i' `i'
	  keep in 1/58
	  save cyield_regionnomissing.dta, replace
	}
	else{
	  sort regioncode itemcode year
	  keep year calorie`i' area`i' `i'
	  keep in 1/58
	  merge 1:1 year using cyield_regionnomissing.dta
	  drop _merge
	save cyield_regionnomissing.dta, replace
	}
	restore
}

preserve
by year: egen areaLow = total(area) if group=="EECA" | group=="SEAO" | group=="SSA" | group=="MENA" | group=="LAC"
by year: egen calorieLow = total(calorie) if group=="EECA" | group=="SEAO" | group=="SSA" | group=="MENA" | group=="LAC"
format areaLow calorieLow %20.0g

keep if group=="EECA" | group=="SEAO" | group=="SSA" | group=="MENA" | group=="LAC"
gen Low = calorieLow/areaLow

sort regioncode itemcode year
keep year calorieLow areaLow Low
keep in 1/58
merge 1:1 year using cyield_regionnomissing.dta
drop _merge
save cyield_regionnomissing.dta, replace	  
	  


use cyield_regionnomissing.dta, clear
gen caloireAll = calorieLow + calorieHigh
gen areaAll = areaLow + areaHigh
gen yieldAll = caloireAll/areaAll
format caloireAll areaAll %20.0g

save cyield_region_nomissing.dta, replace



**********************************
use cyield_regionnomissing.dta, clear


 export excel using "C:\Users\sherr\Dropbox\CurrentSubmission\Yield\2020\160crop\YieldIndex.xlsx", sheet("region_nomissing") firstrow(variables) 



/* This was used to check whether the regional level data matches with the world data

sort year regioncode itemcode
by year: egen calorietotal = total(caloriecrop)
format calorietotal %20.7g

by year: egen areatotal = total(area)
format areatotal %20.7g

gen cyield = calorietotal/areatotal


*For each crop each year

sort regioncode itemcode year

egen croparea = total(area), by(itemcode year)
format croparea %20.7g

egen cropprod = total(prod), by(itemcode year)
format cropprod %20.7g

sort itemcode year

save data_all.dta, replace

egen N_cropbyyear = count(itemcode), by (year)


preserve
keep if area==. & prod !=. & prod !=0
restore */



***************Now let's examine missing data
***Missing data
* shown in the area data (with no values), but not in the prod data. 
*     5101       Eastern Africa        541       Fruit, stone nes  , 1961-1968
*     5101       Eastern Africa        558       Berries nes ,       1961-1983
*     5102        Middle Africa        181       Broad beans, horse beans, dry   1961 - 1987
*     5102        Middle Africa        220                             Chestnut   1961-1984
*     5102        Middle Africa        225                Hazelnuts, with shell   1961 -1985
*      5102        Middle Africa        401          Chillies and peppers, green   1961-1983
*      5102        Middle Africa        526                             Apricots   1961-1984
*      5102        Middle Africa        534               Peaches and nectarines   1961-1986
*      5102        Middle Africa        536                      Plums and sloes   1961-1987
*      5102        Middle Africa        541                     Fruit, stone nes   1961-1979
*     5102        Middle Africa        569                                 Figs   1961-1980
*      5103      Northern Africa        225                Hazelnuts, with shell   1961 -1988
*      5103      Northern Africa        407   Leeks, other alliaceous vegetables   1961-1985
*     5103      Northern Africa        544                         Strawberries   1961-1986
*     5103      Northern Africa        558                          Berries nes   1961 -1985
*      5105       Western Africa        223                           Pistachios   2012-2013
*     5206            Caribbean        687                  Pepper (piper spp.)   1961-1980
*     5207        South America        225                Hazelnuts, with shell   1990
*     5207        South America        547                          Raspberries   1990
*    5207        South America        550                             Currants   1990      
*    5207        South America        554                          Cranberries   1990      
 *    5303        Southern Asia        336                             Hempseed   1990      
 *    5304   South-eastern Asia        367                            Asparagus   1961-1977
 *    5500              Oceania        587                           Persimmons   1961-1982
 *     5500              Oceania        702           Nutmeg, mace and cardamoms   1961    
*      5500              Oceania        813                                 Coir   1992-1997

* Shown in the prod data, but not in the area data

*  5101   Eastern Africa        220                 Chestnut   1961





*************************************************
* Eastern Africa Area code = 5101
* 
* 5101	Eastern Africa	89		Buckwheat	1961 - 1998 both prod and area missing..numbers after 1998 small
* 5101	Eastern Africa	135		Yautia (cocoyam)	missing for all years
* 5101	Eastern Africa	220		Chestnut	1961-2018 area data missing, 1961-1989 prod data missing, prod data after 1989 small
* 5101	Eastern Africa	226		Areca nuts	1961 -2018 area data missing, 1961-1985 prod data missing, prod data after 1985 small	




