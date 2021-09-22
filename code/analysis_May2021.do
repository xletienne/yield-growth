


//Main analysis: aggregated index and various sub-indicies (crops)

clear all
use cyield.dta
merge 1:1 year using cyield_region.dta




tsset year

gen trend=_n
gen trend2=trend^2


rename cyield all
replace all=all/1000

rename Big4 big4
replace big4=big4/1000

rename Big4Other big4other
replace big4other=big4other/1000

rename Low low
replace low=low/1000

rename High high
replace high=high/1000



* Structural break test for the aggregate yield, 1993 is the break date

quietly regress all trend
estat sbcusum
quietly regress all trend
estat sbsingle
estat sbsingle,  all
estat sbsingle,  generate(wald)
tsline wald, title("Wald test statistics")

scalar br=1992-1960
scalar br1=1992
mkspline trend_before `=br' trend_after =trend, marginal


eststo clear

* Table 1

*** All

regress all trend
predict resid, r
dfgls resid //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: quietly regress all trend
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'


regress all trend trend2
predict resid2, r
dfgls resid2 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid2 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: quietly regress all trend trend2
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'


quietly regress all trend_before trend_after
predict resid3, r
dfgls resid3 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid3 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: quietly regress all trend_before trend_after
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'


*** Big 4

regress big4 trend
predict resid4, r
dfgls resid4 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid4 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: quietly regress big4 trend
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'


regress big4 trend trend2
predict resid5, r
dfgls resid5 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid5 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: quietly regress big4 trend trend2
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'

quietly regress big4 trend_before trend_after
predict resid6, r
dfgls resid6 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid6 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: quietly regress big4 trend_before trend_after
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'


*** Other

regress big4other trend
predict resid7, r
dfgls resid7 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid7 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: quietly regress big4other trend
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'


regress big4other trend trend2
predict resid8, r
dfgls resid8 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid8 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: quietly regress big4other trend trend2
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'

quietly regress big4other trend_before trend_after
predict resid9, r
dfgls resid9 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid9 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: quietly regress big4other trend_before trend_after
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'

*** Mature

regress high trend
predict resid10, r
dfgls resid10 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid10 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: quietly regress high trend
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'


regress high trend trend2
predict resid11, r
dfgls resid11 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid11 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: quietly regress high trend trend2
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'

quietly regress high trend_before trend_after
predict resid12, r
dfgls resid12 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid12 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: quietly regress high trend_before trend_after
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'

*** Growing

regress low trend
predict resid13, r
dfgls resid13 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid13 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: quietly regress low trend
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'


regress low trend trend2
predict resid14, r
dfgls resid14 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid14 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: quietly regress low trend trend2
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'

quietly regress low trend_before trend_after
predict resid15, r
dfgls resid15 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid15 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: quietly regress low trend_before trend_after
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'


esttab using results_table1.rtf, b(2) ///
    se(3) ar2(3) stats(r2_a DF_GLS pTau pPval, fmt(2)) star(* 0.10 ** 0.05 *** 0.01)  replace


	

