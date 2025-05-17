/*This file computes the mean and variance of the subjective probability distributions of asset returns*/

drop _all
program drop _all
set logtype t
set more off
clear matrix
set more off
set mem 300000
cap log close

log using Expectations,replace t


/*I start with stock returns*/

u WE_Data0
keep nq probor*
drop if probors11==2
drop if probors21==2
drop probors11 probors21

drop if probors2>=probors1		/*If prob(r>0)=prob(r>10), I cannot compute mean and sd assuming normality*/

sort nq
gen N=_n
reshape long probors, i(nq) j(Q)
count

sort nq Q
qui by nq: gen D=_n
gen P=probors/100

program drop _all

 
		program define nlPHI
            if "`1'" == "?" {         
                global S_1 "mu sig"   /* identify parameters */
                global mu = 1         /* and initialize      */
                global sig= 0.1       /* them                */
                exit
            }
              replace `1'=norm(($mu-1)  /$sig) if D==1
              replace `1'=norm(($mu-1.1)/$sig) if D==2
		end

gen mu_R =0
gen sig_R=0


		local i=1
			while `i'<1735 {
        		nl PHI P if N==`i', nolog
	  		replace mu_R =_b[mu] if N==`i'
	  		replace sig_R=_b[sig] if N==`i'
			local i = `i' + 1
			}

keep if Q==1
keep nq mu_R sig_R
sort nq
*save expstock, replace


/*The other expectation question in 2008 is for interest rates*/


/*Now I compute mean and variance for long-term government bonds, whose 7-2008/6-2009 mean was 4.40%*/

drop _all
program drop _all
clear matrix
set more off
set mem 300000

u WE_Data0
keep nq probint*

drop if probint11==2
drop if probint21==2
drop if probint2>=probint1		/*If prob(rf>0)=prob(rf>1), I cannot compute mean and sd assuming normality*/
drop probint11 probint21

sort nq
replace probint1=100 if probint1==99 & nquest==720139
gen N=_n
reshape long probint, i(nq) j(Q)
count

sort nq Q
qui by nq: gen D=_n
gen P=probint/100

program drop _all

		program define nlPHIBND
            if "`1'" == "?" {         
                global S_1 "mu sig"   /* identify parameters */
                global mu = 1         /* and initialize      */
                global sig= 0.1       /* them                */
                exit
            }
              replace `1'=norm(($mu-1.0440)/$sig)  if D==1
              replace `1'=norm(($mu-1.0540)/$sig)  if D==2
		end



gen mu_rbnd =0
gen sig_rbnd=0


		local i=1
			while `i'<1226 {
        		nl PHIBND P if N==`i', nolog
			di N
	  		replace mu_rbnd =_b[mu] if N==`i'
	  		replace sig_rbnd=_b[sig] if N==`i'
			local i = `i' + 1
			}

keep if Q==1
keep nq mu_rbnd sig_rbnd
sort nq
*save expbond, replace
*merge nq using expstock
*tab _merge



/*Now I compute mean and variance for bank accounts, whose 7-2008/2009 mean was 1.73%*/

drop _all
program drop _all
clear matrix
set more off
set mem 300000

u WE_Data0
keep nq probint*

drop if probint11==2
drop if probint21==2
drop if probint2>=probint1		/*If prob(rf>0)=prob(rf>1), I cannot compute mean and sd assuming normality*/
drop probint11 probint21
sort nq
count
gen N=_n
reshape long probint, i(nq) j(Q)
sort nq Q
qui by nq: gen D=_n
gen P=probint/100

		program define nlPHIRF
            if "`1'" == "?" {         
                global S_1 "mu sig"   /* identify parameters */
                global mu = 1         /* and initialize      */
                global sig= 0.1       /* them                */
                exit
            }
              replace `1'=norm(($mu-1.0173)/$sig)  if D==1
              replace `1'=norm(($mu-1.0273)/$sig)  if D==2
		end



gen mu_rf =0
gen sig_rf=0

		local i=1
			while `i'<1226 {
        		nl PHIRF P if N==`i', nolog
	  		replace mu_rf =_b[mu]  if N==`i'
	  		replace sig_rf=_b[sig] if N==`i'
			local i = `i' + 1
			}

keep if Q==1
keep nq mu_rf sig_rf
sort nq
*save expbank, replace
*merge nq using expbond
*tab _merge



/*Now I compute mean and variance for bank accounts, whose 7-2008/2009 mean was 1.73%*/
/*Last I do it for house prices. Q1: prob that prices drop; Q2: prob that prices drop by 10% or more*/

drop _all
program drop _all
clear matrix
set more off
set mem 300000

u WE_Data0
drop if pcas11==2
drop if pcas21==2
drop pcas11 pcas21

drop if pcas2>=pcas1

sort nq
gen N=_n
reshape long pcas, i(nq) j(Q)
count

sort nq Q
qui by nq: gen D=_n
gen P=pcas/100

program drop _all

 
		program define nlPHIH
            if "`1'" == "?" {         
                global S_1 "mu sig"   /* identify parameters */
                global mu = 1         /* and initialize      */
                global sig= 0.1       /* them                */
                exit
            }
              replace `1'=norm((1-$mu)  /$sig) if D==1
              replace `1'=norm((0.9-$mu)/$sig) if D==2
		end

gen mu_H =0
gen sig_H=0


		local i=1
			while `i'<972 {
        		nl PHIH P if N==`i', nolog
	  		replace mu_H =_b[mu] if N==`i'
	  		replace sig_H=_b[sig] if N==`i'
			local i = `i' + 1
			}

keep if Q==1
keep nq mu_H sig_H anno
sort nq
*save exphousing, replace

log c

