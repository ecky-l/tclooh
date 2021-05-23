# tclooh
Minimally extending the TclOO object system to provide more natural object variables and optional automatic object cleanup on variable unset.

## Problem

The TclOO object system for Tcl is nowadays defacto standard for object oriented programming in Tcl. That has not always been the case and it evolved into the core language not until 8.6. But now it is a well designed meta object system and it can be used to build other object systems, thanks to the fact that even the `oo::class` is an object and can be extended and customized. All the features described in the doc [here](http://tmml.sourceforge.net/doc/tcl/define.html) can be used for classes themselves and so it is easy to extend the base TclOO object system for many use cases.

But the downside of so much flexibility is that the core `oo::class`, although it can be used for everyday jobs, is rather limited for that purpose. The main point is that people are used to the concept of properties in a class, which store state of an object. But with TclOO it is rather cumbersome to achieve that, one always has to declare the properties as `my variable` in each method body like so:

```
oo::class define A {
    constructor {args} {
        my variable X
        set X 1
    }

    method incrX {} {
        my variable X
        incr X
    }
}
```
etc. The reason is probably, that with mixins and multiple inheritance it wpuld be difficult to prevent collisions with object variables visible in methods, or other side effects. This is quite understandable. Still, most people want to use properties in their day-to-day work like they use them in Java or C++: simply declare them in the class body and use them in the methods without declaring them over and over again in every method.

#### configuration
The `configure` method is a quite common concept in Tcl, coming from Tk but also in normal commands. With a set of properties it is often possible to call

```
obj configure -prop1 val1 -prop2 val2
```

and so on, to set properties to the object. This concept is so common that its would help a lot to *not* reinvent it over and over again in every class.

#### potential of resource leaks

Normal TclOO objects are not automatically cleaned up. They live in memory until they are cleaned up explicitly with `destroy`. This is particularly problematic when objects are created with `<classname> new` and assigned to variables, which eventually go out of scope at the end of a proc or method - the variable is deleted and there is a dangling object.


## Solution

*Tclooh* solves the above problems by introducing three new keywords, that can be used in a class which is derived from `oo::class`:

* `property` - define object variables that are automatically available in every method
* `construct`- complements the `constructor` keyword and makes properties available in constructors
* `extends`- complements the `superclass` keyword and makes the properties of a base class available in derived classes

Everthing else works the same way as with base TclOO. Every keyword and functionality of TclOO classes can be used in *tclooh* too, mixins, forwards etc. The above example looks in *tclooh* like that:

```
ooh::class define A {

    property X

    construct {args} {
        set X 1
    }

    method incrX {} {
        incr X
    }
}
```

No code bloat of `my variable`s anymore and nice, clean declaration of the properties.

Additionally there is a `configure` and a `cget` method for every object of a `ooh::class`, that can be used on public properties. There are public and private properties:

* **Public properties** - are properties starting with a lower case. They can be `configure`d and `cget` and are thus visible and editable from the outside.
* **Protected Properties** - are properties starting with an Upper case. They cannot be `configure`d and `cget` and are not visible and editable from the outside
* **Private properties** - in the same sense as in Java or C++ - are not available. Sorry ;-)

Both, public and protected properties are inherited when using the `extends` keyword to derive from a base class.

#### Defaults
Every property can have a default value, which is just declared after its name, like so:

```
property Xvalue x
property emptyvalue {}
```

#### Getters and Setters

For protected properties (and only for them) it is possible to automatically generate getter and setter methods. For that to happen, just append `-get` resp. `-set` at the property declaration;

```
property Xvalue x -get
property Yvalue -get -set
```

And the class will have the methods `getXvalue`, `getYvalue`, `setYvalue` defined for that purposes. Its always *get* resp. *set* prepended to the property name.

#### Object cleanup on variable unset

*Tclooh* introduces a new class command `varcreate`, which can be used to explicitly assign an *tclooh* object to a variable. The variable with the object can then be used normally and as soon as the variable is unset for some reason (manually or when it goes out of scope), the underlying object is destroyed. This is done by a `trace` extension in the `ooh::class`:

```
ooh::class A {
    property name {}
    ...
}

proc do-some-work {} {
    A varcreate v -name theA
    $v incrX
    # with the deletion of v the underlying object is destroyed
}
...
```
This is particularly useful for procedures or methods that create many objects of classes which should not live longer than the current call frame.

# General info

I consider this extension as feature complete, and in that sense it has no limitations. Bugs can be reported or fixed, I encourage pull requests.

Sometimes I *think* about one more keyword `field` for class variables, and maybe another `constant` for class constants that cannot be changed. Maybe there will be a version 2 of the extension with related changes, but maybe not :-). It depends entirely on my mood and time. Anyway, feel free to experiment with the code, maybe extend it, and submit a pull request if you like.