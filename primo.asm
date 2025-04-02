; ================================================
; Sección de datos inicializados
; ================================================
section .data
    msg_input    db 'Ingrese un numero: ', 0   ; Mensaje para solicitar entrada
    msg_primo    db ' es primo', 0xA, 0        ; Mensaje para números primos
    msg_no_primo db ' no es primo', 0xA, 0     ; Mensaje para no primos
    newline      db 10, 0                      ; Carácter de nueva línea

; ================================================
; Sección de datos no inicializados (buffers)
; ================================================
section .bss
    number_input   resb 12   ; Buffer para almacenar la entrada del usuario (como texto)
    number_output  resb 12   ; Buffer para almacenar números convertidos a texto
    number         resd 1    ; Variable para almacenar el número convertido a entero

; ================================================
; Sección de código
; ================================================
section .text
global _start

; ================================================
; PUNTO DE ENTRADA DEL PROGRAMA
; ================================================
_start:
    ; ----- Mostrar mensaje solicitando número -----
    mov rax, 1              ; Código de syscall para escribir (sys_write)
    mov rdi, 1              ; Descriptor de archivo para stdout
    mov rsi, msg_input      ; Puntero al mensaje a imprimir
    mov rdx, 18             ; Longitud del mensaje
    syscall                 ; Llamar al sistema operativo

    ; ----- Leer entrada del usuario -----
    mov rax, 0              ; Código de syscall para leer (sys_read)
    mov rdi, 0              ; Descriptor de archivo para stdin
    mov rsi, number_input   ; Buffer donde se almacenará la entrada
    mov rdx, 12             ; Máximo número de bytes a leer
    syscall                 ; Llamar al sistema operativo

    ; ----- Convertir entrada a número -----
    mov rsi, number_input   ; Puntero al buffer de entrada
    call stoi               ; Llamar a la función de conversión string a entero
    mov [number], eax       ; Almacenar el resultado en la variable 'number'

    ; ----- Verificar si es primo -----
    call es_primo           ; Llamar a la función de verificación
    test eax, eax           ; Verificar el resultado (1=primo, 0=no primo)
    jz .no_primo            ; Saltar si no es primo

    ; ----- Mostrar resultado (primo) -----
    mov eax, [number]       ; Cargar el número a imprimir
    call print_num          ; Llamar a función para imprimir números
    mov rsi, msg_primo      ; Cargar mensaje "es primo"
    call print_str          ; Imprimir mensaje
    jmp .exit               ; Saltar al final del programa

.no_primo:
    ; ----- Mostrar resultado (no primo) -----
    mov eax, [number]       ; Cargar el número a imprimir
    call print_num          ; Llamar a función para imprimir números
    mov rsi, msg_no_primo   ; Cargar mensaje "no es primo"
    call print_str          ; Imprimir mensaje

.exit:
    ; ----- Terminar programa -----
    mov rax, 60             ; Código de syscall para exit
    xor rdi, rdi            ; Código de retorno 0 (éxito)
    syscall                 ; Llamar al sistema operativo

; ================================================
; FUNCIÓN: es_primo
; Verifica si el número en [number] es primo
; Retorno: EAX = 1 (primo), 0 (no primo)
; ================================================
es_primo:
    mov eax, [number]       ; Cargar el número a verificar
    cmp eax, 1              ; Comparar con 1
    jle .no_primo           ; Si es <= 1, no es primo

    mov ecx, 2              ; Inicializar divisor en 2

.loop:
    mov eax, [number]       ; Cargar número original
    cmp ecx, eax            ; Comparar divisor con número
    jge .si_primo           ; Si divisor >= número, es primo

    xor edx, edx            ; Limpiar EDX para división
    div ecx                 ; Dividir EAX/ECX (resultado en EAX, residuo en EDX)
    test edx, edx           ; Verificar residuo
    jz .no_primo            ; Si residuo = 0, no es primo

    inc ecx                 ; Incrementar divisor
    jmp .loop               ; Repetir bucle

.si_primo:
    mov eax, 1              ; Retornar 1 (primo)
    ret

.no_primo:
    xor eax, eax            ; Retornar 0 (no primo)
    ret

; ================================================
; FUNCIÓN: print_str
; Imprime una cadena terminada en NULL
; Entrada: RSI = puntero a la cadena
; ================================================
print_str:
    push rcx                ; Guardar registros que se modificarán
    push rdx
    mov rcx, rsi            ; Guardar puntero original

.calc_len:
    cmp byte [rsi], 0       ; Verificar si llegamos al NULL terminador
    je .print               ; Si es NULL, terminar cálculo
    inc rsi                 ; Avanzar al siguiente carácter
    jmp .calc_len           ; Continuar bucle

.print:
    sub rsi, rcx            ; Calcular longitud (final - inicio)
    mov rdx, rsi            ; Longitud en RDX
    mov rsi, rcx            ; Restaurar puntero original
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    syscall                 ; Llamar al sistema

    pop rdx                 ; Restaurar registros
    pop rcx
    ret

; ================================================
; FUNCIÓN: print_num
; Imprime un número entero
; Entrada: EAX = número a imprimir
; ================================================
print_num:
    push rdi                ; Guardar RDI
    mov rdi, number_output  ; Usar buffer de salida
    call itos               ; Convertir número a string
    mov rsi, number_output  ; Puntero al string resultante
    call print_str          ; Imprimir el string
    pop rdi                 ; Restaurar RDI
    ret

; ================================================
; FUNCIÓN: stoi (String to Integer)
; Convierte string ASCII a entero
; Entrada: RSI = puntero al string
; Salida: EAX = número convertido
; ================================================
stoi:
    xor eax, eax            ; Limpiar acumulador
    xor rcx, rcx            ; Contador de posición

.convert:
    movzx edx, byte [rsi+rcx] ; Leer siguiente byte
    cmp dl, 0xA             ; ¿Es salto de línea?
    je .done                ; Terminar si es salto
    cmp dl, '0'             ; ¿Es menor que '0'?
    jb .done
    cmp dl, '9'             ; ¿Es mayor que '9'?
    ja .done
    sub dl, '0'             ; Convertir ASCII a valor numérico
    imul eax, 10            ; Multiplicar acumulador por 10
    add eax, edx            ; Sumar nuevo dígito
    inc rcx                 ; Avanzar al siguiente carácter
    jmp .convert            ; Repetir bucle

.done:
    ret

; ================================================
; FUNCIÓN: itos (Integer to String)
; Convierte entero a string ASCII
; Entrada: EAX = número, RDI = buffer de salida
; ================================================
itos:
    mov rbx, 10             ; Base 10 para conversión
    xor rcx, rcx            ; Contador de dígitos

    test eax, eax           ; ¿El número es cero?
    jnz .convert            ; Si no es cero, convertir

    ; Manejar caso especial para cero
    mov byte [rdi], '0'     ; Escribir '0'
    inc rdi                 ; Avanzar puntero
    mov byte [rdi], 0       ; NULL terminador
    ret

.convert:
    xor edx, edx            ; Limpiar EDX para división
    div ebx                 ; Dividir EAX/EBX (EBX=10)
    add dl, '0'             ; Convertir residuo a ASCII
    push rdx                ; Guardar dígito en pila
    inc rcx                 ; Incrementar contador de dígitos
    test eax, eax           ; ¿Hay más dígitos?
    jnz .convert            ; Si, continuar conversión

.reverse:
    pop rdx                 ; Recuperar dígito de la pila
    mov [rdi], dl           ; Almacenar en buffer
    inc rdi                 ; Avanzar puntero
    loop .reverse           ; Repetir para todos los dígitos

    mov byte [rdi], 0       ; NULL terminador
    ret