*! version 1.0.0 Rodrigo Martell
/************************
Reference(s): Bartels, R. (1982) The Rank Version of von Neumann’s Ratio Test for Randomness, Journal of the American Statistical Association, 77, 40-46
************************/
capture program drop bartelsTest
program define bartelsTest
version 11.1
syntax varlist(min=1 max=1 numeric), []

    /*--------Some housekeeping before rolling up one's sleeves and getting to work---------*/
        mata: st_rclear()                                                                                                           /*Give mata amnesia*/
        local targetVar = "`varlist'"                                                                                               /*Assign the target var to a local var so it can be read in via mata*/
        
    /*--------Set up some empty vars to use---------*/
        mata: bartels_targetVector_withmissing = 0                                                                                  /*Empty vector to hold target series warts and all*/
        mata: bartels_targetVector = 0                                                                                              /*Empty vector to hold target series sans missing values*/
    
    /*--------Fill up empty vars with supplied series and filter out missing values---------*/
        mata: st_view(bartels_targetVector_withmissing,.,st_local("targetVar"))                                                     /*Reads in the target series into a mata column vector*/
        mata: st_select(bartels_targetVector, bartels_targetVector_withmissing, rowmissing(bartels_targetVector_withmissing):==0)   /*Gets rid of missing values*/
        
    /*--------Record sample size T---------*/
        mata: bartels_T = rows(bartels_targetVector)                                                                                /*Get value of sample size for the test*/
        mata: st_numscalar("r(bartels_T)", bartels_T)                                                                               /*Push the value of T from Mata into Stata's r-class vars*/
        mata: if(bartels_T<4) st_local("bartels_has_min_obs", "no"); else st_local("bartels_has_min_obs", "yes");                   /*Used to test if has minimum number of obs to perform test*/
        if("`bartels_has_min_obs'" == "no"){                                                                                        /*Abort if doesn't have the min obs*/
            display in red "Bartels Test error: `targetVar' has to have at least 3 non-missing observations"
            exit
        }
        
    /*--------Create matrix to sort and rank over---------*/
        mata: bartels_targetMatrix = (bartels_targetVector, (1::rows(bartels_targetVector)))                                        /*Creates matrix [origVar, origOrder]*/
        mata: bartels_targetMatrix = sort(bartels_targetMatrix,1)                                                                   /*Sorts matrix in ASCENDING order of origVar*/
                                                                                                                                    
    /*--------Check and correct for ties in sorted targetVar---------*/                                                             
        mata: sorted_differences = bartels_targetMatrix[1::(bartels_T-1),1] - bartels_targetMatrix[2::bartels_T,1]                  /*Differences in ASC sorted values*/
        mata: min_diff = min(abs(sorted_differences))                                                                               /*The minimum difference between the sorted observations*/
        mata: if(min_diff==0) st_local("bartels_has_series_ties", "yes"); else st_local("bartels_has_series_ties", "no");           /*Set a local flag to see if the series would have rank ties*/
        if("`bartels_has_series_ties'" == "yes"){
            mata: min_diff_non_zero = min(select(sorted_differences, sorted_differences[.,1]:!=0))                                  /*Minimum non-zero difference (will only differ from min_diff if there is a problem)*/
            mata: uniform_lower_bound = (-1*abs(min_diff_non_zero))/100                                                             /*Lower bound for generating shocks*/
            mata: uniform_lower_bound_vector = rangen(uniform_lower_bound,uniform_lower_bound, bartels_T)                           /*T Vector containing all lower bound values*/
            mata: uniform_upper_bound = abs(min_diff_non_zero)/100                                                                  /*Upper bound for generating shocks*/
            mata: shocks_vector = uniform_lower_bound_vector + (uniform_upper_bound - uniform_lower_bound)*runiform(bartels_T, 1)   /*T shocks randomly selected between uniform_lower_bound and uniform_upper_bound*/
            mata: bartels_targetMatrix = sort(bartels_targetMatrix,2)                                                               /*Sort original values in original order */
            mata: if(min_diff==0) bartels_targetMatrix[.,1] = bartels_targetMatrix[.,1] + shocks_vector; else bartels_T;            /*Shock the observations if needed by min_diff_non_zero*/
            mata: bartels_targetMatrix = sort(bartels_targetMatrix,1)                                                               /*Sort the (possibly) shocked values vector in ASC order of origVar+shock*/
            mata: st_local("bartels_warning", "WARNING: original series was shocked to resolve rank ties.")                         /*Store a warning message to use in output*/
        }
            
    /*--------Make ranks of (possibly) shocked series values, getting ready for test statistic calculation---------*/
        mata: bartels_targetMatrix = (bartels_targetMatrix,(1::rows(bartels_targetMatrix)))                                         /*Adds a rank column to the end of bartels_targetMatrix, which is now [origVar, origRowCounter, rankVar]*/
        mata: bartels_targetMatrix = sort(bartels_targetMatrix,2)                                                                   /*Sort in original order and use rankVar column to continue with test*/
    
    /*--------Make RVN = sum_from_i_T(R_i - R_i+1)^2 / sum_from_i_T(R_i-R_mean)^2 = NM_stat/denominator---------*/
        mata: bartels_targetRanks = bartels_targetMatrix[.,3]                                                                       /*Select only the column vector of assigned ranks in the order of original series*/
        mata: bartels_NM_stat = sum((bartels_targetRanks[1::(bartels_T-1),1] - bartels_targetRanks[2::bartels_T,1]):^2)             /*Create NM statistic using the assigned ranks*/
        mata: bartels_RVN_stat = bartels_NM_stat/sum((bartels_targetRanks:-(bartels_T+1)/2):^2)                                     /*Calculates the RVN stat*/
        mata: st_numscalar("r(bartels_NM_stat)", bartels_NM_stat)                                                                   /*Push the NM stat to Stata's return vals*/
        mata: st_numscalar("r(bartels_RVN_stat)", bartels_RVN_stat)                                                                 /*Push the RVN stat to Stata's return vals*/

    /*--------Based on size of T, decide what to display and how to look up the statistic---------*/
        mata: if(bartels_T<=15) st_local("bartels_exact", "yes"); else st_local("bartels_exact", "no");                             /*Used to see which kind of stat to report (approx or exact)*/
        if("`bartels_exact'" == "yes"){                                                                                             /*Look up exact values for T<=15*/
            di "Use NM and report exact result"
            mata: file_handler = fopen("bartelsTest_tables.mmat", "r")                                                              /*Read in the exact test stat matrix*/
            mata: bartelsTest_statTables = fgetmatrix(file_handler)                                                                 /*Read in the exact test stat matrix [T, nm, p>=, p<=, rvn]*/
            mata: fclose(file_handler)                                                                                              /*Read in the exact test stat matrix*/
            
            mata: thisTestTable = select(bartelsTest_statTables, bartelsTest_statTables[.,1]:==bartels_T)                           /*Pull out the relevant test table values*/
            mata: thisStatRowVector = select(thisTestTable, thisTestTable[.,2]:==bartels_NM_stat)                                   /*Pull out the relevant row of results from the test table*/
            mata: st_numscalar("r(bartels_pval_left)", thisStatRowVector[.,3])                                                      /*Push the left tail pval stat to Stata's return vals*/
            mata: st_numscalar("r(bartels_pval_right)", thisStatRowVector[.,4])                                                     /*Push the right tail pval stat to Stata's return vals*/
            mata: st_numscalar("r(bartels_pval_twotail)", 2*min(thisStatRowVector[.,3\4]))                                          /*Push the right tail pval stat to Stata's return vals*/
            mata: thisTestVariance = 4*(bartels_T-2)*(5*bartels_T^2-2*bartels_T-9)/(5*bartels_T*(bartels_T+1)*(bartels_T-1)^2)      /*Variance of RVN stat for this T (see Bartels 1982)*/
            mata: st_numscalar("r(bartels_RVN_stat_zscore)", (bartels_RVN_stat-2)/sqrt(thisTestVariance))                           /*Work out the standardised RVN statistic (see Bartels 1982)*/
            mata: st_numscalar("r(bartels_RVN_stat_zscore_pval)", normalden((bartels_RVN_stat-2)/sqrt(thisTestVariance)))           /*P-val of standardised RVN stat*/
        }
        else{                                                                                                                       /*Approximate with Beta or Nromal dist for T>=16 decide whether to use */
            mata: if(bartels_T<=1000) st_local("bartels_approx_beta", "yes"); else st_local("bartels_approx_beta", "no");           /*Used to see which kind of approx to do (Beta or Normal)*/
            if("`bartels_approx_beta'" == "yes"){
                di "Use RVN and do beta approx"                                                                                     /*Approximate with Beta since T>=16 and T<=1000*/
            }
            else{
                di "Use RVN and do normal approx"                                                                                   /*Approximate with normal since T>1000*/
            }
        }
    
    mata: mata_bartelsTest("`varlist'")
        
    /*--------Display the results---------*/
    **  di in green _newline(1)"-----------------------------------------------------------------"_newline(1) as yellow "Bartels Test for Randomness (1982)"_newline(1) as green "-----------------------------------------------------------------"_newline(1) as red "`bartels_warning'" _newline(1) as green "Ho:" as yellow " `targetVar' is random" _newline(1) as green "T(sample size): " as yellow "`r(bartels_T)'" _newline(1) as green "RVN-statistic: " as yellow round(`r(bartels_RVN_stat)', 0.0001) _newline(1) as green "RVN-statistic z-score: " as yellow round(`r(bartels_RVN_stat_zscore)', 0.0001) _newline(1) as green "RVN-statistic z-score p-val: " as yellow round(`r(bartels_RVN_stat_zscore_pval)', 0.0001) _newline(1) as green "Lower tail p-value: " as yellow round(`r(bartels_pval_left)', 0.0001) as green " (H1: `targetVar' is positively serially correlated)" _newline(1) as green "Upper tail p-value: " as yellow round(`r(bartels_pval_right)', 0.0001) as green " (H1: `targetVar' is negatively serially correlated)" _newline(1) as green "Two-tail p-value: " as yellow round(`r(bartels_pval_twotail)', 0.0001) as green " (H1: `targetVar' is not random)" _newline(1)as green "-----------------------------------------------------------------"
end

version 12
mata:
void mata_bartelsTest(string scalar varname){
    testMat = (1\2\3)
    testMat
}
end
