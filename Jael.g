//a simple verion to play with
grammar Jael;
@header{
import java.util.Map;
import java.util.HashMap;
}

module: stmt* EOF ;

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
;

breakStmt: 'break' (label=ID)? ';' ;
loopStmt: 'continue' (label=ID)? ';' ;

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
//modifier:  'get'|'set'|
//'class'|'private'|'public'|'protected'|'final';
modified: name=ID ('@' mods+=ID)*;

suite: //locals[symtab, eminent] //Symbol Table 
	':' (stmts += stmt)* //no ending ';'!
;

/*
 * class B in A with interfaces:
 */

classStmt:
	'class' name=ID ('@' mods+=ID)* 
		( 'in' parent=qname )?
		( '<<' faces += qname (',' faces += qname)* ) 
		body = suite
	';'
;

defStmt 
locals[Map<String, Object> sigs = new HashMap<String,Object>()]
:
	'def' name=ID ('@' mods+=ID)* (':' type=qname)? 
		( '=' field=ID |  | //property definition
	//def prop@set(v): .prop := v; //define setter
	//note that we use ":=" to assign to field,
	//by-passing the property setter!
		'(' (params=idlist)? ')' 
			body=suite 
		)
	';'
;

blockStmt: 
	('@' ID)? ':' //'for', 'while' labels have no ':'
		body=suite
	//a potential do-while loop
	(':' 'while' expr ('else' suite)? )? ';' 
;

forStmt: 
	('@' label =ID)? 
	'for' (counter=locid '=' cstart=expr ',')? 
		loopvar = loclist 'in' iterable=expr
		body = suite
	('else' //with the help of a label
		exhausted = suite )?
	';'
;
 
whileStmt:
	('@' label =ID)? 
	'while' cond = expr 
		body = suite
	('else' 
		falsified = suite)?
	';'
;

ifStmt:
	'if' cond += expr 
		branches += suite
	('elif' cond+=expr 
		branches += suite)*
	('else'
		branches += suite)?
	';'
;

exprlist: exprs += expr (',' exprs += expr)* ;

caseStmt:
	'case' condval = expr ':'
	('in' conds += exprlist 
		branches += suite)+
	('else'
		branches += suite)?
	';'
;

typelist:
	typesig (',' typesig)?
;

typesig: //type signature, as type constraint or provider
'list' ('<' typesig '>')? //list of some type
//possibly array or function
| typesig ('[' ','* ']' | '(' typelist? ')' )
| qname ('in' '?')? | '?' ('in' qname)? //wild card
;

array_literal: typesig '['']' 
	'{' exprlist? '}'; //nesting level: dimension
list_literal:  '[' exprlist? ']';
set_literal:  '{' exprlist? '}';
dict_literal: '{' ':' '}'  //empty dict
	| '{' expr':'expr (',' expr':'expr)* '}';

array_allocator: typesig '[' exprlist ']';

// to avoid binding a name in current eminent scope,
// use ':=' instead of '=' assignment.
// var: = k rebinds 'var' to the nearest enclosing scope
// that actually defined such a name.
// for later assignments, plain '=' can be used.
// if a name's first appreance is a read operation,
// it is rebound to the nearest enclosing scope.
// augmented assignments have the same understanding.
assignStmt: target = locid ('@' mods += ID)* 
		(':' type= ID)? (bind='='|rebind=':=') value=expr ';'
;

asid: name=ID ('as' rename=ID)? ;

importStmt: 'import' name=qname ('.' forstar='*' | 
    'for' forids+=asid (',' forids+=asid)* )? ';'
;

exprStmt: expr ';' ;

//cast as binary operator of the same pirority as '.'/'@'.
//can't use ':' -- consider for_stmt or dictionary
//ex:  b = a!str * "3"!int;
cast_expr: expr '!' (ID| '(' qname ')');

atom: '(' expr ')' #AtomExpr
	| CHAR #Char
	| INT #Int
	| FLOAT #Float
	| REGEX+ #Regex
	| STR #Str
	| 'nil' #Nil 
	| 'class' #Class
	| ID #Id
;

expr: atom #Simple
	| expr '.' ID #Attr
    | expr '(' exprlist? ')' #Call
	| expr op=(MULT|DIVID) expr # Mult
	| expr op=(ADD|SUB) expr # Add
	| expr op=COMP expr # Comp
//concat values as strings: "count is:" 9
//in case of a leading '.': "count is:" (.counter)
    | expr expr+ #Concat
//format values: expr:%3f
//format_expr: expr ':%' ...
;

MULT: '*';
DIVID: '/' ;
ADD : '+' ;
SUB: '-' ;
COMP: '>'|'<'|'>='|'<=';

ID  :
   ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
;

INT : '0'
	| '1'..'9' '0'..'9'*
    ;

FLOAT
    :   INT '.' ('0'..'9')* EXPONENT?
    |   '.' ('0'..'9')+ EXPONENT?
    |   INT EXPONENT
    ;

REGEX: ('/' (ESC_SEQ | ~'/')* '/')+ ;

CHAR:  '\'' (ESC_SEQ | ~('\''|'\\') ) '\''
    ;

STR
    :  '"' (ESC_SEQ | ~('\\'|'"') )* '"'
    ;

fragment
EXPONENT : ('e'|'E') ('+'|'-')? ('0'..'9')+ ;

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

LINE_COMMENT : '---' .*? '\r'? '\n' -> skip ;
COMMENT      : '/*' .*? '*/' -> skip ;
WS : [ \t\n]+ -> skip ;
