//a simple verion to play with
grammar Jael;
@header{
import java.util.Map;
import java.util.HashMap;
}

module: stmt* EOF ;

stmt: classStmt
    | defStmt
	| refStmt
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

breakStmt: 'break' (ID {System.out.println($ID);})? ';' ;
loopStmt: 'continue' (label=ID)? ';' ;

qname: names+=ID ('.' names+=ID)*;
idlist: ids+=ID (',' ids+=ID)* ;
//in an eminent scope: locid makes 
//the id only available to the scope itself.
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
		( '=' ID |  | //property definition
		'(' (params=idlist)? ')' 
			body=suite 
		)
	';'
;

/* ref statement binds a name to a nonlocal/global 
 * variable/field, to modify its value.
 * the name is then available in the entire 
 * function/method scope, even if the ref stmt is
 * nested in a block stmt. in the global scope, 
 * you can use ref to write something in the builtin 
 * scope, provided the field is modifiable.
 *
 * the refStmt can appear anywhere in a function body.
 * if the referenced name is used before the refStmt,
 * a warning is issued, not error.
 */
refStmt:
	'ref' (names += modified)+ ';'
;

/*
 * class B in A with interfaces:
 */

blockStmt: 
	'@' (label=ID)? //'for', 'while' labels have no ':'
		body=suite
	';'
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

assignStmt: target = locid ('@' mods += ID)* 
		(':' type= ID)? '=' value=expr ';'
;

asid: name=ID ('as' rename=ID)? ;

importStmt: 'import' name=qname ('.' forstar='*' | 
    'for' forids+=asid (',' forids+=asid)* )? ';'
;

exprStmt: value=expr ';' 
;

atom: '(' expr ')' #AtomExpr
	| CHAR #Char
	| INT #Int
	| FLOAT #Float
	| REGEX+ #Regex
	| STR #Str
	| 'nil' #Nil 
	| 'self' #Self
	| 'class' #Class
	| ID #Id
;

expr: atom #Simple
	| expr ('.' ID)+ #Attr
    | expr '(' exprlist? ')' #Call
	| expr op=(MULT|DIVID) expr # Mult
	| expr op=(ADD|SUB) expr # Add
	| expr op=COMP expr # Comp
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
