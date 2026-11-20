

* set globals for margins of incarceration
*-----------------------------------------


* Run before all other files to set globals
macro drop _all


global closef = "capture file close myfile"
global openf = "file open myfile using"
global writef = "file write myfile"


global marginsInc 	"/Users/vesper/...[my file path]"




