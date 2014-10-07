//a simple verion to play with
grammar Jael;

@header{
import java.util.Map;
import java.util.HashMap;
}


module: stmts EOF;

stmts: (seq+=stmt)*;

//a statement has its own ending ';'
stmt: classStmt
    | defStmt
	| ifStmt
	| forStmt
    | asloopStmt
	| caseStmt
	| breakStmt
	| loopStmt
	| importStmt
//	| blockStmt
	| assignStmt
	| exprStmt
	| tryStmt
;

breakStmt: 'break' (label=ID)? ('if' expr)? ';' 
;

loopStmt: 'continue' (label=ID)? ('if' expr)? ';' 
;

easytarg:
   (attach='.')? (access+=':')* (type=typesig)? ID (unreal='?')? 
   //use '?' for nullable/abstract names
;
easytargs: targs+=easytarg (',' rargs+=easytarg)*;

qname: names+=ID ('.' names+=ID)*;

//in an eminent scope: locid makes 
//the id only available to the scope itself.
//in an obscure scope, it binds the name
//in that obscure scope, which is available
//to any scopes nested in that obscure scope.
//locid: (local=':')? name=ID; //NOTE: replaced by easytarg

//loclist: ids+=locid (',' ids+=locid)*;

//should it be at the lexer level? 
//no: 'self', 'class' are also atoms
//modifier: 'class'|ID;
//'class'|'private'|'public'|'protected'|'final';
//modified: name=ID ('@' mods+=modifier)*;

/* 
//normal class
class B from A in my_interface: 
...
;

//abstract class: appending '?' to class name
class B?: ... ;

//interface
class in B from parent_interface: ... ;

//enum
class B{
	a, b, c
}:
...
;


Jael generics: 
A type is generic whenever a member (field or method),
in spite of the same signature (the signature of
a field is its name, just like a method with zero arguments),
can take on different types under different configurations. 
Each configuration defines a specific type from the generics.

Generics are like a template in C++, it will eventually
become many different specific types. When a generic type is
used as a type specification, it is considered as a constraint,
indicating the actually type must be a specific type of it.

It is problematic for a generic type to be used for casting, 
for the compiler can not infer the actual specific type.
Then we either forbid such casting, or provide a way to 
spell out the specific types (say, via type constructor).

However, a third solution is to create a common type 
for the generic type, implemented by all its specific types.
This common type will contain all member signatures
as required in the code under the name of that generic type.
The common type can be either an abstract class or interface.
With this solution, when a generic type is used as a type
specification, it is no longer considered a constraint, 
as there is indeed a real type for it: the common type.

While it might seem fit to create a common type for all
specific types of a general type, a more accommodating and 
accurate way is to create an interface for each concrete use 
of such a general type (at member, variable, argument type 
declaration) in a concrete realization of execution. 
Interface is preferred because of multiple inheritance, 
where the fields can be specified by getters/setters.

The type of a member in the common type is the closest super 
type of the same member in all specific types. For fields, 
it is better to use getters/setters, which should be 
generated automatically. The generated setters will need 
to downcast since the value types are super types.

Do we allow multiple constructors?

//java generics examples
public class GenericsFoo<T> { ...}  
public interface GenericsIFoo<T> { ...}  
public interface List<T> extends Collection<T> { ...}  
T get(int index);   
public static <T> T getFirst(List<T> list) { ...}  
<X> GenericsFoo(X x) {...}  
*/

classStmt:
	('@' decorators += ID)* (generic='*')? 
	'class' (isface='in')? easytarg //use 'in' for interfaces
    ( //enum as a special kind of class, no new keywords
       '{' ID ('(' exprlist ')')? 
           (',' ID ('(' exprlist ')')? )*
        '}' 
    | //normal class def 
      ( 'from' parent=qname )?
	  ( 'in' faces += qname (',' faces += qname)* )? 
    ) //body of class 
    (':' ( defs += defStmt | inits += assignStmt )*)?
    ';'
;

//def .: go(int a, int b):
//that makes the construct of "def .: stmts" problematic!
//maybe just use "@: stmts ;" as instance initializer.
//use "@@: stmts ;" as static initializer.

defStmt
locals[int getIT(int k){ return 0; }
public Map<String, String> sigs = new HashMap<String,String>();
public Map<String, Object> defs = new HashMap<String,Object>()]
:
    ('@' decorators+=qname)* //compile-time decorators
	'def' easytarg //without ID, a caller
	(
    //property definition
	//def int count = v: .count := v; ; //define setter
	//note that we use ":=" to assign to field,
	//by-passing the property setter!
      ('=' setarg=ID)? (':' body=stmts)? ';'
	| 
      '(' (params=easytargs)? ')' (':' body = stmts)? ';'
    ) 
;

//blockStmt
//locals[Map<String, Object> defs = new HashMap<String,Object>()]
//: 
//	(label = ID )? '::' body=stmts ';'
//;

//for x in g: ...
//for @x in g: //x in scope of statement

looper: easytargs 'in' expr;

forStmt:
(label =ID)? 'for'
loopers += looper (',' loopers += looper)* 
':' body = stmts
('else' ':' //with the help of a label
	exhausted = stmts )?
';'
;

asloopStmt:
    (label =ID)? 
	'as' (expr ('as' ID)?)? ':'
	    body = stmts
	('else' ':' 
		other = stmts)?
    ';'
;

ifStmt:
	'if' cond += expr ':'
		branches += stmts
	('elif' cond+=expr ':'
		branches += stmts)*
	('else' ':'
		branches += stmts)?
    ';'
;

exprlist: exprs += expr (',' exprs += expr)* ;

caseStmt: //need more thorough thinking...
	(label =ID)? 'case' expr ('as' ID)?':'
		(defaultcase = stmts)?
	('in' vals += exprlist ':' branches += stmts)+
	//('in' ':' defaultcase = stmts)?
    ';'
;

tryStmt:
   'try' ':' stmts 
   ('catch' catids += qname ('or' catids += qname)* 
           ('as' exvar=ID)? ':' stmts)* 
   ('final' ':' stmts)?
   ';'
;

//mislist:  expr? (',' expr?)* ;
typelist:
	typesig (',' typesig)*
;

//Comment: 2014/9/1
//We probably don't need such a complex type system 
//(that has types with type parameters).
//Assume that, for a general type G, once the type of 
//each field  is given, it is completely determined.
//Thus we can give a concrete type as G[int a, double b],
//if G has only two fields a and b.
//If we further assume that all field types must be
//determined at creation/initialization, then
//we can further simplify the notation by recording
//how it is created: G{int a, double b} indicates
//that an instance of G is created by calling 
//G(int a, double b), which also determines the types of 
//all other possible fields of G.
//Two different creation (if we allow multiple definition of
//initialization methods) might produce the same underlying
//concrete type, if all corresponding field are the same type.

//Inference: each instance is known to be related to 
//a certain creation parameter set (creation signature). 
//If there are still other fields to be assigned values after
//creation, then their types are determined at assignment.
//if there are multiple such field assignments, the
//requirement is that they must agree in type, 
//without regard to the site of creation in the code.

typesig: //simple and general types 
	  qname ('<' typelist '>')? 
	//(jagged) array: int[3][] //jagged, like C#
	| typesig '[' (dims+=',')*  ']' 
	//function type
    | typesig '@' '(' typelist? ')'
	//regular multi-dimension arrays can be added later
	//like: x=int@[3,4] creates a 3 by 4 matrix 
    |'<' (lo=typesig ('in'|'from'))? wild='?' 
         (('in'|'from') hi=typesig)? '>' //bounds
    |'<' typesig (',' typesig )* '>' //tuple type
;

retarg:
	('(' (args=exprlist)? ')')? ('.' ID | '[' idx=exprlist ']')
;

target: //assignment target
 easytarg (retargs += retarg)*
;

// to avoid binding a name in current eminent scope,
// use ':=' instead of '=' assignment.
// var := k rebinds 'var' to the nearest enclosing scope
// that actually defined (or used?) such a name.
// for later assignments, plain '=' can be used.
// if a name's first appreance is a read operation,
// it is rebound to the nearest enclosing scope.
// augmented assignments have the same understanding.
assignStmt: 
	target ('='|':'|AUGASS) expr ';'
; //PI: 3.1415926; //constant definition

//   for public
//:  for package/module
//:: for private
//::? for protected //not supported

asid: name=ID ('as' rename=ID)? ;

importStmt: 'import' name=qname ('.' forstar='*' | 
    'for' forids+=asid (',' forids+=asid)* )? 
   ';'
;

exprStmt: expr ';' //simple call
;


expr: 
//cast as binary operator of the same pirority as '.'/'@'.
//can't use ':' -- consider for_stmt or dictionary
//ex:  b = a!str * "3"!int;
	  expr '.' attr #DotAttr //('@' mods+=modifier)* //..: super
    | expr '(' exprlist? ')' #Call
    | expr '[' exprlist ']' #Index
	| expr op=('*'|'/'|'%') expr # Term
	| expr op=('+'|'-') expr # Arith
	| expr op=('<'|'<='|'>'|'>='|'in'|NOTIN) expr # Comp //not in?
	| 'not' expr # Negate
	| expr ('if' expr ':' expr)+  # Forked
//| (expr (RANGE expr)?)? ('++'|'--') expr? #Ranger

//concat values as strings: "count is:" 9
//in case of a leading '.': "count is:" (.counter)
//    | expr expr+ #Concat
//format values: expr:%3f
//format_expr: expr ':%' ...
//	| vals += expr (',' vals += expr)* '>>' to=expr #Send
	| '(' type=qname? expr ')' #CastAtom //allow cast here!
	| ID #JustId //semantic check on modifiers
	| '.' attr #OwnAttr //('@' mods+=modifier)*
	//def(a,b){c=a+b; return c*c}
	| 'def'  '(' easytargs? ')' (expr | '{' stmts ';'? '}') #Lamb
    | REGEX #Regex //between parts there is a hidden '/'
	| '[' exprlist? ']' #List
    //int[,] x = int@[2,3];
	| ('{'exprlist?'}' | typesig '@' '[' exprlist ']' ) #Array
	| '<' exprlist? '>' #Set
	| ('{'':''}' | '{' expr':'expr (',' expr':'expr)* '}') #Dict
	//could be a string or a template
    | STR expr* #TempStr
	| CHAR #Char
//	| RawCode #RawCode
	| INT #Int
	| FLOAT #Float
	| 'nil' #Nil 
//	| 'class' #Class
	| 'true' #True
	| 'false' #False
;

attr: 'import'| 'if'| 'else'| 'elif'| 'case' |'in' 
	|'for'| 'as'| 'break'| 'continue'
	|'true'| 'false'| 'class'| 'nil'| ID;
/*
primitiveType
    :   'bool'
    |   'char' #'c', 12c
    |   'byte' #12b
    |   'short' #2233s
    |   'int' 
    |   'long' #2344L
    |   'float' #3.0f
    |   'double' #3.0f
    ;
*/

RANGE: '...' | '..';

DOT: '.';

AUGASS: '*=' | '/=' | '%=' | '+=' | '-=' | ':=';

ID  : ('a'..'z'|'A'..'Z'|'_') 
      ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
;

INT : '0'
	| '1'..'9' Undig*
    ;

FLOAT
      //no more syntactic predicates in antlr4:
    : //(INT '.' ~'.')=> INT '.' DIGITS? EXPONENT?
      //So we use this semantic gate:
      INT '.' {_input.LA(1) != '.'}? ('0'..'9' Undig*)? EXPONENT?
    |   '.' '0'..'9' Undig* EXPONENT?
    |   INT EXPONENT
    ;

CHAR:  '\'' (ESC_SEQ | ~('\''|'\\') ) '\''
    ;

//Meta done separately...like macro preprocessing in C
//RawCode: '\'' (ESC_SEQ | ~('\''|'\\'))+ '\'';

//StrOpen:'"' (ESC_SEQ | ~('\\'|'"') )*?  '\'\'';
//StrMid:'\'\'' (ESC_SEQ | ~('\\'|'"') )*?  '\'\'';
//StrEnd: '\'\'' (ESC_SEQ | ~('\\'|'"') )*  '"';

STR :  '"' (ESC_SEQ | ~('\\'|'"'))* '"' ;

// '''there is only '' x,y:percentify(,3):>",".join '' left.'''
//use ''' for multiline strings?
//TOpen : '""' STR;
//TEnd : STR '""';
//GOpen : '""' StrOpen;
//GEnd : StrEnd;

//send one element at a time:
//x,y >> fun  <==> fun(x), fun(y)
SequSend: '>>' ; 
//star notation on receiving function:
//x,y :: fun(*) <==> fun(*x), fun(*y)
//x,y :: fun(*,2) <==> fun(*x,2), fun(*y,2)
//positional notation on rceiving function:
//x,y :: fun(?[1], a, len(?)) <==> fun(x[1], a, len(x))


// /a+b/
REGEX: '/\'' ( ESC_SEQ 
            | '\\' ('+'|'?'|'*'|'('|')'|'['|']'|'{'|':/') 
            | ':' ~('/') 
            | ~('\\'|':') 
            )* 
       '\'/'
;

INTDIV: '/?' //integer division
;

NOTIN: 'not' [ \t\n]+ 'in';

fragment //2'000.000'345, 1'000'825.
Undig: '\''? '0'..'9' ;

fragment
EXPONENT : ('e'|'E') ('+'|'-')? '0'..'9' ('_'? '0'..'9')* ;

fragment
HEX_DIGIT : ('0'..'9'|'a'..'f'|'A'..'F') ;

fragment
ESC_SEQ
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
    |   UNICODE_ESC
    |   OCTAL_ESC
    ;

fragment
OCTAL_ESC
    :   '\\' ('0'..'3') ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7')
    ;

fragment
UNICODE_ESC
    :   '\\' 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
    ;

LINE_COMMENT : '//' .*? '\r'? '\n' -> skip ;
COMMENT      : '/*' .*? '*/' -> skip ;
WS : [ \t\n]+ -> skip ;

