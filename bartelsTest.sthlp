{smcl}
{* *! version 1.0.0  07apr2011}{...}
{cmd:help bartelsTest}
{hline}

{title:Syntax}

{p 8 18 2}
{cmdab:bartelsTest} [{varlist}]
[{cmd:,}
{it:options}]

{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt alternative}}alternative hypothesis to test; default (if left blank or unspecified) is
{cmd:alternative("twosided")}{p_end}

{title:Description}

{pstd}
{opt bartelsTest} calculates the rank version of von Neumann's Ratio Test for Randomness (Bartels, 1982).

{title:Options}

{dlgtab:Main}

{phang}
{opt alternative} one of {cmd: "twosided", "pos",} or {cmd: "neg"} for testing randomness, positive, or negative serial correlation.

{title:Examples}

{phang}{cmd:. webuse bartels1982, clear}{p_end}
{phang}{cmd:. bartelsTest delta_real_undist_income}{p_end}
{phang}{cmd:. bartelsTest delta_real_undist_income, alternative("pos")}{p_end}
{phang}{cmd:. bartelsTest delta_real_undist_income, alternative("neg")}{p_end}
{phang}{cmd:. bartelsTest real_increase_in_stocks}{p_end}

{title:Saved results}

{pstd}
{cmd:bartelsTest} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(bartels_RVN)}}ranked version of Von Neuman's ratio{p_end}
{synopt:{cmd:r(bartels_RVN_numerator)} numerator of RVN}{p_end}
{synopt:{cmd:r(bartels_RVN_denominator)} denominator of RVN}{p_end}
{synopt:{cmd:r(bartels_test_stat)} stanradrised test statistic}{p_end}
{synopt:{cmd:r(bartels_T)} number of observations used}{p_end}
{synopt:{cmd:r(bartels_pvalue)} test statistic's probability value}{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(bartels_ranks)} a column vector containing the ranks of the test's target variable's values}{p_end}
{p2colreset}{...}

{title:Reference}
{phang}Robert Bartels, {it:Journal of the American Statistical Association}, Vol. 77, No. 377 (Mar., 1982), pp. 40-46

{title:Also see}

{psee}
{space 2}Help:  
{manhelp arima TS}
{manhelp runtest R}
{manhelp spearman R}
{p_end}
