* RRF 2024 - Analyzing Data Template	
*-------------------------------------------------------------------------------	
* Load data
*------------------------------------------------------------------------------- 
	
	*load analysis data 
	use "${data}/Final/TZA_CCT_analysis"
	

*-------------------------------------------------------------------------------	
* Summary stats
*------------------------------------------------------------------------------- 

	* defining globals with variables used for summary
	global sumvars 	nonfood_cons_usd_w food_cons_usd_w area_acre_w read sick days_sick treat_cost_usd

	
	* Summary table - overall and by districts
	eststo clear
	eststo all: estpost sum ${sumvars}
	
	forval z=1(1)3 {
	eststo district_`z': estpost sum ${sumvars} if district==`z' 
	}
	
	
	* Exporting table in csv
	esttab 	all district_* ///
			using "${outputs}/summary.csv", replace /// 
			label ///
			main(mean %6.2f) ///
			refcat(hh_size "HH Characteristics" drought_flood "Shocks", nolabel) ///
			mti("Full Sample" "Kibaha" "Bagamoyo" "Chamwino") ///
			nonotes addn(Mean with standard devaitions in parenthesis.)
			

	* Also export in tex for latex
		esttab 	all district_* ///
			using "${outputs}/summary.tex", replace /// 
			label ///
			main(mean %6.2f) ///
			refcat(hh_size "HH Characteristics" drought_flood "Shocks", nolabel) ///
			mti("Full Sample" "Kibaha" "Bagamoyo" "Chamwino") ///
			nonotes addn(Mean with standard devaitions in parenthesis.)
			
			
*-------------------------------------------------------------------------------	
* Balance tables
*------------------------------------------------------------------------------- 	
	
	* Balance (if they purchased cows or not)
	iebaltab 	${sumvars}, ///
				grpvar(treatment) ///
				rowvarlabels	///
				format(%9.2f)	///
				savecsv("${outputs}/balance") ///
				savetex("${outputs}/balance") ///
				nonote addnote("Here is my note") replace 			

				
*-------------------------------------------------------------------------------	
* Regressions
*------------------------------------------------------------------------------- 				
				
	* Model 1: Regress of food consumption value on treatment
	regress food_cons_usd_w treatment
	eststo mod1		// store regression results
	
	estadd local clustering "No"
	
	* Model 2: Add controls 
	regress food_cons_usd_w treatment crop_damage drought_flood
	eststo mod2		// store regression results

	estadd local clustering "No"

	
	* Model 3: Add clustering by village
	regress food_cons_usd_w treatment crop_damage drought_flood, vce(cluster vid)
	eststo mod3		// store regression results
	
	estadd local clustering "Yes"

	* Export results in tex
	esttab 	mod1 mod2 mod3 ///
			using "$outputs/regressions.tex" , ///
			label ///
			b(%9.2f) se(%9.2f) ///
			nomtitles ///
			mgroup("Food conusmption (USD)", pattern(1 0 0 ) span) ///
			scalars("clustering Clustering") ///
			replace
			
*-------------------------------------------------------------------------------			
* Graphs 
*-------------------------------------------------------------------------------	

	* Bar graph by treatment for all districts 
	gr bar area_acre_w, ///
		over(treatment) ///
		by( district, row(1) note(**)) ///
		legend(pos(6)) ///
		ti("Acre cultivated by treatment assignemnt across district") ///
		asy ///
		legend(rows(1) order(0 "Assignment:" 1 "Control" 2 "Treatment")) ///
		subti(, pos(6) bcolor(none)) ///
		blabel(total, format(%9.1f)) ///
		yti("Average area cultivated (Acre)") name(g1, replace)
		
	
	gr export "$outputs/fig1.png", replace		
			
	* Distribution of non food consumption by female headed hhs with means
forval f=0/1{
		sum nonfood_cons_usd_w if female_head==`f'
		local mean_`f' = `r(mean)'
}

	twoway	(kdensity nonfood_cons_usd_w if female_head==0, color(grey)) ///
			(kdensity nonfood_cons_usd_w if female_head==1, color(red)), ///
			xline(`mean_0', lcolor(grey) 	lpattern(dash)) ///
			xline(`mean_1', lcolor(red) 	lpattern(dahs)) ///
			leg(order(0 "Household Head:" 1 "Male" 2 "Female" ) row(1) pos(6)) 	///
			xtitle("Distribution of non food consumption") ///
			ytitle("Density") ///
			title("Distribution of non food consumption") ///
			note("Here is my note.")
			
	gr export "$outputs/fig2.png", replace				

*-------------------------------------------------------------------------------			
* Graphs: Secondary data
*-------------------------------------------------------------------------------			
			
	use "${data}/Final/TZA_amenity_analysis.dta", clear
	
	* createa  variable to highlight the districts in sample
	gen in_sample =inlist(district,1,3,6)
	
	* Separate indicators by sample
	separate n_school, by(in_sample)
	separate n_medical, by(in_sample)
	
	
	* Graph bar for number of schools by districts
gr hbar 	n_school0 n_school1, ///
				nofill ///
				over(district, sort(n_school)) 	///
				legend(order(0 "Sample:" 1 "Out" 2 "In") row(1)  pos(6)) ///
				ytitle("No. of Schools") ///
				name(g1, replace)
				
				
	* Graph bar for number of medical facilities by districts				
	gr hbar 	n_medical0 n_medical1, ///
				nofill ///
				over(district, sort(n_medical)) 	///
				legend(order(0 "Sample:" 1 "Out" 2 "In") row(1)  pos(6)) ///
				ytitle("No. of Medical Facilities") ///
				name(g2, replace)
				
				
 grc1leg2 g1 g2, /// 	row(1) legend(1) /// 	
 ycommon xcommon  ///
	tit("No. of Schools and Medical Facilities by District", size(medsmall))
 		
	gr export "$outputs/fig3.png", replace			

****************************************************************************end!
	
