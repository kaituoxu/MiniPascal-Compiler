%{
#include <stdlib.h>
#include "ast.h"
#include "yacc.h"
#include "auxiliary.h"

#define MAXSTR 20
#define MAXMEMBER 100

#define INTTYPE  0
#define REALTYPE 1

int yyerror(char*);

// define in ast.c
extern struct node root;

extern int yylex();
extern FILE* yyin;
extern char str1[20];

extern NXQ;
extern int VarCount;
extern int tempVarCount;
extern struct QUATERLIST QuaterList[MAXMEMBER];
extern struct VARLIST VarList[MAXMEMBER];

%}
%start    ProgDef
%union 
{
 int Iv;
 int CH;
 int NO;
 struct { int TC,FC;} _BExpr;
 struct { int QUAD,CH;} _WBD;
 struct { int type,place; union{int Iv;float Rv;} Value;} _Expr;
 char _Rop[5];
 int First;
 char str[20];
 struct node *ast_node;
}
/*Define const:  */
%token <str>   	Iden    300
%token <str>   	IntNo		301
%token <str>  	RealNo  302
/*Define keywords here:*/
%token	<str>  	Program 400
%token	<str>  	Begin		401
%token	<str> 	End			402
%token	<str>  	Var			403
%token	<str>  	Integer 404
%token	<str>  	Real		405
%token	<str>  	While		406
%token	<str>  	Do			407
%token	<str>		If			408
%token	<str>		Then		409
%token	<str>		Else		410
%token	<str>		Or			411
%token	<str>		And			412
%token	<str>		Not			413
/*Define double_character terminates:   */
%token		LE	500
%token		GE	501
%token		NE	502

%left 	Or
%left		And
%nonassoc  	Not
%nonassoc '<' '>' '=' LE GE NE
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS


%type <ast_node> ProgDef
%type <ast_node> SubProg
%type <CH> VarDef
%type <CH> VarDefList
%type <Iv> Type
%type <CH> VarDefState
%type <First> VarList
%type <CH> Statement
%type <CH> StateList
%type <CH> S_L
%type <CH> CompState
%type <CH> AsignState
%type <CH> ISE
%type <CH> IBT
%type <_WBD> WBD
%type <_Rop> RelationOp
%type <_Expr> Expr 
/*%type <CH> BAND
%type <CH> BOR*/
%type <CH> Wh
%type <NO> Variable 
%type <_Expr> Const 
%type <_BExpr>	BoolExpr


%%
ProgDef:	Program Iden {set_node_val_str(&root,str1);} ';' SubProg '.'
          {
		      struct node *tmpnode=NULL;
              printf("\n\n**** test ast node ****\n\n");
			  $$=&root;
			  $$->type=e_program;
			  tmpnode=$5;
			  add_son_node(&root,$5);
			  printf("**** Program %s ****\n",root.val.str);
          }
	;
SubProg:	VarDef CompState
		{
		}
	;
VarDef:		Var VarDefList ';'
        {
		}
	;
VarDefList:	VarDefList';'VarDefState
        {
		}
	|	VarDefState
	    {
        }
	;
VarDefState:	VarList':'Type
		{
		while ($1) {
			VarList[$1].type = $3;
			$1 = VarList[$1].addr;
		}
		}
	;
Type:		Integer
		{
		//Type <Iv> <int>
		$$ = 0;
		}
	|	Real
		{
		$$ = 1;
		}
	;
VarList:	VarList','Variable
		{
		// VarList <First> <int>

		$$ = $3;
		VarList[$3].addr = $1;
		}
	|	Variable
		{
		$$ = $1;
		VarList[$1].addr = -1;
		}
	;
StateList:	S_L Statement
		{
		$$ = $2;
		}
	|	Statement
		{
		$$ = $1;
		}
	;
S_L:		StateList ';'
		{
		backPatch($1, NXQ);
		}
	;
Statement:	AsignState
		{
		$$ = 0;
		}
	|	ISE Statement
		{
		$$ = merge($1, $2);
		}
	|	IBT Statement
		{
		$$ = merge($1, $2);
		}
	|	WBD Statement
		{
		backPatch($2, $1.QUAD);
		gen("j", 0, 0, $1.QUAD);
		$$ = $1.CH;
		}
	|	CompState
	    {
		$$ = $1;
		}
	|	{
	    }
	;
CompState:	Begin StateList End
		{
		$$ = $2;
		}
	;
AsignState:	Variable ':''=' Expr
		{
		gen(":=", $4.place, 0, $1);
		}
	;
ISE:		IBT Statement Else
		{
		int q = NXQ;
		gen("j", 0, 0, 0);
		backPatch($1, NXQ); // right now, NXQ = q + 1
		$$ = merge($2, q);
		}
	;
IBT:		If BoolExpr Then
		{
		backPatch($2.TC, NXQ); $$ = $2.FC;
		}

	;
WBD: Wh BoolExpr Do
		{
		// WBD <_WBD> <QUAD, CH>

		backPatch($2.TC, NXQ);
		$$.CH = $2.FC;
		$$.QUAD = $1;
		}
	;
Wh:		While
        {
		$$ = NXQ;
        }
	;
Expr:		Expr'+'Expr
		{
		$$.place = newTemp();
		gen("+", $1.place, $3.place, $$.place);
		}
	|	Expr'-'Expr
		{
		$$.place = newTemp();
		gen("-", $1.place, $3.place, $$.place);
		}

	|	Expr'*'Expr
		{
		$$.place = newTemp();
		gen("*", $1.place, $3.place, $$.place);
		}
	|	Expr'/'Expr
		{
		$$.place = newTemp();
		gen("/", $1.place, $3.place, $$.place);
		}
	|	'('Expr')'
		{
		$$.place = $2.place;
		}
	|	'-' Expr %prec UMINUS
		{
		$$.place = newTemp();
		gen("-", $2.place, 0, $$.place);
		}
	|	Variable
		{
		$$.place = $1;
		}

	|	Const
		{
		$$.type = $1.type;
		$$.place = $1.place;
		if ($$.type) {
			$$.Value.Rv = $1.Value.Rv;
		} else {
			$$.Value.Iv = $1.Value.Iv;
		}
		}
	;

BoolExpr:	Expr RelationOp Expr
		{
		$$.TC = NXQ; $$.FC = NXQ + 1;
		gen($2, $1.place, $3.place, 0);
		gen("j", 0, 0, 0); 
		}
	|	BoolExpr And
	    {
		backPatch($1.TC, NXQ); $$.FC = $1.FC;
		}
	|	BoolExpr Or
	    {
		backPatch($1.FC, NXQ); $$.TC = $1.TC;
		}	
	|	Not BoolExpr
	    {
		$$.TC = $2.FC; $$.FC = $2.TC;
		}
	|	'(' BoolExpr ')'
	    {
		$$.TC = $2.TC; $$.FC = $2.FC;
		}
	;
Variable:	Iden
		{
		//Variable <NO> <int>
		$$ = entry(str1); 
		//printf(" * here %s %d %d * ", str1, $$, VarCount);
		}
	;
Const:		IntNo
		{
		//Const <_Expr> <int, int , int/float>

		$$.type = 0;
		$$.place = entry(str1);
		VarList[$$.place].type = 0;
		$$.Value.Iv = atoi(str1);
		//printf("** %s %d **", str1, atoi(str1));
		}
	|	RealNo
		{
		$$.type = 1;
		$$.place = entry(str1);
		VarList[$$.place].type = 1;
		$$.Value.Rv = (float)atof(str1);
		//printf("** %s **", str1);
		}
	;
RelationOp:	'<'
		{
		//RelationOp <_Rop> <char [5]>
		
		strcpy($$, "j<");
		}
	|	'>'
		{
		strcpy($$, "j>");
		}	
	|	'='
		{
		strcpy($$, "j=");
		}
	|	GE
		{
		strcpy($$, "j>=");
		}
	|	NE
		{
		strcpy($$, "j!=");
		}
	|	LE
		{
		strcpy($$, "j<=");
		}
	;

%%
