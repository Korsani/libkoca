libkoca
=======

Small library for shell scripting.

# Including 

* `koca_cleanOnExit`: remove a file upon script exiting (those who use mktemp will appreciate)
* `getColor`: assign color code to a variable (for sexy logs messages).
* `koca_lockMe`: provide a lock mechanism to your script, preventing it for being launched more than once.
* `getConfValue`: read a key and return a value from a file .properties-like. Useful to provide a configuration file to your script.
* `dieIfNotRoot`: exit if the script is not run as root.
* `koca_load`: return true is load is less than a floating specified value

And some others, less often useful: check that a string is an IPadress, convert seconds to day:hours:minutes:seconds and vice versa, return the path where the scripts is run from, clone a function to an other name, ...

# Featuring 
* UT, with shunit2
* Dynamic building: if a function does not pass the tests, it is not included in the final file.
* Executable library: 'sh libkoca.sh' display helps. 'sh libkoca.sh list' display the lists of functions.
* You only want the lockMe function ? do 'eval "$(libkoca.sh lockMe)"' and you'll have only this function in the namespace of your script.
* Tested on Linux and FreeBSD

# Installation

On FreeBSD you'll need the GNU bc for koca_dec2frac. For Linux, bc is probably already installed. If not, please install it.

## By rebuild

	$ make install

## Using the 'static' file provided

	$ cp libkoca.sh.a libkoca.sh
	$ make install
