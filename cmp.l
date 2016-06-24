
%{
#include <stdlib.h>
#include "cmp.h"
#include "y.tab.h"
void yyerror(char *);
%}

%%
"&&"            return AND;
"||"            return OR;
"!"             return NOT;
"int"           return INT;
"fl"            return FL;
"bool"          return BOOL;
"ch"            return CHAR;
">="            return GE;
"<="            return LE;
"=="            return EQ;
"!="            return NE;
"while"         return WHILE;
"if"            return IF;
"else"          return ELSE;
"print"         return PRINT;
"for"           return FOR;
"switch"        return SWITCH;
"case"          return CASE;
"break"         return BREAK;
"default"       return DEFAULT;
"do"            return DO;

[ \t\n]+        ;       /* ignore whitespace */

"T"        {   yylval.bValue =1 ;
                return BOOLEAN;

            }
"F"         {
                yylval.bValue =0 ;
                return BOOLEAN;

            }

[A-Z^TF]       { 
                yylval.cValue = *yytext ;
                return CHARACTER;
            }

[a-z]       { 
                yylval.sIndex = *yytext-'a';
                return VARIABLE;
            }



[0-9]+"."[0-9]*    {
                yylval.fValue = atof(yytext);
                //yylval.iValue = strtof(yytext,NULL);
                return REAL;
            }            

0           {
                yylval.iValue = atoi(yytext);
                return INTEGER;
            }

[1-9][0-9]* {
                yylval.iValue = atoi(yytext);
                return INTEGER;
            }

[-()<>=+*/;{}.] {
                return *yytext;
             }
                           
.               yyerror("Unknown character");
%%

int yywrap(void) {
    return 1;
}
