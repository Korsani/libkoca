# libkoca

Small library for shell scripting.

## Getting started

A bunch of useful shell functions, patiently crafted over years and heavily used ever since (by me).

They will make your life easier by automating things you always do, and your script sexier by displaying nicely presented infos.

For example, and not limited to:

* Remove a file upon script exiting (those who use mktemp(1) will appreciate) (`koca_cleanOnExit`)
* Assign color code to a variable (for sexy logs messages) (`getColor`)
* Provide a lock mechanism to your script, preventing it for being launched more than once (`koca_lockMe`)
* Read a key and return a value from a properties-like file (section.key=value). Useful to provide a configuration file to your script. (`getConfValue`)
* Exit if the script is not run as root (`dieIfNotRoot`)
* Return true if load is less than a floating specified value (`koca_load`)
* Spining cursor and text scrolling (`koca_spin`)
* A pv(1)-like non blocking not piped progress bar (`koca_progress`)
* Convert bytes to kilo/mega/giga/tera/peta bytes (`koca_b2gmk`)
* and seconds tou day:hour:min:sec, and vice versa (`s2dhms`, `dhms2s`)

And some others, less often useful: check that a string is an IP address, convert seconds to day:hours:minutes:seconds and vice versa, return the path where the scripts is run from, clone a function to an other name, ...


### Prerequisites

bash(1) >= 4, gnu bc(1)

### Installing

	$ git clone git@github.com:Korsani/libkoca.git
	$ cd libkoca
	$ make		# will run unit tests thanks to shunit2(1)

You can also use the provided `libkoca.sh.a`, which has been carefully tested:

	$ cp libkoca.sh.a libkoca.sh

Then install:

	$ sudo make install

Will install `libkoca.sh` in `/usr/local/include`.

### Using

```
#!/usr/bin/env bash
source /usr/local/include/libkoca.sh
```
If you want help on using the lib:

	$ bash libkoca.sh

For a list of included functions:

	$ bash libkoca.sh list

If you want a specific function:

	#!/usr/bin/env bash
	# Includes only koca_lockMe
	eval "$(libkoca.sh koca_lockMe)"

## Acknowledgments

* Tested on Linux, FreeBSD, Darwin (MacOS)
* Code is probably not as clean as it should be...
* But should be fast (I merely develop on rpi and slow computers). If you have faster ways of doing the same things, please send a PR!

# List of functions

```
koca_b2gmk 	# byte to giga, mega, kilo (tera, peta). Usage: $0 <integer>
koca_banner() 	# Display string in a banner way: chars one by one, at givent speed. Usage: $0 [@]<string> <float>
checkNeededFiles 	# Check wether file can be found. Usage: $0 must|may <file>
koca_cleanOnExit  # Remove specified file on script exit. Usage: $0 <file>
koca_dec2frac 	# Return fraction form of a decimal number. Usage: $0 <float>
dhms2s 	# Convert a 'day hour min sec' string to seconds. Usage: $0 <string>
dieIfNotRoot  # Exit calling script if not running under root. Usage: $0
dieIfRoot  # Exit calling script if run under root
underSudo  # Return wether the calling script is run under sudo
gotRoot  # Return wether the calling script is run under root
getColor  # Return a specified color code in a specified var. Usage: $0 <var>[+] <colorname>. $0 list
getConfValue 	# Get a the value corresponding to a key from a conf file. Usage: $0 <key>
getConfAllKeys 
getConfAllSections 
koca_int2pm  # return +, ++, +++ (or -). Usage: $0 <value> [ <max> [ <length> [ 'gauge' [ <sign+><sign-> ] ] ] ]
koca_isBackgrounded()  # Return true if process is backgrounded. Usage: $0
isIp  # return true if parameter is an IPv4/IPv6 address. Usage: $0 <string>
koca_isNumeric  # Return true if parameter is numeric. Usage: $0 <string>
koca_join  # join lines from STDIN with $1. Usage: | $0 <string>
koca_load()  # Return true if load is less or equals to specified float value. Usage: $0 <float>
koca_lockMe  # Lock the calling script with the specified file. Usage: $0 <file>
koca_unlockMe  # Remove the lock. Usage: $0 <file>
koca_isLocked 	# Check wether lock exists
koca_progress     # Display a non blocking not piped progress. Usage: $0 <progress%> <string>
koca_quotemeta  # Escape meta character. Usage: $0 <string>
s2dhms 	# Convert seconds to day hour min sec, or xx:xx:xx if -I. Usage: $0 <int>
koca_spin 	# Display a spinning cursor or scrolling text. Usage: $0 [ <int|string> [ <-1|0|1> [ <int> ] ] ]. $0 list
whereAmI 	# Return the directory where the script reside. Usage: $0
whereIs 	# Return the location of a given file by searching in common locations. Usage: $0 <string>
```
