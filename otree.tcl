## otree.tcl (created by Tloona here)
## The itree::Node as tcloo implementation

package require tclooh 2.0.0

namespace eval ::otree {

::ooh::class create node {
    
    ## \brief the node name, which is also displayed
    property name ""

    ## \brief image: an image to display in front of the name.
    property image {}
    
    ## \brief depth of this node in a tree hierarchy
    property level 0
    
    ## \brief Display format list. 
    # Contains a string as accepted by [format] (e.g. %s) followed by 
    # the attributes that are to be displayed, e.g. -name. E.g. {%s -name}. 
    # The resulting string is displayed as the node's name in a tree display
    property displayformat ""
    
    ## \brief indicates whether the node is displayed
    property displayed no
    
    ## \brief A type associated with the node. Makes image display in a browser easy
    property type
    
    ## \brief Whether the item is expanded on a display
    property expanded 1
    
    ## \brief columnData that is associated with an item.
    # When the node is displayed in a Ttk browser, this is the data that goes in the 
    # columns. The list must match the column count.
    property coldata {}
    
    ## \brief indicates that this node should be deleted when it is removed from its parent.
    property dynamic 0
    
    ## \brief the child nodes
    property Children {}
    
    ## \brief The parent node
    property Parent {} -get -set
    
    destructor {
        my removeChildren
    }
    
    ## \brief Get the parent node
    method addChild {child} {
        if {[lsearch $Children $child] >= 0} {
            return
        }
        lappend Children $child
        $child setParent [self]
        return $child
    }
    
    method addChildren {args} {
        set nl [lmap c $args \
            {expr {[lsearch $Children $c] >= 0 ? [continue] : $c}}]
        foreach cc $nl {
            $cc setParent [self]
            lappend Children $cc
        }
        return $nl
    }
    
    ## \brief Removes a child, evtl. destroy it
    method removeChild {child} {
        if {[set i [lsearch $Children $child]] < 0} {
            return
        }
        if {[$child cget -dynamic]} {
            $child destroy
        }
        set Children [lreplace $Children $i $i]
        return $child
    }
    
    ## \brief Removes all children, evtl. destroy them
    method removeChildren {args} {
        if {[llength $args] == 0} {
            set args $Children
        }
        set newChilds {}
        foreach {c} $Children {
            if {$c ni $args} {
                lappend newChilds $c
                continue
            }
            if {[$c cget -dynamic]} {
                $c destroy
            }
        }
        set Children $newChilds
    }
    
    ## \brief Return children (recursive if deep is true)
    method getChildren {{deep 0}} {
        if {! $deep || $Children == {}} {
            return $Children
        }
        set lst $Children
        foreach ch $Children {
            set lst [concat $lst [$ch getChildren 1]]
        }
        return $lst
    }
    
    ## \brief Returns the next sibling (neighbour to the right) node 
    method nextSibling {} {
        if {$Parent == {}} {
            return
        }
        set ach [$Parent getChildren]
        set idx [lsearch $ach [self]]
        lindex $ach [incr idx]
    }
    
    ## \brief Returns the previous sibling (neighbour to the left) node 
    method prevSibling {} {
        if {$Parent == {}} {
            return
        }
        set ach [$Parent getChildren]
        set idx [lsearch $ach [self]]
        lindex $ach [incr idx -1]
    }
    
    ## \brief Lookup children using a filter
    # 
    # The filter is a proc or lambda expression that evaluates to a
    # boolean result: 1 if the node is to be returned, 0 otherwise.
    # It takes exactly one argument: the node itself. Example:
    # 
    # proc ::filter {node} {
    #    expr {[$node cget -name] eq "the_name"}
    # }
    # set nodesWith_the_name [$parentNode findChildren ::filter]
    #
    # set lambda [list apply {{n} { expr {[$n cget -name] eq "the_name"} }}]
    # set nodesWith_the_name [$parentNode findChildren $lambda]
    # 
    method findChildren {filter {recursive 0}} {
        lmap c [my getChildren $recursive] \
            { expr {[eval $filter $c] ? $c : [continue]} }
    }
    
    ## \brief Lookup parent nodes by name
    method findParents {filter {all 1}} {
        set p [my getParent]
        set result {}
        while {$p ne ""} {
            if {[eval $filter $p]} {
                lappend result $p
                if {! $all} {
                    break
                }
            }
            set p [$p getParent]
        }
        return $result
    }
}

::ooh::class create cnode {
    extends ::otree::node
    property x ""
}

} ;# namespace ::otree

package provide otree 2.0.0
