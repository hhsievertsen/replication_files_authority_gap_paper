// Analysis for "Do female experts face an authority gap? Evidence from economics ", last edited 2025-01-06 by Hans Henrik Sievertsen (mail@hhsievertsen.net)


clear
cd "C:\Users\B059633\Dropbox\Work\Research\Projects\Gender Econ\Survey Experiment\drafts\JEBO\RR2\Replication package"


/****************************************************************************
  Table 1
****************************************************************************/
	use "temporarydata\analysisdata.dta",clear
		collapse (mean) y_opinion y_agree y_likert, by(id_question id_noexpert)
		so id_question id_noexpert
		save "temporarydata\temp.dta", replace
	
	use "temporarydata\analysisdata.dta",clear
		collapse (mean) x_expert_opinion x_expert_agree, by(id_question id_noexpert)
		so id_question id_noexpert
		merge id_question id_noexpert using "temporarydata\temp.dta"

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

/****************************************************************************/

/****************************************************************************
  Figure 2
****************************************************************************/			

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
					plotregion(margin(large)) yscale(noline) ///
					xlab(1 `" "Strongly" "Disagree" "'  2 "Disagree" 3 "Uncertain"  4 "Agree" 5 `" "Strongly" "Agree" "' ) ///
					ytitle("Coefficients on expert opinions") xtitle("Expert opinions") legend(off) 
					graph export "fig2a.png", replace width(2000)
			
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
				graph export "fig2b.png", replace width(2000)
				
		//  panel C: By sub groups
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
		
			frame change frame_estimates
		// Generate heper lines
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
			gen coef=string(beta,"%4.2f")
			gen betalabel=coef+star
			gen betalabel_aer = coef			
			gen plabel=0.26
			
			gen ymarker=0.2605
			gen ymarker2=0.259
			gen ylabel=0.27
			cap gen xreverse=8-x
			cap gen xreverse2=8-xlabel-0.15
			cap drop ylabel2
			cap gen ylabel2=0.35
			
		format beta %4.2f
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
								graph export "fig2c.png", replace	
						

/****************************************************************************
  Figure 3
****************************************************************************/			

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
				
			cap gen xreverse=8-x
		cap dro xreverse2
		cap gen xreverse2=8-xlabel-0.175
			cap drop ylabel2
			cap gen ylabel2=0.045
			
	format beta %4.3f
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
					graph export "fig3.png", replace	
			cap frame drop frame_estimates_survey1
			frame copy frame_estimates frame_estimates_survey1
/****************************************************************************
  Table 2
****************************************************************************/			
			
						
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
		
		esttab using "table2.rtf", se nogaps b(%4.3f) replace star(* 0.1 ** 0.05 *** 0.01)
		eststo clear
		
		
/****************************************************************************
  Figure 4
****************************************************************************/						
		
	// a	
		import excel "rawdata/code_about.xlsx", sheet("Sheet1") firstrow clear
		drop E-N

		// classify
		gen category=.
		// don't know
		replace category=1 if strpos(about,"don't know")!=0
		replace category=1 if strpos(about,"no idea")!=0
		replace category=1 if strpos(about,"nothing")!=0
		replace category=1 if strpos(about,"not really sure")!=0
		replace category=1 if strpos(about,"not sure")!=0
		replace category=1 if strpos(about,"Not ")!=0
		replace category=1 if strpos(about,"not ")!=0
		replace category=1 if strpos(about,"unsure")!=0
		replace category=1 if strpos(about,"uncertain")!=0
		replace category=1 if strpos(about,"unknown")!=0
		replace category=1 if strpos(about,"clue")!=0
		replace category=1 if strpos(about,"sure ")!=0
		replace category=1 if strpos(about,"ont know")!=0
		replace category=1 if strlen(about)<5
		replace category=1 if about==""
		// experts
		replace category=2 if strpos(about,"expert")!=0
		replace category=2 if strpos(about,"economist")!=0
		// appearence, etc
		replace category=5 if strpos(about,"picture")!=0
		replace category=5 if strpos(about,"photo")!=0
		replace category=5 if strpos(about,"look")!=0
		replace category=5 if strpos(about,"appearence")!=0
		replace category=5 if strpos(about,"race")!=0
		replace category=5 if strpos(about,"black")!=0
		replace category=5 if strpos(about,"demograph")!=0
		// gender
		replace category=3 if strpos(about,"gender")!=0
		replace category=3 if strpos(about,"Gender")!=0
		replace category=3 if strpos(about,"Men")!=0
		replace category=3 if strpos(about,"omen")!=0
		replace category=3 if strpos(about,"female")!=0
		replace category=3 if strpos(about,"male")!=0
		replace category=3 if strpos(about,"Female")!=0
		replace category=3 if strpos(about,"Male")!=0
		replace category=3 if strpos(about,"sex")!=0
		// other
		replace category=4 if category==.

		// Rename
		rename code_about code_Sarah
		rename category  code_HansStata 
		rename AI code_AI

		// Agreement Hans (Stata) and Sarah 
		tab code_Sarah code_HansStata

		// Agreement AI and Sarah 
		tab code_Sarah code_AI
		tab about if code_Sarah==3 & code_AI!=3

		// Single tabs
		tab code_HansStata
		tab code_Sarah
		tab code_AI
		
		// Create chart
		drop about 
		reshape long code_ , i(id_prolific) j(who) string
		gen dummy=1
		replace code_=4 if who=="Sarah" & code_==.
			collapse (count) dummy,by(code_ who)
		// shares 
		bys who: egen T=sum(dummy)
		gen share=dummy/T
		// chart
		
		replace code_=code_-0.2 if who=="Sarah"
		replace code_=code_+0.2 if who=="AI"
		
		tw (bar share code_ if who=="Sarah",fcolor(gs12) lcolor(gs12) barwidth(0.4)  horizontal) ///
		(bar share code_ if who=="AI",fcolor(gs8) lcolor(gs8) barwidth(0.4)  horizontal) ///
		, legend(order(1 "Manual classification"  2 "AI classification" ) ///
		pos(2) ring(0) rows(3)) ylab(1 "Do not know" 2 "Influence of experts" ///
		3 "Gender" 4 "My Opinion" 5 "The role of appearance" , nogrid ///
		angle(horizontal)) xlab(,format(%4.2f)) xtitle("Share of respondents") ytitle(" ") ///
			graphregion(color(white)) xlab(,grid) xsize(7) ysize(5)
		graph export "fig4a.png", replace	

	// b
		u "temporarydata/analysisdata.dta", clear
		bys id_prolific: keep if _n==1
		keep if id_noexpert==3
		
		keep  id_prolific whoismore_liberal whoismore_trust whoismore_conf whoismore_expert
		reshape long whoismore_ , j(dim) i(id_prolific) string 
		
		collapse (mean) whoismore (sd) sd_whoismore=whoismore ///
			(count) n_whoismore=whoismore,by(dim)
		
		// confidence intervals
		gen upper=whoismore+invttail(n_whoismore,.025)*(sd_whoismore/(n_whoismore^0.5))
		gen lower=whoismore-invttail(n_whoismore,.025)*(sd_whoismore/(n_whoismore^0.5))
		// chart
		gen count=_n
		labmask count, value(dim)
		tw (bar whoismore count, fcolor(gs12) lcolor(gs12)) ///
			(rspike upper lower count, lcolor(black)) ///
			, xlab(1 "Confident" 2 "Expert" 3 "Liberal" 4 "Trustworthy" ,) ///
			graphregion(color(white)) ///
					ytitle(" ") legend(off)  ///
			xtitle("") ylab(-0.6 "More female 0.6" -0.3 "-0.3" 0 "Equal           0.0" 0.3 "0.3" 0.6 "More male    0.6",angle(horizontal))
			graph export "fig4b.png", replace	

			
/****************************************************************************
  Figure 5
****************************************************************************/				
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
		use "temporarydata/analysisdata.dta",clear
		keep if id_noexpert==3
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
			gen coef=string(beta,"%4.4f")
			gen betalabel=coef+star
			
			
			gen plabel=0.025
			gen ymarker=0.02525
			gen ymarker2=0.0248
				gen ylabel=0.027
		
				

		cap gen xreverse=8-x
		cap dro xreverse2
		cap gen xreverse2=8-xlabel-0.175
		cap drop ylabel2
		cap gen ylabel2=0.065
		
		format beta %6.3f
	// With labels
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
					xlab(-0.075 "-0.075" -0.05 "-0.050" -0.025 "-0.025" 0 "0.000" 0.025 "0.025" 0.05 "0.050" 0.08 " " , labsize(small) noticks)
				
	// Without labels			
	cap graph drop fig2
	cap frame change	frame_estimates			
		tw (pcspike xreverse    upper xreverse lower, lcolor(black)) /// 
		(scatter  xreverse beta, mcolor(black) mlabel(beta) mlabsize(vsmall) mlabcolor(black) mlabposition(12)) ///
		(scatter  xreverse2  ylabel2  if pval!=., mlabel(label) mlabcolor(gs5) mlabsize(small) mcolor(none)) ///
		,  name(fig2) ///
		ylab(7 " " ///
				5.8 " " 6.2 " " ///
				4.8 " " 5.2 " " ///
				3.8 " " 4.2  " " ///
				2.8 " "  3.2 " " ///
				1.8 " "  2.2 " " ///
				0.8 " "  1.2 " " ///
				, noticks  angle(horizontal) labsize(small) ) ///
					graphregion(color(white)) ///
					ytitle(" ") legend(off)  ///
					xtitle(" ", size(small))  title("Without credentials", color(black)) ///
					xline(0,lcolor(gs9) lpattern(dash))  yscale(noline) ///
					xlab(-0.075 "-0.075" -0.05 "-0.050" -0.025 "-0.025" 0 "0.000" 0.025 "0.025" 0.05 "0.050" 0.08 " " , labsize(small) noticks)
					graph export "fig5b.png", replace	

	cap frame change	frame_estimates_survey1			
	
	cap graph drop fig1
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
					ytitle(" ") legend(off) name(fig1)  ///
					xtitle(" ", size(small)) title("With credentials", color(black)) ///
					xline(0,lcolor(gs9) lpattern(dash)) fxsize(94)  ///
					xlab(-0.05 "-0.050" -0.025 "-0.025" 0 "0.000" 0.025 "0.025" 0.06 " " , labsize(small) noticks)
						
			graph combine fig1 fig2 , imargin(0 0 0 0) graphregion(color(white)) xsize(12) ysize(7) ///
					caption("                                                                                          Coefficient on female expert",size(small))
		graph export "fig5.png", replace width(2000)
		

/****************************************************************************
  Figure A1
****************************************************************************/				

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
		collapse (count) x_expert_opinion x_expert_agree, by(id_noexpert)
		gen id_question=11
		save "temporarydata\temp1.dta", replace
	use "temporarydata\analysisdata.dta",clear
		collapse (mean) x_expert_opinion x_expert_agree, by(id_question id_noexpert)
		append using "temporarydata\temp1.dta"
		so id_question id_noexpert
		merge id_question id_noexpert using "temporarydata\temp.dta"
		

	
		drop _merge
		reshape wide x_expert_opinion x_expert_agree y_opinion y_agree y_likert, i(id_question) j(id_noexpert)
		
		gen distance5 =  abs(x_expert_agree2 - y_agree1)
		gen distance10 = abs(x_expert_agree0 - y_agree1)
		gen distance11 = abs(x_expert_agree0 - y_agree0)
								
	
		keep if id_question<11
		
		gen certainty = x_expert_agree2
		replace certainty = 1-x_expert_agree2 if x_expert_agree2<0.5
		replace certainty = certainty*x_expert_opinion2
				
		tw (scatter distance5 certainty, mlabel(id_question)  mcolor(black%50)  mlabcolor(black)) ///
			(lfit distance5 certainty,lpattern(dash) lcolor(black)), ///
		legend(off) ytitle(Expert-public Distance) /// 
		xtitle(Expert Certainty-weighted Consensus) xlab(0.3 0.5 0.7 0.9) graphregion(color(white)) ///
		 xlab(,format(%4.1f)) ylab(,format(%4.1f))
		graph export "figa1.png", replace width(2000)
		
			
/****************************************************************************
  Figure A2
****************************************************************************/	

	use "temporarydata\analysisdata.dta",clear
	keep if id_noexpert==0
	byso id_question: tab x_lastname x_expert_likert
	
	
		label def x_expert_likert -2 "Expert=StrDis" -1 "Expert=Dis" 0 "Expert=Uncertain" 1 "Expert=Agr" 2 "Expert=StrAgr"
		label values x_expert_likert x_expert_likert
		label def y_likert -2 "StrDis" -1 "Dis" 0 "Uncertain" 1 "Agr" 2 "StrAgr"
		label values y_likert y_likert

		gl gshist "discrete percent fcolor(black) lwidth(none) by(, graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) rows(1)) by(x_expert_likert) subtitle(, nobox) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))"

		histogram y_likert, discrete gap(40)  xlabel(-2 -1 0 1 2, valuelabel angle(45)) xline(-0.051) xtitle("Public Opinion") by(,note( " "))  $gshist , if id_question==1
		graph export "figa2a.png", replace
		histogram y_likert, discrete gap(40)  xlabel(-2 -1 0 1 2, valuelabel angle(45)) xline(0.500)  xtitle("Public Opinion") by(,note( " "))  $gshist , if id_question==2
		graph export "figa2b.png", replace
		histogram y_likert, discrete gap(40) xlabel(-2 -1 0 1 2, valuelabel angle(45)) xline(0.917)  xtitle("Public Opinion") by(,note( " "))  $gshist , if id_question==3
		graph export "figa2c.png", replace
		histogram y_likert, discrete gap(40) xlabel(-2 -1 0 1 2, valuelabel angle(45)) xline(-0.337) xtitle("Public Opinion") by(,note( " "))  $gshist  , if id_question==4
		graph export "figa2d.png", replace
		histogram y_likert, discrete gap(40) xlabel(-2 -1 0 1 2, valuelabel angle(45)) xline(0.978)  xtitle("Public Opinion") by(,note( " "))  $gshist , if id_question==5
		graph export "figa2e.png", replace
		histogram y_likert, discrete gap(40) xlabel(-2 -1 0 1 2, valuelabel angle(45)) xline(0.808)  xtitle("Public Opinion") by(,note( " "))  $gshist , if id_question==6
		graph export "figa2f.png", replace
		histogram y_likert, discrete gap(40)  xlabel(-2 -1 0 1 2, valuelabel angle(45)) xline(0.124)  xtitle("Public Opinion") by(,note( " "))  $gshist  , if id_question==7
		graph export "figa2g.png", replace
		histogram y_likert, discrete gap(40)  xlabel(-2 -1 0 1 2, valuelabel angle(45)) xline(0.596)  xtitle("Public Opinion") by(,note( " "))  $gshist  , if id_question==8
		graph export "figa2h.png", replace
		histogram y_likert, discrete gap(40)  xlabel(-2 -1 0 1 2, valuelabel angle(45)) xline(0.635)  xtitle("Public Opinion") by(,note( " "))  $gshist , if id_question==9
		graph export "figa2i.png", replace
		histogram y_likert, discrete gap(40)  xlabel(-2 -1 0 1 2, valuelabel angle(45)) xline(0.367)  xtitle("Public Opinion") by(,note( " "))  $gshist  , if id_question==10
		graph export "figa2j.png", replace
		
/****************************************************************************
  Figure A3
****************************************************************************/
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
		merge 1:1 spec using "temporarydata\table1.dta"
		keep if _merge==3 

		tw (scatter beta y_opinion1, mlabel(spec) mcolor(black%30)  mlabcolor(black)) (lfit beta y_opinion1,lcolor(black) lpattern(dash)), xlab(,format(%4.2f)) legend(off) ytitle(Degree of Persuasiveness) xtitle(Initial Public Certainty) xlab(0.4 0.6 0.8 1.0) graphregion(color(white)) 
				graph export "figa3a.png", replace width(2000)

		tw (scatter beta distance10, mlabel(spec) mcolor(black%30)  mlabcolor(black)) (lfit beta distance10,lcolor(black) lpattern(dash)), xlab(,format(%4.2f)) legend(off) ytitle(Degree of Persuasiveness) xtitle(Initial Expert-public Distance) xlab(0.1 0.3 0.5 0.7 0.9) graphregion(color(white)) 
				graph export "figa3b.png", replace width(2000)
				
/****************************************************************************
  Figure A4
****************************************************************************/				
				
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
			foreach outcome in "y_match" {
				foreach model in "u"  {
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
							
							graph export "figa4.png", width(2000) replace
				}
			}	 
			
			
/****************************************************************************
  Figure A5
****************************************************************************/	

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
							
							graph export "figa5.png", width(2000) replace
	
			
/****************************************************************************
  Figure A6
****************************************************************************/	
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
		*br id_prolific id_question x_lastname count 
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
		
			format beta %4.3f

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
					graph export "figa6.png", replace	
	
			
/****************************************************************************
  Figure A8
****************************************************************************/	

// Panel A: 
	// Load data
		use "temporarydata/analysisdata.dta",clear
		// Estimate
		keep if id_noexpert==3
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
		graph export "figa8a.png", replace				
							

// Panel B: 

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
		// Estimate
		keep if id_noexpert==3
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
		graph export "figa8b.png", replace width(2000)
		
		
// Panel C: 

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
		// Estimate
		keep if id_noexpert==3
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

			format beta %4.2f
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
								xline(0 0.22,lcolor(gs9) lpattern(dash)) ///
								xlab(0 "0.00" 0.05 "0.05" 0.1 "0.10" ///					
								0.15 "0.15" 0.2 "0.20"   0.25 "0.25" 0.3 "0.30" 0.4 " ", labsize(small) noticks)
						
		graph export "figa8c.png", replace		
		
		
/****************************************************************************
  Table A2
****************************************************************************/	
	use "temporarydata\analysisdata.dta",clear
		// Select dataset
		keep if id_noexpert==0
		byso id_question: su(x_female_expert)
		foreach x in x_expert_likert x_female x_degree x_white x_econknowl x_republican x_old{
			ttest `x', by(x_female_expert)
			}
		su x_female_expert x_expert_likert x_female x_degree x_white x_econknowl x_republican x_old if id_noexpert==0
		foreach x in x_expert_likert x_female x_degree x_white x_econknowl x_republican x_old{
		byso id_question: ttest `x', by(x_female_expert)
		}

		
/****************************************************************************
  Table A3
****************************************************************************/	
	use "temporarydata\analysisdata.dta",clear
		// Select dataset
		keep if id_noexpert==0
	eststo clear
	eststo: reghdfe y_likert XStrDis XDis  XAgr XStrAgr, absorb(id_prolific id_question) cluster(id_prolific )
	eststo: reghdfe y_likert XStrDis XDis  XAgr XStrAgr, a(id_question) cluster(id_prolific)
	eststo: xi: ologit y_likert XStrDis XDis  XAgr XStrAgr i.id_question, cluster(id_prolific)
	esttab _all using "tablea3.rtf", replace b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) keep(XStrDis XDis  XAgr XStrAgr _cons)
	eststo clear	

	
/****************************************************************************
  Table A4
****************************************************************************/	
	use "temporarydata\analysisdata.dta",clear
		keep if id_noexpert==0
			eststo clear
			
		eststo: reghdfe y_broad_match x_female_expert, cluster(id_prolific) absorb(id_prolific id_question)
		eststo: reghdfe y_broad_match x_female_expert, cluster(id_prolific) absorb(id_prolific id_question x_inst)
		eststo: reghdfe y_broad_match x_female_expert 	x_p_cheerful x_p_professional , cluster(id_prolific) absorb(id_prolific id_question)
		eststo: reghdfe y_broad_match x_female_expert 	x_p_cheerful x_p_professional x_age x_news x_cites x_hi , cluster(id_prolific) absorb(id_prolific id_question)
		eststo: reghdfe y_broad_match x_female_expert x_maleXfemale_expert x_oldXfemale_expert x_degreeXfemale_expert x_econXfemale_expert x_whiteXfemale_expert x_republicanXfemale_expert , cluster(id_prolific) absorb(id_prolific id_question)
		

		esttab using "tablea4.rtf", se nogaps b(%4.3f) replace star(* 0.1 ** 0.05 *** 0.01)
		eststo clear
	
/****************************************************************************
  Table A5
****************************************************************************/			
			use "temporarydata\analysisdata.dta",clear
		keep if id_noexpert==0
			eststo clear
			
			eststo: reghdfe y_distance x_female_expert, cluster(id_prolific) absorb(id_prolific id_question)
		eststo: reghdfe y_distance x_female_expert, cluster(id_prolific) absorb(id_prolific id_question x_inst)
		eststo: reghdfe y_distance x_female_expert 	x_p_cheerful x_p_professional , cluster(id_prolific) absorb(id_prolific id_question)
		eststo: reghdfe y_distance x_female_expert 	x_p_cheerful x_p_professional x_age x_news x_cites x_hi , cluster(id_prolific) absorb(id_prolific id_question)
		eststo: reghdfe y_distance x_female_expert x_maleXfemale_expert x_oldXfemale_expert x_degreeXfemale_expert x_econXfemale_expert x_whiteXfemale_expert x_republicanXfemale_expert , cluster(id_prolific) absorb(id_prolific id_question)
	

		esttab using "tablea5.rtf", se nogaps b(%4.3f) replace star(* 0.1 ** 0.05 *** 0.01)
		
	
/****************************************************************************
  Table A6
****************************************************************************/
		use "temporarydata\analysisdata.dta",clear
		// Select dataset
		keep if id_noexpert==0
		label def x_expert_likert -2 "StrDis" -1 "Disagree" 0 "Uncertain" 1 "Agree" 2 "StrAgr"
		label values x_expert_likert x_expert_likert
		eststo clear

		eststo: reghdfe y_match x_female_expert if x_expert_likert==-2|x_expert_likert==-1, a(id_question) /*expert disagrees*/
		eststo: reghdfe y_match x_female_expert if x_expert_likert==-0, a(id_question)						/*expert uncertain*/
		eststo: reghdfe y_match x_female_expert if x_expert_likert== 1|x_expert_likert==2, a(id_question)  /*expert agrees*/
		eststo: reghdfe y_match x_female_expert if x_expert_likert== 1|x_expert_likert==-1, a(id_question) /*expert agrees/disagrees, not strongly*/
		eststo: reghdfe y_match x_female_expert if x_expert_likert==-2|x_expert_likert==2, a(id_question)  /*expert agrees/disagrees, strongly*/
		
		esttab using "tablea6.rtf", se nogaps b(%4.3f) replace star(* 0.1 ** 0.05 *** 0.01)
		eststo clear

		
/****************************************************************************
  Table A7
****************************************************************************/
		
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
				esttab using "tablea7.rtf", se nogaps b(%4.3f) replace ///
			star(* 0.1 ** 0.05 *** 0.01) stats(MeanAge MeanAgeWeighted MeanDegree MeanDegreeWeighted MeanRepublican MeanRepublicanWeighted MeanWhite MeanWhiteWeighted) label nolines   nonumbers nonotes
		
		
/****************************************************************************
  Table A8
****************************************************************************/	
	use "temporarydata\analysisdata.dta",clear
		// Select dataset
		keep if id_noexpert==3
		byso id_question: su(x_female_expert)
		foreach x in x_expert_likert x_female x_degree x_white x_econknowl x_republican x_old{
			ttest `x', by(x_female_expert)
			}
		su x_female_expert x_expert_likert x_female x_degree x_white x_econknowl x_republican x_old if id_noexpert==0
		foreach x in x_expert_likert x_female x_degree x_white x_econknowl x_republican x_old{
		byso id_question: ttest `x', by(x_female_expert)
		}

		