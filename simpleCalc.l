%{
#include "simpleCalc.tab.h"
#include <string.h>

char *formatReg(char * input)
{
	char * out;
	int i;
	out = (char *) malloc(3*sizeof(char));
	out[0] = 'R';
	for(i = 0; input[i]; i++);
	out[1] = input[i-1];
	out[2] = '\0';
	return out;
}
%}
DIGIT [0-9]
FLOAT [0-9]*[.][0-9]+
INTREG [Rr][_a-zA-Z]*[0-4]
FLOATREG [Rr][_a-zA-Z]*[5-9]
%%
{DIGIT}+					{ yylval.ival = atoi(yytext); 		printf("TOKEN: NUMBER(%i)\n", yylval.ival); 	return NUMBER;	}
"+"|"-"|"*"|"/"|"("|")"|"^" {yylval.sval = yytext; 				printf("TOKEN: OPERATOR:(%s)\n", yytext); 		return yytext[0];}
{FLOAT} 					{yylval.fval = atof(yytext); 		printf("TOKEN: FLOAT:(%f)\n", yylval.fval); 	return FNUM;	}
{INTREG} 					{yylval.sval = formatReg(yytext);	printf("TOKEN: INTREG:(%s) \n", yylval.sval); 	return IREG;	}
{FLOATREG} 					{yylval.sval = formatReg(yytext); 	printf("TOKEN: FLOATREG:(%s) \n", yylval.sval);	return FREG;	}
[a-zA-z]+ 					{yylval.sval = yytext; return NAME;}
[ \t]	;		/* ignore white space */
<<EOF>>	return 0;	/* logical EOF */
.	return yytext[0];
%%
/*---------------------------------------------------------------------------*/
/* 5. Other C code that we need.                                           */
 
yywrap() {}

yyerror(char *errmsg)
{
    fprintf(stderr, "%s\n", errmsg);
}

int main(int argc, char ** argv ) 
{ 
	regInit();
	++argv, --argc;
 	/* skip over program name */
	if ( argc > 0 ) 
    	yyin = fopen( argv[0], "r" );
	else yyin = stdin;

	while(!yyparse());
}