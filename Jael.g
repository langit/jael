//a simple verion to play with
grammar Jael;

@header{
import java.util.Map;
import java.util.HashMap;
}

stmts: seq+=stmt (';' seq+=stmt)* ;

module: stmts ';' EOF ;

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

breakStmt: 'break' (label=ID)? ;
loopStmt: 'continue' (label=ID)?;

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
modifier: 'class'| ID;
//'class'|'private'|'public'|'protected'|'final';
modified: name=ID ('@' mods+=modifier)*;

suite: //locals[symtab, eminent] //Symbol Table 
	':' (stmts ';')? //no ';' to match ':'
;

/*
 * class B in A with interfaces:
 */

classStmt:
	'class' modified 
		( 'from' parent=qname )?
		( 'in' faces += qname (',' faces += qname)* )?
		body = suite
;

defStmt 
locals[int getIT(int k){ return 0; }
public Map<String, String> sigs = new HashMap<String,String>();
public Map<String, Object> defs = new HashMap<String,Object>()]
:
	'def' modified (':' type=qname)? 
		( '=' field=ID |  | //property definition
	//def prop@set(v): .prop := v; //define setter
	//note that we use ":=" to assign to field,
	//by-passing the property setter!
		'(' (params=idlist)? ')' 
			body=suite 
		)
;

blockStmt
locals[Map<String, Object> defs = new HashMap<String,Object>()]
: 
	('@' ID)? ':' //'for', 'while' labels have no ':'
		body=suite
	//a potential do-while loop
	('while' ':' expr)? 
;

forStmt: 
	('@' label =ID)? 
	'for' (counter=locid '=' cstart=expr ',')? 
		loopvar = loclist 'in' iterable=expr
		body = suite
	('else' //with the help of a label
		exhausted = suite )?
;
 
whileStmt:
	('@' label =ID)? 
	'while' cond = expr 
		body = suite
	('else' 
		falsified = suite)?
;

ifStmt:
	'if' cond += expr 
		branches += suite
	('elif' cond+=expr 
		branches += suite)*
	('else'
		branches += suite)?
;

exprlist: exprs += expr (',' exprs += expr)* ;

caseStmt: //need more thorough thinking...
	'class'? 'case' condval = expr ':'
	('in' vals += exprlist branches += suite)+
	('else' branches += suite)?
;

//mislist:  expr? (',' expr?)* ;

typelist:
	typesig (',' typesig)*
;

simplet: //simple type
	qname ('<' typelist '>')? //such as: list of some type
	//possibly (jagged) array or function
	| simplet ('[' ']' | '(' typelist? ')' )
	| complet ('[' ']' | '(' typelist? ')' )
	//regular multidim arrays can be added later
	//like: x=int@[3,4] creates a 3 by 4 matrix 
;

//type signature, as type constraint or specifier
complet: //complex type
'<' '?' ('in' hi=simplet)? '>'//wild card
|'<' lo=simplet ('in' wild='?' ('in' hi=simplet)?)? '>' //bounds
|'<' typesig (',' typesig )* '>' //tuple type
;

typesig: complet|simplet;

astarget: //assignment target
locid (':' typesig)? | expr '.' ID ;

// to avoid binding a name in current eminent scope,
// use ':=' instead of '=' assignment.
// var := k rebinds 'var' to the nearest enclosing scope
// that actually defined such a name.
// for later assignments, plain '=' can be used.
// if a name's first appreance is a read operation,
// it is rebound to the nearest enclosing scope.
// augmented assignments have the same understanding.
assignStmt: 
	astarget ('='|AUGAS) expr 
;

asid: name=ID ('as' rename=ID)? ;

importStmt: 'import' name=qname ('.' forstar='*' | 
    'for' forids+=asid (',' forids+=asid)* )? 
;

exprStmt: expr (':' exprlist)? //may have simple call
;

expr: 
//cast as binary operator of the same pirority as '.'/'@'.
//can't use ':' -- consider for_stmt or dictionary
//ex:  b = a!str * "3"!int;
      expr '!' (ID|'('qname')') #Cast
	| expr '.' attr ('@' mods+=modifier)* #DotAttr //..: super
    | expr '(' exprlist? ')' #Call
    | expr '[' exprlist ']' #Index
	| expr op=('*'|'/'|'%') expr # Term
	| expr op=('+'|'-') expr # Arith
	| expr op=('<'|'<='|'>'|'>=') expr # Comp
	| expr ('if' expr ':' expr)+  # Forked
//concat values as strings: "count is:" 9
//in case of a leading '.': "count is:" (.counter)
//    | expr expr+ #Concat
//format values: expr:%3f
//format_expr: expr ':%' ...
	| '(' expr ')' #Group
	| modified #JustId //semantic check on modifiers
	| '.' attr ('@' mods+=modifier)* #OwnAttr
	//|a,b|{c=a+b; ret c*c}
	| '|' idlist? '|' '{' stmts ';'? '}' #Lamb
	//between parts there is a hidden '/'
    | REGEX #Regex
	| '[' exprlist? ']' #List
	| ('{'exprlist?'}' | complet ('[' expr ']')+) #Array
	| '<' exprlist? '>' #Set
	| ('{'':''}' | '{' expr':'expr (',' expr':'expr)* '}') #Dict
    | TOPN expr (':'expr)? (TMID expr (':'expr)? )*  TEND #Template
	| CHAR #Char
	| INT #Int
	| FLOAT #Float
	| STR #Str
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
AUGAS: '*='|'/='|'%='|'+='|'-='|':=';

ID  :
   ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
;

INT : '0'
	| '1'..'9' ('_'? '0'..'9')*
    ;

FLOAT
    :   INT '.' ('0'..'9' |'0'..'9' ('_'? '0'..'9')*) EXPONENT?
    |   '.' '0'..'9' ('_'? '0'..'9')* EXPONENT?
    |   INT EXPONENT
    ;

CHAR:  '\'' (ESC_SEQ | ~('\''|'\\') ) '\''
    ;

STR
    :  '"' (ESC_SEQ | ~('\\'|'"') )* '"'
    ;

TOPN :'"""' (ESC_SEQ|'\'' ~('\'')|~('\\'|'\''))* '\'\'';
TMID :'\'\''(ESC_SEQ|'\'' ~('\'')|~('\\'|'\''))* '\'\'';
TEND :'\'\''(ESC_SEQ|'\'' ~('\'')|~('\\'|'\''))* '"""';

REGEX: '/:' (ESC_SEQ | '\\' ('+'|'?'|'*'|'('|')'|'['|']'|'{'|':/') 
    | ':' ~('/') | ~('\\'|':') )* ':/'
;

INTDIV: '/?' //integer division
;

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

