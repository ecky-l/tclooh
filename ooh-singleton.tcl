## ooh-singleton.tcl (created by Tloona here)

namespace eval ::ooh {}

## A singleton implementation
#
# This class ensures that only one instance is created of it. The [new] method 
# creates the only instance if it not exists and returns it if it exists.
::ooh::class create ::ooh::singleton {
    extends ::ooh::class

    property Instance {}

    construct {args} {
        next {*}$args
        # make sure the Instance property is reset when the singleton object
        # is destroyed. We set up a filter for that.
        append mBody {set m [lindex [info level [expr {[info level]-1}]] 1]} \n
        append mBody {if {$m eq "destroy"}} " \{ [namespace origin my] DeleteInstance \}" \n
        append mBody {next {*}$args}
        oo::define [self] method OnDestroyFilter {args} $mBody
        oo::define [self] filter OnDestroyFilter
    }

    method new {args} {
        if {$Instance != {}} {
            return $Instance
        }
        set Instance [next {*}$args]
    }

    method create {args} {
        throw {OOH SINGLETON_CREATE} "A singleton cannot be \[create\]'d! Use \[new\] to get the instance"
    }

    method get {} {
        if {$Instance == {}} {
            throw {OOH SINGLETON_NOT_CREATED} "Singleton not yet created. Use \[new\] (with args) to create it"
        }
        return $Instance
    }

    method unknown {args} {
        if {$Instance == {}} {
            throw {OOH SINGLETON_NOT_CREATED} "Singleton not yet created. Use \[new\] (with args) to create it"
        }
        $Instance {*}$args
    }

    method DeleteInstance {} {
        set Instance {}
    }
}
