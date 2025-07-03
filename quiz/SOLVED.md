# Exercício 2 | Evaluation Exercise

Arthur Vergaças Daher Martins | 12542672
Laura Scotelari | 12543436
Murillo Moraes Martins | 12701599

---

`P1.c `
Ao executar o programa múltiplas vezes verificamos que o endereço da função main carregada na RAM muda. Esse comportamento existe para evitar ataques do tipo ROP (Return-Oriented Programming) onde o atacante explora uma vulnerabilidade para controlar o ponteiro de retorno, dessa forma, é possível executar um código arbritrário utilizando instruções já presentes na memória do programa. 

-----

`P2.c`
Executando o programa com uma senha muito grande (excedendo 10 caracteres) resulta em um erro de Segmentation Fault (core dumped) e um comportamento inesperado, permitindo ao usuário obter acesso mesmo com uma senha incorreta. Isso ocorre quando uma senha maior do que o endereço alocado para user_key é inserida e sobrescreve o endereço de memória destinado à variável verified. Nesse caso, a variável é corrompida e pode apresentar um valor diferente de zero, permitindo acesso não autorizado.

Uma forma de evitar esse problema sem utilizar stack protection é garantir que só será lida a quantidade correta de caracteres, evitando a corrupção da variável verified. Para atingir esse objetivo, podemos utilizar o scanf com limitação (scanf("%9s", user_key);) ou a função fgets. 

Utilizando o scanf com limitação de entrada, foi possível garantir o funcionamento correto do programa mesmo sem o uso de stack protection.

-----

`P3 a.` A função foo chama a função bar na seguinte linha:
    
    80491af:       e8 eb ff ff ff    call   804919f <bar>

Nela, podemos observar que o parâmetro é passado para a função bar utilizando a pilha. Primeiro, o valor a ser passado (armazenado em %eax) é empilhado com a instrução `push %eax`. Em seguida, a função é chamada com call. Esse processo segue a calling convention padrão do x86, definida pela ABI (Application Binary Interface) System V para Linux. Nessa convenção, os argumentos são passados da direita para a esquerda na pilha, e o valor de retorno é colocado no registrador %eax. A ABI também define quem é responsável por preservar quais registradores (caller vs callee saved), além da estrutura da pilha.

`b.` A última linha da função bar move o valor da variável local (onde foi feito o cálculo) para %eax. Como mencionado no item anterior, a convenção de chamada x86 determina que o valor de retorno deve ser colocado no registrador %eax, o qual é lido pela função chamadora (foo) após o call.

Esse comportamento não é exclusivo do Linux, mas sim do ABI usado em sistemas x86. O mesmo vale para sistemas Windows (com pequenas variações), desde que estejam seguindo a convenção de chamada padrão do compilador.

`c.` Essas instruções da função foo fazem parte do prologue e epilogue da função. O push %ebp salva o valor antigo do base pointer para preservar o contexto da função chamadora. Em seguida, mov %esp, %ebp estabelece um novo frame base para a função atual. Isso facilita o acesso a parâmetros e variáveis locais via deslocamentos fixos a partir de %ebp.

Por fim, a instrução leave restaura o ponteiro de pilha ao estado anterior da função, desfazendo o que foi feito no prologue.

Se essas instruções forem omitidas, o código ainda pode funcionar, especialmente em funções simples e curtas, desde que se use apenas %esp para acesso à pilha. No entanto, isso prejudica a legibilidade, a depuração (debug) e a consistência, além de poder causar problemas se a função tiver chamadas aninhadas ou alocação de variáveis locais.

`d.` Essas instruções fazem alocação de espaço na pilha para variáveis locais. Ao subtrair do %esp, o ponteiro de pilha é movido “para baixo”, reservando espaço que pode ser acessado via deslocamento negativo de %ebp.

Esse comportamento está diretamente ligado ao ABI x86, que define que a pilha cresce em direção aos endereços menores e que variáveis locais devem ser armazenadas nessa área. No caso da main, a linha possui um propósito diferente: essa instrução alinha a pilha em um múltiplo de 16 bytes, o que é uma exigência para garantir performance e compatibilidade com instruções SSE, chamadas de funções externas (como de bibliotecas) e convenções modernas de alinhamento. Não há alocação de variáveis locais diretamente nessa linha, ao contrário das funções foo e bar.