; io.asm - Biblioteca de funciones auxiliares para programas en ensamblador x86
; Convención: Preserva los registros EBX, ESI, EDI, EBP (los demás pueden modificarse)
section .data
    newline     db  10, 0

section .bss
    number_input   resb 12    
    number_output  resb 12

section .text

; ----------------------------------------------------------
; scan_num - Lee un número desde la entrada estándar
; Salida: EAX = número leído (entero)
; Modifica: EAX, EBX, ECX, EDX
; ----------------------------------------------------------
scan_num:    
    mov eax, 3                          ; Comenta
    mov ebx, 0                          ; Comenta
    mov ecx, number_input               ; Comenta
    mov edx, 12                         ; Comenta
    int 0x80                            

    mov esi, input_buffer               ; ESI apunta al buffer de entrada
    call stoi                           ; Comenta
    ret

; ----------------------------------------------------------
; print_str - Imprime una cadena terminada en NULL
; Entrada: ESI = dirección de la cadena a imprimir
; Modifica: EAX, EBX, ECX, EDX
; ----------------------------------------------------------
print_str:
    mov edx, 0                  ; Inicia el contador de longitu en 0
.calc_len:
    cmp byte [esi+ edx], 0      ; Compara con NULL terminardor
    je .print                   ; Comenta
    inc edx                     ; Comenta
    jmp .calc_len               
.print:
    mov eax, 4                  ; Comenta
    mov ebx, 1                  ; Comenta
    mov ecx, esi                ; Comenta
    int 0x80                    ; Comenta
    ret


;----------------------------------------------------------
; print_num - Imprime un número almacenado en un buffer, 
;             primero lo convierte en cadena
; Entrada: EAX = número a imprimir
; Modifica: EAX, EBX, ECX, EDX, EDI
; ----------------------------------------------------------
print_num:
    push edi                    ; Preserva EDI
    mov edi, number_output      ; Usa number_output para convertirlo en cadena

    call itos                   ; 
    mov esi, output_buffer      ; Comenta
    call print_str              ; Comenta
    pop edi                     ; Comenta
    ret


; ----------------------------------------------------------
; print_newline - Imprime un carácter de nueva línea
; Modifica: EAX, EBX, ECX, EDX
; ----------------------------------------------------------
print_newline:
    mov eax, 4                  ; Comenta
    mov ebx, 1                  ; Comenta
    mov ecx, newline            ; Comenta
    mov edx, 1                  ; Comenta
    int 0x80                    
    ret


; ----------------------------------------------------------
; stoi - Convierte una cadena ASCII a entero
; Entrada: ESI = dirección de la cadena
; Salida: EAX = número convertido
; Modifica: EAX, ECX, EDX
; ----------------------------------------------------------
stoi:
    xor eax, eax                        ; Limpia EAX (acumulador)
    xor ecx, ecx                        ; Limpia ECX (contador)
.convert:
    ; movz - Move with Zero Extend: Copia un valor pequeño en un registro grande rellenando con ceros
    movzx edx, byte [esi+ecx]           ; Lee siguiente caracter de la cadena
    cmp dl, 0x0A                        ; Comenta
    je ..convert_done                   ; Comenta
    cmp dl, '0'                         ; Comenta
    jb .convert_done                    ; Comenta
    cmp dl, '9'                         ; Comenta
    ja .convert_done                    ; Comenta
    sub dl, '0'                         ; Comenta
    imul eax, 10                        ; Comenta
    add eax, edx                        ; Comenta
    inc ecx                             ; Avanza al siguiente caracter
    jmp .convert                     
.convert_done:
    ret


; ----------------------------------------------------------
; itos - Convierte un entero a cadena ASCII
; Entrada: EAX = número a convertir
;          EDI = dirección del buffer de salida
; Modifica: EAX, EBX, ECX, EDX, EDI
; ----------------------------------------------------------
itos:
    mov ebx, 10                 ; Comenta
    xor ecx, ecx                ; Limpia el contador de dígitos

    test eax, eax               ; Comenta
    jnz .convertir              ; Comenta

    ; Caso especial para cero
    mov byte [edi], '0'         ; Almacena '0' en el buffer
    inc edi                     ; Avanza el apuntador
    mov byte [edi], 0           ; Agrega fin de cadena
    ret                        

.convert:
    xor edx, edx                ; Comenta
    div ebx                     ; Comenta
    add dl, '0'                 ; Comenta
    push dx                     ; Guarda el dígito en la pila
    inc ecx                     ; Comenta
    test eax, eax               ; Comenta
    jnz .convert                ; Comenta

    ; Para este ciclo es importante que el contador del ciclo este almacenado en ecx
.reverse:               
    pop dx                      ; Recupera el dígito en la pila
    mov [edi], dl               ; Almacena el dígito en el buffer
    inc edi                     ; Avanza el apuntador del buffer
    loop .reverse               ; Repite para todos los dígitos, decrementa automaticamente ecx

    mov byte [edi], 0           ; Agrega fin de cadena
    ret
