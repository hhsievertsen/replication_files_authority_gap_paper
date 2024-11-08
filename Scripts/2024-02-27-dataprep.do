// clean prolific data, last edited 2024-02-27 by HHS
*cd "C:\Users\B059633\Dropbox\Work\Research\Projects\2 igm\Survey Experiment\"
*cd "/Users/hhs/Dropbox/Work/Research/Projects/2 igm/Survey Experiment"
cd "C:\Users\ecsls\Dropbox\igm\Survey Experiment\"

/******************** Full expert panel  **************************/

// Hans to Sarah: this is how it was before 
	// Load data
	use "rawdata/allexpert_responses.dta",clear
	// Sample identifier
	gen id_noexpert=2
	// rename 
	rename question id_question
	// Response
	gen x_expert_likert = -2 if response=="Strongly Disagree"
	replace x_expert_likert = -1 if response=="Disagree"
	replace x_expert_likert = 0 if response=="Uncertain"
	replace x_expert_likert = 1 if response=="Agree"
	replace x_expert_likert = 2 if response=="Strongly Agree"
	rename response x_expert_response
// Hans to Sarah: Note how Thaler and Udry have two duplicates with different responses! 
	// Print duplicates
	bys lastname id_question:  gen N=_N
	list if N>1
	br if N>1
	drop N
	// Delete duplicates
	bys lastname id_question: keep if _n==1
	// Keep vars
	keep id* x*
	save "temporarydata/allexperts.dta",replace

	/* stats for table 1 - cols 1 and 2 */
	
		gen opi = x_expert_likert==-1|x_expert_likert==-2|x_expert_likert==1|x_expert_likert==2
		tab id_question, su(opi)
		gen agr = x_expert_likert==1|x_expert_likert==2
		replace agr = . if opi==0
		tab id_question, su(agr)
	
	
/******************** Full expert panel  **************************/
// Hans to Sarah: this is the new one, where we load the responses directly from the scraped files
// Hans to Sarah: I suspect that there was an issue with importing from csv, so I first changed them to xlsx and important them
	
	// Loop over questions
	forval i=1/10{
		// Load data
		import excel "rawdata/q`i'.xlsx", clear
		// cleaning
		drop if A=="Last Name"
		// var names 
		rename A lastname 
		rename C response 
		rename D confidence
		// likert 
		gen x_expert_likert = -2 if response=="Strongly Disagree"
		replace x_expert_likert = -1 if response=="Disagree"
		replace x_expert_likert = 0 if response=="Uncertain"
		replace x_expert_likert = 1 if response=="Agree"
		replace x_expert_likert = 2 if response=="Strongly Agree"
		rename response x_expert_response
		// identify q
		gen id_question=`i'
		// keep 
		keep id_question  id_question x_* lastname
		save "temporarydata/q`i'.dta",replace
	}
	// Append 
	clear 
	forval i=1/10{
		append using "temporarydata/q`i'.dta",
	}
	// Print duplicates
	
	bys lastname id_question:  gen N=_N
	list if N>1
	drop N
	// Save 
	// Sample identifier
	gen id_noexpert=2
	save "temporarydata/allexperts.dta",replace
		/* stats for table 1 - cols 1 and 2 */
	
		gen opi = x_expert_likert==-1|x_expert_likert==-2|x_expert_likert==1|x_expert_likert==2
		tab id_question, su(opi)
		gen agr = x_expert_likert==1|x_expert_likert==2
		replace agr = . if opi==0
		tab id_question, su(agr)
	

/******************** Check the expert responses **************************/
// Hans to Sarah: I wanted to check that the experts in the survey had the right responses
	u "rawdata/matched_responses.dta", clear
	keep lastname response question
	// For some reason there is another duplicate here? But that seems harmless, because it is the same response
	bys lastname question: gen N=_N 
	*br if N>1
	bys lastname question: keep if _n==1

	rename question id_question
	merge 1:1 lastname id_question using "temporarydata/allexperts.dta", keep(1 3)

	compare response x_expert_response
	// Looks good! Phew!
/*********************** No expert panel (baseline) ****************************/
		clear
		insheet using "rawdata/voices_noexpert_1july.csv"
	
		// Define age variable
		encode age, gen(x_age)
		drop age
		replace x_age=. if x_age==7 /* Prefer not to say */
		gen x_old = x_age==6
		replace x_old = . if x_age==.
		label def old 0 "<65" 1 "65+"
		label values x_old old

		// Define gender variable 
		rename gender temp
		encode temp, gen(gender)
		drop temp
		gen x_female=gender==1
		replace x_female = . if gender>2  /* Non-binary, prefer not to say, etc */
		label def x_female 0 "Man" 1 "Woman"
		label values x_female female
	
		// Define ethnicity
		encode ethnicity, gen(race)
		gen x_white = race==12
		replace x_white = . if race==11
		drop ethnicity
		label def white 0 "Nonwhite" 1 "White"
		label values x_white white

		// Define education
		rename education temp
		encode temp, gen(education)
		gen x_degree = education<4
		replace x_degree = . if education==5
		drop education temp
		label def degree 0 "No degree" 1 "Degree"
		label values x_degree degree

		// Define econ knowledge
		ren econknowl x_econknowl
		label var x_econknowl "Economics knowledge"

		// Define political view
		rename politics temp
		ren temp  politics 
		gen x_democrat = politics=="Democrat"
		replace x_democrat = . if politics=="Prefer not to say"
		gen x_republican = politics=="Republican"
		replace x_republican = . if politics=="Prefer not to say"
		label def republican 0 "Democrat/Ind" 1 "Republican"
		label values x_republican republican
		gen x_independent = politics=="Independent"|politics=="Something else"
		replace x_independent = . if politics=="Prefer not to say"
		drop politics
		gen x_politics = -1*x_republican + x_democrat
		replace x_politics = . if x_democrat==.
		label def politics -1 "Republican" 0 "Independent" 1 "Democrat"
		label values x_politics politics 
	
		// duration 
		rename duration x_duration_sec
		
		// Keep what we need 
		
		keep question* prolific_pid x_*
		// Make long 
		reshape long question,i(prolific_pid) j(q)
		
		// Response
		gen y_likert = -2 if question=="Strongly disagree"
		replace y_likert = -1 if question=="Disagree"
		replace y_likert = 0 if question=="Uncertain"
		replace y_likert = 1 if question=="Agree"
		replace y_likert = 2 if question=="Strongly agree"
		rename question y_response
		// Rename 
		rename prolific_pid id_prolific 
		rename  q id_question
		gen id_noexpert=1
		
		 
		
		save "temporarydata/public_responses.dta", replace


/* stats for table 1 - cols 3 and 4 */
	
		gen opi = y_likert==-1|y_likert==-2|y_likert==1|y_likert==2
		tab id_question, su(opi)
		gen agr = y_likert==1|y_likert==2
		replace agr = . if opi==0
		tab id_question, su(agr)
	
		
/*********************** Expert panel ****************************/
	// load data extracted with R (reformatsurveyexperimentdata.R)
	u "temporarydata/surveyexperimentdata_long.dta", replace

	// Remove redundant variables
	drop start_date end_date status ip_address progress finished recorded_date recipient_* external_reference location* distribution_* user_language consent_*
	
	// Rename variables
	ren q id_question
	ren expert x_lastname
	rename female_expert x_female_expert 
	rename prolific_id id_prolific 

	// Define age variable
	encode background_q1, gen(x_age)
	drop background_q1
	replace x_age=. if x_age==7 /* Prefer not to say */
	gen x_old = x_age==6
	label def old 0 "<65" 1 "65+"
	label values x_old old

	// Define gender variable 
	encode background_q2, gen(gender)
	drop background_q2
	gen x_female=gender==1
	replace x_female = . if gender>2  /* Non-binary, prefer not to say, etc */
	label def x_female 0 "Man" 1 "Woman"
	label values x_female female
	label def female_expert 0 "Male" 1 "Female"
	label values x_female_expert female_expert

	// Define ethnicity
	encode background_q3, gen(race)
	gen x_white = race==12
	replace x_white = . if race==11
	drop background_q3
	label def white 0 "Nonwhite" 1 "White"
	label values x_white white

	// Define education
	encode background_q4, gen(education)
	gen x_degree = education<4
	replace x_degree = . if education==5
	drop background_q4
	label def degree 0 "No degree" 1 "Degree"
	label values x_degree degree

	// Define econ knowledge
	ren background_q5_1 x_econknowl
	label var x_econknowl "Economics knowledge"
	gen x_econ = x_econknowl>=6 & x_econknowl!=. 

	// Define political view
	ren background_q6 politics 
	gen x_democrat = politics=="Democrat"
	replace x_democrat = . if politics=="Prefer not to say"
	gen x_republican = politics=="Republican"
	replace x_republican = . if politics=="Prefer not to say"
	label def republican 0 "Democrat/Ind" 1 "Republican"
	label values x_republican republican
	gen x_independent = politics=="Independent"|politics=="Something else"
	replace x_independent = . if politics=="Prefer not to say"
	drop politics
	gen x_politics = -1*x_republican + x_democrat
	replace x_politics = . if x_democrat==.
	label def politics -1 "Republican" 0 "Independent" 1 "Democrat"
	label values x_politics politics 

	// Define id 
	qui bys id_prolific: gen id_count = _n

	// Define outcome 
	rename value y_response 
	// Summary stats
	su x_female x_degree x_white x_republican x_democrat x_independent x_econknowl if id_count==1
	tab x_age if id_count==1

	// Likert 
	gen y_likert = -2 if y_response=="Strongly disagree"
	replace y_likert = -1 if y_response=="Disagree"
	replace y_likert = 0 if y_response=="Uncertain"
	replace y_likert = 1 if y_response=="Agree"
	replace y_likert = 2 if y_response=="Strongly agree"
	
	// duration 
		rename duration x_duration_sec
		
		
	// Save temporary data
	so x_lastname id_question
	keep id_* x_* y_*
	order id_* x_* y_*
	save "temporarydata/temp.dta", replace

	// Load data on experts responses from EEP
	u "rawdata/matched_responses.dta", clear
	// Adjust encoding issues
	replace lastname = "Holmstrom" if lastname == "Holmstr√∂m"
	// Keep what we need 
	keep lastname question likert response
	// Merge with information on institution
	merge m:1 lastname using  "rawdata/inst.dta",nogen keep(3)
	// Rename 
	rename likert x_expert_likert 
	ren response x_expert_response
	rename lastname x_lastname 
	rename i_inst x_inst
	rename i_age x_age
	rename i_cites_all x_cites
	replace x_cites = x_cites/10000
	rename i_hi_all x_hi
	replace x_hi = x_hi/10
	replace x_age = x_age/10
	rename countnews x_news
	replace x_news = x_news/100
	rename question id_question
	// Remove duplicates - Saez sampled twice 
	so x_lastname id_question
	drop if x_lastname==x_lastname[_n-1] & id_question==id_question[_n-1]
	// Merge to prolific data
	merge 1:m x_lastname id_question using "temporarydata/temp.dta",nogen keep(3)
	
	// Merge to photocharacteristics
	gen lastname=x_lastname
	merge m:1 lastname using "rawdata/aiphotos.dta", nogen keepusing(professionalism trustworthiness confidence cheerful professional)  keep(3)
	drop lastname
	foreach v in professionalism trustworthiness confidence cheerful professional{
		rename `v' x_p_`v'
	}
	// ID for sample
	gen id_noexpert=0

	
/****************** combine datasets ****************/
		
	// Stack with other dataset
	append using "temporarydata/public_responses.dta"
	append using "temporarydata/allexperts.dta"
	
	tab id_noexpert
  
  label def id_noexpert 0 "experimental" 1 "baseline" 2 "all experts"
  label values id_noexpert id_noexpert

	// Create opinion/ agree variables 
	
	gen y_opinion = y_likert==-1|y_likert==-2|y_likert==1|y_likert==2
	gen y_agree = y_likert==1|y_likert==2
	replace y_agree = . if y_opinion==0
	
	gen x_expert_opinion = x_expert_likert==-1|x_expert_likert==-2|x_expert_likert==1|x_expert_likert==2
	gen x_expert_agree = x_expert_likert==1|x_expert_likert==2
	replace x_expert_agree = . if x_expert_opinion==0
	
	// Create Likert variables
		gen XStrDis=x_expert_response=="Strongly Disagree" 
		gen XDis=x_expert_response=="Disagree" 
		gen XStrAgr=x_expert_response=="Strongly Agree" 
		gen XAgr=x_expert_response=="Agree" 
	
	// Question names
	gen id_questiontext=""
	replace id_questiontext="AI" if id_question==1
	replace id_questiontext="Twitter" if id_question==2
	replace id_questiontext="Gouging" if id_question==3
	replace id_questiontext="NetZero" if id_question==4
	replace id_questiontext="SemiConductors" if id_question==5
	replace id_questiontext="Greedflation" if id_question==6
	replace id_questiontext="FinReg" if id_question==7
	replace id_questiontext="EcPolicy" if id_question==8
	replace id_questiontext="Windfall" if id_question==9
	replace id_questiontext="JunkFood" if id_question==10
	labmask id_question, val(id_questiontext)
	
	// Create outcomes
		gen y_distance=abs(y_likert-x_expert_likert)
		gen y_match=y_likert==x_expert_likert
		gen y_broad_match = 0
		replace y_broad_match=1 if y_match==1
		replace y_broad_match=1 if y_likert>0 & x_expert_likert>0 
		replace y_broad_match=1 if y_likert<0 & x_expert_likert<0
		replace y_broad_match=. if x_expert_likert==. | y_likert==.
		replace y_match=. if x_expert_likert==. | y_likert==.
		
	// Create interactions with expert_likert - heterogeneity of response to expertise
		gen x_male=1-x_female
		gen x_expert_likertXx_male = x_expert_likert*x_male
		gen x_expert_likertXx_female = x_expert_likert*x_female
		gen x_expert_likertXx_young = x_expert_likert*(1-x_old)
		gen x_expert_likertXx_old = x_expert_likert*x_old
		gen x_expert_likertXx_demind = x_expert_likert*(1-x_republican)
		gen x_expert_likertXx_republican = x_expert_likert*x_republican
		gen x_expert_likertXx_degree = x_expert_likert*x_degree
		gen x_expert_likertXx_nodegree = x_expert_likert*(1-x_degree)
		gen x_expert_likertXx_econ = x_expert_likert*x_econ
		gen x_expert_likertXx_noecon = x_expert_likert*(1-x_econ)
		gen x_expert_likertXx_white	= x_expert_likert*x_white	
		gen x_expert_likertXx_nonwhite = x_expert_likert*(1-x_white)
		
	// Create interactions with female experts
		
		gen x_expert_likertXfemale_expert=x_expert_likert*x_female_expert
		gen x_maleXfemale_expert=x_male*x_female_expert
		gen x_republicanXfemale_expert=x_republican*x_female_expert
		gen x_oldXfemale_expert=x_old*x_female_expert 
		gen x_whiteXfemale_expert=x_white*x_female_expert 
		gen x_degreeXfemale_expert=x_degree*x_female_expert
		gen x_econXfemale_expert=x_econ*x_female_expert
	// save 
	compress
	order id_* x_* y_*
	save "temporarydata/analysisdata.dta",replace
