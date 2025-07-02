# Exercício 2 | Evaluation Exercise

Arthur Vergaças Daher Martins | 12542672
Laura Scotelari | 12543436
Murillo Moraes Martins | 12701599

---

P1.c 
    Ao executar o programa múltiplas vezes verificamos que o endereço da função main carregada na RAM muda. Esse comportamento existe para evitar ataques do tipo ROP (Return-Oriented Programming) onde o atacante explora uma vulnerabilidade para controlar o ponteiro de retorno, dessa forma, é possível executar um código arbritrário utilizando instruções já presentes na memória do programa. 

P2.c
    Executando o programa com uma senha muito grande (excedendo 10 caracteres) resulta em um erro de Segmentation Fault (core dumped) e um comportamento inesperado, permitindo ao usuário obter acesso mesmo com uma senha incorreta. Isso ocorre quando uma senha maior do que o endereço alocado para user_key é inserida e sobrescreve o endereço de memória destinado à variável verified. Nesse caso, a variável é corrompida e pode apresentar um valor diferente de zero, permitindo acesso não autorizado.

    Uma forma de evitar esse problema sem utilizar stack protection é garantir que só será lida a quantidade correta de caracteres, evitando a corrupção da variável verified. Para atingir esse objetivo, podemos utilizar o scanf com limitação (scanf("%9s", user_key);) ou a função fgets. 

    Utilizando o scanf com limitação de entrada, foi possível garantir o funcionamento correto do programa mesmo sem o uso de stack protection.


