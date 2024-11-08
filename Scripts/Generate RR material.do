// RR material 
graph set window fontface default
*cd "C:\Users\ecsls\Dropbox\igm\Survey Experiment\Survey for RR\Data"
cd "C:\Users\B059633\Dropbox\Work\Research\Projects\Gender Econ\Survey Experiment\Survey for RR\Data"


				
// Figure 4 - main effects and interactions: Expert identity - RR survey
		* Load survey without credentials
		u analysisdata, clear
		gen rrsurvey=1
		// Append original survey
		append using "C:\Users\B059633\Dropbox\Work\Research\Projects\Gender Econ\Survey Experiment\temporarydata\analysisdata.dta"
		replace rrsurvey=0 if rrsurvey==.
		// Generate interaction 
		gen x_female_expertXrrsurvey=x_female_expert*rrsurvey
		// Test for difference
		reghdfe y_match x_female_expert rrsurvey x_female_expertXrrsurvey, cluster(id_prolific) absorb(id_prolific id_question)
		
		// Keep only RR survey 
		keep if rrsurvey==1
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
		use "analysisdata.dta",clear
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
			gen coef=string(beta,"%4.4f")
			gen betalabel=coef+star
			
			
			gen plabel=0.025
			gen ymarker=0.02525
			gen ymarker2=0.0248
				gen ylabel=0.027
		
				
// Maybe a horizontal figure is better?
		cap gen xreverse=8-x
		cap dro xreverse2
		cap gen xreverse2=8-xlabel-0.175
		cap drop ylabel2
		cap gen ylabel2=0.065
		
		format beta %6.4f
		* change beta if very small
		
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
					graph export "Results\fig4a.png", replace	

					
							
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
			frame change default
		// Load data
					// Estimate  for all
					use "analysisdata.dta",clear
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
		graph export "results\figA8b.png", replace width(2000)
		
	// Table A9
	u analysisdata, clear
		// Select dataset
	
	byso id_question: su(x_female_expert)
	cap file close mf
	file open mf using  "results\tab_balance_second.csv", write replace
		file write mf "Question `i'"
		foreach x in  x_expert_likert x_female x_old x_degree x_white x_republican x_econknowl   {
			ttest `x' , by(x_female_expert)
			local d: disp %4.2f  r(p) 
			file write mf ",[`d']"
		}
		file write mf _n _n
	forval i=1/10{
		file write mf "Question `i'"
		foreach x in  x_expert_likert x_female x_old x_degree x_white x_republican x_econknowl   {
			ttest `x' if id_question==`i', by(x_female_expert)
			local d: disp %4.2f  r(p) 
			file write mf ",[`d']"
		}
		file write mf _n
	}
		file write mf "Question `i'"
		foreach x in  x_expert_likert x_female x_old x_degree x_white x_republican x_econknowl   {
			sum `x' 
			local d: disp %4.2f  r(mean) 
			file write mf ",`d'"
		}
		file write mf _n
	cap file close mf
// Now consider the opinions
		u analysisdata, clear
		bys id_prolific: keep if _n==1
		
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
			graph export "Results\fig4b.png", replace	

			
// Now consider what the survey is about


// load data
		import excel "code_about.xlsx", sheet("Sheet1") firstrow clear
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
			graphregion(color(white)) xlab(,grid)
		graph export "Results\fig4c.png", replace	
