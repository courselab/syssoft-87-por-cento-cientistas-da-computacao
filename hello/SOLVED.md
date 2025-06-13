# Exercício 1 | Hello World

Arthur Vergaças Daher Martins | 12542672
Laura Scotelari | 12543436
Murillo Moraes Martins | 12701599

---

Para esta atividade, foi implementada a função `sleep`, que realiza uma pausa (delay) no programa por um número de segundos informado como parâmetro. A pausa é realizada utilizando o serviço `0x86` da interrupção `15h`, disponibilizada pela BIOS.

O serviço `0x86` espera que a duração da pausa seja informada nos registradores `%cx:%dx`, em microsegundos. Como o valor de entrada (em segundos) pode ser maior que o limite de 16 bits, é feita uma conversão escalonada:

1. O valor em segundos (armazenado em `%cx`) é movido para `%bx`.

2. `%bx` é multiplicado por 1000 para converter de segundos para milissegundos.

3. O resultado, em `%ax`, é novamente multiplicado por 1000 para obter o valor em microsegundos.

4. Como a instrução mul armazena o resultado em `%dx:%ax`, o valor é reorganizado para `%cx:%dx` como esperado pela BIOS.

5. O registrador `%ah` é configurado com o valor `0x86`, e a interrupção `15h` é chamada.

Após a execução da interrupção, o programa continua normalmente.
