
.. _brief:

***************************************
How "dynamic" can a static language be?
***************************************

Dynamic/scripting languages, like Python and Ruby, 
are designed for the uttermost ease of use, so that 
an idea can be fleshed out with as little effort as 
possible. They seem to be extremely expressive for 
common programming tasks, and because of much less
code, they are also much easier to maintain in general.

We may note some common features in those languages
conducing to that goal. There is no need to 
specify the type of a variable, as the language is 
dynamic, their types are determined at runtime. 
Sometimes you don't even need to declare a variable before
using it. Secondly, functions/methods are first-class
citizens, which means they 
can be passed around just like other objects. 
Thirdly, they support the concept of 
closures or blocks, which are useful in that a 
piece of code can be passed around like a function/method,
and can still use (read and write) variables defined 
in its environment (hence the term closure).

All this convenience comes at the cost
of runtime speed, but with the speed of hardware
increased so much during these years, 
such a trade off is more readily acceptable 
when performance is not critical. However,
there is always a need for performance, and 
nobody would blame it if things can speed up.
In those cases when performance is critical,
static languages are the only choice.
Static languages must be compiled to executable
machine code first, and the compilation requires
all type information explicitly specified in 
the code, together with other rigor coding 
rules to be strictly observed before the compiler stops wining.
Since 'less is better', and 'more words, more faults',
the verbosity of static languages makes it harder to learn,
more difficult to write, easier to make mistakes, 
and harder to read and maintain.
It would be very nice to have a language that
looks and feels like a dynamic one, but runs just as fast
as a static one. Hence the birth of the language named "Jael".
To build upon what's already there, the language is
first translated to a target language, which is another
high level static language. The target language is Java at 
this moment, as Java is popular and has lots of libraries.

Jael shows us how "dynamic" a static language could be.
In a truly dynamic language, a variable can change its
type of value on the fly, while a static language requires
that a variable must be type consistent. 
This restriction is at the core of static compilation, and 
lifting it would open up a whole can of worms when
translating to static languages.
So here comes the first pilar of design: 
a symbol in Jael must be type consistent.
Aside from this restriction, there are still
plenty of room to adopt most of the luring language features 
in dynamic languages that is alread discussed.

Jael appears to allow dynamic argument types to methods.
A method/function in Jael is more like an 
*implicit template*, for each combination of argument types 
passed to the it, a distinct version is generated, where 
even local variables may end up taking different types!
The underlying mechanism in static languages is called
method overloading, which allows a method to have different 
(overloaded) versions that accept differet argument types.
Thus different argument types may be passed
to functions/methods, as long as the code in the
body of the function/method "makes sense" with those types.
The sense-making involves type interpretation for the 
expressions and variables in the method, to see 
if static compilation is OK or not. Type interpretation 
is a dyanmic way of doing type inference, so to speak,
which will be discussed in full details shortly.
If it "makes sense", a version of this method
is generated, overloading it. In an overloaded version, 
a variable may not be of the same type as in another version.
Thus a function/method in Jael becomes much more
powerful than meets the eye, which is essentially a template 
that serves as a description of a general algorithm,
for unlimited reuse without additional effort of the coder.

As in dynamic languages, a variable in Jael needs no 
declaration before its use, and its (consistent) 
type would be inferred from code analysis before code generation.
Type inference (TI -- references, tutorials here) 
is the analysis of a chunk of code (such 
as in the body of a method) to find out the type of the
expressions and variables there.
TI will find out the types of all of the variables and, as
types also determine the operations that is available,
and it thus tells if that code "makes sense" or not.
To do TI on a variable, the range of code to consider 
is naturally the scope of the variable. The scope of a 
variable is simply the context (code range) within which the 
variable lives and works. 
What makes TI difficult is that
the argument types of a function/method is unknown,
so there are some "free" variables to deal with.
For those "free" variables, code analysis will produce 
a list of requirements on the type of an argument, which
is called a type contract (-- references, tutorials).
For example, a contract may require that the type must have
such and such a method, etc. 
By analyzing the body of the function/method, a
contract is discovered on the type of each argument,
which is called contract analysis.
Any type for an argument is allowed as long
as the contract is satisfied. 

A complete contract analysis would be difficult,
and Jael does not need it. First, it is not necessary
to generate all versions of a method/function
whose argument type combination satisfies the contract.
Jael generates overloaded versions on demand -- that is, 
only when at the sight of an actuall calling of a 
method/function, where all the argument types are precisely known.
This greatly simplifies type inference, as it eliminates
all "free" variables. In fact, the type inference of Jael
works through something similar to interpretation, only that
if-statements will have all branches executed in order, 
and loop-statements always get executed once and no more.

To infer the types of variables of simple types 
(in constrast to collection types), it is 
sufficient to only look at the assignment statements 
using those variables as assignment targets. If two
different types of values are assigned to the same
variable, the least general parent type (hereafter 
referred to as the union type) of both types is 
the resultant inference type. When there are more
than two different types, the union of all those
assigned types are the resultant inference type. 
However, there are two potential difficulties with
the union of types: the first is when primitive types
are involved in the union, the second is caused by
multiple inheritance. It is straightforward to solve
the first problem by providing wrapping classes to
primitive types as in Java. For union among the 
primitive types, automatic type promotion
in popular static languages, such as C and Java,
solves the problem. The second is more challenging.
It is solvable if the multiple inheritance is 
well-behaved, that is, when there is a 
"method resolution order" (MRO, as a sequence of 
types, where a method is resolved to the first 
type in the sequence that has it, as in Python).
Simply take the MRO of the two types in question and 
start from the very end of them (which should be
the "object" type -- the root of the object system),
and move toward the start of the MRO until the 
types differ. The last common type is the union type.
For an object system as in Java, allowing only 
single inheritance, complemented with possible 
multiple interfaces implementation, 
the union type is uncertain. On the one hand, 
the nearest common ancestor is a reasonable candidate,
on the other hand, any shared interface could be another.
An agreeable approach here is to let the code analyzer
first try the type union operation
according to the inheritance tree and ignoring the interfaces. 
If that does not yield a type that "makes sense", 
it would then look at common interfaces,
choosing any one that would make the code work (because 
interfaces are not about implementation, so whichever that 
works would be fine). If none works, the code is considered bad.

For a collection, the type of the element also need 
to be inferred. The ability to iterate through
collections via for-statements, where the elements are 
assigned to a loop variable, requires that all 
elements in the collection can be unified to a single type.
Another reason to require same-typed elements is
that collections may provide a way to access elements
through indexing, and indexing is viewed as a method call,
which should return a consistent type given the index type.
So, collections are homogenous.
To infer the element type, the translator should simply analyze 
the code for element level value assignments, such as adding
elements to the collection (appending, inserting, creating via 
comprehension), and changing the value of an element.

What complicates the element TI is when the collection is
passed as an argument to a function/method, in side of
which it is possible that more elements are 
assigned to the collection, thus
further type unions need be considered. Note that
with simple types, when passed to a function/method as
an argument, assignment to the argument in the function 
body that entails type union only requires a more general
type on the argument of the function, and there is no need
to make type adjustments to the variable in the caller's scope 
that holds the simple-typed value passed in as an argument.
If a collection (say a list) with element type A
is considered a subtype of a list with element type B if
B is a subtype of A, then the problem is reduced to the
same situation as the case with simple types.
However, more careful evaluation is needed:
Is there any unpleasant consequences with such design? 
And the answer is yes -- it would 
cause inconsistency: a list of element type B is passed in
to a function, and some element of type A is added to it,
then the list contains some elements that are not of type B.
Therefore there is a potential side effect to pass a collection
as argument to a function/method, which TI should not ignore.
So with collections, when passed to a function,
the function will first take the type information passed
in and may come back telling the caller that its element
type might need updating. Thus once the side effect of 
element assignment by a function call is taken care of,
the element type resolution of a collection is complete.

And note that during a pass of TI, a variable type could
be changed due to the type unions. If any such changes 
occur, a second pass should check that all operations 
needed by the code are defined by the new types. 
In this process, it might also find out that the types 
returned by operations as defined on the new types 
from the previous pass is more general (as the new types
are more general), so some variable types need to become 
more general. If any types changed, another pass will be 
needed. It might take several passes until no type changes 
occur, at which point the types are said to be *fixed*,
and the TI iteration process is complete. 

However, the TI iteration process might fail, while the
code is just fine in a dynamic sense. Here is a new idea:
create new variables as needed so that the type of the old
variable remain unchanged.  If an assignment assigns a 
value of a new type to the symbol, a new
variable is created for the new type, 
and latter reference to the same symbol 
is redirected to that new variable. So the symbol is recast
as the old variable playing that symbol is replaced by the new.
This solution of symbol recasting will be problematic
when there is conditional execution (if, for, while),
for at leaving the statement, the type of a symbol may
be one of several types. Type union is used to make sure
that at leaving a single type is determined for a symbol,
see discussions below for the details.
This way, as the TI process works sequentially 
down the code, when asigning a value of different type
to a symbol, a new variable is created to recast the symbol,
so that the type change of a symbol only
affect the code reachable from this point on, 
before another assignment of some other different type.
This approach would
work with both simple and complex types (in Java, 
a list of less general element type can be assinged 
to a variable for a list of more general element type).
As such, only one single pass is needed! Great!

Discussions:  (symbol recasting)

1. if-stmt: new variables of different types may 
   recast a symbol inside each branch,
   and immediately after the whole if statement, 
   the symbol may recast to another new variable 
   having the union of the types to recast the symbol 
   in all branches. If there is no else-clause,
   or there are some branches that do not recast the symbol,
   then the symbol type immediately before the 
   if-stmt is also considered in the type union.
   the variable of the union type should be declared
   immediately before the if-stmt so that it is 
   assigned to whenever the symbol is assigned to.
   the union type variable is initialized to the 
   active variable for the symbol if its type 
   participated in the type union, otherwise it is null. 
   but the union type recast variable is not read
   anywhere inside the if-stmt, as there should be
   branch specific variable to recast the symbol.

2. loop-stmt (break, continue): 
   there is a starting set of variables to recast the
   involved symbols and there is an ending  set.
   the starting set is for the symbols whose first
   visit may be a reading visit in the loop and its
   type may be changed when the execution loops back.
   a variable in the starting set must have 
   its type set to the union type of the entering
   type and any possible type as a result of looping
   (from the end of the loop body or from continue-stmt).
   the ending set containts variables to recast the
   symbols whose types are changed in the loop.
   a variable in the ending set will have types as
   a union of all possible types at leaving the
   loop-stmt (loop skipped -- entering type, 
   loop broken -- type when broken, loop exited
   normally -- type in the end).

3. for each variable, we may try to find its
   most general type.  

To make up for the inability of collections to
have different types of values, a complimentary instrument
called "tuple" is provided. A tuple may bound several values 
of heterogenous types, and moreover, they have fixed sizes
while collections may dynamically grow/shrink in size. 
For each element in the tuple, as distinguished by position,
the type can be inferred according to the same rules as simple 
types. It is possible to iterate through tuples via for-statements,
but the type of the loop variable would be the union type
of all the element types in the tuple.
As a last remedy, you can have a collection of the most
generic element type (the "object" type at the root of the
object system), and then use the "in" operator to tell
if an element belongs to a particular type or not, and
then cast it into that type and perform any desired operations.

Side note: a named tuple can have names for each element.
A tuple with all elements of the same type can be indexed,
which can also have name (implemented in C with union)::
   a = (x=1, y=3); //a.x==1, a[0]==1
   //C: typedef a union{int x, y; int __item__[2];};



Statically compile a truly dynamic language
===========================================

At each assignment statement, if the value type is different
(note, we may do a union with its previous type, and check
if the union type works with code from last type change),
simply define a new variable of the new type required by
the assignment. If there are no if/loop statements, the only care 
to be exercised is to make sure that the later references to
the symbol is interpreted as referring to the newly introduced
variable. Thus the symbol is recasted to a new variable, which
is referred to as symbol recasting. If there is an if-statement, 
code generation is needed.
First, an artifical variable $cid$ is introduced to 
register the recasting table ID when the execution leaves 
each branch. Immediately after the if-stmt, if there are
multiple possible $cid$ values, an artificial 
switch-stmt on the $cid$ is inserted, corresponding to 
different ways of symbol recasting. Naturally, the generated
switch-stmt has a case for each $cid$ value.
Under the case the remaining code after the if-stmt is 
correctly interpreted according to the right symbol 
recasting. Clearly this idea is applicable in a recursive
way when the if-stmt itself contains other if-stmts.
The code analyzer would distribute a branch id to
each branch, which is assigned to $bid$ on entering 
the branch. For branches that have no symbol recasting,
there is no need to keep track of entering it. Note::

    A simplified way of achieving the same effect without 
    using a switch is to replicate all of the code
    after the if-stmt into each branch that changed the
    type of a symbol, and should return within that branch. 

Now consider a loop-stmt. 
Because of looping, the loop body may end up using
symbols recasted in the previous execution of itself.
To account for that, symbols whose first visit in the
loop code is a reading visit are called loop-sensitive 
symbols. If any loop-sensitive symbols gets recasted,
the loop body will have to be replicated by cases in 
a switch statement on recasting id.
The TI algorithm could take many iterations
to complete on finding out all possible recastings in
a loop body. Note that the initialization part of a 
loop-stmt is not part of the loop body. 
After the loop-stmt, the same switch-stmt as used 
for the if-stmt is generated, if there are multiple
possibilities of symbol recasting upon leaving the loop-stmt.

Random thoughts
-----------------

When overriding a method, the method must have 
override all signatures generated in 
the parent class. It is possible to specifiy
parameter types in the declaration of the overriding
method, to exclude some signatures in the parent class.


Lazy compilation of class methods: if a method is never
used, it won't be generated at all. This allows for
class templates to be @realized as types that is 
incompatible for some methods that are never used.
To enforce a method generation, use @activate(int, str).

Implementation: a method has its own AST, and 
a map of called signatures to return types.
We do not replicate the AST, rather, the 
TI is performed once at finding out
the return type (intermediate results could be saved),
and once at time of code generation (the saved
intermediate results might be used 
for code generation). 

The TI engine almost works like an 
interpreter (the type interpreter), 
with the emphasis on types, not values:
this may be called "interpretive type inference" (ITI).
The loop statements are not looped, typically only
"executed" once. All branches of conditional statements
are "executed" simultaneously. 
The AST represents the code, and the
tree of symbols with their inferred types 
serves as the memory. 

Then the second pass is code generation.
A method is replicated as many times as there
are different signatures (which could come with
auxilary intermediate results from ITI engine).

If the above way of implementation is possible,
then code (corresponding to the AST) reuse might be
possible if the virtual machine is specially designed. 

To ensure instance method overriding, a getter method
is needed for that method when pass it around as an object.
For example,  in java::

    method method$obj(){ return new method(); }

The requirement that a function/method must return
a unique type of value given a signature, can be
called type regularity. This term is also applicable
to shared fields: instance fields of a class,
or shared local variables via closures.

NOTE: for other local variables, type regularity is not
required, so type recasting is fine. 
When a local variable symbol changes its type
via an assignment, it will affect the type switching
only if in the future it is first read.

NOTE: it is possible to explicitly break type regularity
by @irregular (or simply @many)  post-modifier.

Compile type statements: 
One choice is to explicitly use #: such as 
#if, #else, #elif, #for, #while.
However, implicit way is also possible:
as long as the expressions can be computed
at compile time, it is executed at compile time.

As equal: x @= 3; --- x take on both the value 
and the type

contextual type relationship::
    def fun(a, b:a.class):
        if a: ret b
        else: ret a
then both arguments must have the same type.

Type expression: to denote the type of a variable::
    def fun(a, a# b) a#:
        print("class of argument 'a' is:", a#)
it is NOT a syntactic sugar for a.class (why not?).

Tuple assignment::
    x, x.a.b = "1", 2;
is problematic in Python. the intention is to change x 
and x.a simultaneously, but in Python x is first changed
to "1" then x.a.b becomes equivalent to "1".a.b, which would
cause problem. to avoid this problem, a qualified name
is split into two parts: first part contains everything
up to the last '.', and second part contains the remaining.
the first part is assigned to a temp var $lhs. Of course
this is done after the right hand side values are calculated::
    $rhs0 = "1";
    $rhs1 = 2;
    $lhs1 = x.a;
    x = $rhs0;
    $lhs1 = $rhs1;
This way the problem is solved.

There are eminent and obscure scopes.
Obscure scopes belong to a complex statement (if, for, case, while). 
Eminent scopes include global, class, and function scopes.
While a function scope is simple and only has a common layer,
global and class scopes has finer controls of access.
The "def/class" statements at the ground level
of the class/module (a module is just a class, there is no 
real difference) scope are special. If the name is 
prepended with a '.', then it defines a static member;
if the name is a plain name, the it defines an instance member;
if the name is prepended with ':', then it is not a member, but 
only a local definition.
Method/function/class definitions not on the ground level are 
never members, they can only be local definitions. 
A static field is defined by prepending the name with '.' in
a class/module scope. All other variables are considered local.
It is not possible to define instance fields within the class
scope, they are defined inside instance methods. 
In instance methods, instance fields are defined by prepending 
a variable name with '.'.

Prepend an ID with a ':' to define an obscure variable in 
an obscure scope. Future reference to the same
variable may omit the ':' before its ID.
The assignment of "ID '=' expr" in an 
obscure scope puts the definition into the immediately enclosing
eminent scope (IEES). 

Use .<ID> to access (read/write) an instance member 
(field or method) in a method. 
Define/access a class member in an instance method via "..ID=value".
Define/access a class member in class/static method via ".ID=value".
Class scope is invisible.
But instance methods defined in super classes can only
be refered to by ".meth" or "super.meth".

An abstract method is always intended to be virtual, 
so it can never be a class/static method.

Nested classes.
To refer to the the static/instance member of an outer class,
the syntax is ".@member". Super class member is simply referred
to as "super.member". If the super class is nested, to refer
to its outer class member is possible: "super.@member". Such
a syntax can be generalized to a variable 'v' referring to an 
instance of a nested class: "v.@member" refers to an outer member.

Below is an example::

 class bare:
  .staticfield = 3; // static field
  def .staticfun(): // static method
    .staticfield += 1;
  ;

  def imethod(): // instance method
    .ifield += 1;
  ;

  class iclass: // instance class
    def imeth():
      .@instancefield += 1; //outer instance field
      ..@staticfield = 0; //outer static field
      ..staticfield = 0; 
    ;
  ;

  class .sclass: ; // static class

  def :lf(): ; //a local function

  local_var:+int = 4; //local variable, unsigned int
  for i in range(3): // i in IEES, local
    local_var += i;
    def mfun(): jot(i); ; // local function
  ;
  puts(i);
  i = 4; // not a member, but a local var
 ;

To support inedentation/dedentation, require
that the first line of the source code have
a directive of ident=space or indent=tab.
without this directive, semicolon is assumed.

the most specific common super type:
this is used to find the union type of
two types for a member (method/function/field).
The spirit is to be as concrete as possible.
The same spirit is applied to infer the types
of (mutually) recursive calls. In the function
calling graph, there must exist a function
that has an execution path to a return statement
that does not involve a call that 
eventually causes a call back to itself
(note, it may incur recursive calls to other 
functions that do not depend on this function).
Such a path is called a *simple execution path* (SEP)
and ends with a return statement, whose
return type can be found apart from the return
type of the recursive function in question.
A union of the types at the end of all such paths
would is a type proposal for the function. 
With such a proposal, the return types at
the end of all the execution paths (not just 
those that do not cause call backs to itself)
can be found, and the union of them, if different
from the previous proposal, can be used as 
a new proposal and it all start over again,
and this process is repeated until a fixed point
is reached, or an error occur. In the initial
round, the proposal would be "UNKNOWN", and
if any operation (method calls) involves 
"UNKNONW" would produce "UNKNOWN". At the end
of this initial round, all execution paths that
produce a return type is not "UNKNOWN" must be a SEP.


Independent Compilation 
=======================

The code can be first compiled into an intermediate format
like the python byte code (without much type information yet),
which would be called the raw byte code.
Then the next stage is interpretive type inference (ITI), 
which is separated from the production of byte code 
(e.g. a library could first be compiled into raw byte code).
The ITI generates executable code with full type information.

Type Intervals
==============

When inferring the type of a name, an interval with lower and
upper bound is maintained. An assignment to the name
helps tighten the lower bound: 
the least common type of the current lower bound and 
the assigned type will be the new lower bound.
Any member fetching via the dot-operator (including 
mathematic operators, which can eventually be converted
into dot-operators) will help tighten the upper bound:
the member searching starts from the current lower bound
up the chain of inheritance until the member is found 
at some class, which will be the new upper bound if it
is a subclass of the current upper bound. 

Note that if there is no name shadowing along the 
inheritance chain, the searching from the current
upper bound also works:
if the current upper bound does not have the requested 
member, it is searched for down the chain of inheritance
toward the lower bound. The first type having the requested
member will replace the current upper bound.
However, we might want to mix with Java classes, when
that approach breaks down.


Name shadowing
==============

A name defined in a scope will shadow the same 
name defined in scopes containing it.
However, unlike in Java, a name defined
in a class can NOT be shadowed in its subclasses.
No name can be shared by any two members of class,
such as methods, fields, properties, and inner classes.
Inner class can access members of outer class
by grammar "..outer_field". Inner class can
have a field of the same name with an outer field,
which will be shadowed for an inner class defined
further inside the inner class.

Scope for Closure
=================

Closure is an ad-hoc environment where local variables
can live and serve methods enclosed in the closure.
An open method is a method that refers to a variable 
(not a member of some enclosing class) outside itself.
An open method requires a closure to execute or 
to instanciate as a method object.
Variables referred to by and outside of open methods
are closure variables. 

There are two considerations for closure formation: 
1. a closure coincides with a method signature;
   NO, that's not the most general case! a closure
   can even happen inside a for-loop where local
   variables serve as closure variables.
2. a closure must serve all enclosed open methods.
If 2 can not be satisfied, then there must be some
open method that refers to a variable beyond the
method that the closure coincides with. Thus it is
clear the closure should coincide with a containing method.
Once both conditions are met, all closure variables will
become the member variables of the closure class.

Alternatively, for each enclosing method there will be
its own closure, nested inside other closures. This way
the closures form a tree structure paralell to that
of the methods. Closures has the implementation,
Wrappers presents the methods in the right place.
The good thing about nested closures is that 
enclosure variables are only instantiated as needed.
A method with some local variables serving as closure variables 
is implemented in its closure class while its corresponding method
simply instantiate the closure and invoke the implementation. 
Otherwise it does not need a closure class, and is implemented 
in its corresponding method. A nested local method may use some 
closure variables, and it must be wrapped inside the closure class
of the method it is nested.
Otherwise the local method can be wrapped in the wrapper class 
for the method it is nested.
Those local methods are not open: they do not refer to
any variables outside themselves. 
And they can be referred to as 
"<enclosing method>.<enclosed method>" in Java.
A local class nested in a method follows the same pattern as a local method.

Partial function call (Curry)
=============================

A function can be called with partial parameters, using brackets.
for example, if log(x,b) gives the logarithm of x with base b,
then "fun = log[3]" produces a function 'fun' that takes
an argument b, so fun(5) produces log(3,5).
Of course you can do fun2=log[3,5], then fun2() gives log(3,5).
And the same calling convention with keywords and default values
is applicable with partial calling. if "fun3=log[b=2]" then
fun3(5) gives log(5,2). 

The signature of a function/method is given by "log{float,float}",
the curried signature of log[3] is "log{[float],float}".

Funtional programming
======================

Any function can be applied to each element of an iterable, which
results in a new iterable with elements being the returned values.
"iterable@fun" is the grammar. the expression "1..5@log(.,2)" 
produces an iterable object that gives log2 values of 1 to 5.
if the object is not iterable, the whole object is passed to
the function. For example: "123@print" will have 123 printed.
This expression "2..5,3..6@log" gives [log(2,3), log(3,4), log(4,5)].
It is easy to chain functions: "items@cos@sin"
evaluates to [sin(cos(x)) for x in items].


Function definition grammar
========================================
Define a private function (only availble in scope of definition) this way::

  def::mult(int a, int b) int:
      return a*b

Define a protected function (available in package and for inheritance) this way::

  def:mult(int a, int b) int:
      return a*b

Define a public one like this::

  def mult(int a, int b) int:
      return a*b

A lambda function is defined as "def(x,y) x**2+y**2" or 
"def(x,y){...}" with multiple statements. 


Class definition and initialization
===================================
A class definition is a set of declarations for: fields, methods, properties.
Methods are similar to functions, static ones starts with '.', instance ones without.
Special methods: initializers def.(...): and default init def .:.
fields: static fields are declared in class scope, with possible initial 
values, like an assignment statement. For fields, package level fields 
are plain assignments (in class scope for class fields or in the default 
init def scope for instance fields, also in module scope for module 
fields -- this feature could cause problems: what if a field defined in 
another method is not intended to be that in the init method (that 
variable can be hidden by :)? how to access a public global variable 
in a class defined in that module? using ..<name> would work if 
not shaded, or use <module>.<name> if shaded).
properties:  def prop: and def prop=v:. Example::

  class myclass from parentclass:

     .staticfield = 1 //declare and init a static field
     //static init code with local variables goes here
     //static methods can be invoked here
     //while instance methods can not

     def .smeth(a): //static method
        return a + .staticfield

     def .: //default instance initializer, define/init instance fields
        .ifield2 = 3 //declare & init an instance field
        .ifield3 = 2 //introduce fields anywhere in the class

     //from super class constructor with params (0)  
     def .() < (0): //constructor
        .int ifield3 = 1 //introduce field with type

     //constructor that depends on another one
     def .(int a) < (): 
        .ifield = a

     def(a): //make a instance callable 
        return .ifield+a

     def int meth(a) @atomic: //instance method
        return a+.ifield+..staticfield

     def +(a): //instance operator
        return .ifield + a

     def name: //property getter
        return .name_ //holding field

     def name = str n: //property setter, returns nothing
        .::str name_ = n //defined private field "name_" 

Note: the callable definition, and the static callable is the constructor
Note for translating to Java: Java allows a method name to be the same as the class name.


Object Initialization
======================

It is important to check if all fields of an object is properly initialized.
It seems this can be checked at Type Interpretation: since code is followed
through for type inference, it is also possible to check if a field/variable
is initialized (assigned to) or not before a reading of its value. 
When there are branches in the code,
a field/variable is considered fully initialized if and only if all branches
fully initialize it (this can be applied recursively to all branches as well). 
Meanwhile, the type interpretor also ensures that when 
fields/variables are read, they are fully initialized, otherwise a 
warning/error may be reported. 
A warning is reported if multiple partial initializations are 
attempted sequentially before a reading (should it be an error too? 
because if that does not cause an initialization error, 
then some branches without initialization must never be reached), 
otherwise (only one attempt before a reading) an error is reported.

No default values will be assumed, all fields/variables must be fully initialized
before value reading is allowed. This also provides the opportunity to check 
if a field/variable is a "maybe" value: if it is assinged to a 'nil' value or 
another "maybe" value.

During type inference, all objects are essentially treated the same way 
as scopes as they contain name definitions as scopes. If a name is defined 
but never read, a warning can be given. In a class, a method might have never
been used, it is also a warning, no code will be generated for that method.

The ':' In Grammar
===================
The separater ':' is a very active grammar element. It introduces sub-statements
in a compound statement, such as in if, def, class, for, and while statements.
It also helps form the "a if cond: b" expression.

It also defines a variable in a obscure scope instead of the enclosing eminent scope,
when it preceeds the defined variable, e.g. ":var = 3".
This construct used in a class scope simply means less visibility. A private
field can be defined with '::private_field=1', or if in a instance method, 
".::private_field=1". similarly, "def::private_meth()" defines a private method.

And when combined with '=' it forms the ':=' symbol, which assigns to 
a symbol already defined in the nearest enclosing scope.
Sometimes it needs to define a variable in a scope without initializing it, which 
is simply done by the "var=." grammar construct (where the '.' means missing value).

Object query grammar
=====================
How about something like the case matching in LISP?

   case ?{.age < 5, .sex = female}:

Meta-programming
=================
Use a template like syntax to do meta-programming::

   #for i in ("a", "b", "c"):
      def <<i>>: return ._<<i>>; ;
   #;

That will generate the following code::

   def a: return ._a; ;
   def b: return ._b; ;
   def c: return ._c; ;

The template-style meta-programming grammar is a mix of 
macro in C and shell scripting (bash).
It is also possible to define a meta-class::

   #class mymeta(parent_meta):
      _dict = {}
      //a callback function
      #def getattr(attr):
          #if attr in dir(.):
          #return .attr
          #return ._dict[attr]

      #def setattr(attr, value):
          #if attr in dir(.):
          #return .attr = value
          #return ._dict[attr] = value

Parsing/Interpretation/Generation Pipeline
===========================================
Parser will generate a parse tree as input for type interpretation. 
The parse tree has named subtrees and other supporting data fields to support
type interpretation. Once the type interpretation is complete, the parse tree
is then read for code generation.

