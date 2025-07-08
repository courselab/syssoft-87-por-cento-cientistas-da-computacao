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

`e.` Podemos notar uma nova instrução na função `foo` logo após chamar `bar`:
    
    804919f:       e8 0e 00 00 00          call   80491b2 <bar>
    80491a4:       83 c4 10                add    $0x10,%esp
    80491a7:       0f be c0                movsbl %al,%eax

A instrução `movsbl`, que extende um byte representando um número com sinal para um inteiro de 32-bits com sinal, o compilador fez isso por agora a função `bar` retorna um `char` e a função `foo` espera receber um `int`, então, para evitar problemas na hora de retornar esse valor, o compilador transformou o resultado de `char` para `int` "estendendo" o valor de `char` armazenado no `al` para o registrador de 32-bits `eax`.

As declarações das funções antes da `main` são importantes pois elas que mostram para o compilador qual o tipo de retorno correto, caso elas não estivessem ali, o compilador assumiria que o retorno de `bar` é um `int`, então ele não teria inserido a instrução demonstrada acima, o que poderia levar a erros por isso ser comportamento não definido (ou *undefined behaviour*, como é mais conhecido).

-----

`P4 a.` Quando executamos os comandos `./p4-v1` e `./p4-v2` obtemos o mesmo resultado. Ao executar o comando `./p4-v3`, recebemos a seguinte mensagem:

    ./p4-v3: error while loading shared libraries: libp4.so: cannot open shared object file: No such file or directory

Por se tratar de uma biblioteca dinâmica local, na hora da execução precisamos indicar a localização dessa biblioteca, podemos fazer isso no momento da execução executando o comando da seguinte forma (nesse caso é necessário estar no diretório `quiz/`):

    LD_LIBRARY_PATH=. ./p4-v3

Isso indica para o loader que ele precisa buscar a biblioteca no diretório atual.

Mas podemos resolver isso também no momento em que compilamos o programa através da seguinte mudança no Makefile:

    p4-v3 : p4.o libp4.so
	    gcc -m32 $< -L. -lp4 -Wl,-rpath='$$ORIGIN' -o $@

Ao adicionarmos a flag `-Wl,-rpath='$$ORIGIN'` nós sinalizamos para o loader onde está o caminho de nossas bibliotecas (assim ele não só busca nos caminhos padrões, mas também neste que foi sinalizado). Precisamos adicionar `$$ORIGIN` pois ele sinaliza que a biblioteca está no mesmo lugar de origem do executável, para assim podermos executar `p4-v3` de fora do diretório `quiz/`.

`b.` Pegando o tamanho de cada programa usando o comando `size` temos:

    text	   data	    bss	    dec	    hex	filename
    1446	    304	      4	   1754	    6da	./p4-v1

    text	   data	    bss	    dec	    hex	filename
    1355	    304	      4	   1663	    67f	./p4-v2

    text	   data	    bss	    dec	    hex	filename
    1254	    320	      4	   1578	    62a	./p4-v3

Podemos ver que o programa com os objetos explícitos tem a maior `.text` por conter todas as definições (provavelmente contendo definições que não são utilizadas como por exemplo a função `bar()`).

Já o programa que utiliza a biblioteca estática possui uma sessão `.text` menor, muito provavelmente por uma otimização do linker de remover símbolos não utilizados (mas ainda sim a função `foo()` é copiada para o executável por se tratar de uma biblioteca estática), assim gerando um executável ligeiramente menor.

Por fim, o programa com a biblioteca dinâmica possui a menor sessão `.text` por não possuir definições da biblioteca (que será carregada pelo loader). Ele possui uma sessão `.data` ligeiramente maior provavelmente por possuir mais metadados para carregar a biblioteca dinâmica.

`c.` Ao utilizar o comando `nm` no `p4-v1`, podemos ver tanto o símbolo `foo` e `bar` aparecendo, ambos estão marcados como símbolos `T` (o que indica que eles estão presentes na sessão `.text`). Mostrando que a função `bar`, mesmo não sendo utilizada, foi carregada no executável.

Já utilizando o comando no `p4-v2`, é possível notar a ausência do símbolo `bar`, comprovando o que foi dito anteriormente sobre o linker ter excluído símbolos inutilizados no programa. Mesmo assim o símbolo `foo` ainda foi marcado como estando no `.text` por se tratar de uma biblioteca estática, então seu código está junto com o código do resto do programa.

Por fim, utilizando o comando no `p4-v3`, podemos notar, novamente, a ausência do `bar`, e agora, o símbolo `foo` está marcado com a letra `U`, o que representa que ele não está definido. Isso faz sentido pois, por se tratar de uma biblioteca dinâmica, o símbolo só será definido em tempo de execução.

`d.` O `p4-v1` e o `p4-v2` possuem a mesma informação quando se trata de informações de bibliotecas. Ambos somente contém a dependência da `libc` por utilizarem a função `printf` na execução.

Já no `p3-v3`, vemos dois novos campos, o primeiro é uma declaração do uso da nossa biblioteca dinâmica `libp4.so`:
    
    0x00000001 (NEEDED)                     Shared library: [libp4.so]

E o segundo novo campo é a declaração do caminho da nossa biblioteca:

    0x0000001d (RUNPATH)                    Library runpath: [$ORIGIN]

Isso vem da nossa declaração no Makefile do item `a`, indicando para nosso loader que devemos adicionar ao caminho de bibliotecas o mesmo caminho do executável.

Quando o programa `p4-v3` é carregado, o kernel utiliza o linker dinâmico para realizar as ações de ler as bibliotecas necessárias (marcadas como `NEEDED`), adicionar o `ORIGIN` como `RUNPATH` para encontrar nossas bibliotecas dinâmicas, mapear as bibliotecas necessárias para a memória (`libc` e `libp4`) e resolver os símbolos não definidos (no caso do `p4-v3` ele irá definir o `foo` que estava como não definido, como apresentado no item `c`). Assim ele pode executar nosso programa com todos os símbolos definidos e prontos para execução.

`e. a)` Quando se trata de um programa instalado em outros hosts, é preferível o uso de bibliotecas estáticas, pois assim temos uma biblioteca já contida direto no executável, ao contrário de bibliotecas dinâmicas que, para instalar a aplicação em outro host, precisamos garantir que essas bibliotecas também estejam instaladas e configuradas nos caminhos corretos para o linker dinâmico procurá-las.

`b)` Quando a biblioteca é atualizada regularmente, é preferível o uso de bibliotecas dinâmicas. Pelo motivo de, caso fosse usada uma biblioteca estática, sempre que atualizarmos a biblioteca, seremos obrigados à refazer a build do programa que utiliza a biblioteca (pois esta é copiada para o código do executável). Já com bibliotecas dinâmicas, só precisamos atualizar código da biblioteca em si, que na hora de executável esse código atualizado será linkado com o executável.

`c)` Caso a biblioteca seja compartilhada por mais de um programa, seria melhor utilizar uma biblioteca dinâmica. O uso de uma biblioteca estática nesse caso implicaria em duplicações desse código na memória (pois o código da biblioteca é copiado para o executável). Já com uma biblioteca dinâmica, esse código existe em somente uma região da memória que é compartilhada pelos programas que a utilizam.

-----

`dyn a.` Uma biblioteca estática é uma coleção de objetos que, durante a fase de compilação/linking, tem o código necessário para o executável copiado para dentro desse executável. A maior vantagem de se ter uma biblioteca estática é o fato de não haver dependências externas para executar o seu programa (pois todo o código necessário está dentro do programa em si) e o fato dele ter um tempo de inicialização mais rápido (pois não é necessário processar algum símbolo não definido). A desvantagem desse tipo de biblioteca é que ela não só gera binários maiores (pois todo o código precisa ser copiado para o executável), mas também gera um gasto maior de memória caso vários programas utilizem essa biblioteca (pois cada um terá uma cópia do mesmo código), além de também ser mais difícil atualizar a biblioteca pois, caso ela tenha seu código alterado, é necessário recompilar todos os programas que a utilizam para realizar as alterações.

`b.` Já bibliotecas dinâmicas com código realocável são bibliotecas em que o código delas assume um endereço fixo de memória para carregamento (ou seja, caso ela seja carregada em um endereço de memória diferente do que ela espera, o linker dinâmico necessita realizar uma realocação de todos os endereços). Ela possui a vantagem de gerar binários menores que a opção estática (pois o código não é copiado para o executável), além de ser mais rápida quando comparada com outras alternativas se utilizada somente por um programa (ou seja, se ele for somente um objeto compartilhavel de uso único). Porém, ela possui a disvantagem de ter realocações caras (pois o processo de transformar todos os endereços pré-computados da biblioteca em endereços novos na memória é bem caro), além de ter a possibilidade de gastar memória caso essa bibliteca seja utilizada por mais de um programa ao mesmo tempo (é possível que o linker dinâmico aloque um local para essa biblioteca para um programa e aloque outro local para essa mesma lib em outro programa).

`c.` Por fim temos a biblioteca dinâmica com PIC, essa opção é similar à anterior (o código não é copiado no executável), mas com a mudança que ele evita endereços de memória hardcodados, ao invés disso, todos os endereços são computados de forma relativa à localização atual da biblioteca da memória. A vantagem disso é que esse tipo de biblioteca permite que o código dela seja carregado em qualquer endereço sem realocação no momento de execução, além de também permitir que essa memória seja compartilhada por diversos processos (o que pode aumentar o tempo de inicialização de uma aplicação por ela não precisar carregar a biblioteca na memória novamente, e também salva espaço por não ser código duplicado na RAM). A desvantagem é principalmente na geração de código, pois necessita que o compilador tenha uma implementação que permita o uso de PIC (o que, se feito de forma descuidada, pode gerar diversos problemas).