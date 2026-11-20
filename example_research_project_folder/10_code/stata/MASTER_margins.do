


*-------
* MASTER
*-------


// globals
//--------

	do "/Users/vesper/Documents/Projects/Margins_Incarceration/ ... set_globals_adriane.do"



// prep by source
//---------------

	cd "${marginsInc}/20_code/10_prep_by_source/"
	do 00_prepsource_MASTER.do



// clean
//------

	cd "${marginsInc}/20_code/20_clean/"
	do 00_clean_MASTER.do



// aggregate to county-year
//-------------------------

	cd "${marginsInc}/20_code/30_aggregate/"
	do 00_aggregate_MASTER.do



// margins analysis
//-----------------

	cd "${marginsInc}/20_code/40_margins/"
	do 00_margins_MASTER.do



// paper tables, figures, and numbers
//-----------------------------------

	cd "${marginsInc}/20_code/50_paper/"
	do 00_paper_MASTER.do



// black elected officials
//------------------------

	cd "${marginsInc}/20_code/45_beo/"
	do 00_beo_MASTER.do




*--------------
* end of MASTER
*--------------



