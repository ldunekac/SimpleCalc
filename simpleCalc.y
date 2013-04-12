%{ 
#include <stdio.h>
#include <stdlib.h>

int R0;
int R1;
int R2;
int R3;
int R4;
float R5;
float R6;
float R7;
float R8;
float R9;

float powFun(float base, int exp)
{
	float result;
	int i;

	result = base;
	for(i = 1; i < exp; i++)
	{
		result = result * base;
	}
	return result;
}

void regInit(void)
{
	R0 = 0;
	R1 = 0;
	R2 = 0;
	R3 = 0;
	R4 = 0;
	R5 = 0;
	R6 = 0;
	R7 = 0;
	R8 = 0;
	R9 = 0;
}

void setIntReg(char * s, int value)
{
	if(s[1] == '0') { R0 = value; return; }
	if(s[1] == '1') { R1 = value; return; }
	if(s[1] == '2') { R2 = value; return; }
	if(s[1] == '3') { R3 = value; return; }
	if(s[1] == '4') { R4 = value; return; }
}

void setFloatReg(char *s, float value)
{
	if(s[1] == '5') { R5 = value; return; }
	if(s[1] == '6') { R6 = value; return; }
	if(s[1] == '7') { R7 = value; return; }
	if(s[1] == '8') { R8 = value; return; }
	if(s[1] == '9') { R9 = value; return; }
}

float getFloat(char *s)
{
	if(s[1] == '5') return R5;
	if(s[1] == '6') return R6;
	if(s[1] == '7') return R7;
	if(s[1] == '8') return R8;
	if(s[1] == '9') return R9;	
}

int getInt(char *s)
{
	if(s[1] == '0') return R0;
	if(s[1] == '1') return R1;
	if(s[1] == '2') return R2;
	if(s[1] == '3') return R3;
	if(s[1] == '4') return R4;	
}

int toInt(float input)
{
	int rtn = (int)input;
	return rtn;
}

float toFloat(int input)
{
	float rtn = (float)input;
	return rtn;
}

%}
%union {
	float fval;
	int ival;
	char* sval;
}
%token <sval> NAME 
%token <sval> IREG
%token <sval> FREG
%token <ival> NUMBER
%token <fval> FNUM
%token <sval> NEWLINE
%type <ival> iexpression
%type <ival> iterm
%type <ival> ifactor
%type <fval> fexpression
%type <fval> fterm
%type <fval> ffactor
%type <fval> statement
%type <fval> power
%type <ival> ivalue
%type <fval> fvalue
%%

program:
	  '{' statements '}' {printf("REDUCE: <program> -> { <statements> } \n"); exit(0); }
	| '{' NEWLINE statements '}' {printf("REDUCE: <program> -> { <statements> } \n"); exit(0); }
	| statement NEWLINE 		 {printf("REDUCE: <program> -> <statement> NEWLINE \n"); exit(0);} 
	;

statements:
	  statement ';' statements 	{printf("REDUCE: <statements> -> <statement> ; <statements> \n"); }
	| statement ';' NEWLINE statements 	{printf("REDUCE: <statements> -> <statement> ; <statements> \n"); }
	| statement ';' NEWLINE		{printf("REDUCE: <statements> -> <statement> ; <statements> \n"); }
	| statement ';'				{printf("REDUCE: <statements> -> <statement> ; \n"); }
	;

statement:	
      IREG '=' iexpression  
      	{ $$ = $3; 	setIntReg($1, $3);	printf("REDUCE: <statement> -> <IREG> = <iexpression> (%s = %i) \n", $1,$3); }
	| IREG '=' fexpression  
		{ $$ = toInt($3); setIntReg($1, toInt($3)); 	printf("REDUCE: <statement> -> <IREG> = <fexpression> (%s = %i) \n", $1, toInt($$)); }
	| FREG '=' iexpression  
		{ $$ = toFloat($3);	setFloatReg($1, toFloat($3)); printf("REDUCE: <statement> -> <FREG> = <iexpression> (%s = %f) \n", $1, toFloat($$)); }
	| FREG '=' fexpression  
		{ $$ = $3;	setFloatReg($1, $3); printf("REDUCE: <statement> -> <FREG> = <fexpression> (%s = %f) \n", $1, $$); }
	| iexpression	        
		{ $$ = $1; 			printf("REDUCE: <statement> -> <iexpression> (%i) \n", $1); }
	| fexpression		    
		{ $$ = $1;			printf("REDUCE: <statement> -> <fexpression> (%f) \n", $$); }
	;

iexpression:
      iexpression '+' iterm	{ $$ = $1 + $3; printf("REDUCE: <iexpression> -> <iexpression> + <ifactor> (%i) \n", $$); }
 	| iexpression '-' iterm	{ $$ = $1 - $3; printf("REDUCE: <iexpression> -> <iexpression> - <ifactor> (%i) \n", $$); }
	| iterm			        { $$ = $1; 		printf("REDUCE: <iexpression> -> <iterm> (%i) \n", $$); }
	;

fexpression:
      fexpression '+' fterm { $$ = $1 + $3; printf("REDUCE: <fexpression> -> <fexpression> + <fterm> (%g) \n", $$); }
    | fexpression '+' iterm { $$ = $1 + $3; printf("REDUCE: <fexpression> -> <fexpression> + <iterm> (%g) \n", $$); }
    | iexpression '+' fterm { $$ = $1 + $3; printf("REDUCE: <fexpression> -> <iexpression> + <fterm> (%g) \n", $$); }
	| fexpression '-' fterm { $$ = $1 - $3; printf("REDUCE: <fexpression> -> <fexpression> - <fterm> (%g) \n", $$); }
	| fexpression '-' iterm { $$ = $1 - $3; printf("REDUCE: <fexpression> -> <fexpression> - <iterm> (%g) \n", $$); }
	| iexpression '-' fterm { $$ = $1 - $3; printf("REDUCE: <fexpression> -> <iexpression> - <fterm> (%g) \n", $$); }
	| fterm                 { $$ = $1;      printf("REDUCE: <fexpression> -> <fterm> (%f) \n", $$);}
	;

iterm: 
      iterm '*' ifactor { $$ = $1 * $3; printf("REDUCE: <iterm> -> <iterm> * <ifactor> (%i) \n", $$); }
	| iterm '/' ifactor { $$ = $1 / $3; printf("REDUCE: <iterm> -> <iterm> / <ifactor> (%i) \n", $$); }
	| ifactor			{ $$ = $1;      printf("REDUCE: <iterm> -> <ifactor> (%i) \n", $$); }
	; 

fterm: 
      fterm '*' power 	{ $$ = $1 * $3; printf("REDUCE: <fterm> -> <fterm> * <power> (%f) \n",$$); }
    | fterm '*' ifactor { $$ = $1 * $3; printf("REDUCE: <fterm> -> <fterm> * <ifactor> (%f) \n",$$); }
    | iterm '*' power 	{ $$ = $1 * $3; printf("REDUCE: <fterm> -> <iterm> * <power> (%f) \n",$$); }
    | fterm '/' power 	{ $$ = $1 / $3; printf("REDUCE: <fterm> -> <fterm> / <power> (%f) \n",$$); }
    | fterm '/' ifactor { $$ = $1 / $3; printf("REDUCE: <fterm> -> <fterm> / <ifactor> (%f) \n",$$); }
    | iterm '/' power 	{ $$ = $1 / $3; printf("REDUCE: <fterm> -> <iterm> / <power> (%f) \n",$$); }
	| power           { $$ = $1;      printf("REDUCE: <fterm> -> <power> (%f) \n", $$); }
	;



power:
	  ffactor '^' power {$$ = powFun($1, toInt($3)); 			printf("<power> -> <ffactor> ^ <ffactor> (%f)\n", $$);}
	| ffactor '^' ifactor {$$ = powFun($1,$3);					printf("<power> -> <ffactor> ^ <ifactor> (%f)\n", $$);}
	| ifactor '^' power {$$ = powFun(toFloat($1), toInt($3)); printf("<power> -> <ifactor> ^ <ffactor> (%f)\n", $$);}
	| ifactor '^' ifactor {$$ = powFun(toFloat($1), $3); 		printf("<power> -> <ifactor> ^ <ifactor> (%f)\n", $$);}
	| ffactor {$$ = $1;}
	;

ifactor: 
	  ivalue { $$ = $1;}
	| '+' ivalue {$$ = $2;}
	| '-' ivalue {$$ = -$2;}


ffactor:
	  fvalue {$$ = $1;}
	| '+' fvalue {$$ = $2;}
	| '-' fvalue {$$ = -$2;}

ivalue:
	  NUMBER 				{$$ = $1; 			printf("REDUCE: <ifactor> -> <NUMBER> (%i) \n", $$); }
    | IREG 					{$$ = getInt($1);	printf("REDUCE: <ifactor> -> <IREG> (%i) \n", $$); }
	| '(' iexpression ')' 	{$$ = $2; 			printf("REDUCE: <ifactor> -> ( <iexpression> ) (%i) \n", $$); }
	;

fvalue:
      FNUM 					{$$ = $1; 			printf("REDUCE: <ffactor> -> <FNUM> (%f) \n", $$); }
    | FREG  				{$$ = getFloat($1); printf("REDUCE: <ffactor> -> <FREG> (%f) \n", $$); }
	| '(' fexpression ')' 	{$$ = $2; 			printf("REDUCE: <ffactor> -> ( <fexpression> ) (%f)\n", $$); }
	;
