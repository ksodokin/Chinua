version 8.0
clear
set logtype t
set more off
set mem 50m
set matsize 800
cap log close

log using tables_1_2_3,replace t
/***************************************************************************************************/


/****************************************************************************************************/
/******										For table1					    					*****/
/****************************************************************************************************/
u WE_Data0
/*The data set contains household identifiers, year of survey and 
the responses to the expectation questions from the SHIW for 2008 and for 2010*/

/*Response to expectation question for stock prices*/
preserve
drop if anno==2010
drop if probors2>=probors1 & probors2!=.

count
count if probors1==0
count if probors1>0 & probors1<=25
count if probors1>25 & probors1<=50
count if probors1>50 & probors1<=75
count if probors1>75 & probors1<=100
count if probors1==.

drop if probors1==.
drop if probors1==0

count
count if probors2==0
count if probors2>0 & probors2<=25
count if probors2>25 & probors2<=50
count if probors2>50 & probors2<=75
count if probors2>75 & probors2<=100
count if probors2==.

restore

/*Response to expectation questions for interest rate*/

preserve
drop if anno==2010
drop if probint2>=probint1 & probint2!=.

count
count if probint1==0
count if probint1>0 & probint1<=25
count if probint1>25 & probint1<=50
count if probint1>50 & probint1<=75
count if probint1>75 & probint1<=100
count if probint1==.

drop if probint1==.
drop if probint1==0

count if probint2==0
count if probint2>0 & probint2<=25
count if probint2>25 & probint2<=50
count if probint2>50 & probint2<=75
count if probint2>75 & probint2<=100
count if probint2==.
count if probint2==.
count

restore

/*Response to expectation questions for housing prices*/

preserve
drop if anno==2008
drop if pcas2>=pcas1 & pcas2!=.

count
count if pcas1==0
count if pcas1>0 & pcas1<=25
count if pcas1>25 & pcas1<=50
count if pcas1>50 & pcas1<=75
count if pcas1>75 & pcas1<=100
count if pcas1==.

drop if pcas1==.
drop if pcas1==0

count if pcas2==0
count if pcas2>0 & pcas2<=25
count if pcas2>25 & pcas2<=50
count if pcas2>50 & pcas2<=75
count if pcas2>75 & pcas2<=100
count if pcas2==.
count if pcas2==.
count

restore
clear all
/***************************************************************************************************/



/****************************************************************************************************/
/******										For table2					    					*****/
/****************************************************************************************************/

#delimit;
u WE_Data1;

replace mu_R=mu_R-1;			/*Net returns because the instruments are net returns*/
replace mu_rbnd=mu_rbnd-1;
replace mu_rf=mu_rf-1;

/*Drop ouliers (1%)*/
replace mu_R=. if mu_R<=-0.75 /*| mu_R>.15*/;
replace mu_rf=. if mu_rf<=-0.04 /*| mu_rf>=0.044*/;
replace mu_rbnd=. if mu_rbnd<=0 | mu_rbnd>=0.10;

gen Dexp1=mu_R!=.; replace Dexp1=. if anno==2010;
gen Dexp2=mu_rf!=.; replace Dexp2=. if anno==2010;

/********** COMPUTE REALIZATIONS: R10(1+R09)+R9 **********/

gen RR  = FTSE2010/100   *(1+FTSE2009/100)   +FTSE2009/100;
gen Rbnd= gbnds2010/100  *(1+gbnds2009/100)  +gbnds2009/100;
gen Rrf = bankdep2010/100*(1+bankdep2009/100)+bankdep2009/100;

/*For realized housing returns, I take 2010 SHIW prov/com avg changes in valabit/supab (over previous 2 yrs)*/
ren rH_prov rH_prov2; lab var rH_prov2 "Avg biennial (2009, 2010) return on housing, by iprov";
gen rH_prov=sqrt(rH_prov2+1)-1;
/******NOTA BENE che il rendimento e' il rendimento medio sul biennio/anno precedente!!!*/ 

gen RH = rH_prov*(1+rH_prov)+rH_prov;

/**********************************************************/

keep nq anno cn /*
*/ mu_H sex yrsedu whiteco eta A52-A55 com2-com4 Dnperc lit risfin risf2 Daf3 /*
*/ p_prov p_prov2 p_com2-p_com4 p_A5* impacq* manstra anposs anposq Danposs piubagni /*
*/ hprices06 hpr_sq sport04 high_grw trib_inef va2 avgva rotaz x_cas /*
*/ lowcomp verored klima Dexp* /*
*/ mu_R FTSEm_l1-FTSEm_l6 x_bor FTSEmo* /*
*/ mu_rf bank_l1-bank_l6 x_int bankdep* /*
*/ mu_rbnd bonds_l1-bonds_l6 bonds* /*
*/ af af1-af3 ar ar1-ar3 R* sig*/*
*/ ncomp nperc np2 married employed pubblico self small Dpf;

/**************** TABLE 2***********************/
sum mu_rf mu_rbnd mu_R mu_H, det;
sum sig_rf sig_rbnd sig_R sig_H, det;
/****************************************************************************************************/





/****************************************************************************************************/
/******										For table3					    					*****/
/****************************************************************************************************/

#delimit cr
/******FIT H*****/
			qui heckman mu_H sex yrsedu whiteco eta A52-A55 com2-com4 Dnperc lit risfin risf2 Daf3 /*
			*/ p_prov p_prov2 p_com2-p_com4 p_A5* impacq* manstra anposs anposq Danposs piubagni /*
			*/ hprices06 hpr_sq sport04 high_grw trib_inef va2 avgva if rotaz==1 & x_cas==0, /*
			*/ select(lowcomp verored klima Dexp sex sex yrsedu whiteco eta A52-A55 com2-com4 Dnperc lit risfin risf2 Daf3 /*
			*/ p_prov p_prov2 p_com2-p_com4 p_A5* impacq* manstra anposs anposq Danposs piubagni /*
			*/ hprices06 hpr_sq sport04 high_grw trib_inef va2 avgva) nolog twostep 

			predict mu_Hh_heck			/*Valabit is missing for a handful of households*/
										/*1ST FITTED REGRESSOR*/

			sort nq anno
			qui by nq: gen mu_H10=mu_H[_n+1]
			lab var mu_H10 "Expected return on housing in 2010 (for those in the panel)"
				
/******FIT FTSE*****/
			#delimit cr
			gen x1=FTSEm_l1
			gen x2=FTSEm_l2
			gen x3=FTSEm_l3
			gen x4=FTSEm_l4
			gen x5=FTSEm_l5
			gen x6=FTSEm_l6

			qui heckman mu_R sex yrsedu whiteco eta A52-A55 com2-com4 Dnperc lit risfin risf2 Daf3 /*
			*/ FTSEm_l1 FTSEm_l2 FTSEm_l3 FTSEm_l4 FTSEm_l5 FTSEm_l6 hprices06 hpr_ sport04 /*
			*/ trib_inef high_grw va2 avgva if x_bor==0, /*
			*/ select(lowcomp verored klima Dexp2 sex yrsedu whiteco eta A52-A55 com2-com4 lit Dnperc risfin risf2/*
			*/ Daf3 FTSEm_l1 FTSEm_l2 FTSEm_l3 FTSEm_l4 FTSEm_l5 FTSEm_l6 hprices06 hpr_ sport04 /*
			*/ trib_inef high_grw va2 avgva) nolog twostep

			replace FTSEm_l1=FTSEmo12
			replace FTSEm_l2=FTSEmo11
			replace FTSEm_l3=FTSEmo10 
			replace FTSEm_l4=FTSEmo9
			replace FTSEm_l5=FTSEmo8
			replace FTSEm_l6=FTSEmo7
			predict mu_Rh_heck if x_bor==0 	/*2ND FITTED REGRESSOR*/

			replace FTSEm_l1=x1
			replace FTSEm_l2=x2
			replace FTSEm_l3=x3 
			replace FTSEm_l4=x4
			replace FTSEm_l5=x5
			replace FTSEm_l6=x6
			drop x1-x6

/******FIT Bank deposits*****/
			gen x1=bank_l1
			gen x2=bank_l2
			gen x3=bank_l3
			gen x4=bank_l4
			gen x5=bank_l5
			gen x6=bank_l6

			qui heckman mu_rf sex yrsedu whiteco eta A52-A55 com2-com4 Dnperc lit risfin risf2 Daf3 /*
			*/ bank_l1 bank_l2 bank_l3 bank_l4 bank_l5 bank_l6 hprices06 hpr_ sport04 /*
			*/ trib_inef high_grw va2 avgva if x_int==0, /*
			*/ select(lowcomp verored klima Dexp1 sex yrsedu whiteco eta A52-A55 com2-com4 Dnperc lit risfin risf2/*
			*/ Daf3 bank_l1 bank_l2 bank_l3 bank_l4 bank_l5 bank_l6 hprices06 hpr_ sport04 /*
			*/ trib_inef high_grw va2 avgva) nolog twostep

			replace bank_l1=bankdep12
			replace bank_l2=bankdep11
			replace bank_l3=bankdep10 
			replace bank_l4=bankdep9
			replace bank_l5=bankdep8
			replace bank_l6=bankdep7
			predict mu_rfh_heck if x_int==0 	/*3RD FITTED REGRESSOR*/

			replace bank_l1=x1
			replace bank_l2=x2
			replace bank_l3=x3 
			replace bank_l4=x4
			replace bank_l5=x5
			replace bank_l6=x6
			drop x1-x6
			
/******FIT Government bonds*****/
			gen x1=bonds_l1
			gen x2=bonds_l2
			gen x3=bonds_l3
			gen x4=bonds_l4
			gen x5=bonds_l5
			gen x6=bonds_l6

			qui heckman mu_rbnd sex yrsedu whiteco eta A52-A55 com2-com4 Dnperc lit risfin risf2 Daf3 /*
			*/ bonds_l1 bonds_l2 bonds_l3 bonds_l4 bonds_l5 bonds_l6 hprices06 hpr_ sport04 /*
			*/ trib_inef high_grw va2 avgva if x_int==0, /*
			*/ select(lowcomp verored klima Dexp1 sex yrsedu whiteco eta A52-A55 com2-com4 Dnperc lit risfin risf2/*
			*/ Daf3 bonds_l1 bonds_l2 bonds_l3 bonds_l4 bonds_l5 bonds_l6 hprices06 hpr_ sport04 /*
			*/ trib_inef high_grw va2 avgva) nolog twostep

			replace bonds_l1=bonds12
			replace bonds_l2=bonds11
			replace bonds_l3=bonds10 
			replace bonds_l4=bonds9
			replace bonds_l5=bonds8
			replace bonds_l6=bonds7
			predict mu_rbndh_heck if x_int==0 	/*4TH FITTED REGRESSOR*/

			replace bonds_l1=x1
			replace bonds_l2=x2
			replace bonds_l3=x3 
			replace bonds_l4=x4
			replace bonds_l5=x5
			replace bonds_l6=x6
			drop x1-x6
			
/**************************************************************************************/
/********** COMPUTE (1+rho)E08(R09) (expectation)**********/

			#delimit;
			gen exp_R  =(1+0.4558194)*mu_R;
			gen exp_Rhk=(1+0.4558194)*mu_Rh_heck;

			gen exp_bnd  =(1+0.7531304)*mu_rbnd;
			gen exp_bndhk=(1+0.7531304)*mu_rbndh_heck;

			gen exp_rf  =(1+0.739289)*mu_rf;
			gen exp_rfhk=(1+0.739289)*mu_rfh_heck;

			gen exp_Hhk=2*mu_Hh_heck;

/********NOW CONSTRUCT the regressors**********************/
/*... unexpected shocks...*/
			gen unexp_af1  =af1*(Rrf-exp_rf);
			gen unexp_af1hk=af1*(Rrf-exp_rfhk);

			gen unexp_af2  =af2*(Rbnd-exp_bnd);		/*Many zeros for non-holders!*/
			gen unexp_af2hk=af2*(Rbnd-exp_bndhk);

			gen unexp_af3  =af3*(RR-exp_R);
			gen unexp_af3hk=af3*(RR-exp_Rhk);

			gen unexp_ar1hk=ar1*(RH-exp_Hhk);

			gen unexp_ar2  =ar2*(RR-exp_R);
			gen unexp_ar2hk=ar2*(RR-exp_Rhk);

			gen unexp_af  =unexp_af1+unexp_af2+unexp_af3;
			gen unexp_ar  =unexp_ar1hk+unexp_ar2;
			gen unexp_afar=unexp_af+unexp_ar;

			gen unexp_afhk=unexp_af1hk+unexp_af2hk+unexp_af3hk;
			gen unexp_arhk=unexp_ar1hk+unexp_ar2hk;
			gen unexp_afarhk=unexp_afhk+unexp_arhk;


			/* ... and anticipated changes */
			gen exp_af1  =af1*exp_rf;
			gen exp_af1hk=af1*exp_rfhk;

			gen exp_af2  =af2*exp_bnd;
			gen exp_af2hk=af2*exp_bndhk;

			gen exp_af3  =af3*exp_R;
			gen exp_af3hk=af3*exp_Rhk;

			gen exp_ar1hk=ar1*exp_Hhk;

			gen exp_ar2  =ar2*exp_R;
			gen exp_ar2hk=ar2*exp_Rhk;

			gen exp_af  =exp_af1+exp_af2+exp_af3;
			gen exp_ar  =exp_ar1hk+exp_ar2;
			gen exp_afar=exp_af+exp_ar;

			gen exp_afhk=exp_af1hk+exp_af2hk+exp_af3hk;
			gen exp_arhk=exp_ar1hk+exp_ar2hk;
			gen exp_afarhk=exp_afhk+exp_arhk;

			gen afar=af+ar;
			
/*2008-2010 panel*/
			drop if (eta<20 | eta>80) & anno==2008;
			sort nq anno; qui by nq: gen N=_N; keep if N==2; drop N;

			sort nq anno; 
			qui by nq: gen delta_cn=(cn[_n+1]-cn)/1000;
			qui by nq: gen cngrw =(cn[_n+1]-cn)/cn;
			drop if cngrw<-0.5 | (cngrw>2 & cngrw!=.); drop cngrw;
			
			sort nq anno; qui by nq: gen N=_N; keep if N==2; drop N;



/****************TABLE 3***********************/
/*Estimation sample*/
sum mu_rfh_heck mu_rbndh_heck mu_Rh_heck mu_Hh_heck if  afar>0 & mu_R!=. & mu_rf!=. & afar<2000;

/*Whole sample*/
sum mu_rfh_heck mu_rbndh_heck mu_Rh_heck mu_Hh_heck if  afar>0 & ar<1000 & af3<100 &  exp_afhk!=.;

clear all;
log c;

