
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
Sometimes you don't even to declare a variable before
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
machine code first, and the compilation require 
all type information explicitly specified in 
the code to succedd, together with other rigor coding 
rules to be strictly observed before the compiler stops wining.
As the saying goes, "more words, more faults,"
the verbosity of static languages makes it harder to learn,
more difficult to code with, easier to make mistakes, 
and harder to read and maintain.
It would be very nice to have a static language
looks and feels like a dynamic one, and runs just as fast
as a static one. Hence the birth of a language named "Yael".

Yael shows us how "dynamic" can a static language be.
To build upon what's already there, the language is
designed and translated into a target language, which is another
high level static language. The target language is Java at 
this moment, since Java offers garbage collection, it would
be a more friedly environment to work with.
In a truly dynamic language, a variable can change its
type of value on the fly, while a static language requires
that a variable must be consistent in its type. 
This restriction is at the core of static compilation, and 
lifting it means departing from the paradigm of static languages.
So here comes the first pilar of design: 
a symbol in Yael must be used consistently
to carry values in one single class/type.
Once this rule is observed, there are actually 
plenty of room for other language instruments that
boost up productivity in dynamic languages, 
such as mentioned in the beginning.

You might be a little disappointed in the idea of monotyped
variables, but a method/function in Yael is more like an 
*implicit template*, thus an argument or local 
variable may end up taking totally different types!
The underlying mechanism in static languages is called
method overloading, which allows a method to have different 
(overloaded) versions that accepts differet types of parameters.
Thus different value types of the same parameter may be passed
to functions/methods, as long as the code in the
body of the function/method "makes sense" with those types.
Clearly, here "makes sense" simply means if that code can 
be statically compiled or not, after types being inferred 
(which will be discussed in full details shortly).
If it "makes sense", an overloaded version of this method
is generated in parallel to other overloaded versions.
As such, in each overloaded version, the corresponding
variable can turn out to be of different types.
With automatic paralell overloading in translation, 
a function/method in Yael becomes much more
powerful than it meets the eye, as different types of
values can be passed in with possibly different returned
types of values, and the code is reused without any additional
effort from the coder.

As in dynamic languages, a variable in Yael needs no 
declaration before its use, and its consistent 
type would be inferred from code analysis before compilation.
Type inference (TI -- references, tutorials here) 
is the analysis of a piece of code (such 
as in the body of a method) to find out if it "makes sense".
TI will find out the types of all of the variables and, as
types also determine the operations that is available,
and it thus tells if that peice of code "makes sense" or not.
To do TI on a variable, the range of code to consider 
is naturally the scope of the variable. The scope of a 
variable is simply the context (code range) within which the 
variable lives. What makes the traditional TI difficult is that
the parameter types of a function/method is unknown,
so there are some "free" variables to deal with.
For those "free" variables, code analysis will produce 
a list of requirements on the type of a parameter, which
is called a type contract (-- references, tutorials).
For example, a contract may require that the type must have
such and such a method, which can take some kind of parameters,
and should return values of such kind (which may be described
by another contract), etc. 
By analyzing the body of the function/method, a
contract is discovered on each of the parameters,
which is called contract analysis.
Any types for the parameters are allowed as long
as the contract is satisfied. 
A complete contract analysis would be difficult,
and Yael does not need it. First, it is not necessary
to generate all overloaded versions of a method/function
for all known type combinations that satisfies the contract.
Yael generates overloaded versions on demand -- that is, 
only when at the sight of an actuall calling of a 
method/function, where all the parameter types are known.
This greatly simplifies type inferencing, as it eliminates
all "free" variables from the game.

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
would first try the type union operation
according to the inheritance tree and ignoring the interfaces. 
If that does not work, it would then look at common interfaces,
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
to make type adjustments to the variable that holds the 
simple-typed value passed in as an argument.
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
with the emphasis on types, not values.
The loop statements are not looped, typically only
"executed" once. All branches of conditional statements
are "executed" simultaneously. 
The AST represents the code, and the
tree of symbols with their inferred types 
serves as the memory. 

Then the second pass is code generation.
A method is replicated as many times as there
are different signatures (which could come with
auxilary intermediate results from TI engine).

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

Type expression: to denote the type of a variable, use prime::
    def fun(a, b:a'):
        print("class of argument 'a' is:", a')
it is NOT a syntactic sugar for a.class.

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

Local variables and instance fields:
preceed an ID with a ':' to define a local variable in 
an obscure  scope (where name def automatically belongs
to closest containing eminent scope, such as 
builtin, global, class, and function scopes, 
obscure scopes are introduced by blocks and complex stmt). 
such a local variable must be defined on its 
first appearance in the scope, 
which must be an assignment. Futer reference to the same
variable should not have ':' before its ID anymore.
In an eminent scope (where assingments by default define
a name in itself), ': ID = expr' defines a name only
available to itself (even nested scopes can't see that ID).

Use .<ID> to access (read/write) an instance 
or a class member (field or method) in a method. 
You can also refer to a class member by class.<ID>.
To write to a class field, it is also possible to
use a ref statement as per scoping rule, and since
methods are readonly, you don't have to ref them. 
Scoping rule does not apply to instance fields, 
because they are never defined in the class scope.
If self is seen in a method, the method must be an 
instance method, otherwise it is automatically 
considered a class method. It is OK to explicitly
specify that a method is static by doing this::

    def static@class ():

In the rare case when an instance method does not 
refer to self anywhere, you can make an artificial 
reference statement like this::

    def meth@self(...): ... ; 
    
so that the method is considered an instance method.
An abstract method is always intended to be virtual, 
so it can never be a class/static method.

If a class is a non-static inner class, use 
self.@field to refer to the member of an outer class.
We may use self.@Outer.field to refer to the exact outer
class (the same as "Outer.self.field" in Java).
If an inner class (including its own inner classes if any)
never refers to an instance member of an
outer class, then it is deemed a static inner class, 
it is optional to provide a @class modifier in this case,
just as define a static method. To force such
a class to be nonstatic, simply do::

    class Inner@self:

which says the Inner class needs an outer instance.

Note, a (global/class) field does not need to be
explicitly declared, it is automatically inferred.
In the translation to Java, a field might not show
up as a member of the enclosing class when it is
*only* used in the defining scope (not even used
in a nested scope). To enforce a member to be
so, use @global or @class modifiers.

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
