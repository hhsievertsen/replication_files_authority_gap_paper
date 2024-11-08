// analyse data, last edited 2024-02-27 by HHS
cd "C:\Users\B059633\Dropbox\Work\Research\Projects\Gender Econ\Survey Experiment"
*cd "C:\Users\ecsls\Dropbox\igm\Survey Experiment
graph set window fontface default
cap log close 
log using results.log, replace

// Table 1 - share agreeing/ giving an opinion

	use "temporarydata\analysisdata.dta",clear
		collapse (mean) y_opinion y_agree, by(id_noexpert)
		gen id_question=11
		save "temporarydata\temp.dta", replace
	use "temporarydata\analysisdata.dta",clear
		collapse (mean) y_opinion y_agree y_likert, by(id_question id_noexpert)
		append using "temporarydata\temp.dta"
		so id_question id_noexpert
		save "temporarydata\temp.dta", replace
	use "temporarydata\analysisdata.dta",clear
		collapse (mean) x_expert_opinion x_expert_agree, by(id_noexpert)
		gen id_question=11
		save "temporarydata\temp1.dta", replace
	use "temporarydata\analysisdata.dta",clear
		collapse (mean) x_expert_opinion x_expert_agree, by(id_question id_noexpert)
		append using "temporarydata\temp1.dta"
		so id_question id_noexpert
		merge id_question id_noexpert using "temporarydata\temp.dta"
		
/*columns of Table 1
y_opinion y_agree, id_noexpert==0 (experimental)               -> columns 8 and 9
y_opinion y_agree, id_noexpert==1 (baseline)                   -> columns 3 and 4
x_expert_opinion x_expert_agree, id_noexpert==0 (experimental) -> columns 6 and 7
x_expert_opinion x_expert_agree, id_noexpert==2 (all_experts)  -> columns 1 and 2 */

		tab id_question, su(y_likert), if id_noexpert==1 /* these numbers are used in histograms of responses */

		drop _merge
		reshape wide x_expert_opinion x_expert_agree y_opinion y_agree y_likert, i(id_question) j(id_noexpert)
		
		gen distance5 =  abs(x_expert_agree2 - y_agree1)
		gen distance10 = abs(x_expert_agree0 - y_agree1)
		gen distance11 = abs(x_expert_agree0 - y_agree0)
		
		/*col1*/  tab id_question, su(x_expert_opinion2) 
		/*col2*/  tab id_question, su(x_expert_agree2)
		/*col3*/  tab id_question, su(y_opinion1)
		/*col4*/  tab id_question, su(y_agree1)
		/*col5*/  tab id_question, su(distance5)
		/*col6*/  tab id_question, su(x_expert_opinion0)
		/*col7*/  tab id_question, su(x_expert_agree0)
		/*col8*/  tab id_question, su(y_opinion0)
		/*col9*/  tab id_question, su(y_agree0)
		/*col10*/ tab id_question, su(distance10)
		/*col11*/ tab id_question, su(distance11)
		
								
// Figure A1, Appendix - expert versus public opinion
		
		keep if id_question<11
		
		gen certainty = x_expert_agree2
		replace certainty = 1-x_expert_agree2 if x_expert_agree2<0.5
		replace certainty = certainty*x_expert_opinion2
				
		tw (scatter distance5 certainty, mlabel(id_question)) (lfit distance5 certainty), legend(off) ytitle(Expert-public Distance) xtitle(Expert Certainty-weighted Consensus) xlab(0.3 0.5 0.7 0.9) graphregion(color(white)) 
		graph export "results\figA1.png", replace width(2000)
		
		reg distance5 certainty
		
				
		/* variable spec allows us to merge with regression coefficients later on */
		gen spec="AI " if id_question==1
		replace spec="Twitter" if id_question==2
		replace spec="Gouging" if id_question==3
		replace spec="NetZero" if id_question==4
		replace spec="SemiConductors" if id_question==5
		replace spec="Greedflation" if id_question==6
		replace spec="FinReg" if id_question==7
		replace spec="EcPolicy" if id_question==8
		replace spec="Windfall" if id_question==9
		replace spec="JunkFood" if id_question==10
				
		so spec
		save "temporarydata\table1.dta", replace 
				
// Table A1, Appendix - which experts/ opinions for each question

	use "temporarydata\analysisdata.dta",clear
	keep if id_noexpert==0
	byso id_question: tab x_lastname x_expert_likert
	
	
label def x_expert_likert -2 "Expert=StrDis" -1 "Expert=Dis" 0 "Expert=Uncertain" 1 "Expert=Agr" 2 "Expert=StrAgr"
label values x_expert_likert x_expert_likert
label def y_likert -2 "StrDis" -1 "Dis" 0 "Uncertain" 1 "Agr" 2 "StrAgr"
label values y_likert y_likert

gl gshist "discrete percent fcolor(black) lwidth(none) by(, graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) rows(1)) by(x_expert_likert) subtitle(, nobox) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))"

histogram y_likert, discrete gap(40)  xlabel(-2 -1 0 1 2, valuelabel angle(45)) xline(-0.051) xtitle("Public Opinion") by(,note( " "))  $gshist , if id_question==1
graph export "results\fig_hist_1.png", replace
histogram y_likert, discrete gap(40)  xlabel(-2 -1 0 1 2, valuelabel angle(45)) xline(0.500)  xtitle("Public Opinion") by(,note( " "))  $gshist , if id_question==2
graph export "results\fig_hist_2.png", replace
histogram y_likert, discrete gap(40) xlabel(-2 -1 0 1 2, valuelabel angle(45)) xline(0.917)  xtitle("Public Opinion") by(,note( " "))  $gshist , if id_question==3
graph export "results\fig_hist_3.png", replace
histogram y_likert, discrete gap(40) xlabel(-2 -1 0 1 2, valuelabel angle(45)) xline(-0.337) xtitle("Public Opinion") by(,note( " "))  $gshist  , if id_question==4
graph export "results\fig_hist_4.png", replace

histogram y_likert, discrete gap(40) xlabel(-2 -1 0 1 2, valuelabel angle(45)) xline(0.978)  xtitle("Public Opinion") by(,note( " "))  $gshist , if id_question==5
graph export "results\fig_hist_5.png", replace

histogram y_likert, discrete gap(40) xlabel(-2 -1 0 1 2, valuelabel angle(45)) xline(0.808)  xtitle("Public Opinion") by(,note( " "))  $gshist , if id_question==6
graph export "results\fig_hist_6.png", replace
histogram y_likert, discrete gap(40)  xlabel(-2 -1 0 1 2, valuelabel angle(45)) xline(0.124)  xtitle("Public Opinion") by(,note( " "))  $gshist  , if id_question==7
graph export "results\fig_hist_7.png", replace
histogram y_likert, discrete gap(40)  xlabel(-2 -1 0 1 2, valuelabel angle(45)) xline(0.596)  xtitle("Public Opinion") by(,note( " "))  $gshist  , if id_question==8
graph export "results\fig_hist_8.png", replace
histogram y_likert, discrete gap(40)  xlabel(-2 -1 0 1 2, valuelabel angle(45)) xline(0.635)  xtitle("Public Opinion") by(,note( " "))  $gshist , if id_question==9
graph export "results\fig_hist_9.png", replace
histogram y_likert, discrete gap(40)  xlabel(-2 -1 0 1 2, valuelabel angle(45)) xline(0.367)  xtitle("Public Opinion") by(,note( " "))  $gshist  , if id_question==10
graph export "results\fig_hist_10.png", replace

stop


// Table A2, Appendix - balance tests */
	use "temporarydata\analysisdata.dta",clear
		// Select dataset
		keep if id_noexpert==0
	byso id_question: su(x_female_expert)

	su x_female_expert x_expert_likert x_female x_degree x_white x_econknowl x_republican x_old if id_noexpert==0
	foreach x in x_expert_likert x_female x_degree x_white x_econknowl x_republican x_old{
	byso id_question: ttest `x', by(x_female_expert)
	}
	
	// Alternative balancing tests
	// Load data
		use "temporarydata\analysisdata.dta",clear
		// Select dataset
		keep if id_noexpert==0
		// All
		eststo clear
		eststo: reg   x_female_expert  x_expert_likert , cluster(id_prolific) 
		eststo: reg   x_female_expert  x_female , cluster(id_prolific) 
		eststo: reg   x_female_expert  x_white , cluster(id_prolific) 
		eststo: reg   x_female_expert  x_degree , cluster(id_prolific) 
		eststo: reg   x_female_expert  x_republican x_old, cluster(id_prolific) 
		eststo: reg   x_female_expert  x_old, cluster(id_prolific) 
		eststo: reg   x_female_expert  x_expert_likert x_female  x_white x_degree x_republican x_old, cluster(id_prolific) 
		
		esttab using "results\tab_A_balance.rtf", se nogaps b(%4.3f) replace ///
		star(* 0.1 ** 0.05 *** 0.01) label nolines   nonumbers nonotes
		
		eststo clear

		
// Figure 1  - effect of expert opinion on public opinions

	// panel A: Overall

		// Load data
		use "temporarydata/analysisdata.dta",clear
		// Select dataset
		keep if id_noexpert==0
		// Estimate
	
		eststo m1: reghdfe y_likert XStrDis XDis  XAgr XStrAgr, absorb(id_prolific id_question) cluster(id_prolific )
		
		// Create chart
		cap frame change default 
		cap frame drop chart 
		frame create chart 
		frame change chart
		set obs 4
		// Estimation results 
		mat results=r(table)
		mat betas=results[1,1..4]
		mat beta=betas'
		mat lower=results[5,1..4]
		mat ll=lower'
		mat upper=results[6,1..4]
		mat ul=upper'
		svmat double beta, name(beta)
		svmat double ll, name(lower)
		svmat double ul, name(upper)
		gen count=_n
		set obs 5
		replace count=2.5 if _n==5
		sort count 
		replace count=_n
		replace beta=0 if beta==.
		replace upper=0 if upper==.
		format beta %4.2f
		tw  (rspike upper lower count,lcolor(gs4)) ///
			(scatter beta count, mcolor(black) ) ///
			(scatter upper count,mlabposition(12) mlabel(beta) mcolor(none) mlabcolor(black)) ///
			,graphregion(color(white)) yline(0,lwidth(medthick) lcolor(black)) ///
			ylab(,format(%4.1f) angle(horizontal)) ///
			plotregion(margin(large)) ///
			xlab(1 `" "Strongly" "Disagree" "'  2 "Disagree" 3 "Uncertain"  4 "Agree" 5 `" "Strongly" "Agree" "' ) ///
			ytitle("Coefficients on expert opinions") xtitle("Expert opinions") legend(off) 
			graph export "results\fig2a.png", replace width(2000)
			
	//  panel B: By question
		// Create chart
		cap frame change default 
		cap frame drop chart 
		frame create chart 
		frame change chart
		set obs 11
		gen beta=. 
		gen ul=. 
		gen ll=. 
		gen spec=""
		// Load data
		frame change default
		use "temporarydata/analysisdata.dta",clear
		// Select dataset
		keep if id_noexpert==0

		// Estimate  for all
		reghdfe y_likert x_expert_likert, absorb(id_prolific id_question) cluster(id_prolific )
		// Save results
		frame change chart 
		mat results=r(table)
		replace beta=results[1,1] if _n==1
		replace ll=results[5,1] if _n==1
		replace ul=results[6,1] if _n==1
		replace spec="All" if _n==1
		
		// Now loop over questions
		frame change default 
		forval i=1/10{
			eststo m`1': reghdfe y_likert x_expert_likert if id_question==`i', noabsorb cluster(id_prolific )
			// Save results
			local row=`i'+1
			frame change chart 
			mat results=r(table)
			replace beta=results[1,1] if _n==`row'
			replace ll=results[5,1] if _n==`row'
			replace ul=results[6,1] if _n==`row'
			replace spec="`i'" if _n==`row'
			frame change default 
		}
		// Labels
		frame change chart 
		replace spec="AI " if spec=="1"
		replace spec="Twitter" if spec=="2"
		replace spec="Gouging" if spec=="3"
		replace spec="NetZero" if spec=="4"
		replace spec="SemiConductors" if spec=="5"
		replace spec="Greedflation" if spec=="6"
		replace spec="FinReg" if spec=="7"
		replace spec="EcPolicy" if spec=="8"
		replace spec="Windfall" if spec=="9"
		replace spec="JunkFood" if spec=="10"
		drop if spec=="SemiConductors"
		gen count=11-_n
		// Create figure
		labmask count, val(spec)
		format %4.2f beta

		twoway (pcspike count ul count ll, lcolor(gs4)) ///
				(scatter count beta,mlabposition(12) mlabel(beta) ///
				mcolor(none) mlabcolor(black)  mcolor(black) ) ///
		,graphregion(color(white)) ///	
		ylab(1(1)10,valuelabel  angle(horizontal)) ///
		plotregion(margin(large))	///
		xlab(, format(%4.2f) ) xline(0,lpattern(dash) lcolor(gs6)) ///
		xtitle("Coefficient on expert opinion (Likert scale)") ytitle(" ") legend(off) 
		graph export "results\fig2b.png", replace width(2000)

// Figure A2, Appendix - persuasiveness by statement and expert-public distance
		
so spec
merge 1:1 spec using "temporarydata\table1.dta"
keep if _merge==3 

tw (scatter beta y_opinion1, mlabel(spec)) (lfit beta y_opinion1), legend(off) ytitle(Degree of Persuasiveness) xtitle(Initial Public Certainty) xlab(0.4 0.6 0.8 1.0) graphregion(color(white)) 
		graph export "results\figA2a.png", replace width(2000)

tw (scatter beta distance10, mlabel(spec)) (lfit beta distance10), legend(off) ytitle(Degree of Persuasiveness) xtitle(Initial Expert-public Distance) xlab(0.1 0.3 0.5 0.7 0.9) graphregion(color(white)) 
		graph export "results\figA2b.png", replace width(2000)
		
reg beta distance10
reg beta y_opinion1


// Figure/Table AX - heterogeneity of expert persuasiveness - by individual characteristics

use "temporarydata/analysisdata.dta",clear

eststo all:     reghdfe y_likert x_expert_likert, absorb(id_prolific id_question) cluster(id_prolific )
eststo female:   reghdfe y_likert x_expert_likert x_expert_likertXx_male, absorb(id_prolific id_question) cluster(id_prolific )
eststo male:     reghdfe y_likert x_expert_likert x_expert_likertXx_female, absorb(id_prolific id_question) cluster(id_prolific )
eststo young:    reghdfe y_likert x_expert_likert x_expert_likertXx_old, absorb(id_prolific id_question) cluster(id_prolific )
eststo old:      reghdfe y_likert x_expert_likert x_expert_likertXx_young, absorb(id_prolific id_question) cluster(id_prolific )
eststo nodegree: reghdfe y_likert x_expert_likert x_expert_likertXx_degree, absorb(id_prolific id_question) cluster(id_prolific )
eststo degree:   reghdfe y_likert x_expert_likert x_expert_likertXx_nodegree, absorb(id_prolific id_question) cluster(id_prolific )
eststo noecon:   reghdfe y_likert x_expert_likert x_expert_likertXx_econ, absorb(id_prolific id_question) cluster(id_prolific )
eststo econ:     reghdfe y_likert x_expert_likert x_expert_likertXx_noecon, absorb(id_prolific id_question) cluster(id_prolific )
eststo nonwhite: reghdfe y_likert x_expert_likert x_expert_likertXx_white, absorb(id_prolific id_question) cluster(id_prolific )
eststo white:    reghdfe y_likert x_expert_likert x_expert_likertXx_nonwhite, absorb(id_prolific id_question) cluster(id_prolific )
eststo demind:   reghdfe y_likert x_expert_likert x_expert_likertXx_republican, absorb(id_prolific id_question) cluster(id_prolific )
eststo repub:    reghdfe y_likert x_expert_likert x_expert_likertXx_demind, absorb(id_prolific id_question) cluster(id_prolific )
eststo: reghdfe y_likert x_expert_likert x_expert_likertXx_male x_expert_likertXx_old x_expert_likertXx_degree x_expert_likertXx_econ x_expert_likertXx_white x_expert_likertXx_republican, absorb(id_prolific id_question) cluster(id_prolific )

esttab _all using "results\tableAX.rtf", replace b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05) 

coefplot	 (all			,aseq("All")) ///
	         (female		,aseq("Women")) ///
			 (male			,aseq("Men")) ///
			 (young			,aseq("Age<65")) ///
			 (old			,aseq("Age65+")) ///
			 (nodegree		,aseq("NoDegre")) ///
	         (degree		,aseq("Degree")) ///
			 (noecon		,aseq("LowEcon")) ///
			 (econ			,aseq("HighEcon")) ///
			 (nonwhite		,aseq("Nonwhite")) ///
			 (white		    ,aseq("White")) ///
			 (demind		,aseq("Dem/Ind")) ///
			 (repub	        ,aseq("Republican")) ///
	        ,keep(x_expert_likert)  swapnames graphregion(color(white)) ///
			xtitle("Coefficient on expert opinion (Likert scale)") legend(off) xline(0.172,lpattern(dash) lcolor(gs6)) xtitle("Coefficient on expert opinion (Likert scale)") format(%5.2f)  mlabel  mlabposition(12) mlabgap(*2) mlabcolor(gs8) msize(medsmall) msymbol(O) mcolor(black) ///
							 levels(95)  ciopts( lcolor(black) lwidth(0.5 ))  ///
							
			graph export "results\fig2c.png", replace width(2000)


// Same analysis as above, but in a different format			
	
		// dataset for results
			cap frame change default
			cap frame drop frame_estimates
			frame create frame_estimates
			cap frame change frame_estimates
			set obs 14
			gen beta=.
			gen lower=.
			gen upper=.
			gen se=.
			gen spec=""
			gen x=.
			gen pval=.
			gen p=.
			frame change default
		// Load data
		use "temporarydata/analysisdata.dta",clear
		// Select dataset
		keep if id_noexpert==0
		// Reg main
		eststo:  reghdfe y_likert x_expert_likert, absorb(id_prolific id_question) cluster(id_prolific )
			// save results
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] if _n==1
				replace lower=results[5,1] if _n==1
				replace upper=results[6,1] if _n==1
				replace se=results[2,1] if _n==1
				replace spec="Main" if _n==1
				replace p=results[4,1] if _n==1
				replace x=1 if _n==1
			frame change default
	
		// Interacted: Male vs female respondent
			  reghdfe y_likert x_expert_likert x_expert_likertXx_male, absorb(id_prolific id_question) cluster(id_prolific )
			// save results female
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] if _n==2
				replace se=results[2,1] if _n==2
				replace lower=results[5,1] if _n==2
				replace upper=results[6,1] if _n==2
				replace spec="Female" if _n==2
				replace pval=results[4,2] if _n==2
			replace p=results[4,1] if _n==2
				replace x=1.8 if _n==2
			frame change default
			// save results male
			lincom  x_expert_likert+ x_expert_likertXx_male
			frame change frame_estimates
				replace beta= r(estimate) if _n==3
				replace se=r(se) if _n==3
				replace lower= r(lb) if _n==3
				replace upper= r(ub)  if _n==3
				replace spec="Male" if _n==3
				replace p=results[4,1] if _n==3
				replace x=2.2 if _n==3
			frame change default
			
		// Interacted: Old vs young respondent
			eststo:   reghdfe y_likert x_expert_likert x_expert_likertXx_old, cluster(id_prolific) absorb(id_prolific id_question)
			// save results young
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] 		if _n==4
				replace lower=results[5,1] 		if _n==4
				replace se=results[2,1] if _n==4
				replace upper=results[6,1] 		if _n==4
				replace spec="<65" 				if _n==4
				replace pval=results[4,2] 		if _n==4
				replace p=results[4,1] if _n==4
				replace x=2.8 					if _n==4
			frame change default
			// save results old
			lincom  x_expert_likert+ x_expert_likertXx_old
			frame change frame_estimates
				replace beta= r(estimate) 		if _n==5
				replace lower= r(lb) 			if _n==5
				replace se= r(se) if _n==5
				replace upper= r(ub)  			if _n==5
				replace spec="65+" 				if _n==5
				replace p=results[4,1] if _n==5
				replace x=3.2 					if _n==5
			frame change default	
			
		// Interacted: Degree vs no degree respondent
		eststo: reghdfe y_likert x_expert_likert x_expert_likertXx_degree, cluster(id_prolific) absorb(id_prolific id_question)
			// save results no degree
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] 		if _n==6
				replace lower=results[5,1] 		if _n==6
				replace upper=results[6,1] 		if _n==6
				replace se=results[2,1] if _n==6
				replace spec="No Degree" 		if _n==6
				replace pval=results[4,2] 		if _n==6
				replace p=results[4,1] if _n==6
				replace x=3.8 					if _n==6
			frame change default
			// save results degree
			lincom  x_expert_likert+ x_expert_likertXx_degree
			frame change frame_estimates
				replace beta= r(estimate) 		if _n==7
				replace lower= r(lb) 			if _n==7
				replace upper= r(ub)  			if _n==7
				replace se= r(se) if _n==7
				replace spec="Degree" 			if _n==7
				replace p=results[4,1] if _n==7
				replace x=4.2 					if _n==7
			frame change default	
			
		// Interacted: White vs not white respondent
		eststo: reghdfe  y_likert x_expert_likert x_expert_likertXx_white, cluster(id_prolific) absorb(id_prolific id_question)
			// save results Non-White
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] 		if _n==8
				replace lower=results[5,1] 		if _n==8
				replace upper=results[6,1] 		if _n==8
				replace se=results[2,1] if _n==8
				replace spec="Non-White" 		if _n==8
				replace pval=results[4,2] 		if _n==8
				replace x=4.8					if _n==8
				replace p=results[4,1] if _n==8
			frame change default
			// save results White
			lincom  x_expert_likert+ x_expert_likertXx_white
			frame change frame_estimates
				replace beta= r(estimate) 		if _n==9
				replace lower= r(lb) 			if _n==9
				replace upper= r(ub)  			if _n==9
				replace se= r(se) if _n==9
				replace spec="White" 			if _n==9
				replace x=5.2					if _n==9
				replace p=results[4,1] if _n==9
			frame change default	
			
		// Interacted: Republican vs not rep respondent
		eststo: reghdfe    y_likert x_expert_likert x_expert_likertXx_republican, cluster(id_prolific) absorb(id_prolific id_question)
			// save results Not Republican
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] 		if _n==10
				replace lower=results[5,1] 		if _n==10
				replace upper=results[6,1] 		if _n==10
				replace se=results[2,1] if _n==10
				replace spec="Not Republican" 	if _n==10
				replace pval=results[4,2] 		if _n==10
				replace x=5.8 					if _n==10
				replace p=results[4,1] if _n==10
			frame change default
			// save results Republican
			lincom  x_expert_likert+ x_expert_likertXx_republican
			frame change frame_estimates
				replace beta= r(estimate) 		if _n==11
				replace lower= r(lb) 			if _n==11
				replace upper= r(ub)  			if _n==11
				replace se= r(se) if _n==11
				replace spec="Republican" 		if _n==11
				replace x=6.2 					if _n==11
				replace p=results[4,1] if _n==11
			frame change default	
			
		// Interacted: Econ  vs not econ
		eststo:  reghdfe y_likert x_expert_likert x_expert_likertXx_econ, cluster(id_prolific) absorb(id_prolific id_question)
			// save results female
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] 		if _n==12
				replace lower=results[5,1] 		if _n==12
				replace upper=results[6,1] 		if _n==12
				replace se=results[2,1] if _n==12
				replace spec="Low Econ" 	if _n==12
				replace pval=results[4,2] 		if _n==12
				replace x=6.8 					if _n==12
				replace p=results[4,1] if _n==12
			frame change default
			// save results Rep
			lincom  x_expert_likert+ x_expert_likertXx_econ
			frame change frame_estimates
				replace beta= r(estimate) 		if _n==13
				replace lower= r(lb) 			if _n==13
				replace upper= r(ub)  			if _n==13
				replace se=r(se) if _n==13
				replace spec="High Econ" 		if _n==13
				replace x=7.2 					if _n==13
				replace p=results[4,1] if _n==13
			frame change default	
			
		// Now the actual chart (fig2c)
		//
			frame change frame_estimates
		
			gen xlabel=x
			gen xlabel2=x-0.1
			gen prangeStart=x if pval!=. 
			gen prangeStop=x+0.4 if pval!=.
			gen star=""
			
			replace star="*" if p<0.1
			replace star="**" if p<0.05
			replace star="***" if p<0.01
			gen ps=string(pval,"%4.2f")
			gen label="p="+ps 
			gen xmarker=xlabel-0.3 if pval!=.
			replace xmarker=xlabel-0.25 if pval==.
			gen beta2=beta+0.005
			gen beta3=beta-0.015
			gen coef=string(beta,"%4.3f")
			gen betalabel=coef+star
			gen betalabel_aer = coef			
			gen plabel=0.26
			
			gen ymarker=0.2605
			gen ymarker2=0.259
			gen ylabel=0.27
			// Version 1

			format beta %4.3f
			tw  (bar beta x if pval!=., barwidth(0.4) fcolor(gs5) lcolor(gs5)) ///
				(bar beta x if pval==., barwidth(0.4)  fcolor(gs12) lcolor(gs12)) ///
				(bar beta x if x==1, barwidth(0.4)  fcolor(black) lcolor(black))  ///
				(pcspike plabel prangeStart plabel prangeStop, lcolor(gs7)) ///
				(scatter ymarker xmarker  if pval==. & x>1.5, msize(vsmall) msymbol(|) mcolor(gs7)) ///
				(scatter ymarker2 x if x>1.5, msize(vsmall) msymbol(|) mcolor(gs7)) ///
				(scatter ylabel xlabel2  if pval!=., mlabel(label) mlabcolor(gs7) mlabsize(small) mcolor(none)) ///
				(scatter beta2 xmarker  if x==1 , mlabel(betalabel) mlabcolor(black) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta2 xmarker  if x!=1 & pval!=. , mlabel(betalabel) mlabcolor(gs5) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta2 xmarker   if x!=1 & pval==.  & beta2>0, mlabel(betalabel) mlabcolor(gs12) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta3 xmarker   if x!=1 & pval==.  & beta2<0, mlabel(betalabel) mlabcolor(gs12) mlabsize(vsmall) mcolor(none)) ///
				,graphregion(color(white)) ///	
				ylab(0(0.05)0.275,  angle(horizontal) format(%4.2f))	///
				xlab(1 "All" ///
							1.8 "Fem" 2 `" " " " " "Gender" "' 2.2 "Mal" ///
							2.8 "<65" 3 `" " " " " "Age" "' 3.2 "65+" ///
							3.8 "No" 4 `" " " " " "Degree" "' 4.2 "Yes" ///
							4.8 "No" 5 `" " " " " "White" "' 5.2 "Yes" ///
							5.8 "No" 6 `" " " " " "Republican" "' 6.2 "Yes" ///
							6.8 "Low" 7 `" " " " " "Econ Know." "' 7.2 "High" ///
							, noticks   labsize(small)) yline(0,lcolor(gs6)) ///
		xtitle(" ") ytitle("Coefficient on expert opinion (Likert scale)") legend(off)  ///
		yline(0.172,lpattern(dash) lcolor(gs6))
		graph export "results\fig2c.png", replace		
		
		// No stars
		format beta %4.3f
			tw  (bar beta x if pval!=., barwidth(0.4) fcolor(gs5) lcolor(gs5)) ///
				(bar beta x if pval==., barwidth(0.4)  fcolor(gs12) lcolor(gs12)) ///
				(bar beta x if x==1, barwidth(0.4)  fcolor(black) lcolor(black))  ///
				(pcspike plabel prangeStart plabel prangeStop, lcolor(gs7)) ///
				(scatter ymarker xmarker  if pval==. & x>1.5, msize(vsmall) msymbol(|) mcolor(gs7)) ///
				(scatter ymarker2 x if x>1.5, msize(vsmall) msymbol(|) mcolor(gs7)) ///
				(scatter ylabel xlabel2  if pval!=., mlabel(label) mlabcolor(gs7) mlabsize(small) mcolor(none)) ///
				(scatter beta2 xmarker  if x==1 , mlabel(betalabel_aer) mlabcolor(black) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta2 xmarker  if x!=1 & pval!=. , mlabel(betalabel_aer) mlabcolor(gs5) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta2 xmarker   if x!=1 & pval==.  & beta2>0, mlabel(beta) mlabcolor(gs12) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta3 xmarker   if x!=1 & pval==.  & beta2<0, mlabel(beta) mlabcolor(gs12) mlabsize(vsmall) mcolor(none)) ///
				,graphregion(color(white)) ///	
				ylab(0(0.05)0.275,  angle(horizontal) format(%4.2f))	///
				xlab(1 "All" ///
							1.8 "Fem" 2 `" " " " " "Gender" "' 2.2 "Mal" ///
							2.8 "<65" 3 `" " " " " "Age" "' 3.2 "65+" ///
							3.8 "No" 4 `" " " " " "Degree" "' 4.2 "Yes" ///
							4.8 "No" 5 `" " " " " "White" "' 5.2 "Yes" ///
							5.8 "No" 6 `" " " " " "Republican" "' 6.2 "Yes" ///
							6.8 "Low" 7 `" " " " " "Econ Know." "' 7.2 "High" ///
							, noticks   labsize(small)) yline(0,lcolor(gs6)) ///
		xtitle(" ") ytitle("Coefficient on expert opinion (Likert scale)") legend(off)  ///
		yline(0.172,lpattern(dash) lcolor(gs6))
		graph export "results\fig2c.png", replace		
		
		
// No stars, but spikes
		format beta %4.3f
			tw  (bar beta x if pval!=., barwidth(0.4) fcolor(gs5) lcolor(gs5)) ///
				(bar beta x if pval==., barwidth(0.4)  fcolor(gs12) lcolor(gs12)) ///
				(bar beta x if x==1, barwidth(0.4)  fcolor(black) lcolor(black))  ///
				(rspike upper lower  x if pval==.,  lcolor(gs12%30)) ///
				(rspike upper lower  x if pval!=.,  lcolor(gs5%30)) ///
				(pcspike plabel prangeStart plabel prangeStop, lcolor(gs7)) ///
				(scatter ymarker xmarker  if pval==. & x>1.5, msize(vsmall) msymbol(|) mcolor(gs7)) ///
				(scatter ymarker2 x if x>1.5, msize(vsmall) msymbol(|) mcolor(gs7)) ///
				(scatter ylabel xlabel2  if pval!=., mlabel(label) mlabcolor(gs7) mlabsize(small) mcolor(none)) ///
				(scatter beta2 xmarker  if x==1 , mlabel(betalabel_aer) mlabcolor(black) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta2 xmarker  if x!=1 & pval!=. , mlabel(betalabel_aer) mlabcolor(gs5) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta2 xmarker   if x!=1 & pval==.  & beta2>0, mlabel(beta) mlabcolor(gs12) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta3 xmarker   if x!=1 & pval==.  & beta2<0, mlabel(beta) mlabcolor(gs12) mlabsize(vsmall) mcolor(none)) ///
				,graphregion(color(white)) ///	
				ylab(0(0.05)0.275,  angle(horizontal) format(%4.2f))	///
				xlab(1 "All" ///
							1.8 "Fem" 2 `" " " " " "Gender" "' 2.2 "Mal" ///
							2.8 "<65" 3 `" " " " " "Age" "' 3.2 "65+" ///
							3.8 "No" 4 `" " " " " "Degree" "' 4.2 "Yes" ///
							4.8 "No" 5 `" " " " " "White" "' 5.2 "Yes" ///
							5.8 "No" 6 `" " " " " "Republican" "' 6.2 "Yes" ///
							6.8 "Low" 7 `" " " " " "Econ Know." "' 7.2 "High" ///
							, noticks   labsize(small)) yline(0,lcolor(gs6)) ///
		xtitle(" ") ytitle("Coefficient on expert opinion (Likert scale)") legend(off)  ///
		yline(0.172,lpattern(dash) lcolor(gs6))
		graph export "results\fig2c.png", replace		
		

			format beta %4.2f
			cap gen newlab=string(beta,"%4.2f")+"("+string(se,"%4.2f")+")"
			gen newx=xmarker-0.1
			tw  (bar beta x if pval!=., barwidth(0.4) fcolor(gs5) lcolor(gs5)) ///
				(bar beta x if pval==., barwidth(0.4)  fcolor(gs12) lcolor(gs12)) ///
				(bar beta x if x==1, barwidth(0.4)  fcolor(black) lcolor(black))  ///
				(pcspike plabel prangeStart plabel prangeStop, lcolor(gs7)) ///
				(scatter ymarker xmarker  if pval==. & x>1.5, msize(vsmall) msymbol(|) mcolor(gs7)) ///
				(scatter ymarker2 x if x>1.5, msize(vsmall) msymbol(|) mcolor(gs7)) ///
				(scatter ylabel xlabel2  if pval!=., mlabel(label) mlabcolor(gs7) mlabsize(small) mcolor(none)) ///
				(scatter beta2 newx  if x==1 , mlabel(newlab) mlabcolor(black) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta2 xmarker  if x!=1 & pval!=. , mlabel(newlab) mlabcolor(gs5) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta2 newx   if x!=1 & pval==.  & beta2>0, mlabel(newlab) mlabcolor(gs12) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta3 newx   if x!=1 & pval==.  & beta2<0, mlabel(newlab) mlabcolor(gs12) mlabsize(vvsmall) mcolor(none)) ///
				,graphregion(color(white)) ///	
				ylab(0(0.05)0.275,  angle(horizontal) format(%4.2f))	///
				xlab(1 "All" ///
							1.8 "Fem" 2 `" " " " " "Gender" "' 2.2 "Mal" ///
							2.8 "<65" 3 `" " " " " "Age" "' 3.2 "65+" ///
							3.8 "No" 4 `" " " " " "Degree" "' 4.2 "Yes" ///
							4.8 "No" 5 `" " " " " "White" "' 5.2 "Yes" ///
							5.8 "No" 6 `" " " " " "Republican" "' 6.2 "Yes" ///
							6.8 "Low" 7 `" " " " " "Econ Know." "' 7.2 "High" ///
							, noticks   labsize(small)) yline(0,lcolor(gs6)) ///
		xtitle(" ") ytitle("Coefficient on expert opinion (Likert scale)") legend(off)  ///
		yline(0.172,lpattern(dash) lcolor(gs6))
		graph export "results\fig2c.png", replace	
		
		
// Maybe a horizontal figure is better?
		cap gen xreverse=8-x
		cap gen xreverse2=8-xlabel-0.15
		cap drop ylabel2
		cap gen ylabel2=0.35
		
	
		tw (pcspike xreverse    upper xreverse lower, lcolor(black)) /// 
	(scatter  xreverse beta, mcolor(black) mlabel(beta) mlabsize(vsmall) mlabcolor(black) mlabposition(12)) ///
	(scatter  xreverse2  ylabel2  if pval!=., mlabel(label) mlabcolor(gs5) mlabsize(small) mcolor(none)) ///
		,  ///
		ylab(7 "All" ///
							5.8 "Male" 6.2 "Gender              Female" ///
							4.8 "<65" 5.2 "Age                          65+" ///
							3.8 "Yes" 4.2  "Degree                      No" ///
							2.8 "Yes"  3.2 "White                        No" ///
							1.8 "Yes"  2.2 "Republican               No" ///
							0.8 "High"  1.2 "Econ knowledge     Low" ///
							, noticks  angle(horizontal) labsize(small) ) ///
								graphregion(color(white)) ///
								ytitle(" ") legend(off)  ///
								xtitle("Coefficient on expert opinion (Likert scale)", size(small)) ///
								xline(0 0.172,lcolor(gs9) lpattern(dash)) ///
								xlab(0 "0.00" 0.05 "0.05" 0.1 "0.10" ///					
								0.15 "0.15" 0.2 "0.20"   0.25 "0.25" 0.3 "0.30" 0.4 " ", labsize(small) noticks)
								graph export "results\fig2c.png", replace	
						
		
/// Now in table
		
		
			// Table A3, Appendix - alternative specifications (do experts persuade the public?)

	frame change default
	eststo clear
	eststo: reghdfe y_likert XStrDis XDis  XAgr XStrAgr, absorb(id_prolific id_question) cluster(id_prolific )
	eststo: areg y_likert XStrDis XDis  XAgr XStrAgr, a(id_question) cluster(id_prolific)
	eststo: xi: ologit y_likert XStrDis XDis  XAgr XStrAgr i.id_question, cluster(id_prolific)
	esttab _all using "results\tableA3.rtf", replace b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) keep(XStrDis XDis  XAgr XStrAgr _cons)
	eststo clear	

// Figure 3 - main effects and interactions: Expert identity

		// dataset for results
			cap frame change default
			cap frame drop frame_estimates
			frame create frame_estimates
			cap frame change frame_estimates
			set obs 14
			gen beta=.
			gen lower=.
			gen upper=.
			gen spec=""
			gen x=.
			gen pval=.
			gen p=.
			frame change default
		// Load data
		use "temporarydata\analysisdata.dta",clear
		// Select dataset
		keep if id_noexpert==0
		// Reg main
		eststo: reghdfe y_match x_female_expert, cluster(id_prolific) absorb(id_prolific id_question)
			// save results
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] if _n==1
				replace lower=results[5,1] if _n==1
				replace upper=results[6,1] if _n==1
				replace spec="Main" if _n==1
				replace p=results[4,1] if _n==1
				replace x=1 if _n==1
			frame change default
			
			
			// Interacted: Male vs female respondent
			eststo: reghdfe y_match x_female_expert x_maleXfemale_expert, cluster(id_prolific) absorb(id_prolific id_question)
			
			// save results female
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] if _n==2
				replace lower=results[5,1] if _n==2
				replace upper=results[6,1] if _n==2
				replace spec="Female" if _n==2
				replace pval=results[4,2] if _n==2
			replace p=results[4,1] if _n==2
				replace x=1.8 if _n==2
			frame change default
			// save results male
			lincom  x_female_expert+ x_maleXfemale_expert
			frame change frame_estimates
				replace beta= r(estimate) if _n==3
				replace lower= r(lb) if _n==3
				replace upper= r(ub)  if _n==3
				replace spec="Male" if _n==3
				replace p=results[4,1] if _n==3
				replace x=2.2 if _n==3
			frame change default
			
		// Interacted: Old vs young respondent
			eststo: reghdfe y_match x_female_expert x_oldXfemale_expert, cluster(id_prolific) absorb(id_prolific id_question)
			// save results female
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] 		if _n==4
				replace lower=results[5,1] 		if _n==4
				replace upper=results[6,1] 		if _n==4
				replace spec="<65" 				if _n==4
				replace pval=results[4,2] 		if _n==4
				replace p=results[4,1] if _n==4
				replace x=2.8 					if _n==4
			frame change default
			// save results male
			lincom  x_female_expert+ x_oldXfemale_expert
			frame change frame_estimates
				replace beta= r(estimate) 		if _n==5
				replace lower= r(lb) 			if _n==5
				replace upper= r(ub)  			if _n==5
				replace spec="65+" 				if _n==5
				replace p=results[4,1] if _n==5
				replace x=3.2 					if _n==5
			frame change default	
			
		// Interacted: Degree vs no degree respondent
		eststo: reghdfe y_match x_female_expert x_degreeXfemale_expert, cluster(id_prolific) absorb(id_prolific id_question)
			// save results female
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] 		if _n==6
				replace lower=results[5,1] 		if _n==6
				replace upper=results[6,1] 		if _n==6
				replace spec="No Degree" 		if _n==6
				replace pval=results[4,2] 		if _n==6
				replace p=results[4,1] if _n==6
				replace x=3.8 					if _n==6
			frame change default
			// save results male
			lincom  x_female_expert+ x_degreeXfemale_expert
			frame change frame_estimates
				replace beta= r(estimate) 		if _n==7
				replace lower= r(lb) 			if _n==7
				replace upper= r(ub)  			if _n==7
				replace spec="Degree" 			if _n==7
				replace p=results[4,1] if _n==7
				replace x=4.2 					if _n==7
			frame change default	
			
		// Interacted: White vs not white respondent
		eststo: reghdfe y_match x_female_expert x_whiteXfemale_expert, cluster(id_prolific) absorb(id_prolific id_question)
			// save results female
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] 		if _n==8
				replace lower=results[5,1] 		if _n==8
				replace upper=results[6,1] 		if _n==8
				replace spec="Non-White" 		if _n==8
				replace pval=results[4,2] 		if _n==8
				replace x=4.8					if _n==8
				replace p=results[4,1] if _n==8
			frame change default
			// save results male
			lincom  x_female_expert+ x_whiteXfemale_expert
			frame change frame_estimates
				replace beta= r(estimate) 		if _n==9
				replace lower= r(lb) 			if _n==9
				replace upper= r(ub)  			if _n==9
				replace spec="White" 			if _n==9
				replace x=5.2					if _n==9
				replace p=results[4,1] if _n==9
			frame change default	
			
		// Interacted: Republican vs not rep respondent
		eststo: reghdfe y_match x_female_expert x_republicanXfemale_expert, cluster(id_prolific) absorb(id_prolific id_question)
			// save results female
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] 		if _n==10
				replace lower=results[5,1] 		if _n==10
				replace upper=results[6,1] 		if _n==10
				replace spec="Not Republican" 	if _n==10
				replace pval=results[4,2] 		if _n==10
				replace x=5.8 					if _n==10
				replace p=results[4,1] if _n==10
			frame change default
			// save results male
			lincom  x_female_expert+ x_republicanXfemale_expert
			frame change frame_estimates
				replace beta= r(estimate) 		if _n==11
				replace lower= r(lb) 			if _n==11
				replace upper= r(ub)  			if _n==11
				replace spec="Republican" 		if _n==11
				replace x=6.2 					if _n==11
				replace p=results[4,1] if _n==11
			frame change default	
		// Interacted: Econ  vs not econ
		eststo:  reghdfe y_match x_female_expert x_econXfemale_expert, cluster(id_prolific) absorb(id_prolific id_question)
			// save results female
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] 		if _n==12
				replace lower=results[5,1] 		if _n==12
				replace upper=results[6,1] 		if _n==12
				replace spec="Low Econ" 	if _n==12
				replace pval=results[4,2] 		if _n==12
				replace x=6.8 					if _n==12
				replace p=results[4,1] if _n==12
			frame change default
			// save results Rep
			lincom  x_female_expert+ x_econXfemale_expert
			frame change frame_estimates
				replace beta= r(estimate) 		if _n==13
				replace lower= r(lb) 			if _n==13
				replace upper= r(ub)  			if _n==13
				replace spec="High Econ" 		if _n==13
				replace x=7.2 					if _n==13
				replace p=results[4,1] if _n==13
			frame change default	
		
		// Now the actual chart (fig3)
		//
			frame change frame_estimates
		
			gen xlabel=x
			gen xlabel2=x-0.1
			gen prangeStart=x if pval!=. 
			gen prangeStop=x+0.4 if pval!=.
			gen star=""
			
			replace star="*" if p<0.1
			replace star="**" if p<0.05
			replace star="***" if p<0.01
			gen ps=string(pval,"%4.2f")
			gen label="p="+ps 
				gen xmarker=xlabel-0.3 if pval!=.
			replace xmarker=xlabel-0.25 if pval==.
			gen beta2=beta+0.00115
			gen beta3=beta-0.0015
			gen coef=string(beta,"%4.3f")
			gen betalabel=coef+star
			
			
			gen plabel=0.025
			gen ymarker=0.02525
			gen ymarker2=0.0248
				gen ylabel=0.027
			// Version 1

			format beta %4.3f
			tw  (bar beta x if pval!=., barwidth(0.4) fcolor(gs5) lcolor(gs5)) ///
				(bar beta x if pval==., barwidth(0.4)  fcolor(gs12) lcolor(gs12)) ///
				(bar beta x if x==1, barwidth(0.4)  fcolor(black) lcolor(black))  ///
				(pcspike plabel prangeStart plabel prangeStop, lcolor(gs7)) ///
				(scatter ymarker xmarker  if pval==. & x>1.5, msize(tiny) msymbol(|) mcolor(gs7)) ///
				(scatter ymarker2 x if x>1.5, msize(tiny) msymbol(|) mcolor(gs7)) ///
				(scatter ylabel xlabel2  if pval!=., mlabel(label) mlabcolor(gs7) mlabsize(small) mcolor(none)) ///
				(scatter beta2 xmarker  if x==1 , mlabel(betalabel) mlabcolor(black) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta2 xmarker  if x!=1 & pval!=. , mlabel(betalabel) mlabcolor(gs5) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta2 xmarker   if x!=1 & pval==.  & beta2>0, mlabel(betalabel) mlabcolor(gs12) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta3 xmarker   if x!=1 & pval==.  & beta2<0, mlabel(betalabel) mlabcolor(gs12) mlabsize(vsmall) mcolor(none)) ///
				,graphregion(color(white)) ///	
				ylab(-0.03(0.01)0.03,  angle(horizontal) format(%4.2f))	///
				xlab(1 "All" ///
							1.8 "Fem" 2 `" " " " " "Gender" "' 2.2 "Mal" ///
							2.8 "<65" 3 `" " " " " "Age" "' 3.2 "65+" ///
							3.8 "No" 4 `" " " " " "Degree" "' 4.2 "Yes" ///
							4.8 "No" 5 `" " " " " "White" "' 5.2 "Yes" ///
							5.8 "No" 6 `" " " " " "Republican" "' 6.2 "Yes" ///
							6.8 "Low" 7 `" " " " " "Econ Know." "' 7.2 "High" ///
							, noticks   labsize(small)) yline(0,lcolor(gs6)) ///
		xtitle(" ") ytitle("Coefficient on female expert") legend(off)  ///
		yline(0.011,lpattern(dash) lcolor(gs6%30))
		graph export "results\fig3.png", replace width(2000)
		
			/* without stars */
			
			replace betalabel=coef
			
			tw  (bar beta x if pval!=., barwidth(0.4) fcolor(gs5) lcolor(gs5)) ///
				(bar beta x if pval==., barwidth(0.4)  fcolor(gs12) lcolor(gs12)) ///
				(bar beta x if x==1, barwidth(0.4)  fcolor(black) lcolor(black))  ///
				(pcspike plabel prangeStart plabel prangeStop, lcolor(gs7)) ///
				(scatter ymarker xmarker  if pval==. & x>1.5, msize(tiny) msymbol(|) mcolor(gs7)) ///
				(scatter ymarker2 x if x>1.5, msize(tiny) msymbol(|) mcolor(gs7)) ///
				(scatter ylabel xlabel2  if pval!=., mlabel(label) mlabcolor(gs7) mlabsize(small) mcolor(none)) ///
				(scatter beta2 xmarker  if x==1 , mlabel(betalabel) mlabcolor(black) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta2 xmarker  if x!=1 & pval!=. , mlabel(betalabel) mlabcolor(gs5) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta2 xmarker   if x!=1 & pval==.  & beta2>0, mlabel(beta) mlabcolor(gs12) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta3 xmarker   if x!=1 & pval==.  & beta2<0, mlabel(beta) mlabcolor(gs12) mlabsize(vsmall) mcolor(none)) ///
				,graphregion(color(white)) ///	
				ylab(-0.03(0.01)0.03,  angle(horizontal) format(%4.2f))	///
				xlab(1 "All" ///
							1.8 "Fem" 2 `" " " " " "Gender" "' 2.2 "Mal" ///
							2.8 "<65" 3 `" " " " " "Age" "' 3.2 "65+" ///
							3.8 "No" 4 `" " " " " "Degree" "' 4.2 "Yes" ///
							4.8 "No" 5 `" " " " " "White" "' 5.2 "Yes" ///
							5.8 "No" 6 `" " " " " "Republican" "' 6.2 "Yes" ///
							6.8 "Low" 7 `" " " " " "Econ Know." "' 7.2 "High" ///
							, noticks   labsize(small)) yline(0,lcolor(gs6)) ///
		xtitle(" ") ytitle("Coefficient on female expert") legend(off)  ///
		yline(0.011,lpattern(dash) lcolor(gs6%30))
		graph export "results\fig3.png", replace width(2000)

				
		// Version 2
		replace ymarker=ymarker+0.02
		replace ymarker2=ymarker2+0.02
		replace ylabel=ylabel+0.02
		replace plabel=plabel+0.02
			tw  (rspike upper lower x if x==1, lcolor(black)) ///
				(rspike upper lower x if pval!=., lcolor(gs5)) ///
				(rspike upper lower x if pval==. & x!=1, lcolor(gs12)) ///
				(scatter beta x if pval!=.,mcolor(gs5) lcolor(gs5)) ///
				(scatter beta x if pval==., mcolor(gs12) lcolor(gs12)) ///
				(scatter beta x if x==1,  mcolor(black) lcolor(black))  ///
				(scatter ylabel xlabel  if pval!=., mlabel(label) mlabcolor(gs5) mlabsize(small) mcolor(none)) ///				
				,graphregion(color(white)) ///	
				ylab(,  angle(horizontal) format(%4.2f))	///
				xlab(1 "All" ///
							1.8 "Fem" 2 `" " " " " "Gender" "' 2.2 "Mal" ///
							2.8 "<65" 3 `" " " " " "Age" "' 3.2 "65+" ///
							3.8 "No" 4 `" " " " " "Degree" "' 4.2 "Yes" ///
							4.8 "No" 5 `" " " " " "White" "' 5.2 "Yes" ///
							5.8 "No" 6 `" " " " " "Republican" "' 6.2 "Yes" ///
							, noticks   labsize(small)) yline(0,lcolor(gs6)) ///
		xtitle(" ") ytitle("Coefficient on female expert") legend(off) 
				
				
// Maybe a horizontal figure is better?
		cap gen xreverse=8-x
		cap dro xreverse2
		cap gen xreverse2=8-xlabel-0.45
		cap drop ylabel2
		cap gen ylabel2=0.045
		
	
		tw (pcspike xreverse    upper xreverse lower, lcolor(black)) /// 
	(scatter  xreverse beta, mcolor(black) mlabel(beta) mlabsize(vsmall) mlabcolor(black) mlabposition(12)) ///
	(scatter  xreverse2  ylabel2  if pval!=., mlabel(label) mlabcolor(gs5) mlabsize(small) mcolor(none)) ///
		,  ///
		ylab(7 "All" ///
				5.8 "Male" 6.2 "Gender              Female" ///
				4.8 "65+" 5.2 "Age                         <65" ///
				3.8 "Yes" 4.2  "Degree                     No" ///
				2.8 "Yes"  3.2 "White                        No" ///
				1.8 "Yes"  2.2 "Republican               No" ///
				0.8 "High"  1.2 "Econ knowledge     Low" ///
				, noticks  angle(horizontal) labsize(small) ) ///
					graphregion(color(white)) ///
					ytitle(" ") legend(off)  ///
					xtitle("Coefficient on female expert", size(small)) ///
					xline(0,lcolor(gs9) lpattern(dash)) ///
					xlab(-0.05 "-0.050" -0.025 "-0.025" 0 "0.000" 0.025 "0.025" 0.06 " " , labsize(small) noticks)
					graph export "results\fig3.png", replace	

				
// Table 2 - Different specifications 
				
		use "temporarydata\analysisdata.dta",clear
		keep if id_noexpert==0
		
		eststo clear
		eststo: reghdfe y_match x_female_expert, cluster(id_prolific) absorb(id_prolific id_question)
		eststo: reghdfe y_broad_match x_female_expert, cluster(id_prolific) absorb(id_prolific id_question)
		eststo: reghdfe y_distance x_female_expert, cluster(id_prolific) absorb(id_prolific id_question)
		eststo: reghdfe y_likert x_female_expert x_expert_likert  x_expert_likertXfemale_expert, cluster(id_prolific) absorb(id_prolific id_question)
		eststo: reghdfe y_match x_female_expert, cluster(id_prolific) absorb(id_prolific id_question x_inst)
		eststo: reghdfe y_match x_female_expert 	x_p_cheerful x_p_professional , cluster(id_prolific) absorb(id_prolific id_question)
		eststo: reghdfe y_match x_female_expert 	x_p_cheerful x_p_professional x_age x_news x_cites x_hi , cluster(id_prolific) absorb(id_prolific id_question)
		eststo: reghdfe y_match x_female_expert x_maleXfemale_expert x_oldXfemale_expert x_degreeXfemale_expert x_econXfemale_expert x_whiteXfemale_expert x_republicanXfemale_expert , cluster(id_prolific) absorb(id_prolific id_question)
		
		esttab using "results\table2.rtf", se nogaps b(%4.3f) replace star(* 0.1 ** 0.05 *** 0.01)
		eststo clear
		
		
		eststo: reghdfe y_broad_match x_female_expert, cluster(id_prolific) absorb(id_prolific id_question)
		eststo: reghdfe y_broad_match x_female_expert, cluster(id_prolific) absorb(id_prolific id_question x_inst)
		eststo: reghdfe y_broad_match x_female_expert 	x_p_cheerful x_p_professional , cluster(id_prolific) absorb(id_prolific id_question)
		eststo: reghdfe y_broad_match x_female_expert 	x_p_cheerful x_p_professional x_age x_news x_cites x_hi , cluster(id_prolific) absorb(id_prolific id_question)
		eststo: reghdfe y_broad_match x_female_expert x_maleXfemale_expert x_oldXfemale_expert x_degreeXfemale_expert x_econXfemale_expert x_whiteXfemale_expert x_republicanXfemale_expert , cluster(id_prolific) absorb(id_prolific id_question)
		
		esttab using "results\table2_broad.rtf", se nogaps b(%4.3f) replace star(* 0.1 ** 0.05 *** 0.01)
		eststo clear
		
		eststo: reghdfe y_distance x_female_expert, cluster(id_prolific) absorb(id_prolific id_question)
		eststo: reghdfe y_distance x_female_expert, cluster(id_prolific) absorb(id_prolific id_question x_inst)
		eststo: reghdfe y_distance x_female_expert 	x_p_cheerful x_p_professional , cluster(id_prolific) absorb(id_prolific id_question)
		eststo: reghdfe y_distance x_female_expert 	x_p_cheerful x_p_professional x_age x_news x_cites x_hi , cluster(id_prolific) absorb(id_prolific id_question)
		eststo: reghdfe y_distance x_female_expert x_maleXfemale_expert x_oldXfemale_expert x_degreeXfemale_expert x_econXfemale_expert x_whiteXfemale_expert x_republicanXfemale_expert , cluster(id_prolific) absorb(id_prolific id_question)
		
		esttab using "results\table2_distance.rtf", se nogaps b(%4.3f) replace star(* 0.1 ** 0.05 *** 0.01)
		eststo clear
	
	stop
		
// Table A3, Appendix - effects, by opinion type

		use "temporarydata\analysisdata.dta",clear
		// Select dataset
		keep if id_noexpert==0
		label def x_expert_likert -2 "StrDis" -1 "Disagree" 0 "Uncertain" 1 "Agree" 2 "StrAgr"
		label values x_expert_likert x_expert_likert
		graph bar y_match, over(x_female_expert, label(labsize(small))) over(x_expert_likert) graphregion(color(white)) ytitle(Exact Match)
		graph bar y_broad_match, over(x_female_expert, label(labsize(small))) over(x_expert_likert) graphregion(color(white)) ytitle(Broad Match)

		eststo: areg y_match x_female_expert if x_expert_likert==-2|x_expert_likert==-1, a(id_question) /*expert disagrees*/
		eststo: areg y_match x_female_expert if x_expert_likert==-0, a(id_question)						/*expert uncertain*/
		eststo: areg y_match x_female_expert if x_expert_likert== 1|x_expert_likert==2, a(id_question)  /*expert agrees*/
		eststo: areg y_match x_female_expert if x_expert_likert== 1|x_expert_likert==-1, a(id_question) /*expert agrees/disagrees, not strongly*/
		eststo: areg y_match x_female_expert if x_expert_likert==-2|x_expert_likert==2, a(id_question)  /*expert agrees/disagrees, strongly*/
		
		esttab using "results\tableA3.rtf", se nogaps b(%4.3f) replace star(* 0.1 ** 0.05 *** 0.01)
		eststo clear

	
// Figure A3, Appendix - leave one out (expert) 

			// Here we loop over all female experts and for each question of that female expert find a random male who gave the same opinion and drop him for everyone
			set seed 1234

			use "temporarydata\analysisdata.dta",clear
			keep if id_noexpert==0
			* identify all  female experts
			levelsof x_lastname if x_female_expert==1,local(females)
			foreach e in `females'{
				
				// load data
				use "temporarydata\analysisdata.dta",clear
				keep if id_noexpert==0
				* randomly sort the data
				* give males and females ids
				preserve
					bys  id_question  x_lastname: keep if _n==1
					gen r=runiform()
					sort  id_question x_expert_likert x_female_expert r
					by  id_question x_expert_likert x_female_expert: gen id=_n
					keep   id_question x_expert_likert x_female_expert x_lastname id
					save "temporarydata\temp.dta",replace
				restore
				merge m:1  id_question x_expert_likert x_female_expert x_lastname using "temporarydata\temp.dta",keep(3) nogen

				// now identify the males to drop for focal female exert
					preserve 
						keep if x_lastname=="`e'"
						bys  id_question: keep if _n==1
						keep  id_question id x_expert_likert
						gen x_female_expert=0
						save "temporarydata\selected_male.dta",replace
					restore
				merge m:1  id_question id x_female_expert x_expert_likert using "temporarydata\selected_male.dta",keep(1 3) 
				// drop the focal female
				drop if x_lastname=="`e'"
				// drop matched males
				drop if _merge==3
				// estimate uncondtional
				cap rename y_broad_match y_b_match
				foreach y in y_b_match y_match {
					reghdfe `y'  x_female_expert, a( id_prolific  id_question) cluster( id_prolific)
					estimates store m_u_`y'_`e'
				}
				// estimate condtional
				foreach y in y_b_match y_match {
					reghdfe `y'  x_female_expert  x_maleXfemale_expert x_republicanXfemale_expert x_oldXfemale_expert x_whiteXfemale_expert , a( id_prolific  id_question) cluster( id_prolific)
					estimates store m_c_`y'_`e'
				}
			}

			// Now get baseline regressions
					use "temporarydata\analysisdata.dta",clear
					keep if id_noexpert==0
					cap rename y_broad_match y_b_match
					// estimate uncondtional
					foreach y in y_b_match y_match {
						reghdfe `y'  x_female_expert, a( id_prolific  id_question) cluster( id_prolific)
						estimates store m_u_`y'
					}
					// estimate condtional
					foreach y in y_b_match y_match {
						reghdfe `y'  x_female_expert  x_maleXfemale_expert x_republicanXfemale_expert x_oldXfemale_expert x_whiteXfemale_expert , a( id_prolific  id_question) cluster( id_prolific)
						estimates store m_c_`y'
					}	

			// Now create four plots - figure A4
			foreach outcome in "y_b_match" "y_match"{
				foreach model in "u" "c" {
					*local outcome="broad_match"
					*local model="c"
					if "`outcome'"=="b_match"{
						local title="Broad Match"
					}
					else{
						local title="Exact Match"
					}
					if "`model'"=="c"{
						local modelt="conditional on covariates"
					}
					else{
						local modelt="unconditional"
					}
					
					coefplot (m_`model'_`outcome', asequation("Baseline ")) ///
							 (m_`model'_`outcome'_Baicker, asequation("Dropping Baicker")) ///
							 (m_`model'_`outcome'_Bertrand, asequation("Dropping Bertrand")) ///
							 (m_`model'_`outcome'_Chevalier, asequation("Dropping Chevalier")) ///
							 (m_`model'_`outcome'_Finkelstein, asequation("Dropping Finkelstein")) ///
							 (m_`model'_`outcome'_Goldberg, asequation("Dropping Goldberg")) ///
							 (m_`model'_`outcome'_Hoxby, asequation("Dropping Hoxby")) ///
							 (m_`model'_`outcome'_Hoynes, asequation("Dropping Hoynes")) ///
							 ,keep(x_female_expert)  graphregion(fcolor(white) lcolor(white)) ///
							 legend(off)  xline(0, lpattern(dash) lcolor(gs8)) swapnames msize(medsmall) msymbol(O) mcolor(black) ///
							 levels(95)  ciopts( lcolor(black) lwidth(0.5 ))  ///
							 xlab(,labsize(small)) xtitle("Coefficient on female expert") format(%5.3f)  mlabel  mlabposition(12) mlabgap(*2) mlabcolor(gs8)
							
							graph export "results\figA3_dropping_one_female_expert_`outcome'_`model'.png", width(2000) replace
				}
			}	 

// Figure A4, Appendix - leave one out (statement)
 
			// load data
			use "temporarydata\analysisdata.dta",clear
			keep if id_noexpert==0
			// Reg main
			reghdfe y_match  x_female_expert, a( id_prolific  id_question) cluster( id_prolific)
			estimates store model_all
				reghdfe y_match  x_female_expert if id_question!=1, a( id_prolific  id_question) cluster( id_prolific)
			// Looping
			forval i=1/10{
					reghdfe y_match  x_female_expert if id_question!=`i', a( id_prolific  id_question) cluster( id_prolific)
					estimates store model_`i'
				}
			
			// Now create  plot
			
					coefplot (model_all, asequation("Baseline                              ")) ///
							 (model_1,   asequation("Dropping the 'AI' Question            "))  ///
							 (model_2,   asequation("Dropping the 'Twitter' Question       "))  ///
							 (model_3,   asequation("Dropping the 'Gouging' Question       "))  ///
							 (model_4,   asequation("Dropping the 'NetZero' Question       "))  ///
							 (model_5,   asequation("Dropping the 'SemiConductors' Question"))  ///
							 (model_6,   asequation("Dropping the 'Greedflation' Question  "))  ///
							 (model_7,   asequation("Dropping the 'FinReg' Question        "))  ///
							 (model_8,   asequation("Dropping the 'EcPolicy' Question      "))  ///
							 (model_9,   asequation("Dropping the 'Windfall' Question      "))  ///
							 (model_10,  asequation("Dropping the 'JunkFood' Question      "))  ///
							 ,keep(x_female_expert)  graphregion(fcolor(white) lcolor(white)) ///
							 legend(off)  xline(0, lpattern(dash) lcolor(gs8)) swapnames msize(medsmall) msymbol(O) mcolor(black) ///
							 levels(95)  ciopts( lcolor(black) lwidth(0.5 )) xlab(,labsize(small)) ///
							 ylab(,labsize(small)) xtitle("Coefficient on female expert") format(%5.3f)  mlabel  mlabposition(12) mlabgap(*2) mlabcolor(gs8)
							
							graph export "results\figA4.png", width(2000) replace
	
	
	// Now loop over statements
			// Reg main
			reghdfe y_match  x_female_expert, a( id_prolific  id_question) cluster( id_prolific)
			estimates store model_all
			//Looping
			forval i=1/10{
			reghdfe y_match x_female_expert if id_question==`i', noabsorb cluster(id_prolific )
			estimates store model_`i'
			}
			
					coefplot (model_all, asequation("Baseline")) ///
							 (model_1, asequation("AI"))  ///
							 (model_2, asequation("Twitter"))  ///
							 (model_3, asequation("Gouging"))  ///
							 (model_4, asequation("NetZero"))  ///
							 (model_5, asequation("SemiConductors"))  ///
							 (model_6, asequation("Greedflation"))  ///
							 (model_7, asequation("FinReg"))  ///
							 (model_8, asequation("EcPolicy"))  ///
							 (model_9, asequation("Windfall"))  ///
							 (model_10, asequation("JunkFood"))  ///
							 ,keep(x_female_expert)  graphregion(fcolor(white) lcolor(white)) ///
							 legend(off)  xline(0, lpattern(dash) lcolor(gs8)) swapnames msize(medsmall) msymbol(O) mcolor(black) ///
							 levels(95)  ciopts( lcolor(black) lwidth(0.5 ))  ///
							 ylab(,labsize(small)) xtitle("Coefficient on female expert") format(%5.3f)  mlabel  mlabposition(12) mlabgap(*2) mlabcolor(gs8)
							
							graph export "results\figA4.png", width(2000) replace
										
		
// Figure A5, Appendix - first time someone sees an expert
		// dataset for results
			cap frame change default
			cap frame drop frame_estimates
			frame create frame_estimates
			cap frame change frame_estimates
			set obs 14
			gen beta=.
			gen lower=.
			gen upper=.
			gen spec=""
			gen p=.
			gen x=.
			gen pval=.
			frame change default
		// Load data
		use "temporarydata\analysisdata.dta",clear
		// Select dataset
		keep if id_noexpert==0
		// order of expert
		sort id_prolific id_question
		egen x_expertid=group(x_lastname)
		sort id_prolific  x_lastname id_question
		by id_prolific  x_lastname:  gen count=_n
		sort id_prolific   id_question x_lastname
		br id_prolific id_question x_lastname count 
		gen x_firststime=count==1
		
		keep if x_firststime==1
		// Reg main
		eststo: reghdfe y_match x_female_expert, cluster(id_prolific) absorb(id_prolific id_question)
			// save results
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] if _n==1
				replace lower=results[5,1] if _n==1
				replace upper=results[6,1] if _n==1
				replace spec="Main" if _n==1
				replace p=results[4,1] if _n==1
				replace x=1 if _n==1
			frame change default
	
		// Interacted: Male vs female respondent
			eststo: reghdfe y_match x_female_expert x_maleXfemale_expert, cluster(id_prolific) absorb(id_prolific id_question)
			// save results female
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] if _n==2
				replace lower=results[5,1] if _n==2
				replace upper=results[6,1] if _n==2
				replace spec="Female" if _n==2
				replace pval=results[4,2] if _n==2
			replace p=results[4,1] if _n==2
				replace x=1.8 if _n==2
			frame change default
			// save results male
			lincom  x_female_expert+ x_maleXfemale_expert
			frame change frame_estimates
				replace beta= r(estimate) if _n==3
				replace lower= r(lb) if _n==3
				replace upper= r(ub)  if _n==3
				replace spec="Male" if _n==3
				replace p=results[4,1] if _n==3
				replace x=2.2 if _n==3
			frame change default
			
		// Interacted: Ols vs young respondent
			eststo: reghdfe y_match x_female_expert x_oldXfemale_expert, cluster(id_prolific) absorb(id_prolific id_question)
			// save results female
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] 		if _n==4
				replace lower=results[5,1] 		if _n==4
				replace upper=results[6,1] 		if _n==4
				replace spec="<65" 				if _n==4
				replace pval=results[4,2] 		if _n==4
				replace p=results[4,1] if _n==4
				replace x=2.8 					if _n==4
			frame change default
			// save results male
			lincom  x_female_expert+ x_oldXfemale_expert
			frame change frame_estimates
				replace beta= r(estimate) 		if _n==5
				replace lower= r(lb) 			if _n==5
				replace upper= r(ub)  			if _n==5
				replace spec="65+" 				if _n==5
				replace p=results[4,1] if _n==5
				replace x=3.2 					if _n==5
			frame change default	
			
		// Interacted: Degree vs no degree respondent
		eststo: reghdfe y_match x_female_expert x_degreeXfemale_expert, cluster(id_prolific) absorb(id_prolific id_question)
			// save results female
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] 		if _n==6
				replace lower=results[5,1] 		if _n==6
				replace upper=results[6,1] 		if _n==6
				replace spec="No Degree" 		if _n==6
				replace pval=results[4,2] 		if _n==6
				replace p=results[4,1] if _n==6
				replace x=3.8 					if _n==6
			frame change default
			// save results male
			lincom  x_female_expert+ x_degreeXfemale_expert
			frame change frame_estimates
				replace beta= r(estimate) 		if _n==7
				replace lower= r(lb) 			if _n==7
				replace upper= r(ub)  			if _n==7
				replace spec="Degree" 			if _n==7
				replace p=results[4,1] if _n==7
				replace x=4.2 					if _n==7
			frame change default	
			
		// Interacted: White vs not white respondent
		eststo: reghdfe y_match x_female_expert x_whiteXfemale_expert, cluster(id_prolific) absorb(id_prolific id_question)
			// save results female
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] 		if _n==8
				replace lower=results[5,1] 		if _n==8
				replace upper=results[6,1] 		if _n==8
				replace spec="Non-White" 		if _n==8
				replace pval=results[4,2] 		if _n==8
				replace x=4.8					if _n==8
				replace p=results[4,1] if _n==8
			frame change default
			// save results male
			lincom  x_female_expert+ x_whiteXfemale_expert
			frame change frame_estimates
				replace beta= r(estimate) 		if _n==9
				replace lower= r(lb) 			if _n==9
				replace upper= r(ub)  			if _n==9
				replace spec="White" 			if _n==9
				replace x=5.2					if _n==9
				replace p=results[4,1] if _n==9
			frame change default	
			
		// Interacted: Republican vs not rep respondent
		eststo: reghdfe y_match x_female_expert x_republicanXfemale_expert, cluster(id_prolific) absorb(id_prolific id_question)
			// save results female
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] 		if _n==10
				replace lower=results[5,1] 		if _n==10
				replace upper=results[6,1] 		if _n==10
				replace spec="Not Republican" 	if _n==10
				replace pval=results[4,2] 		if _n==10
				replace x=5.8 					if _n==10
				replace p=results[4,1] if _n==10
			frame change default
			// save results male
			lincom  x_female_expert+ x_republicanXfemale_expert
			frame change frame_estimates
				replace beta= r(estimate) 		if _n==11
				replace lower= r(lb) 			if _n==11
				replace upper= r(ub)  			if _n==11
				replace spec="Republican" 		if _n==11
				replace x=6.2 					if _n==11
				replace p=results[4,1] if _n==11
			frame change default	
		// Interacted: Econ  vs not econ
		eststo:  reghdfe y_match x_female_expert x_econXfemale_expert, cluster(id_prolific) absorb(id_prolific id_question)
			// save results female
			frame change frame_estimates
				mat results=r(table)
				replace beta=results[1,1] 		if _n==12
				replace lower=results[5,1] 		if _n==12
				replace upper=results[6,1] 		if _n==12
				replace spec="Low Econ" 	if _n==12
				replace pval=results[4,2] 		if _n==12
				replace x=6.8 					if _n==12
				replace p=results[4,1] if _n==12
			frame change default
			// save results Rep
			lincom  x_female_expert+ x_econXfemale_expert
			frame change frame_estimates
				replace beta= r(estimate) 		if _n==13
				replace lower= r(lb) 			if _n==13
				replace upper= r(ub)  			if _n==13
				replace spec="High Econ" 		if _n==13
				replace x=7.2 					if _n==13
				replace p=results[4,1] if _n==13
			frame change default		
		
		// Now the actual chart
		//
			frame change frame_estimates
		
			gen xlabel=x
			gen xlabel2=x-0.1
			gen prangeStart=x if pval!=. 
			gen prangeStop=x+0.4 if pval!=.
			gen star=""
			
			replace star="*" if p<0.1
			replace star="**" if p<0.05
			replace star="***" if p<0.01
			gen ps=string(pval,"%4.2f")
			gen label="p="+ps 
			gen xmarker=xlabel-0.2
			gen beta2=beta+0.00115
			gen beta3=beta-0.0015
			gen coef=string(beta,"%4.3f")
			gen betalabel=coef+star
			
			
			gen plabel=0.025
			gen ymarker=0.02525
			gen ymarker2=0.0248
				gen ylabel=0.027
			// Version 1

			format beta %4.3f
			tw  (bar beta x if pval!=., barwidth(0.4) fcolor(gs5) lcolor(gs5)) ///
				(bar beta x if pval==., barwidth(0.4)  fcolor(gs12) lcolor(gs12)) ///
				(bar beta x if x==1, barwidth(0.4)  fcolor(black) lcolor(black))  ///
				(pcspike plabel prangeStart plabel prangeStop, lcolor(gs7)) ///
				(scatter ymarker xmarker  if pval==. & x>1.5, msize(tiny) msymbol(|) mcolor(gs7)) ///
				(scatter ymarker2 x if x>1.5, msize(tiny) msymbol(|) mcolor(gs7)) ///
				(scatter ylabel xlabel2  if pval!=., mlabel(label) mlabcolor(gs7) mlabsize(small) mcolor(none)) ///
				(scatter beta2 xmarker  if x==1 , mlabel(betalabel) mlabcolor(black) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta2 xmarker  if x!=1 & pval!=. , mlabel(betalabel) mlabcolor(gs5) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta2 xmarker   if x!=1 & pval==.  & beta2>0, mlabel(betalabel) mlabcolor(gs12) mlabsize(vsmall) mcolor(none)) ///
				(scatter beta3 xmarker   if x!=1 & pval==.  & beta2<0, mlabel(betalabel) mlabcolor(gs12) mlabsize(vsmall) mcolor(none)) ///
				,graphregion(color(white)) ///	
				ylab(-0.03(0.01)0.03,  angle(horizontal) format(%4.2f))	///
				xlab(1 "All" ///
							1.8 "Fem" 2 `" " " " " "Gender" "' 2.2 "Mal" ///
							2.8 "<65" 3 `" " " " " "Age" "' 3.2 "65+" ///
							3.8 "No" 4 `" " " " " "Degree" "' 4.2 "Yes" ///
							4.8 "No" 5 `" " " " " "White" "' 5.2 "Yes" ///
							5.8 "No" 6 `" " " " " "Republican" "' 6.2 "Yes" ///
										6.8 "Low" 7 `" " " " " "Econ Know." "' 7.2 "High" ///
							, noticks   labsize(small)) yline(0,lcolor(gs6)) ///
		xtitle(" ") ytitle("Effect of female expert") legend(off) 
	graph export "results\figA5.png", width(2000) replace

	
// Maybe a horizontal figure is better?
		cap gen xreverse=8-x
		cap gen xreverse2=8-xlabel-0.15
		cap drop ylabel2
		cap gen ylabel2=0.045
		
	
		tw (pcspike xreverse    upper xreverse lower, lcolor(black)) /// 
	(scatter  xreverse beta, mcolor(black) mlabel(beta) mlabsize(vsmall) mlabcolor(black) mlabposition(12)) ///
	(scatter  xreverse2  ylabel2  if pval!=., mlabel(label) mlabcolor(gs5) mlabsize(small) mcolor(none)) ///
		,  ///
		ylab(7 "All" ///
							5.8 "Male" 6.2 "Gender                 Female" ///
							4.8 "65+" 5.2 "Age                            <65" ///
							3.8 "Yes" 4.2  "Degree                        No" ///
							2.8 "Yes"  3.2 "White                          No" ///
							1.8 "Yes"  2.2 "Republican                 No" ///
							0.8 "High"  1.2 "Econ knowledge      Low" ///
							, noticks  angle(horizontal) labsize(small) ) ///
								graphregion(color(white)) ///
								ytitle(" ") legend(off)  ///
								xtitle("Coefficient on female expert)", size(small)) ///
								xline(0,lcolor(gs9) lpattern(dash)) ///
								xlab(-0.05 "-0.050" -0.025 "-0.025" 0 "0.000" 0.025 "0.025" 0.06 " " , labsize(small) noticks)
					graph export "results\figA5.png", replace	
		
		
// Table A5, Appendix - Reweighting
			
				// load data
				use "temporarydata\analysisdata.dta",clear
				keep if id_noexpert==0
				// Compute weights
					* old
					sum x_old
					gen _weight_age=(0.17/r(mean)) if x_old==1
					sum x_old
					replace _weight_age=((1-0.17)/(1-r(mean))) if x_old==0
					* degree
					sum x_degree
					gen _weight_degree=(0.45/r(mean)) if x_degree==1
					sum x_degree
					replace _weight_degree=((1-0.45)/(1-r(mean))) if x_degree==0
					* republican
					sum x_republican
					gen _weight_rep=(0.29/r(mean)) if x_republican==1
					sum x_republican
					replace _weight_rep=((1-0.29)/(1-r(mean))) if x_republican==0
					* white
					sum x_white
					gen _weight_white=(0.71/r(mean)) if x_white==1
					sum x_white
					replace _weight_white=((1-0.71)/(1-r(mean))) if x_white==0
					
					
				// Reg main
				eststo clear
				eststo: reghdfe y_match  x_female_expert, a( id_prolific  id_question) cluster( id_prolific)
				sum x_old 
				estadd scalar MeanAge=r(mean)
				sum x_degree 
				estadd scalar MeanDegree=r(mean)
				sum x_republican 
				estadd scalar MeanRepublican=r(mean)
				sum x_white
				estadd scalar MeanWhite=r(mean)
				// Reg weighted by old 
				eststo: reghdfe y_match  x_female_expert [aweight=_weight_age], a( id_prolific  id_question) cluster( id_prolific)
				sum x_old 
				estadd scalar MeanAge=r(mean)
				sum x_old  [aweight=_weight_age]
				estadd scalar MeanAgeWeighted=r(mean)
				sum x_degree 
				estadd scalar MeanDegree=r(mean)
				sum x_degree   [aweight=_weight_age]
				estadd scalar MeanDegreeWeighted=r(mean)
				sum x_republican 
				estadd scalar MeanRepublican=r(mean)
				sum x_republican [aweight=_weight_age]
				estadd scalar MeanRepublicanWeighted=r(mean)
				sum x_white 
				estadd scalar MeanWhite=r(mean)
				sum x_white [aweight=_weight_age]
				estadd scalar MeanWhiteWeighted=r(mean)
				// Reg weighted by degree 
				eststo: reghdfe y_match  x_female_expert [aweight=_weight_degree], a( id_prolific  id_question) cluster( id_prolific)
				sum x_old 
				estadd scalar MeanAge=r(mean)
				sum x_old  [aweight=_weight_degree]
				estadd scalar MeanAgeWeighted=r(mean)
				sum x_degree 
				estadd scalar MeanDegree=r(mean)
				sum x_degree   [aweight=_weight_degree]
				estadd scalar MeanDegreeWeighted=r(mean)
				sum x_republican 
				estadd scalar MeanRepublican=r(mean)
				sum x_republican [aweight=_weight_degree]
				estadd scalar MeanRepublicanWeighted=r(mean)
				sum x_white 
				estadd scalar MeanWhite=r(mean)
				sum x_white [aweight=_weight_degree]
				estadd scalar MeanWhiteWeighted=r(mean)
				// Reg weighted by republican
				eststo: reghdfe y_match  x_female_expert [aweight=_weight_rep], a( id_prolific  id_question) cluster( id_prolific)
				sum x_old 
				estadd scalar MeanAge=r(mean)
				sum x_old  [aweight=_weight_rep]
				estadd scalar MeanAgeWeighted=r(mean)
				sum x_degree 
				estadd scalar MeanDegree=r(mean)
				sum x_degree   [aweight=_weight_rep]
				estadd scalar MeanDegreeWeighted=r(mean)
				sum x_republican 
				estadd scalar MeanRepublican=r(mean)
				sum x_republican [aweight=_weight_rep]
				estadd scalar MeanRepublicanWeighted=r(mean)
				sum x_white 
				estadd scalar MeanWhite=r(mean)
				sum x_white [aweight=_weight_rep]
				estadd scalar MeanWhiteWeighted=r(mean)
								// Reg weighted by republican
				eststo: reghdfe y_match  x_female_expert [aweight=_weight_white], a( id_prolific  id_question) cluster( id_prolific)
				sum x_old 
				estadd scalar MeanAge=r(mean)
				sum x_old  [aweight=_weight_white]
				estadd scalar MeanAgeWeighted=r(mean)
				sum x_degree 
				estadd scalar MeanDegree=r(mean)
				sum x_degree   [aweight=_weight_white]
				estadd scalar MeanDegreeWeighted=r(mean)
				sum x_republican 
				estadd scalar MeanRepublican=r(mean)
				sum x_republican [aweight=_weight_white]
				estadd scalar MeanRepublicanWeighted=r(mean)
				sum x_white 
				estadd scalar MeanWhite=r(mean)
				sum x_white [aweight=_weight_white]
				estadd scalar MeanWhiteWeighted=r(mean)
				esttab
				esttab using "results\tab_A5.rtf", se nogaps b(%4.3f) replace ///
			star(* 0.1 ** 0.05 *** 0.01) stats(MeanAge MeanAgeWeighted MeanDegree MeanDegreeWeighted MeanRepublican MeanRepublicanWeighted MeanWhite MeanWhiteWeighted) label nolines   nonumbers nonotes
		
		
// Results by duration, Appendix 
// load data
use "temporarydata\analysisdata.dta",clear
keep if id_noexpert==0
// distribution
gen x_duration_min=x_duration/60
sum x_duration_min,d
local p50: disp %4.2f r(p50)
local p10: disp %4.2f r(p10)
local p90: disp %4.2f r(p90)
hist x_duration_min if x_duration_min<r(p95), fcolor(gs8) lcolor(white) lwidth(vvthin) ///
   graphregion(fcolor(white) lcolor(white)) ///
	 legend(off)  fraction bins(100) ///
	 text ( 0.03 8 "Median: `p50' minutes") ///
	 text ( 0.028 8 "P90: `p90' minutes") ///
	 text ( 0.026 8 "P10: `p10' minutes") ///
		ylab(,labsize(small) format(%5.3f)  angle(horizontal)) xtitle("Duration (minutes)") 
		graph export "results\fig_dist_duration.png", width(2000) replace

sum x_duration_min,d
gen abovemedian=x_duration_min>r(p50) & x_duration_min!=.
sum x_duration_min,d
gen p75=x_duration_min>r(p75) & x_duration_min!=.
sum x_duration_min,d
gen p25=x_duration_min<r(p25) & x_duration_min!=.
sum x_duration_min,d
gen p10=x_duration_min<r(p10) & x_duration_min!=.

gen dur_above_p50Xx_female_expert=x_female_expert*abovemedian
gen dur_below_p25Xx_female_expert=x_female_expert*p25

	// Regs
				eststo clear
				eststo: reghdfe y_match  x_female_expert, a( id_prolific  id_question) cluster( id_prolific)
				sum x_duration_min
				estadd scalar MeanDuration=r(mean)
				eststo: reghdfe y_match  x_female_expert if abovemedian==0, a( id_prolific  id_question) cluster( id_prolific)
				sum x_duration_min if abovemedian==0
				estadd scalar MeanDuration=r(mean)
				eststo: reghdfe y_match  x_female_expert if abovemedian==1, a( id_prolific  id_question) cluster( id_prolific)
				sum x_duration_min if abovemedian==1
				estadd scalar MeanDuration=r(mean)
				eststo: reghdfe y_match  x_female_expert if p25==1, a( id_prolific  id_question) cluster( id_prolific)
				sum x_duration_min if p25==1
				estadd scalar MeanDuration=r(mean)
				eststo: reghdfe y_match  x_female_expert if p75==1, a( id_prolific  id_question) cluster( id_prolific)
				sum x_duration_min if p75==1
				estadd scalar MeanDuration=r(mean)
				eststo: reghdfe y_match  x_female_expert dur_above_p50Xx_female_expert, a( id_prolific  id_question) cluster( id_prolific)
				sum x_duration_min
				estadd scalar MeanDuration=r(mean)
				eststo: reghdfe y_match  x_female_expert dur_below_p25Xx_female_expert, a( id_prolific  id_question) cluster( id_prolific)
				sum x_duration_min
				estadd scalar MeanDuration=r(mean)
				esttab using "results\tab_byduration.rtf", se nogaps b(%4.3f) replace ///
		star(* 0.1 ** 0.05 *** 0.01) stats(MeanDuration) label nolines   nonumbers nonotes
	
						
/* Regs of likert */
use "temporarydata\analysisdata.dta",clear
// Select dataset
keep if id_noexpert==0
gen x_duration_min=x_duration/60

sum x_duration_min,d
gen abovemedian=x_duration_min>r(p50) & x_duration_min!=.
sum x_duration_min,d
gen p75=x_duration_min>r(p75) & x_duration_min!=.
sum x_duration_min,d
gen p25=x_duration_min<r(p25) & x_duration_min!=.
sum x_duration_min,d
gen p10=x_duration_min<r(p10) & x_duration_min!=.

gen dur_above_p50Xx_expert_likert=x_expert_likert*abovemedian
gen dur_below_p25Xx_expert_likert=x_expert_likert*p25
		
		// Estimate  

				eststo clear
			eststo:	reghdfe y_likert x_expert_likert, a( id_prolific  id_question) cluster( id_prolific)
			sum x_duration_min
			estadd scalar MeanDuration=r(mean)
			eststo:	reghdfe y_likert x_expert_likert if abovemedian==0, a( id_prolific  id_question) cluster( id_prolific)
			sum x_duration_min if abovemedian==0
			estadd scalar MeanDuration=r(mean)
			eststo:	reghdfe y_likert x_expert_likert if abovemedian==1, a( id_prolific  id_question) cluster( id_prolific)
			sum x_duration_min if abovemedian==1
			estadd scalar MeanDuration=r(mean)
			eststo:	reghdfe y_likert x_expert_likert if p25==1, a( id_prolific  id_question) cluster( id_prolific)
			sum x_duration_min if p25==1
			estadd scalar MeanDuration=r(mean)
			eststo:	reghdfe y_likert x_expert_likert if p75==1, a( id_prolific  id_question) cluster( id_prolific)
			sum x_duration_min if p75==1
			estadd scalar MeanDuration=r(mean)
			eststo:	reghdfe y_likert x_expert_likert dur_above_p50Xx_expert_likert , a( id_prolific  id_question) cluster( id_prolific)
			sum x_duration_min
			estadd scalar MeanDuration=r(mean)
			eststo:	reghdfe y_likert x_expert_likert dur_below_p25Xx_expert_likert , a( id_prolific  id_question) cluster( id_prolific)
			sum x_duration_min
			estadd scalar MeanDuration=r(mean)
			esttab using "results\tab_byduration_likert_on_likert.rtf", se nogaps b(%4.3f) replace ///
		star(* 0.1 ** 0.05 *** 0.01) stats(MeanDuration) label nolines   nonumbers nonotes
	
	
	
	

