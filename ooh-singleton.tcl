## ooh-singleton.tcl (created by Tloona here)

namespace eval ::ooh {}

## A singleton implementation
#
# This class ensures that only one instance is created of it. The [new] method 
# creates the only instance if it not exists and returns it if it exists.
::ooh::class create ::ooh::singleton {
    extends ::ooh::class

    property Instance {}

    method new {args} {
        if {$Instance != {}} {
            return $Instance
        }
        set Instance [next {*}$args]

        # make sure the Instance property is reset when the singleton object
        # is destroyed. We set up a filter for that.
        append mBody "if \{\$args == \"\"\} \{ [namespace origin my] DeleteInstance \}" \n
        append mBody "next \{*\}\$args" \n
        oo::define [self] method OnDestroyFilter {args} $mBody
        oo::define [self] filter OnDestroyFilter

        return $Instance
    }

    method create {args} {
        throw {OOH SINGLETON_CREATE} "A singleton cannot be \[create\]'d! Use \[new\] to get the instance"
    }

    method DeleteInstance {} {
        set Instance {}
    }

}
