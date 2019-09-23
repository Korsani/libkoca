libkoca
=======

Small library for shell scripting.

* Remove a file upon script exiting (those who use mktemp will appreciate) (`koca_cleanOnExit`)
* Assign color code to a variable (for sexy logs messages) (`getColor`)
* Provide a lock mechanism to your script, preventing it for being launched more than once (`koca_lockMe`)
* Read a key and return a value from a properties-like file (section.key=value). Useful to provide a configuration file to your script. (`getConfValue`)
* Exit if the script is not run as root (`dieIfNotRoot`)
* Return true if load is less than a floating specified value (`koca_load`)
* Spining cursor and text scrolling (`koca_spin`)
* Convert bytes to kilo/mega/giga/tera/peta bytes (`koca_b2gmk`)
* and seconds tou day:hour:min:sec, and vice versa (`s2hms`, `hms2s`)

And some others, less often useful: check that a string is an IPadress, convert seconds to day:hours:minutes:seconds and vice versa, return the path where the scripts is run from, clone a function to an other name, ...

# Featuring 
* UT, with shunit2
* Dynamic building: if a function does not pass the tests, it is not included in the final file.
* Executable library: 'sh libkoca.sh' display helps. 'sh libkoca.sh list' display the lists of functions.
* You only want the lockMe function ? do 'eval "$(libkoca.sh lockMe)"' and you'll have only this function in the namespace of your script.
* Tested on Linux, FreeBSD, Darwin (MacOS)

# Installation

On FreeBSD you'll need the GNU bc for koca_dec2frac. For Linux, bc is probably already installed. If not, please install it.

## By rebuild

	$ make install

## Using the 'static' file provided

	$ cp libkoca.sh.a libkoca.sh
	$ make install
