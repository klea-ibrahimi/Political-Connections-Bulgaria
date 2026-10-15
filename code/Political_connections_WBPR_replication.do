**************************************************************************
*** REPLICATION DO-FILE
*** "The Economic Impact of Firms' Political Connections"
*** Ibrahimi, Fazekas, Schiffbauer, Galev
***
*** Produces all tables of the paper.
*** Starting dataset: Orbis_pcfirms_elections_merged.dta
***   (political connection variables and TFP already computed;
***    election-based treatment variables are defined below)
***
*** Structure
***   0.  Setup
***   PART A - FIRM-LEVEL ANALYSIS
***   A.1 Sample and variable definitions
***   Table 1   Descriptive statistics: outcomes (all firm-years)
***   Tables 2-3 Descriptive statistics: size, age, sector, region (2010)
***   Table 5   Connecting to power - firm performance
***   Table 6   Connecting to power - local vs national elections
***   Table 7   Losing connections
***   Table 10  Election margins (Annex)
***   PART B - SECTOR-LEVEL ANALYSIS
***   B.1 Sample and variable definitions
***   Table 4   Number of sectors across years
***   Table 8   Sector connecting to power
***   Table 9   Sector connecting to power - local vs national elections
***
*** Figures 1 and 2 (election timelines) are illustrations based on the
*** election calendar and are not produced by code.
**************************************************************************

**************************************************************************
*** 0. SETUP
**************************************************************************
clear all
set more off
version 18

*** Set the root folder of the replication package (the only path to edit)
global root "/Users/kleaibrahimi/Library/CloudStorage/Dropbox/bulgaria/World_Bank/replication_package"

global data    "${root}/data"
global tables  "${root}/output/tables"

*** Required user-written packages (uncomment to install)
* ssc install ftools,    replace
* ssc install reghdfe,   replace
* ssc install estout,    replace
* ssc install coefplot,  replace
* ssc install ietoolkit, replace   // iebaltab

*** Variables loaded from the starting dataset
global keepvars bvdidnumber empl nuts3_int year lnsales_real lnva_real ///
	lnempl lnrev_real lnaveragecostofemployee_th_real lnfixedassets_real ///
	lnintangiblefixedassets_real lncap_real lnage markup_tl_pc Markup_tl_pc ///
	Markup_cd_pc markup_cd_pc tfp_cd_pc tfp_tl_pc gained_power_n ///
	remain_power_n lost_power_n power_l gained_power_l remain_power_l lost_power_l ///
	local_2011 local_2015 local_2019 local_2007 mergepc first_treat ///
	local_firm national_firm size age_ct sectors_group ///
	plforperiodnetincome_real lnoperatingplebit_real ///
	operatingplebitmargin plnetincomemargin ///
	operatingplebitmarginL plnetincomemarginL lnplforperiodnetincome_real ///
	lninv_real lnsalesw lnvaw lnkl intangiblesh operatingplebit_real ///
	Parliament_41 Parliament_42 Parliament_43 Parliament_44 locally_con ///
	national_conn age emp nace2 standardisedlegalform active nace4 codemun ///
	margins_2015 margins_2011 materialcosts_real


**************************************************************************
**************************************************************************
*** PART A - FIRM-LEVEL ANALYSIS
**************************************************************************
**************************************************************************

**************************************************************************
*** A.1 SAMPLE AND VARIABLE DEFINITIONS
**************************************************************************
use ${keepvars} using "${data}/Orbis_pcfirms_elections_merged.dta", clear

drop if missing(codemun) // drop observations with no information on municipality code

gen pcfirm=0
replace pcfirm=1 if mergepc==3
gen lnmaterial_costs=log(materialcosts_real)
encode age_ct, gen(Age_ct)
encode sectors_group, gen(Sectors_group)
encode size, gen(Size)

*** Treatment: firm gets connected to power (wins local or national election)
gen treated=0
replace treated=1 if first_treat==2011 & year>=2011
replace treated=1 if first_treat==2015 & year>=2015
replace treated=1 if first_treat==2013 & year>=2013
replace treated=1 if first_treat==2014 & year>=2014
replace treated=1 if first_treat==2017 & year>=2017
replace treated=0 if first_treat==2011 & local_2015==0 & year>2015
replace treated=0 if first_treat==2013 & Parliament_43==0 &  year>2014
replace treated=1 if Parliament_43==0 & Parliament_42==1 &  year==2014
replace treated=1 if first_treat==2013 & Parliament_43==0 & Parliament_44==1 &  year>2017
replace treated=0 if first_treat==2014 & Parliament_44==0 & year>2017

*** Treatment: firm loses connection (loses election when previously in power)
gen first_lost=0
bysort bvdidnumber: replace first_lost=2011 if local_2007==1 & local_2011==0
bysort bvdidnumber: replace first_lost=2015 if local_2015==0 & local_2011==1
bysort bvdidnumber: replace first_lost=2013 if Parliament_41==1 &  Parliament_42==0
bysort bvdidnumber: replace first_lost=2014 if Parliament_43==0 &  Parliament_42==1 & first_lost==0
bysort bvdidnumber: replace first_lost=2017 if Parliament_44==0 &  Parliament_43==1 & first_lost==0
tab first_lost first_treat if first_lost!=0 & first_treat!=0

gen treated_lost=0
replace treated_lost=1 if year>=first_lost & first_lost!=0

replace treated=0 if first_treat==2007
replace treated=0 if first_treat==2009

*** Control: firms connected before 2010 (until they lose the election)
gen treated_pre10=0
replace treated_pre10=1 if first_treat==2007 & year<first_lost
replace treated_pre10=1 if first_treat==2009 & year<first_lost

*** Outcomes
gen lnprofit=lnplforperiodnetincome_real
gen lnavg_wage=lnaveragecostofemployee_th_real

*** Local vs national connection
gen treated_loc=0
gen treated_nat=0
replace treated_loc=treated if first_treat==2011 | first_treat==2015
replace treated_nat=treated if first_treat==2013 | first_treat==2014 | first_treat==2017

*** Sample restrictions
drop if first_treat==0 & pcfirm==1          // PC firms never connected through elections (other connection types)
xtset bvdidnumber year
drop if first_treat==2007 & first_lost==0   // connected before 2007 and never lose power
drop if first_treat==2009 & first_lost==0   // connected before 2009 and never lose power
drop if pcfirm==1 & missing(first_treat)    // connected, but timing of connection not observed

*** Firm type for descriptive statistics
gen type=1 if first_treat==0
replace type=2 if first_treat==2011 | first_treat==2015
replace type=3 if first_treat==2013 | first_treat==2014 | first_treat==2017
label define type_lbl 1 "Never-connected" 2 "Locally connected" 3 "Nationally connected"
label values type type_lbl


**************************************************************************
*** TABLE 1: Descriptive statistics - outcomes by connection type
*** (all firm-years 2010-2018, observed values only; no imputation)
**************************************************************************
gen log_tfp_tl = log(tfp_tl_pc)
gen log_tfp_cd = log(tfp_cd_pc)

iebaltab lnprofit lnsales_real lnempl lnavg_wage log_tfp_tl log_tfp_cd lnva_real, ///
	grpvar(type) savetex("${tables}/Table1_descriptives.tex") replace

*** Number of unique firms by type
codebook bvdidnumber if type==1, compact
codebook bvdidnumber if type==2, compact
codebook bvdidnumber if type==3, compact


**************************************************************************
*** TABLES 2-3: Descriptive statistics - size, age, sector, region
*** (firms observed in 2010)
**************************************************************************
preserve
	keep if year==2010

	*** Table 2: size, age and sector shares (column %)
	tab Size          type, col nofreq
	tab Age_ct        type, col nofreq
	tab Sectors_group type, col nofreq
	tab type

	*** Table 3: regional (NUTS3) shares (column %)
	tab nuts3_int     type, col nofreq
restore


**************************************************************************
*** Balanced sample for Tables 5, 6, 7 and 10: drop never-connected firms
*** with missing value added per worker
**************************************************************************
drop if pcfirm==0 & lnvaw==.


**************************************************************************
*** TABLE 5: Connecting to power - firm performance
**************************************************************************
eststo clear

local outcomes1 lnprofit lnsales_real lnempl lnavg_wage lnvaw
local outcomes2 tfp_tl_pc tfp_cd_pc
local controls  treated treated_lost treated_pre10

foreach v in `outcomes1' {
	eststo: reghdfe `v' `controls',       cluster(nace4) absorb(i.nace4##i.year i.bvdidnumber)
	eststo: reghdfe `v' `controls' lnage, cluster(nace4) absorb(i.nace4##i.year i.bvdidnumber)
}
foreach v in `outcomes2' {
	eststo: reghdfe `v' `controls',                    cluster(nace4) absorb(i.nace4##i.year i.bvdidnumber)
	eststo: reghdfe `v' `controls' lnage,              cluster(nace4) absorb(i.nace4##i.year i.bvdidnumber)
	eststo: reghdfe `v' `controls' lnage lnsales_real, cluster(nace4) absorb(i.nace4##i.year i.bvdidnumber)
}
esttab using "${tables}/Table5_firms_connected.csv", nocons se r2 ar2 starlevels(* 0.1 ** 0.05 *** 0.01) replace
esttab using "${tables}/Table5_firms_connected.tex", nocons se r2 ar2 starlevels(* 0.1 ** 0.05 *** 0.01) replace


**************************************************************************
*** TABLE 6: Connecting to power - local vs national elections
**************************************************************************
eststo clear

local outcomes1 lnprofit lnsales_real lnempl lnavg_wage lnvaw
local outcomes2 tfp_tl_pc tfp_cd_pc
local controls  treated_loc treated_nat treated_lost treated_pre10

foreach v in `outcomes1' {
	eststo: reghdfe `v' `controls',       cluster(nace4) absorb(i.nace4##i.year i.bvdidnumber)
	eststo: reghdfe `v' `controls' lnage, cluster(nace4) absorb(i.nace4##i.year i.bvdidnumber)
}
foreach v in `outcomes2' {
	eststo: reghdfe `v' `controls',                    cluster(nace4) absorb(i.nace4##i.year i.bvdidnumber)
	eststo: reghdfe `v' `controls' lnage,              cluster(nace4) absorb(i.nace4##i.year i.bvdidnumber)
	eststo: reghdfe `v' `controls' lnage lnsales_real, cluster(nace4) absorb(i.nace4##i.year i.bvdidnumber)
}
esttab using "${tables}/Table6_firms_local_national.csv", nocons se r2 ar2 starlevels(* 0.1 ** 0.05 *** 0.01) replace
esttab using "${tables}/Table6_firms_local_national.tex", nocons se r2 ar2 starlevels(* 0.1 ** 0.05 *** 0.01) replace


**************************************************************************
*** TABLE 7: Losing connections
**************************************************************************
eststo clear

local outcomes1 lnprofit lnsales_real lnempl lnavg_wage lnvaw
local outcomes2 tfp_tl_pc tfp_cd_pc
local controls  treated treated_lost

foreach v in `outcomes1' {
	eststo: reghdfe `v' `controls',       cluster(nace4) absorb(i.nace4##i.year i.bvdidnumber)
	eststo: reghdfe `v' `controls' lnage, cluster(nace4) absorb(i.nace4##i.year i.bvdidnumber)
}
foreach v in `outcomes2' {
	eststo: reghdfe `v' `controls',                    cluster(nace4) absorb(i.nace4##i.year i.bvdidnumber)
	eststo: reghdfe `v' `controls' lnage,              cluster(nace4) absorb(i.nace4##i.year i.bvdidnumber)
	eststo: reghdfe `v' `controls' lnage lnsales_real, cluster(nace4) absorb(i.nace4##i.year i.bvdidnumber)
}
esttab using "${tables}/Table7_firms_lost.csv", nocons se r2 ar2 starlevels(* 0.1 ** 0.05 *** 0.01) replace
esttab using "${tables}/Table7_firms_lost.tex", nocons se r2 ar2 starlevels(* 0.1 ** 0.05 *** 0.01) replace


**************************************************************************
*** TABLE 10 (Annex): Connecting to local power by election margin
*** Low margin: winning margin <= 30%; high margin: > 30%
**************************************************************************
gen loc_low_marg=0
gen loc_high_marg=0
replace loc_low_marg=1  if first_treat==2011 & margins_2011<=0.3 & year>=2011
replace loc_low_marg=1  if first_treat==2015 & margins_2015<=0.3 & year>=2015
replace loc_high_marg=1 if first_treat==2011 & margins_2011>0.3  & year>=2011
replace loc_high_marg=1 if first_treat==2015 & margins_2015>0.3  & year>=2015

eststo clear

local outcomes1 lnprofit lnsales_real lnempl lnvaw
local outcomes2 lnavg_wage tfp_tl_pc tfp_cd_pc
local controls  loc_low_marg loc_high_marg treated_nat treated_lost treated_pre10

foreach v in `outcomes1' {
	eststo: reghdfe `v' `controls',       cluster(nace4) absorb(i.nace4##i.year i.bvdidnumber)
	eststo: reghdfe `v' `controls' lnage, cluster(nace4) absorb(i.nace4##i.year i.bvdidnumber)
}
foreach v in `outcomes2' {
	eststo: reghdfe `v' `controls',                    cluster(nace4) absorb(i.nace4##i.year i.bvdidnumber)
	eststo: reghdfe `v' `controls' lnage,              cluster(nace4) absorb(i.nace4##i.year i.bvdidnumber)
	eststo: reghdfe `v' `controls' lnage lnsales_real, cluster(nace4) absorb(i.nace4##i.year i.bvdidnumber)
}
esttab using "${tables}/Table10_firms_margins.csv", nocons se r2 ar2 starlevels(* 0.1 ** 0.05 *** 0.01) replace
esttab using "${tables}/Table10_firms_margins.tex", nocons se r2 ar2 starlevels(* 0.1 ** 0.05 *** 0.01) replace
eststo clear


**************************************************************************
**************************************************************************
*** PART B - SECTOR-LEVEL ANALYSIS
**************************************************************************
**************************************************************************

**************************************************************************
*** B.1 SAMPLE AND VARIABLE DEFINITIONS
**************************************************************************
use ${keepvars} using "${data}/Orbis_pcfirms_elections_merged.dta", clear

drop if missing(codemun) // drop observations with no information on municipality code

gen pcfirm=0
replace pcfirm=1 if mergepc==3
encode age_ct, gen(Age_ct)
encode sectors_group, gen(Sectors_group)
encode size, gen(Size)

*** Firm-level treatment (as in Part A)
gen treated=0
replace treated=1 if first_treat==2011 & year>=2011
replace treated=1 if first_treat==2015 & year>=2015
replace treated=1 if first_treat==2013 & year>=2013
replace treated=1 if first_treat==2014 & year>=2014
replace treated=1 if first_treat==2017 & year>=2017
replace treated=0 if first_treat==2011 & local_2015==0 &  year>2015
replace treated=0 if first_treat==2013 & Parliament_43==0 &  year>2014
replace treated=1 if Parliament_43==0 & Parliament_42==1  &  year==2014
replace treated=1 if first_treat==2013 & Parliament_43==0 & Parliament_44==1 &  year>2017
replace treated=0 if first_treat==2014 & Parliament_44==0  & year>2017
tab first_treat year

replace first_treat=. if first_treat==0

*** Sector treatment: earliest year a firm in the NACE4 sector gets connected
egen first_treat_ind=min(first_treat), by(nace4)

gen treated_ind=0
forvalues i = 2010(1)2018 {
	replace treated_ind=1 if first_treat_ind==`i' & year>=`i'
}

*** Firm loses connection
gen first_lost=0
bysort bvdidnumber: replace first_lost=2011 if local_2007==1 & local_2011==0
bysort bvdidnumber: replace first_lost=2015 if local_2015==0 & local_2011==1
bysort bvdidnumber: replace first_lost=2013 if Parliament_41==1 &  Parliament_42==0
bysort bvdidnumber: replace first_lost=2014 if Parliament_43==0 &  Parliament_42==1 & first_lost==0
bysort bvdidnumber: replace first_lost=2017 if Parliament_44==0 &  Parliament_43==1 & first_lost==0

gen treated_lost=0
forvalues i = 2010(1)2018 {
	replace treated_lost=1 if first_lost==`i' & year>=`i'
}

*** Sector loses connection: all connected firms in the sector have lost power
*** Running sums need a fixed order within groups to be reproducible
bysort nace4 year (bvdidnumber): gen treated_sum_ind=sum(treated)
bysort nace4 (year bvdidnumber): gen ever_treated=sum(treated)
bysort nace4 year: egen first_lost_ind=max(first_lost) if treated_sum_ind==0 & ever_treated!=0

replace first_treat_ind=0 if first_treat_ind==.

gen ind_lost=0
bysort nace4 year: replace ind_lost=1 if first_lost_ind!=0 & first_lost_ind<=year

*** Outcomes
gen lnprofit=lnplforperiodnetincome_real
gen lnavg_wage=lnaveragecostofemployee_th_real

*** Local vs national sector connection
gen treated_ind_loc=0
gen treated_ind_nat=0
replace treated_ind_loc=1 if first_treat_ind==2011 & year>=2011
replace treated_ind_loc=1 if first_treat_ind==2015 & year>=2015
replace treated_ind_nat=1 if first_treat_ind==2013 & year>=2013
replace treated_ind_nat=1 if first_treat_ind==2014 & year>=2014
replace treated_ind_nat=1 if first_treat_ind==2017 & year>=2017


**************************************************************************
*** Sample restriction: drop sectors connected before 2010
**************************************************************************
drop if first_treat_ind==2007
drop if first_treat_ind==2009


**************************************************************************
*** TABLE 4: Number of sectors across years
*** Connected: sector has had at least one newly connected firm (including
*** sectors that later lost the connection); Disconnected: of which lost it.
**************************************************************************
preserve
	collapse (max) treated_ind ind_lost, by(nace4 year)
	gen not_yet      = (treated_ind==0)
	gen connected    = (treated_ind==1)
	gen disconnected = (treated_ind==1 & ind_lost==1)
	gen total        = 1
	collapse (sum) not_yet connected disconnected total, by(year)
	list, noobs sep(0)
	export delimited using "${tables}/Table4_sectors_by_year.csv", replace
restore


**************************************************************************
*** TABLE 8: Sector connecting to power
**************************************************************************
eststo clear

local outcomes lnprofit lnsales_real lnempl lnavg_wage tfp_tl_pc tfp_cd_pc lnvaw
local controls treated_ind ind_lost

foreach v in `outcomes' {
	eststo: reghdfe `v' `controls', cluster(nace4) absorb(i.nace4 i.year)
	eststo: reghdfe `v' `controls', cluster(nace4) absorb(i.bvdidnumber i.year)
}
esttab using "${tables}/Table8_sectors_connected.csv", nocons se r2 ar2 starlevels(* 0.1 ** 0.05 *** 0.01) replace
esttab using "${tables}/Table8_sectors_connected.tex", nocons se r2 ar2 starlevels(* 0.1 ** 0.05 *** 0.01) replace


**************************************************************************
*** TABLE 9: Sector connecting to power - local vs national elections
**************************************************************************
eststo clear

local outcomes lnprofit lnsales_real lnempl lnavg_wage tfp_tl_pc tfp_cd_pc lnvaw
local controls treated_ind_loc treated_ind_nat ind_lost

foreach v in `outcomes' {
	eststo: reghdfe `v' `controls', cluster(nace4) absorb(i.nace4 i.year)
	eststo: reghdfe `v' `controls', cluster(nace4) absorb(i.bvdidnumber i.year)
}
esttab using "${tables}/Table9_sectors_local_national.csv", nocons se r2 ar2 starlevels(* 0.1 ** 0.05 *** 0.01) replace
esttab using "${tables}/Table9_sectors_local_national.tex", nocons se r2 ar2 starlevels(* 0.1 ** 0.05 *** 0.01) replace


*** END
