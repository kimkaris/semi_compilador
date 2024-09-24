%{
    #include "y.tab.h"
    int countn=0;

    void print_token(const char* token_name, const char* token_value) {
        printf("Token: %s\tValor: %s\n", token_name, token_value);
    }
%}

%option yylineno

alpha [a-zA-Z_]
digit [0-9]
inc_dec "++"|"--"

%%
"inclua biblioteca"[ \t]+[A-Z][a-zA-Z0-9_]*[ \t]*"--> "[a-z][a-zA-Z0-9_]* { print_token("INCLUA_BIBLIOTECA", yytext);  strcpy(yylval.nd_obj.name,(yytext)); return INCLUA_BIBLIOTECA; }
"programa"                      { print_token("PROGRAMA", yytext); strcpy(yylval.nd_obj.name,(yytext)); return PROGRAMA; }
"funcao inicio"                 { print_token("FUNCAO_INICIO", yytext); strcpy(yylval.nd_obj.name,(yytext)); return FUNCAO_INICIO; }
"funcao"                        { print_token("FUNCAO", yytext); strcpy(yylval.nd_obj.name,(yytext)); return FUNCAO; }
"escreva"                       { print_token("ESCREVA", yytext); strcpy(yylval.nd_obj.name,(yytext)); return ESCREVA; }
"leia"                          { print_token("LEIA", yytext); strcpy(yylval.nd_obj.name,(yytext)); return LEIA; }
"inteiro"                       { print_token("INTEIRO", yytext); strcpy(yylval.nd_obj.name,(yytext)); return INTEIRO; }
"real"                          { print_token("REAL", yytext); strcpy(yylval.nd_obj.name,(yytext)); return REAL; }
"caracter"                      { print_token("CARACTERE", yytext); strcpy(yylval.nd_obj.name,(yytext)); return CARACTERE; }
"cadeia"                        { print_token("STRING", yytext); strcpy(yylval.nd_obj.name,(yytext)); return STRING; }
"faca"                          { print_token("FACA", yytext); strcpy(yylval.nd_obj.name,(yytext)); return FACA; }
"enquanto"                      { print_token("ENQUANTO", yytext); strcpy(yylval.nd_obj.name,(yytext)); return ENQUANTO; }
"para"	                        { print_token("PARA", yytext); strcpy(yylval.nd_obj.name,(yytext)); return PARA; }
"se"	                        { print_token("SE", yytext); strcpy(yylval.nd_obj.name,(yytext)); return SE; }
"senao"	                        { print_token("SENAO", yytext); strcpy(yylval.nd_obj.name,(yytext)); return SENAO; }
[-]?{digit}+                    { print_token("INTEIRO_LITERAL", yytext); strcpy(yylval.nd_obj.name,(yytext)); return INTEIRO_LITERAL; }
[-]?{digit}+\.{digit}{1,6}      { print_token("REAL_LITERAL", yytext); strcpy(yylval.nd_obj.name,(yytext)); return REAL_LITERAL; }
{alpha}({alpha}|{digit})*       { print_token("ID", yytext); strcpy(yylval.nd_obj.name,(yytext)); return ID; }
{inc_dec}                       { print_token("INC_DEC", yytext); strcpy(yylval.nd_obj.name,(yytext)); return INC_DEC; }                 
"<="                            { print_token("MENOR_IGUAL", yytext); strcpy(yylval.nd_obj.name,(yytext)); return MENOR_IGUAL; }
">="                            { print_token("MAIOR_IGUAL", yytext); strcpy(yylval.nd_obj.name,(yytext)); return MAIOR_IGUAL; }
"=="                            { print_token("IGUAL", yytext); strcpy(yylval.nd_obj.name,(yytext)); return IGUAL; }
"!="                            { print_token("DIFERENTE", yytext); strcpy(yylval.nd_obj.name,(yytext)); return DIFERENTE; }
"<"                             { print_token("MENOR", yytext); strcpy(yylval.nd_obj.name,(yytext)); return MENOR; }
">"	                            { print_token("MAIOR", yytext); strcpy(yylval.nd_obj.name,(yytext)); return MAIOR; }
"+"                             { print_token("ADICAO", yytext); strcpy(yylval.nd_obj.name,(yytext)); return ADICAO; }
"-"                             { print_token("SUBTRACAO", yytext); strcpy(yylval.nd_obj.name,(yytext)); return SUBTRACAO; }
"/"                             { print_token("DIVISAO", yytext); strcpy(yylval.nd_obj.name,(yytext)); return DIVISAO; }
"*"                             { print_token("MULTIPLICACAO", yytext); strcpy(yylval.nd_obj.name,(yytext)); return MULTIPLICACAO; }
\/\/.*                          { ; }
\/\*(.*\n)*.*\*\/               { ; } 
[ \t]*                          { ; }
[\n]                            { countn++; }
.	                            { print_token("SIMBOLO", yytext); return *yytext; }
["].*["]                        { print_token("STRING_LITERAL", yytext); strcpy(yylval.nd_obj.name,(yytext)); return STRING_LITERAL; }
['].[']                         { print_token("CARACTERE_LITERAL", yytext); strcpy(yylval.nd_obj.name,(yytext)); return CARACTERE_LITERAL; }


%%

int yywrap() {
    return 1;
}