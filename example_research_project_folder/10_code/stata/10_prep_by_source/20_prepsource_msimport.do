


	******************************************************************
	**
	**
	**		NAME:	Adriane Fresh
	**
	**		PROJECT: 	Margins of Incarceration
	**
	**
	**
	******************************************************************





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* preliminaries
*-------------------------------------------------------------------------------


* preliminaries
*--------------

clear
set more off


local src = "${marginsInc}/10_source_data/20_transcribed_records/ms_transcribed/transcribed_files_ellen"


tempfile all
save `all', emptyok




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* import every spreadsheet (14 MS_Completed_Files folders)
*-------------------------------------------------------------------------------

	/*

		Template columns are identical across all files (A-U, 21 columns), so
		columns are imported by position and renamed below.  Columns beyond U
		were checked to be empty in every file.

		Same book-part can appear in several folders (e.g. 13 and 14 hold
		the same Book T files); every copy is imported and duplicates are
		resolved in the next section.  The zips the folders were extracted from
		sit in transcribed_files_ellen/zips and are not read.

	*/


* loop over folders
*------------------

foreach base in "`src'" {

	local dirs : dir "`base'" dirs "MS_Completed_Files*"

	foreach d of local dirs {

		local files : dir "`base'/`d'" files "*.xlsx"

		foreach f of local files {

			quietly {

			import excel using "`base'/`d'/`f'", describe
			
			if ustrregexm("`r(range_1)'", ":([A-Z]+)([0-9]+)$") {
				local lastcol = ustrregexs(1)
				local lastrow = min(real(ustrregexs(2)), 500)
			}
			if strlen("`lastcol'") > 1 | "`lastcol'" > "U" local lastcol = "U"
			
			import excel using "`base'/`d'/`f'", cellrange(A2:`lastcol'`lastrow') allstring clear

			foreach v in A B C D E F G H I J K L M N O P Q R S T U {
				capture confirm variable `v'
				if _rc gen `v' = ""
			}
			keep A-U

			gen rowinfile 		= _n
			gen source_file 	= "`f'"
			gen source_container = "`d'"
			gen source_zipped 	= 0

			append using `all'
			save `all', replace

			}
		}
	}
}




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* book and part from the file name
*-------------------------------------------------------------------------------


* book and part
*--------------

gen book = ustrregexs(1) 			if ustrregexm(source_file, "Book([A-Z](-[A-Z])?)_Part([0-9]+)")
gen part = real(ustrregexs(3)) 		if ustrregexm(source_file, "Book([A-Z](-[A-Z])?)_Part([0-9]+)")


assert book != ""
assert part != .




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* one copy of each book-part
*-------------------------------------------------------------------------------


* copies per book-part
*---------------------

egen tag_copy = tag(book part source_container source_zipped)
bysort book part: egen n_copies = total(tag_copy)
drop tag_copy

label var n_copies "number of folders holding this book-part"




* drop duplicate copies
*----------------------

sort book part source_zipped source_container rowinfile

duplicates drop book part rowinfile A-U, force

isid book part rowinfile


drop source_zipped




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* rename and drop empty rows
*-------------------------------------------------------------------------------


* rename
*-------

rename A ms_state
rename B filename
rename C pages
rename D recv_raw
rename E home_raw
rename F age_raw
rename G complexion_raw
rename H educ_raw
rename I readwrite_raw
rename J crimhist_raw
rename K county_raw
rename L crime_raw
rename M sentdate_raw
rename N term_raw
rename O nativity_raw
rename P race_raw
rename Q occup_raw
rename R relig_raw
rename S disch_raw
rename T pardon_raw
rename U notes_raw




* trim
*-----

foreach v of varlist ms_state-notes_raw {
	replace `v' = strtrim(stritrim(`v'))
}




* drop rows with no record content
*---------------------------------

	// rows where only the RA-entered identifiers (state, file, pages) are filled

egen n_content = rownonmiss(recv_raw-pardon_raw), strok

count if n_content == 0
drop if n_content == 0
drop n_content




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* drop files whose content duplicates another part
*-------------------------------------------------------------------------------

	/*
	
		Three sets of differently-named files hold the same records:
		
			S part 28 and A-M part 9 	= the records of A-A part 26 (1962)
			T part 27 and T part 28 	= identical
			A-K part 5 and A-K part 6 	= identical
			A-P part 20 and A-R part 20 	= same 40 people, re-typed (A-P 20's
										  Aug 1980 dates fit A-R, not A-P)
			A-H part 9 and A-H part 10 	= same people; A-H 9 has every date 
										  with day and month swapped (Excel 
										  re-read it day-first), so A-H 10 is kept
		
		So....... S 28, A-M 9, A-P 20, A-H 9 and one of each identical pair were not actually 
		transcribed.  Which of T 27/28 (and A-K 5/6) the records belong to 
		cannot be told from the spreadsheets; the lower-numbered part is kept.
		The dropped parts count as untranscribed in the coverage measure.
	
	*/


* drop
*-----

drop if book == "S" 	& part == 28
drop if book == "A-M" 	& part == 9
drop if book == "T" 	& part == 28
drop if book == "A-K" 	& part == 6
drop if book == "A-P" 	& part == 20
drop if book == "A-H" 	& part == 9




* check that no other part substantially duplicates another
*---------------------------------------------------------

egen content = concat(recv_raw-pardon_raw), punct("|")

duplicates tag content, gen(dup)
replace dup = 0 		if ustrregexm(content, "^[\| ]*$")

bysort book part: egen sh_dup = mean(dup > 0)

	// where are identical rows; whole parts not
assert sh_dup < 0.5

drop content dup sh_dup




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* label
*-------------------------------------------------------------------------------


* label
*------

label var ms_state 			"raw: state (RA entered)"
label var filename 			"raw: file name (RA entered)"
label var pages 			"raw: pdf pages (RA entered)"
label var recv_raw 			"raw: received date"
label var home_raw 			"raw: home address (city, state)"
label var age_raw 			"raw: age"
label var complexion_raw 	"raw: complexion"
label var educ_raw 			"raw: education"
label var readwrite_raw 	"raw: yrs read and write"
label var crimhist_raw 		"raw: criminal history"
label var county_raw 		"raw: county of conviction"
label var crime_raw 		"raw: crime"
label var sentdate_raw 		"raw: date of sentence"
label var term_raw 			"raw: term"
label var nativity_raw 		"raw: nativity"
label var race_raw 			"raw: race"
label var occup_raw 		"raw: occupation"
label var relig_raw 		"raw: religion"
label var disch_raw 		"raw: discharged"
label var pardon_raw 		"raw: pardoned/paroled"
label var notes_raw 		"raw: RA notes"

label var rowinfile 		"row number within the source spreadsheet (excl. header)"
label var source_file 		"source spreadsheet name"
label var source_container 	"folder the kept copy came from"
label var book 				"MS convict register book (S, T, ..., A-R)"
label var part 				"MS convict register part (pdf) within book"


order book part rowinfile, first




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* save the data
*-------------------------------------------------------------------------------


* save
*-----

cd "${marginsInc}/20_intermediate_data/stata/10_prep_by_source/"
save 20_prepsource_msimport.dta, replace




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


					** end of do file **



