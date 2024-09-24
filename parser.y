%{
    #include<stdio.h>
    #include<string.h>
    #include<stdlib.h>
    #include<ctype.h>
    #include"lex.yy.c"
    void yyerror(const char *s);
    int yylex();
    int yywrap();
    void add(char);
    void insert_type();
    int search(char *);
    void insert_type();
    void printtree(struct node*);
	void print_preorder(struct node*, int);
	void check_declaration(char *);
	int check_types(char *, char *);
	char *get_type(char *);
    struct node* mknode(struct node *left, struct node *right, char *token);

    struct dataType {
        char * id_name;
        char * data_type;
        char * type;
        int line_no;
    } symbol_table[40];

    int count = 0;
    int q;
    char type[11];
    extern int countn;
    struct node *head;
	int sem_errors = 0;
	int label = 0;
	char buff[100];
	char errors[10][100];
	char reserved[11][11] = {"inteiro", "real", "caracter", "se", "senao", "para", "funcao inicio", "inclua bibilioteca", "enquanto", "faca", "funcao"};

//estrutura de nó da ast
    struct node {  
		struct node *left; 
		struct node *right; 
		char *token; 
    };

	char *tokens[100];
    int token_count = 0;
%}

%union { 
	struct var_name { 
		char name[100]; 
		struct node* nd;
	} nd_obj; 

	struct var_name2 { 
		char name[100]; 
		struct node* nd;
		char type[7];
	} nd_obj2; 
}

%token <nd_obj> INCLUA_BIBLIOTECA PROGRAMA FUNCAO_INICIO FUNCAO FUNCTION_CALL ESCREVA LEIA INTEIRO REAL CARACTERE STRING PARA SE SENAO ENQUANTO FACA INTEIRO_LITERAL REAL_LITERAL ID MENOR_IGUAL MAIOR_IGUAL IGUAL DIFERENTE MAIOR MENOR ADICAO SUBTRACAO MULTIPLICACAO DIVISAO INC_DEC STRING_LITERAL CARACTERE_LITERAL  
%type <nd_obj> header funcao_inicio body datatype statement operacao relop bloco condition senao funcao outras_funcoes chamada_funcao
%type <nd_obj2> init valor expression

%%
//regras de produção
bloco: PROGRAMA '{' header outras_funcoes funcao_inicio '(' ')' '{' body '}' '}' {
	$5.nd = mknode($9.nd, NULL, "funcao_inicio"); //funcao_inicio: body, NULL
	$1.nd = mknode($5.nd, $4.nd, "programa"); //PROGRAMA: FUNCAO_INICIO, outras_funcoes
	$$.nd = mknode($3.nd, $1.nd, "bloco"); //bloco: header, programa
	head = $$.nd;
}
;

header: INCLUA_BIBLIOTECA { add('H'); } { 
		$$.nd = mknode(NULL, NULL, $1.name); 
	}
| /* vazio */ { 
		$$.nd = mknode(NULL, NULL, "NULL"); 
	}
;

funcao_inicio: FUNCAO_INICIO { add('F'); }
;

outras_funcoes: funcao {
	$$.nd = $1.nd;
}
| outras_funcoes funcao {
	$$.nd = mknode($1.nd, $2.nd, "outras_funcoes");
}
| /* vazio */ {
	$$.nd = mknode(NULL, NULL, "NULL"); 
}
;

funcao: FUNCAO ID { add('F'); } '(' ')' '{' body '}' { 
	$$.nd = mknode($1.nd, $7.nd, $2.name);  //funcao, id, body
}

chamada_funcao: ID { check_declaration($1.name); } '(' ')' { 
	$1.nd = mknode(NULL, NULL, $1.name); 
	$$.nd = mknode($1.nd, NULL, "chamada_funcao"); 
}


datatype: INTEIRO { insert_type(); }
| REAL { insert_type(); }
| CARACTERE { insert_type(); }
| STRING { insert_type(); }
;

body: PARA { add('K'); } '(' statement ';' condition ';' statement ')' '{' body '}' { 
	struct node *temp = mknode($6.nd, $8.nd, "CONDITION"); 
	struct node *temp2 = mknode($4.nd, temp, "CONDITION"); 
	$$.nd = mknode(temp2, $11.nd, $1.name);  
}
| SE { add('K'); } '(' condition ')' '{' body '}' senao { 
	struct node *iff = mknode($4.nd, $7.nd, $1.name); 
	$$.nd = mknode(iff, $9.nd, "se-senao"); 
}
| ENQUANTO { add('K'); } '(' condition ')' '{' body '}' {
    struct node *temp = mknode($4.nd, $7.nd, "CONDITION");
    $$.nd = mknode(NULL, temp, $1.name);
}
| FACA { add('K'); } '{' body '}' ENQUANTO { add('K'); } '(' condition ')' ';' {
    struct node *body_node = $4.nd;
    struct node *condition_node = $9.nd;
    struct node *temp = mknode(condition_node, body_node, "CONDITION");
    $$.nd = mknode(NULL, temp, $1.name);
}
| statement ';' { 
	$$.nd = $1.nd; 
}
| body body { 
	$$.nd = mknode($1.nd, $2.nd, "statements"); 
}
| ESCREVA  { add('K'); } '(' STRING_LITERAL ')' ';' {
    $$.nd = mknode(NULL, NULL, "escreva");
}
| LEIA { add('K'); } '(' ID ')' ';' { 
	$$.nd = mknode(NULL, NULL, "leia");
}
| chamada_funcao ';' { 
	$$.nd = $1.nd; 
}
;

senao: SENAO { add('K'); } '{' body '}' { 
	$$.nd = mknode(NULL, $4.nd, $1.name); 
}
| /* vazio */  { 
	$$.nd = NULL; 
}
;

condition: valor relop valor  {
	$$.nd = mknode($1.nd, $3.nd, $2.name); 
}
| /* vazio */ { 
	$$.nd = NULL; 
}
;

//declarações
statement: datatype ID { add('V'); } init { //declaração de variável identificador
	$2.nd = mknode(NULL, NULL, $2.name); 
	int t = check_types($1.name, $4.type); 
	if(t>0) { 
		if(t == 1) {
			struct node *temp = mknode(NULL, $4.nd, "real_para_inteiro"); 
			$$.nd = mknode($2.nd, temp, "declaration"); 
		} 
		else if(t == 2) { 
			struct node *temp = mknode(NULL, $4.nd, "inteiro_para_real"); 
			$$.nd = mknode($2.nd, temp, "declaration"); 
		} 
		else if(t == 3) { 
			struct node *temp = mknode(NULL, $4.nd, "caracter_para_inteiro"); 
			$$.nd = mknode($2.nd, temp, "declaration"); 
		} 
		else if(t == 4) { 
			struct node *temp = mknode(NULL, $4.nd, "inteiro_para_caracter"); 
			$$.nd = mknode($2.nd, temp, "declaration"); 
		} 
		else if(t == 5) { 
			struct node *temp = mknode(NULL, $4.nd, "caracter_para_real"); 
			$$.nd = mknode($2.nd, temp, "declaration"); 
		} 
		else{
			struct node *temp = mknode(NULL, $4.nd, "real_para_caracter"); 
			$$.nd = mknode($2.nd, temp, "declaration"); 
		}
	} 
	else { 
		$$.nd = mknode($2.nd, $4.nd, "declaration"); 
	} 
}
| ID { check_declaration($1.name); } '=' expression { //atribuição de valor a um identificador
	$1.nd = mknode(NULL, NULL, $1.name);
	char *id_type = get_type($1.name); 
	if(strcmp(id_type, $4.type)) {
		if(!strcmp(id_type, "inteiro")) {
			if(!strcmp($4.type, "real")) {
				struct node *temp = mknode(NULL, $4.nd, "real_para_inteiro");
				$$.nd = mknode($1.nd, temp, "="); 
			}
			else {
				struct node *temp = mknode(NULL, $4.nd, "caracter_para_inteiro");
				$$.nd = mknode($1.nd, temp, "="); 
			}
		}
		else if(!strcmp(id_type, "real")) {
			if(!strcmp($4.type, "inteiro")) {
				struct node *temp = mknode(NULL, $4.nd, "inteiro_para_real");
				$$.nd = mknode($1.nd, temp, "="); 
			}
			else {
				struct node *temp = mknode(NULL, $4.nd, "caracter_para_real");
				$$.nd = mknode($1.nd, temp, "="); 
			}
		}
		else {
			if(!strcmp($4.type, "inteiro")) {
				struct node *temp = mknode(NULL, $4.nd, "inteiro_para_caracter");
				$$.nd = mknode($1.nd, temp, "="); 
			}
			else {
				struct node *temp = mknode(NULL, $4.nd, "real_para_caracter");
				$$.nd = mknode($1.nd, temp, "="); 
			}
		}
	}
	else {
		$$.nd = mknode($1.nd, $4.nd, "="); 
	}
}
| ID { check_declaration($1.name); } relop expression {  //atribuição ao identificador valores como menor, maior, maior igual e em seguida uma expressão
	$1.nd = mknode(NULL, NULL, $1.name); 
	$$.nd = mknode($1.nd, $4.nd, $3.name); 
}
| ID  { check_declaration($1.name);} INC_DEC { 
	$1.nd = mknode(NULL, NULL, $1.name); 
	$3.nd = mknode(NULL, NULL, $3.name); 
	$$.nd = mknode($1.nd, $3.nd, "ITERATOR"); 
}
| INC_DEC ID { 
	check_declaration($2.name);
	$1.nd = mknode(NULL, NULL, $1.name); 
	$2.nd = mknode(NULL, NULL, $2.name); 
	$$.nd = mknode($1.nd, $2.nd, "ITERATOR"); 
}
;

init: '=' valor { $$.nd = $2.nd; sprintf($$.type, $2.type); strcpy($$.name, $2.name); }
| { sprintf($$.type, "null"); $$.nd = mknode(NULL, NULL, "NULL"); strcpy($$.name, "NULL"); }
;

expression: expression operacao expression { 
	if(!strcmp($1.type, $3.type)) {
		sprintf($$.type, $1.type);
		$$.nd = mknode($1.nd, $3.nd, $2.name); 
	}
	else {
		if(!strcmp($1.type, "inteiro") && !strcmp($3.type, "real")) {
			struct node *temp = mknode(NULL, $1.nd, "inteiro_para_real");
			sprintf($$.type, $3.type);
			$$.nd = mknode(temp, $3.nd, $2.name);
		}
		else if(!strcmp($1.type, "real") && !strcmp($3.type, "inteiro")) {
			struct node *temp = mknode(NULL, $3.nd, "inteiro_para_real");
			sprintf($$.type, $1.type);
			$$.nd = mknode($1.nd, temp, $2.name);
		}
		else if(!strcmp($1.type, "inteiro") && !strcmp($3.type, "caracter")) {
			struct node *temp = mknode(NULL, $3.nd, "caracter_para_inteiro");
			sprintf($$.type, $1.type);
			$$.nd = mknode($1.nd, temp, $2.name);
		}
		else if(!strcmp($1.type, "caracter") && !strcmp($3.type, "inteiro")) {
			struct node *temp = mknode(NULL, $1.nd, "caracter_para_inteiro");
			sprintf($$.type, $3.type);
			$$.nd = mknode(temp, $3.nd, $2.name);
		}
		else if(!strcmp($1.type, "real") && !strcmp($3.type, "caracter")) {
			struct node *temp = mknode(NULL, $3.nd, "caracter_para_real");
			sprintf($$.type, $1.type);
			$$.nd = mknode($1.nd, temp, $2.name);
		}
		else {
			struct node *temp = mknode(NULL, $1.nd, "caracter_para_real");
			sprintf($$.type, $3.type);
			$$.nd = mknode(temp, $3.nd, $2.name);
		}
	}
}
| valor { strcpy($$.name, $1.name); sprintf($$.type, $1.type); $$.nd = $1.nd; }
;

operacao: ADICAO 
| SUBTRACAO 
| MULTIPLICACAO
| DIVISAO
;

relop: MENOR
| MAIOR
| MENOR_IGUAL
| MAIOR_IGUAL
| IGUAL
| DIFERENTE
;

valor: INTEIRO_LITERAL { strcpy($$.name, $1.name); sprintf($$.type, "inteiro"); add('C'); $$.nd = mknode(NULL, NULL, $1.name); }
| REAL_LITERAL { strcpy($$.name, $1.name); sprintf($$.type, "real"); add('C'); $$.nd = mknode(NULL, NULL, $1.name); } 
| CARACTERE_LITERAL { strcpy($$.name, $1.name); sprintf($$.type, "caracter"); add('C'); $$.nd = mknode(NULL, NULL, $1.name); } 
| STRING_LITERAL  { strcpy($$.name, $1.name); sprintf($$.type, "cadeia"); add('C'); $$.nd = mknode(NULL, NULL, $1.name); } 
| ID { strcpy($$.name, $1.name); char *id_type = get_type($1.name); sprintf($$.type, id_type); check_declaration($1.name); $$.nd = mknode(NULL, NULL, $1.name); } 
;


%%

int main() {
  	printf("\n\n");
	printf("========= ANÁLISE LÉXICA =========\n\n");

  	yyparse();

  	printf("\n\n");  
	printf("========= ANÁLISE SINTÁTICA =========\n\n");

	printf("\n%-20s%-20s%-20s%-10s\n", "Token", "Tipo de dado", "Tipo de token", "Linha");
    printf("_______________________________________________________________\n\n");
	int i = 0;
    for(int i = 0; i < count; i++) {
        printf("%-20s%-20s%-20s\t%d\n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no + 1);
    }
    
    for(int i = 0; i < count; i++) {
        free(symbol_table[i].id_name);
        free(symbol_table[i].type);
    }

	printf("\n\n");
	printf("Estrutura da Árvore Sintática Abstrata - AST Binária \n\n");
	print_preorder(head, 0);
	printf("\n\n\n\n");

	printf("\n\n");
	printf("========= ANÁLISE SEMÂNTICA =========\n\n");
	if(sem_errors>0) {
		printf("Análise semântica possui %d erros.\n", sem_errors);
		for(int i=0; i<sem_errors; i++){
			printf("\t - %s", errors[i]);
		}
	}
	else {
		printf("Analise semantica concluida.");
	}
	printf("\n\n");
}

int search(char *type) {
	int i;
	for(i=count-1; i>=0; i--) {
		if(strcmp(symbol_table[i].id_name, type)==0) {
			return -1;
			break;
		}
	}
	return 0;
}

void check_declaration(char *c) {
    q = search(c);
    if(!q) {
        sprintf(errors[sem_errors], "Linha %d: Variável \"%s\" não declarada!\n", countn+1, c);
		sem_errors++;
    }
}

int check_types(char *type1, char *type2){ //realização de conversão necessária entre tipos
	// declaration with no init
	if(!strcmp(type2, "null"))
		return -1;
	// both datatypes are same
	if(!strcmp(type1, type2))
		return 0;
	// both datatypes are different
	if(!strcmp(type1, "int") && !strcmp(type2, "float"))
		return 1;
	if(!strcmp(type1, "float") && !strcmp(type2, "int"))
		return 2;
	if(!strcmp(type1, "int") && !strcmp(type2, "char"))
		return 3;
	if(!strcmp(type1, "char") && !strcmp(type2, "int"))
		return 4;
	if(!strcmp(type1, "float") && !strcmp(type2, "char"))
		return 5;
	if(!strcmp(type1, "char") && !strcmp(type2, "float"))
		return 6;
}

char *get_type(char *var){ //retorna o tipo de dado associado a variável na tabela de símbolos
	for(int i=0; i<count; i++) {
		// Handle case of use before declaration
		if(!strcmp(symbol_table[i].id_name, var)) {
			return symbol_table[i].data_type;
		}
	}
}

void add(char c) { //adiciona as entradas à symbol table, sendo 'c' o identificador sendo processado
	if(c == 'V'){
		for(int i=0; i<10; i++){
			if(!strcmp(reserved[i], strdup(yytext))){
        		sprintf(errors[sem_errors], "Line %d: Variable name \"%s\" is a reserved keyword!\n", countn+1, yytext);
				sem_errors++;
				return;
			}
		}
	}
  q=search(yytext);
  if(!q) {
    if(c == 'H') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup(type);
			symbol_table[count].line_no=countn;
			symbol_table[count].type=strdup("Cabecalho");
			count++;
		}
		else if(c == 'K') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup("N/A");
			symbol_table[count].line_no=countn;
			symbol_table[count].type=strdup("Palavra-chave");
			count++;
		}
		else if(c == 'V') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup(type);
			symbol_table[count].line_no=countn;
			symbol_table[count].type=strdup("Variavel");
			count++;
		}
		else if(c == 'C') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup("literal");
			symbol_table[count].line_no=countn;
			symbol_table[count].type=strdup("Constante");
			count++;
		}
		else if(c == 'F') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup("");
			symbol_table[count].line_no=countn;
			symbol_table[count].type=strdup("Funcao");
			count++;
		}
	}

	else if(c == 'V' && q) {
        sprintf(errors[sem_errors], "Linha %d: Mais de uma declaração de \"%s\".\n", countn+1, yytext);
		sem_errors++;
    }
}

struct node* mknode(struct node *left, struct node *right, char *token) {	
	struct node *newnode = (struct node *)malloc(sizeof(struct node));
	char *newstr = (char *)malloc(strlen(token)+1);
	strcpy(newstr, token);
	newnode->left = left;
	newnode->right = right;
	newnode->token = newstr;
	return(newnode);
}

void printtree(struct node* tree) {
	print_preorder(tree, 0);
}

void print_preorder(struct node *tree, int level) {
    if (tree == NULL) {
        return;
    }
    for (int i = 0; i < level; i++) {
        printf("  ");
    }
    printf("%s\n", tree->token);
    
    //imprime o nó esquerdo
    print_preorder(tree->left, level + 1);
    
    //imprime o nó direito
    print_preorder(tree->right, level + 1);
}


void insert_type() {
	strcpy(type, yytext);
}

void yyerror(const char *s) {
    extern int yylineno;
    extern char *yytext;
    fprintf(stderr, "ERRO NA LINHA %d: %s.\n", yylineno, s);
	exit(1);
}
