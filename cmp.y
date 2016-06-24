%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <ctype.h> 


#include "cmp.h"

#include <process.h> /* for system command */
#include <conio.h>  /* for clrscr */
#include <dos.h> /* for delay */
#include <math.h>

/* prototypes */
nodeType *opr(int oper, int nops, ...);
nodeType *id(int i);
nodeType *con(int value);
nodeType *conf(float value);
nodeType *conC(char value);
nodeType *conB(bool value) ;
void freeNode(nodeType *p);
int assembly(nodeType *p);
int yylex(void);
static int lbl;

void print_sym()
{
int i=0;
printf("======================\n");
printf("\n### Symbol Table ###\n");
    while( i<26)
    {

        if(sym[i]!=0)
        {
            switch(sym[i])
            {
                case(1):
                    printf("INT %c\n",i+'a');
                    break;

                case(2):
                    printf("FLOAT %c\n",i+'a');
                    break;
                case(3):
                    printf("CHAR %c\n",i+'a');
                    break;
                case(4):
                    printf("BOOL %c\n",i+'a');
                    break;
            }
        }
        i=i+1;
    }
}

void yyerror(char *s);
int sym[26]={0};                    /* symbol table */
%}
%union {
    int iValue;                 /* integer value */
    char sIndex;                /* symbol table index */
    nodeType *nPtr;             /* node pointer */
    char *string;
    float fValue;
    char cValue;
    bool bValue;
};

%token INT
%token FL CHAR BOOL
%token <bValue> BOOLEAN
%token <iValue> INTEGER
%token <fValue> REAL
%token <cValue> CHARACTER
%token <sIndex> VARIABLE
%token BREAK
%token CASE DEFAULT
%token WHILE IF PRINT FOR SWITCH DO 
%nonassoc IFX
%nonassoc ELSE

%left OR
%left AND
%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%right NOT
%nonassoc UMINUS 

%type <nPtr> stmt expr stmt_list bool_expr logic_expr def_expr BOOOOL case_st big_case def_int def_fl def_c
 
%%

program:
        function                { print_sym();exit(0); }
        ;

function:
          function stmt         { assembly($2); ; freeNode($2); }
        | /* NULL */
        ;

stmt:
          ';'                               { $$ = opr(';', 2, NULL, NULL); }
        | expr ';'                          { $$ = $1; }
        | bool_expr ';'                     { $$ = $1;}
        | logic_expr ';'                    { $$ = $1; }
        | PRINT expr ';'                    { $$ = opr(PRINT, 1, $2); }
        | INT def_expr ';'                  { $$ = opr(INT, 1, $2); }
        | BOOL def_expr ';'                 { $$ = opr(BOOL,1,$2); }

        | BOOL VARIABLE '=' logic_expr';'   { if(sym[id($2)->id.i]==0 || sym[id($2)->id.i]==4)
                                               {sym[id($2)->id.i]=4;  $$ = opr('=', 2, id($2), $4); }
                                            else
                                                {printf("semantic error bool....already declared wz another datatype!!\n"); $$=0;}
                                            }

        | BOOL VARIABLE '=' BOOOOL';'       { if(sym[id($2)->id.i]==0 || sym[id($2)->id.i]==4)
                                               {sym[id($2)->id.i]=4;  $$ = opr('=', 2, id($2), $4); }
                                            else
                                                {printf("semantic error bool...already declared wz another datatype!!\n"); $$=0;}
                                            }

        | INT VARIABLE '=' def_int ';'       { if(sym[id($2)->id.i]==0 || sym[id($2)->id.i]==1)
                                               {sym[id($2)->id.i]=1;  $$ = opr('=', 2, id($2), $4); }
                                            else
                                                {printf("semantic error int...already declared wz another datatype!!\n"); $$=0;}
                                            }

        | FL def_expr ';'                   { $$ = opr(FL, 1, $2); }

        | FL VARIABLE '=' def_fl ';'        { if(sym[id($2)->id.i]==0 || sym[id($2)->id.i]==2)
                                               {sym[id($2)->id.i]=2;  $$ = opr('=', 2, id($2), $4); }
                                            else
                                                {printf("semantic error float....already declared wz another datatype!!\n"); $$=0;}
                                            }

        | CHAR def_expr ';'                 { $$ = opr(CHAR, 1, $2); }
        | CHAR VARIABLE '=' def_c ';'        {
                                            if(sym[id($2)->id.i]==0 || sym[id($2)->id.i]==3)
                                                {sym[id($2)->id.i]=3; $$ = opr('=', 2, id($2), $4);}
                                            else
                                                {printf("semantic error char....already declared wz another datatype!!\n"); $$=0;}
                                            }

        | VARIABLE '=' expr ';'             { if(sym[id($1)->id.i]==0)
                                                {$$=0; printf("using undeclared variable...!! \nplease declare and initialize it first\n");}
                                            else
                                                $$ = opr('=', 2, id($1), $3); 
                                            }
        | DO stmt WHILE '(' bool_expr ')' ';'     { $$ = opr(DO, 2, $2, $5); }
        | DO stmt WHILE '(' logic_expr ')' ';'     { $$ = opr(DO, 2, $2, $5); }                                   
        | WHILE '(' bool_expr ')' stmt      { $$ = opr(WHILE, 2, $3, $5); }
        | WHILE '(' logic_expr ')' stmt     { $$ = opr(WHILE, 2, $3, $5); }
        | FOR  '(' stmt bool_expr';' stmt ')' stmt   { $$ = opr(FOR, 4, $3, $4,$6,$8); }
        | FOR  '(' stmt logic_expr';' stmt ')' stmt  { $$ = opr(FOR, 4, $3, $4,$6,$8); }
        | IF '(' bool_expr ')' stmt %prec IFX   { $$ = opr(IF, 2, $3, $5); }
        | IF '(' logic_expr ')' stmt %prec IFX  { $$ = opr(IF, 2, $3, $5); }
        | IF '(' bool_expr ')' stmt ELSE stmt   { $$ = opr(IF, 3, $3, $5, $7); }
        | IF '(' logic_expr ')' stmt ELSE stmt  { $$ = opr(IF, 3, $3, $5, $7); }
        | SWITCH '('expr')' '{'big_case'}'      { $$ = $6; }
        | '{' stmt_list '}'                     { $$ = $2; }
        ;

stmt_list:
          stmt                  { $$ = $1; }
        | stmt_list stmt        { $$ = opr(';', 2, $1, $2); }
        ;

case_st:
          CASE stmt stmt BREAK ';'    { $$ = opr(CASE, 2, $2, $3); }
        | DEFAULT stmt                  { $$ = $2; }
        ;

big_case:
        case_st                 { $$ = $1;}
        | big_case case_st      { $$ = opr(';' , 2, $1, $2); } 
        ;
        
expr:
          def_int               { $$ = $1;}
        | def_fl                { $$ =$1;}
        | def_c                 { $$ = $1;}
        | VARIABLE              { if(sym[id($1)->id.i]==0)
                                    {$$=0; printf("using undeclared variable!! \nplease declare and initialize it first\n");}
                                else
                                    $$ = id($1); 
                                }
        | '-' expr %prec UMINUS { $$ = opr(UMINUS, 1, $2); }
        | expr '+' expr         { $$ = opr('+', 2, $1, $3); }
        | expr '-' expr         { $$ = opr('-', 2, $1, $3); }
        | expr '*' expr         { $$ = opr('*', 2, $1, $3); }
        | expr '/' expr         { $$ = opr('/', 2, $1, $3); }
        | '(' expr ')'          { $$ = $2; }
        ;
def_expr:
          VARIABLE      { $$ = id($1);}
          ;

def_int:
        INTEGER         { $$ = con($1); }
        ;
def_fl:
        REAL         { $$ = conf($1); }
        ;

def_c:
        CHARACTER         { $$ = conC($1); }
        ;
BOOOOL:
          BOOLEAN { $$ = conB($1); }
          ;

bool_expr:
          expr '<' expr         { $$ = opr('<', 2, $1, $3); }
        | expr '>' expr         { $$ = opr('>', 2, $1, $3); }
        | expr GE expr          { $$ = opr(GE, 2, $1, $3); }
        | expr LE expr          { $$ = opr(LE, 2, $1, $3); }
        | expr NE expr          { $$ = opr(NE, 2, $1, $3); }
        | expr EQ expr          { $$ = opr(EQ, 2, $1, $3); }
        | BOOOOL                { $$ = $1; }
        | '(' bool_expr ')'     { $$ = $2; }
        ;

logic_expr:
          bool_expr AND bool_expr { $$ = opr(AND, 2, $1, $3); }
        | bool_expr OR bool_expr  { $$ = opr(OR, 2, $1, $3); }
        | logic_expr AND logic_expr { $$ = opr (AND, 2, $1, $3); }
        | logic_expr OR logic_expr { $$ = opr (OR, 2, $1, $3); }
        | NOT bool_expr     { $$ = opr(NOT, 1, $2); }
        | NOT logic_expr    { $$ = opr(NOT, 1, $2); }
        ;


%%

nodeType *con(int value) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeCon;
    p->con.value = value;

    return p;
}

nodeType *conf(float value) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeConf;
    p->conf.fval = value;

    return p;
}

nodeType *conC(char value) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeCon_C;
    p->conC.Cval = value;

    return p;
}
nodeType *conB(bool value) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeConB;
    p->conB.bval = value;

    return p;
}

nodeType *id(int i) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeId;
    p->id.i = i;

    return p;
}

nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    int i;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");
    if ((p->opr.op = malloc(nops * sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;
    va_start(ap, nops);
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, nodeType*);
    va_end(ap);
    return p;
}

void freeNode(nodeType *p) {
    int i;

    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
		free (p->opr.op);
    }
    free (p);
}

int assembly(nodeType *p) {
int lbl1, lbl2;
if (!p) return 0;
switch(p->type) {

	case typeCon:
        printf("\tpush\t%d\n", p->con.value);
        break;
    case typeConf:
        printf("\tpush\t%f\n", p->conf.fval);
        break;
    case typeCon_C:
        printf("\tpush\t%c\n", p->conC.Cval);
        break;
    case typeConB:
        printf("\tpush\t%c\n", p->conB.bval+48);
        break;
	case typeId:
		printf("\tpush\t%c\n", p->id.i + 'a');
		break;
	case typeOpr:
		switch(p->opr.oper) {
		case WHILE:
			printf("L%03d:\n", lbl1 = lbl++);
			assembly(p->opr.op[0]);
			printf("\tjz\tL%03d\n", lbl2 = lbl++);
			assembly(p->opr.op[1]);
			printf("\tjmp\tL%03d\n", lbl1);
			printf("L%03d:\n", lbl2);
			break;
        case DO:
            printf("L%03d:\n", lbl1 = lbl++);
            assembly(p->opr.op[0]);
            assembly(p->opr.op[1]);
            printf("\tjmp\tL%03d\n", lbl1);
            printf("L%03d:\n", lbl2);
            break;
        case FOR:
            assembly(p->opr.op[0]);
            printf("L%03d:\n", lbl1 = lbl++);

            assembly(p->opr.op[1]);
            printf("\tjz\tL%03d\n", lbl2 = lbl++);
            
            assembly(p->opr.op[3]);
            assembly(p->opr.op[2]);
            printf("\tjmp\tL%03d\n", lbl1);
            printf("L%03d:\n", lbl2);
            break;
		case IF:
			assembly(p->opr.op[0]);
			if (p->opr.nops > 2) {
			/* if else */
			printf("\tjz\tL%03d\n", lbl1 = lbl++);
			assembly(p->opr.op[1]);
			printf("\tjmp\tL%03d\n", lbl2 = lbl++);
			printf("L%03d:\n", lbl1);
			assembly(p->opr.op[2]);
			printf("L%03d:\n", lbl2);
			} else {
			/* if */
			printf("\tjz\tL%03d\n", lbl1 = lbl++);
			assembly(p->opr.op[1]);
			printf("L%03d:\n", lbl1);
			}
			break;

        case CASE:
            assembly(p->opr.op[0]);
            printf("\tjz\tL%03d\n", lbl1 = lbl++);
            assembly(p->opr.op[1]);
            printf("L%03d:\n", lbl1);
            break;

        case SWITCH:
            assembly(p->opr.op[1]);
           // printf("L%03d:\n", lbl1);
            break;

		case PRINT:
			assembly(p->opr.op[0]);
			printf("\tprint\n");
			break;

        //case BREAK:
          //  printf("\t break\n");
            //break;

		case '=':
			assembly(p->opr.op[1]);
			printf("\tpop\t%c\n", p->opr.op[0]->id.i + 'a');
			break;
		case UMINUS:
			assembly(p->opr.op[0]);
			printf("\tneg\n");
			break;
		default:
			assembly(p->opr.op[0]);
			assembly(p->opr.op[1]);
			switch(p->opr.oper)
			 {
				case '+': printf("\tadd\n"); break;
				case '-': printf("\tsub\n"); break;
				case '*': printf("\tmul\n"); break;
				case '/': printf("\tdiv\n"); break;
				case '<': printf("\tcompLT\n"); break;
				case '>': printf("\tcompGT\n"); break;
				case GE: printf("\tcompGE\n"); break;
				case LE: printf("\tcompLE\n"); break;
				case NE: printf("\tcompNE\n"); break;
				case EQ: printf("\tcompEQ\n"); break;
                case AND: printf("\tAND\n"); break;
                case OR: printf("\tOR\n"); break;
                case NOT: printf("\tNOT\n"); break;
                //case BREAK: printf("\tBREAK\n"); break;
 
 
			  }
		 }
}
    return 0;
}
void yyerror(char *s) {
    fprintf(stdout, "%s\n", s);
}

int main(void) {
    while(1)
    {
        if(yyparse()==1)
        {
            printf("please enter valid stmt\n");
        } 
        else
        {
            yyparse();
        }
    }
    return 0;
}
