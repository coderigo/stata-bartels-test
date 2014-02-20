cd "~/Documents/Stuff/bartelsTestv2"
local maxT = 15
forvalues sample_i = 4/`maxT' {
    di "Importing T=`sample_i'"
    local sheetName = "T=`sample_i'"
    clear
    import excel using "Permutation summary.xlsx", sheet("`sheetName'")
    drop in 1
    gen t = `sample_i'
    if(`sample_i' > 4){
        append using all_Ts.dta
    }
    save all_Ts.dta, replace
}

rename A nm
rename B p_lte
rename C p_gte
rename D rvn
drop E-J
drop if nm == ""
destring * ,replace

order t nm *

/*--------save it as a matrix---------*/
    mata: bartelsTestTables = st_data(.,"t nm p_lte p_gte rvn")
    *mata: mata matsave bartelsTest_tables bartelsTestTables
    mata: fh = fopen("bartelsTest_tables.mmat", "w")
    mata: fputmatrix(fh, bartelsTestTables)
    mata: fclose(fh)


