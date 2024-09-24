# compilador_portugol
Trabalho de Introdução a Compiladores realizado em C, para processar a linguagem Portugol, utilizando as ferramentas Lex e Yacc.
- Feito para usar as mesmas palavras-chave desse compilador: https://portugol.dev
- Utilizado como base esse repositório: https://github.com/AnjaneyaTripathi/c-compiler

Realiza:
- Análise léxica;
- Análise sintática;
- Análise semântica (em partes).

Execução:
- `lex lexer.l`  – cria o arquivo lex.yy.c.
- `parser -d -v parser.y`  – gera o arquivo y.tab.h, y.tab.c e y.output para a gramática do compilador.
- `gcc y.tab.c` – compila o arquivo do código y.tab.c, gerando o arquivo a.out
- `./a.out < input1.txt` – realiza as análises léxica, sintática e semântica do código-fonte contido no arquivo input1.txt.
