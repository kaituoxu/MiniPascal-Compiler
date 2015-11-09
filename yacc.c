#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <math.h>

#include "ast.h"
#include "yacc.h"
#include "auxiliary.h"

extern struct node root;

extern int yylex();
extern FILE* yyin;
extern char str1[20];
/*int CheckKeyWord(char *str);*/
void OutputQ(void);
int yyparse();
void OutputIList(void);
int yyerror(char*);

extern int VarCount;
FILE* fp;
extern int NXQ;  /* used to indicate the number of next Quater*/


extern struct QUATERLIST QuaterList[MAXMEMBER];
extern struct VARLIST VarList[MAXMEMBER];

/*int yylex(void)
{
}
*/

void OutputQ(void)
{
	int i = 1;

	if (i >= NXQ) {
		printf("no quater exists!\n");
	}

	for (i = 1;i<NXQ;i++) {

		printf("(%3d) ( %5s, ", i, QuaterList[i].op);
		if (QuaterList[i].arg1)
			printf("%6s, ", VarList[QuaterList[i].arg1].name);
		else
			printf("      , ");

		if (QuaterList[i].arg2)
			printf("%6s, ", VarList[QuaterList[i].arg2].name);
		else printf("      , ");

		if ((QuaterList[i].op[0] == 'j') || (QuaterList[i].op[0] == 'S'))
			printf("%6d )\n", QuaterList[i].result);
		else if (QuaterList[i].result)
			printf("%6s )\n", VarList[QuaterList[i].result].name);
		else printf("-\t )\n");
	}

	return;
}

int main(int argc, char *argv[])
{
	yyin = stdin;
	init_node(&root);

	if (argc>1) {
		if ((yyin = fopen(argv[1], "r")) == NULL) {
			printf("Can't open file %s\n", argv[1]);
			return -1;
		}
	}

	yyparse();

	OutputQ();

	OutputIList();

	return 0;
}

int yyerror(char *errstr)
{
	printf(" %s\n", errstr);
	return 0;
}

void OutputIList(void)
{
	int i = 1;

	printf("\n**** Symbol Table ****\n");
	printf(" No.\t name \t\t   type\n");

	if (i >= VarCount) {
		printf("Symbol Table is NULL!\n");
	}

	for (i = 1;i<VarCount;i++) {
		printf("%4d\t%6s\t\t", i, VarList[i].name);
		if (VarList[i].type) {
			printf(" REAL  \n");
		} else {
			printf(" INTEGER\n");
		}
	}

	return;
}
