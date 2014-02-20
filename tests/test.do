/*--------Unit test for Bartels Test---------*/

do "../bartelsTest.ado"

/*--------Load Bartels's 1982 test dataset---------*/
use bartels1982.dta, clear

/*--------Generate a series that will have ties---------*/
capture drop ties_test
gen ties_test        = real_increase_in_stocks
local increase_in_11 = increase_in_stocks in 11
local cpi_in_11      = gdp_price_index in 11
replace ties_test    = `increase_in_11'/`cpi_in_11' in 12

/*--------Test out using the series in Bob's paper's pg42---------*/
bartelsTest real_increase_in_stocks
local expectedNMStat = 169
if(`r(bartels_NM_stat)' == `expectedNMStat'){
    di as green "Test 1 PASSED"
}
else{
    di as red "Test 1 FAILED. Expected r(bartels_NM_stat) to be `expectedNMStat' but got `r(bartels_NM_stat)'"
}
mata: bartels_targetMatrix /*Shows the series to test, second column is the original order, and the third is the rank*/
return list

/*--------Test out using a modified series of Bob's paper's pg42, modified to have a tie---------*/
bartelsTest ties_test
if(`r(bartels_NM_stat)' == `expectedNMStat'){
    di as green "Test 2 PASSED"
}
else{
    di as red "Test 2 FAILED. Expected r(bartels_NM_stat) to be `expectedNMStat' but got `r(bartels_NM_stat)'"
}
mata: bartels_targetMatrix /*Shows the shocked series with broken ties, second column is the original order, and the third is the rank*/
return list