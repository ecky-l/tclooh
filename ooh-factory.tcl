## ooh-factory.tcl (created by Tloona here)

::ooh::class create ::ooh::factory {
    extends ::ooh::class

    property _Objects {}

    construct {args} {
        my variable _Objects
        set _Objects {}
        next {*}$args
    }

    method new {args} {
        set obj [next {*}$args]
        lappend _Objects $obj
        my InstallFilter $obj
        return $obj
    }

    method create {args} {
        set obj [next {*}$args]
        lappend _Objects $obj
        my InstallFilter $obj
        return $obj
    }

    method InstallFilter {obj} {
        # make sure the Instance property is reset when the singleton object
        # is destroyed. We set up a filter for that.
        append mBody "if \{\$args == \"\"\} \{ [namespace origin my] RemoveObject \[self\] \}" \n
        append mBody "next \{*\}\$args" \n
        oo::objdefine $obj method OnDestroyFilter {args} $mBody
        oo::objdefine $obj filter OnDestroyFilter
    }

    method objects {} {
        set _Objects
    }

    method RemoveObject {obj} {
        set idx [lsearch $_Objects $obj]
        if {$idx >= 0} {
            set _Objects [lreplace $_Objects $idx $idx]
        }
    }
}

#::ooh::factory create test {
#    property x {}
#
#    construct {args} {
#        my configure {*}$args
#    }
#}
