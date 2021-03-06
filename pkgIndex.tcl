# Tcl package index file, version 1.1
# This file is generated by the "pkg_mkIndex" command
# and sourced either when an application starts up or
# by a "package unknown" script.  It invokes the
# "package ifneeded" command to set up package-related
# information so that packages will be loaded automatically
# in response to "package require" commands.  When this
# script is sourced, the variable $dir must contain the
# full path name of this file's directory.
proc _load-tclooh {dir} {
    source [file join $dir tclooh.tcl]
    source [file join $dir ooh-singleton.tcl]
    source [file join $dir ooh-factory.tcl]
    package provide tclooh 1.1.0
}

package ifneeded tclooh 1.1.0 [list _load-tclooh $dir]
package ifneeded otree 1.0.0 [list source [file join $dir otree.tcl]]
