typedef enum { typeCon, typeConf, typeCon_C,typeConB, typeId, typeOpr } nodeEnum;

//typedef enum { true, false } bool;
#include<stdbool.h>

/* constants */
typedef struct {
    int value;           
} conNodeType;

typedef struct {
	float fval;
} conNodeTypef;

typedef struct {
	char Cval;
} conNodeType_C;

typedef struct {
	bool bval;
} conNodeTypeB;

/* identifiers */
typedef struct {
    int i;                      /* subscript to sym array */
} idNodeType;

/* operators */
typedef struct {
    int oper;                   /* operator */
    int nops;                   /* number of operands */
    struct nodeTypeTag **op;	/* operands */
} oprNodeType;

typedef struct nodeTypeTag {
    nodeEnum type;              /* type of node */

    union {
        conNodeType con;        /* constants */
		conNodeTypef conf;
		conNodeType_C conC;
		conNodeTypeB conB;
        idNodeType id;          /* identifiers */
        oprNodeType opr;        /* operators */
    };
} nodeType;

extern int sym[26];
