//a simple verion to play with
grammar Jael;

@header{
import java.util.Map;
import java.util.HashMap;
}

stmts: (seq+=stmt)*;

module: stmts EOF;

//a statement has its own ending ';'
stmt: classStmt
    | defStmt
	| ifStmt
	| forStmt
	| whileStmt
	| caseStmt
	| breakStmt
	| loopStmt
	| importStmt
	| blockStmt
	| assignStmt
	| exprStmt
	| tryStmt
;

breakStmt: 'break' (label=ID)? ('if' expr)? ';' 
;

loopStmt: 'continue' (label=ID)? ('if' expr)? ';' 
;

qname: names+=ID ('.' names+=ID)*;
idlist: ids+=ID (',' ids+=ID)* ;
//in an eminent scope: locid makes 
//the id only available to the scope itself.
//in an obscure scope, it binds the name
//in that obscure scope, which is available
//to any scopes nested in that obscure scope.
locid: (local=':')? name=ID;
loclist: ids+=locid (',' ids+=locid)*;
//should it be at the lexer level? 
//no: 'self', 'class' are also atoms
modifier: 'class'|ID;
//'class'|'private'|'public'|'protected'|'final';
modified: name=ID ('@' mods+=modifier)*;

/* 
//normal class
class B from A if my_interface: 
...
;

//enum class
class color def:
...
;

*/

   
classStmt:
    //@interface @abstract -- compile-time decorators
	('@' decorators += ID)* 
	'class' modified 
    ( //enum as a special kind of class, no new keywords
       '{' ID ('(' exprlist ')')? 
           (',' ID ('(' exprlist ')')? )*
        '}' 
    | //normal class def 
      ( 'from' parent=qname )?
	  ( 'if' faces += qname (',' faces += qname)* )? 
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
	'def' (type=qname)? modified 
	(
    //property definition
	//def int count = v: .count := v; ; //define setter
	//note that we use ":=" to assign to field,
	//by-passing the property setter!
      ('=' setarg=ID)? (':' body=stmts)? ';'
	| 
      '(' (params=idlist)? ')' (':' body = stmts)? ';'
    ) 
;

blockStmt
locals[Map<String, Object> defs = new HashMap<String,Object>()]
: 
	('@' label =ID )? ':' body=stmts ';'
;

//for x in g: ...
//for &x in g: //x in scope of statement
//for: //forever
//for: //forever
//for(x=1; x<10; x++): //old-style 

forStmt: 
('@' label =ID)? 
	'for' (counter=locid ('=' cstart=expr)? ',')? 
	loopvar = loclist (':' dict_value = ID)? 'in' iterable=expr
        ':' body = stmts
	('else' ':' //with the help of a label
		exhausted = stmts )?
';'
;
 
whileStmt:
    ('@' label =ID)? 
	'while' (expr ('as' ID)?)? ':'
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
	('@' label =ID)? 
	'case' expr ('as' ID)?':'
	('in' vals += exprlist ':' branches += stmts)+
	('else' ':' branches += stmts)?
    ';'
;

tryStmt:
   'try' ':' stmts 
   ('catch' ID ':' stmts)* 
   ('ensure' ':' stmts)?
   ';'
;

//mislist:  expr? (',' expr?)* ;
typelist:
	typesig (',' typesig)*
;

typesig: //simple type
	  qname ('<' typelist '>')? //such as: list of some type
	//possibly (jagged) array or function
	| typesig ('[' ']' |'@' '(' typelist? ')' )
	//regular multi-dimension arrays can be added later
	//like: x=int@[3,4] creates a 3 by 4 matrix 
    |'<' (lo=typesig ('in'|'from'))? wild='?' 
         (('in'|'from') hi=typesig)? '>' //bounds
    |'<' typesig (',' typesig )* '>' //tuple type
;

target: //assignment target
   ('.')? (':')* (typesig)? ID
 | target ('(' (args=exprlist)? ')')? ('.' ID | '[' idx=exprlist ']');

// to avoid binding a name in current eminent scope,
// use ':=' instead of '=' assignment.
// var := k rebinds 'var' to the nearest enclosing scope
// that actually defined such a name.
// for later assignments, plain '=' can be used.
// if a name's first appreance is a read operation,
// it is rebound to the nearest enclosing scope.
// augmented assignments have the same understanding.
assignStmt: 
	target ('='|AUGAS) expr ';'
;

asid: name=ID ('as' rename=ID)? ;

importStmt: 'import' name=qname ('.' forstar='*' | 
    'for' forids+=asid (',' forids+=asid)* )? 
   ';'
;

exprStmt: exprlist (':' target)? ';' //simple call
;


expr: 
//cast as binary operator of the same pirority as '.'/'@'.
//can't use ':' -- consider for_stmt or dictionary
//ex:  b = a!str * "3"!int;
      expr '!' (ncast=ID | '(' qncast=qname ')') #Cast
	| expr '.' attr ('@' mods+=modifier)* #DotAttr //..: super
    | expr '(' exprlist? ')' #Call
    | expr '[' exprlist ']' #Index
	| expr op=('*'|'/'|'%') expr # Term
	| expr op=('+'|'-') expr # Arith
	| expr op=('<'|'<='|'>'|'>=') expr # Comp
	| expr ('if' expr ':' expr)+  # Forked
    | expr RANGE expr ((('++'|'--') expr)|('+'|'-'))? #Ranger
//concat values as strings: "count is:" 9
//in case of a leading '.': "count is:" (.counter)
//    | expr expr+ #Concat
//format values: expr:%3f
//format_expr: expr ':%' ...
    | expr (',' expr)* (MonoSend|SequSend) target #Send
	| '(' expr ')' #Group
	| modified #JustId //semantic check on modifiers
	| '.' attr ('@' mods+=modifier)* #OwnAttr
	//def(a,b){c=a+b; return c*c}
	| 'def'  '(' idlist? ')' (expr | '{' stmts ';'? '}') #Lamb
	//between parts there is a hidden '/'
    | REGEX #Regex
	| '[' exprlist? ']' #List
    //int[,] x = int@[2,3];
	| ('{'exprlist?'}' | typesig '@' '[' exprlist ']' ) #Array
	| '<' exprlist? '>' #Set
	| ('{'':''}' | '{' expr':'expr (',' expr':'expr)* '}') #Dict
    | TOPN expr (STR expr)* TEND #Template
	| CHAR #Char
	| RawCode #RawCode
	| INT #Int
	| FLOAT #Float
	| (STR|StrOpen expr (StrMid expr)* StrEnd) #Str
	| 'nil' #Nil 
	| 'class' #Class
	| 'true' #True
	| 'false' #False
;

attr: 'import'| 'if'| 'else'| 'elif'| 'case' |'in' 
	|'for'| 'while'| 'break'| 'continue'
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
AUGAS: '*=' | '/=' | '%=' | '+=' | '-=' | ':=';

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

RawCode: '\'' (ESC_SEQ | ~('\''|'\\'))+ '\''
	;

StrOpen:'"' (ESC_SEQ | ~('\\'|'"') )*?  '\'\'';
StrMid:'\'\'' (ESC_SEQ | ~('\\'|'"') )*?  '\'\'';
StrEnd: '\'\'' (ESC_SEQ | ~('\\'|'"') )*  '"';

STR :  '"' (ESC_SEQ | ~('\\'|'"'))* '"' ;

// '''there is only '' x,y:percentify(,3):>",".join '' left.'''
//use ''' for multiline strings?
TOpen : '""' STR;
TEnd : STR '""';
GOpen : '""' StrOpen;
GEnd : StrEnd;


//send elements as multiple parameters
//x,y => fun  <==> fun(x,y)
MonoSend: '=>' ; 
//send one element at a time:
//x,y,z :: fun <==> fun(x), fun(y), fun(z)
SequSend: '::' ; 
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

