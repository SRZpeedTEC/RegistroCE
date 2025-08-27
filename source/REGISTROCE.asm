; Implementacion de RegistroCE.ASM
.MODEL SMALL
.STACK 256

.DATA

;--- CONSTANTES ---
NUM_MAX_ESTU EQU 15 ; se definen 15 alumnos como maximo
NOMBRE_LEN EQU 30; tamano maximo de char del nombre
NOTA_LEN EQU 9; tamano de char de la nota
tmpNota DB NOTA_LEN DUP(0)

;--- MSG DE MENU DE SISTEMA ---
msg_Titulo DB 13, 10, '--- Bienvenido a RegistroCE ---', 13, 10, '$' ; (CR->13) = volver a la linea, (LF->10) = saltar linea

;mensajes del Menu
msg_Menu_Acciones DB 13, 10, '- Menu de acciones -', '$'
msg_Ingresar_Calif DB 13, 10, '(1) Ingresar calificaciones (Maximo 15 estudiantes. Formato -Nombre Apellido1 Apellido 2 Nota-)', '$'
msg_Mostrar_Stats DB 13, 10, '(2) Mostrar estadisticas', '$'
msg_Buscar_Estud DB 13, 10, '(3) Buscar estudiantes por posicion', '$'
msg_Ordenar_Calid DB 13, 10, '(4) Ordenar calificaciones', '$'
msg_Salir DB 13, 10, '(5) Salir', '$'
msg_Opciones  DB 13,10, 'Ingrese una opcion (1-5): $'

;mensajes de error
msg_Error_Menu DB 13, 10, 'Se ha ingresado un valor fuera del rango. Por favor ingresar un valor entre 1-5', 13, 10, '$'

;mensajes de ingresar estudiante
msg_In_Nombre_Estud DB 13, 10, 'Ingrese el nombre del estudiante o ingrese 0 para salir al menu:', 13, 10, '$'
msg_In_Nota_Estud DB 13, 10, 'Ingrese la nota del estudiante:', 13, 10, '$'
msg_Max_Alcanzado DB 13,10,'Se alcanzo el maximo de 15 estudiantes.',13,10,'$'
msg_Nota_Inc DB 13,10,'Las notas solo pueden estar entre 0 y 100.',13,10,'$'
msg_Listado DB 13,10,'--- Estudiantes registrados ---',13,10,'$'



;mensajes de mostrar estadisticas
msg_Stats_Promedio DB 13, 10, 'Promedio:', '$'
msg_Stats_Nota_Max DB 13, 10, 'Nota Maxima:', '$'
msg_Stats_Nota_Min DB 13, 10, 'Nota Minima:', '$'
msg_Stats_Aprob DB 13, 10, 'Cantidad de estudiantes aprobados:', '$'
msg_Stats_Aprob_Porc DB 13, 10, 'Porcentaje aprobacion:', '$'
msg_Stats_Desaprob DB 13, 10, 'Cantidad de estudiantes desaprobados:', '$'
msg_Stats_Desaprob_Porc DB 13, 10, 'Porcentaje desaprobacion:', '$'

;mensajes de buscar estudiante por posicion
msg_Buscar_Idx DB 13, 10, 'Ingrese el valor de la posicion del estudiante que desea consultar:', 13, 10, '$'

;mensajes de ordenar calificaciones
msg_Ordenar_Asc_Desc DB 13, 10, 'Ingrese (1) si quiere ordenar ascendente o (2) descendente', 13, 10, '$'

;mensajes de salir programa
msg_End DB 13, 10, 'Usted ha salido del registro. El programa se cerro', 13, 10, '$'

; INPUTS Y MEMORIA ----> DOS line input buffers (AH=0Ah): [max][count][data]

buf_Contador    DB 3,0, 3 DUP(?)
buf_Nombre     DB NOMBRE_LEN,0, NOMBRE_LEN DUP(?)
bufNota    DB NOTA_LEN,0, NOTA_LEN DUP(?)

contador_Estud DB 0
idx_actual DB 0


nombres_Estud DB NUM_MAX_ESTU*NOMBRE_LEN  DUP(0)

NOMBRE_LEN_ARR  DB NUM_MAX_ESTU           DUP(0)  

notas      DB NUM_MAX_ESTU*NOTA_LEN DUP(0)      

NOTAS_LEN_ARR DB NUM_MAX_ESTU           DUP(0) 

; buffer para AH=0Ah: [max][count][data...]
; max=2 -> permitimos 1 caracter + CR
buf_Opcion   DB 2,0, 2 DUP(0)


.CODE
start:
    mov ax, @DATA
    mov ds, ax
    mov es, ax      ; <-- ES = DS para que movsb escriba en el mismo segmento
    cld             ; <-- asegura incrementos (DF=0) en las instrucciones de cadena

    ;titulo RegistroCE
    mov dx, OFFSET msg_Titulo ;buscar el offset del string
    mov ah, 09h ; buscar el '$' para terminar el string
    int 21h ; printear y terminar servicio

Menu_Principal:
    ; ------------------ MENÚ ------------------

    ; Imprimir menu de acciones
    mov dx, OFFSET msg_Menu_Acciones
    mov ah, 09h
    int 21h

    ; Opciones (1 a 5)
    mov dx, OFFSET msg_Ingresar_Calif   ; (1) Registrar/Ingresar calificaciones
    mov ah, 09h
    int 21h

    mov dx, OFFSET msg_Mostrar_Stats    ; (2) Mostrar estadisticas
    mov ah, 09h
    int 21h

    mov dx, OFFSET msg_Buscar_Estud     ; (3) Buscar estudiante por posicion
    mov ah, 09h
    int 21h

    mov dx, OFFSET msg_Ordenar_Calid    ; (4) Ordenar notas
    mov ah, 09h
    int 21h

    mov dx, OFFSET msg_Salir            ; (5) Salir/Cerrar el programa
    mov ah, 09h
    int 21h

    ; ------------------ LECTURA OPCIÓN VALIDADA ------------------
Inputs:
    mov dx, OFFSET msg_Opciones
    mov ah, 09h
    int 21h

    ; limpiar buffer 
    mov ah, 0Ch         ; flush/limpiar buffer
    mov al, 0Ah         ; input
    mov dx, OFFSET buf_Opcion
    int 21h             ; 


    ; se verifica si se ingresó al menos 1 carácter
    mov al, [buf_Opcion+1]
    cmp al, 1
    jb  Inputs

    ; primer char se guarda en bl
    mov bl, [buf_Opcion+2]

    ; muestra digito del usuario
    mov dl, bl
    mov ah, 02h
    int 21h
    mov dl, 13         
    mov ah, 02h
    int 21h
    mov dl, 10         
    mov ah, 02h
    int 21h

; ------------------ Jumps condicionales cortos (solucion jumps out of range)------------------
    cmp bl, '1'
    jne  _No1
    jmp  Opcion1
_No1:
    cmp bl, '2'
    jne  _No2
    jmp  Opcion2
_No2:
    cmp bl, '3'
    jne  _No3
    jmp  Opcion3
_No3:
    cmp bl, '4'
    jne  _No4
    jmp  Opcion4
_No4:
    cmp bl, '5'
    jne  _Error
    jmp  Opcion5

_Error:
    jmp  Opcion6

; ------------------ RUTAS DE OPCIÓN ------------------

; ------- Ingresar calificaciones -------
Opcion1:
    ; comprobar si el array esta lleno
    mov al, contador_Estud
    cmp al, NUM_MAX_ESTU
    jb  O1_PedirNombre
    ; si esta lleno, volver al menu
    mov dx, OFFSET msg_Max_Alcanzado
    mov ah, 09h
    int 21h
    jmp Menu_Principal

; ----------- Pedir NOMBRE -----------
O1_PedirNombre:
    mov dx, OFFSET msg_In_Nombre_Estud
    mov ah, 09h
    int 21h

    ; leer linea 
    mov ah, 0Ch
    mov al, 0Ah
    mov dx, OFFSET buf_Nombre
    int 21h

    ; se ingreso un char
    mov al, [buf_Nombre+1]
    cmp al, 1
    jb  O1_PedirNombre

    ; si primer char es '0', volver al menú
    mov al, [buf_Nombre+2]
    cmp al, '0'
    jne _NomOK
    jmp Menu_Principal
_NomOK:

    ; ---------- Calcular destino NOMBRE ----------
    mov al, contador_Estud    ; idx
    mov cl, al                ; CL = idx
    mov idx_actual, al        

    xor ah, ah                ; AX = idx
    mov bl, NOMBRE_LEN        ; Se guarda en bl el offset del largo del nombre
    mul bl                    ; AX = idx*30
    mov di, OFFSET nombres_Estud
    add di, ax                ; DI = &nombres_Estud[idx*30] preparado para recibir los bytes del nombre

    ; len_nombre = min(buf_Nombre[1], NOMBRE_LEN)
    mov al, [buf_Nombre+1]
    mov bl, NOMBRE_LEN
    cmp al, bl
    jbe  O1_LenNom_OK
    mov al, bl

O1_LenNom_OK:
    mov dl, al                ; DL=len_nombre

    ; NOMBRE_LEN_ARR[idx] = len_nombre
    mov bx, OFFSET NOMBRE_LEN_ARR 
    xor ax, ax ; AX = idx
    mov al, cl
    add bx, ax ; Encontrar la posicion en el array
    mov [bx], dl ; Guardar len en posicion bx

    ; Copiar nombre
    mov si, OFFSET buf_Nombre+2
    xor cx, cx
    mov cl, dl
    rep movsb ; Pasa CX bytes de DS:SI a ES:DI

    ; ----------- Pedir NOTA -----------
O1_PedirNota:
    mov dx, OFFSET msg_In_Nota_Estud
    mov ah, 09h
    int 21h

    ; leer línea en bufNota
    mov ah, 0Ch
    mov al, 0Ah
    mov dx, OFFSET bufNota
    int 21h

    ; se comprueba si se ingreso por lo menos un char
    mov al, [bufNota+1]
    cmp al, 1
    jb  O1_PedirNota

    ; -------------------------------------------------
    ; Formato nota 0<=nota<=100
    ; -------------------------------------------------
    mov dh, idx_actual           ; guardar idx en DH
    mov si, OFFSET bufNota+2    ; entrada
    mov di, OFFSET tmpNota       ; salida 

    ; Verificar si el valor es 100
    mov al, [si]
    cmp al, '1'
    jne  O1_Nota_Inf_100
    mov al, [si+1]
    cmp al, '0'
    jne  O1_Nota_Inf_100
    mov al, [si+2]
    cmp al, '0'
    jne  O1_Nota_Inf_100

    ; base = "100"
    mov byte ptr [di],   '1' ; puntero a [di] con '1'
    mov byte ptr [di+1], '0'
    mov byte ptr [di+2], '0'
    mov bx, 3                  ; próxima posición en tmp
    add si, 3
    jmp O1_CheckSiguiente

O1_Nota_Inf_100:
    ; primer dígito 
    lodsb ; LoadStringByte
    cmp al, '0'
    jb  _MalF1           
    cmp al, '9'
    ja  _MalF1
    mov [di], al

    ; segundo dígito 
    lodsb 
    cmp al, '0'
    jb  _MalF2
    cmp al, '9'
    ja  _MalF2
    mov [di+1], al

    mov bx, 2                  ; próxima posición en tmp
    jmp O1_CheckSiguiente           

_MalF1: jmp O1_Mala_Nota         
_MalF2: jmp O1_Mala_Nota

O1_CheckSiguiente:
    mov al, [si]
    cmp al, 13                 
    je  O1_Anadir_Punto_Ceros

    ; numero decimal '.'
    cmp al, '.'
    jne O1_Mala_Nota
    mov byte ptr [di+bx], '.'
    inc bx
    inc si

    ; copiar decimales 1..5
    xor cx, cx                 ; CX = dec_count
    
O1_Copiar_Deci:
    mov al, [si]
    cmp al, 13                 
    je  O1_Completar_Ceros
    cmp al, '0'
    jb  O1_Mala_Nota
    cmp al, '9'
    ja  O1_Mala_Nota
    cmp cx, 5
    jae O1_Mala_Nota             ; >5 decimales => inválido
    mov [di+bx], al
    inc bx
    inc si
    inc cx
    jmp short O1_Copiar_Deci

; no hubo punto: agrégalo y rellena 5 ceros
O1_Anadir_Punto_Ceros:
    mov byte ptr [di+bx], '.'
    inc bx
    mov cx, 5
O1_Anadir_Ceros:
    mov byte ptr [di+bx], '0'
    inc bx
    loop O1_Anadir_Ceros
    jmp short O1_Guardar_Nota

; hubo punto y algunos decimales: completar hasta 5
O1_Completar_Ceros:
    mov ax, 5
    sub ax, cx                 ; AX = faltantes (0..4)
    mov cx, ax
    jcxz O1_Guardar_Nota
O1_Anadir_Ceros2:
    mov byte ptr [di+bx], '0'
    inc bx
    loop O1_Anadir_Ceros2

O1_Guardar_Nota:
    ; BL tiene la longitud final de la nota
    mov dl, bl                 ; DL = longitud

    ; CX = longitud (para rep movsb)
    xor cx, cx
    mov cl, dl

    ; restaurar idx desde DH
    mov al, dh                 ; AL = idx
    xor ah, ah

    ; destino: &notas[idx * NOTA_LEN]
    mov bl, NOTA_LEN           ; stride = 9
    mul bl                     ; AX = idx*9
    mov di, OFFSET notas
    add di, ax

    ; guardar longitud en NOTAS_LEN_ARR[idx]
    mov bx, OFFSET NOTAS_LEN_ARR
    mov al, dh                 ; AL = idx otra vez
    xor ah, ah
    add bx, ax
    mov [bx], dl

    ; copiar tmpNota -> notas[idx] 
    mov si, OFFSET tmpNota
    rep movsb

    inc contador_Estud
    call MostrarEstudiantes
    jmp Menu_Principal
    
O1_Mala_Nota:
    ; repreguntar si es invalida
    mov dx, OFFSET msg_Nota_Inc
    mov ah, 09h
    int 21h
    jmp O1_PedirNota

; ------------------------------------------------------------
; MostrarEstudiantes: imprime
; ------------------------------------------------------------
MostrarEstudiantes PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov dx, OFFSET msg_Listado
    mov ah, 09h
    int 21h

    xor cx, cx
    mov cl, contador_Estud     ; CL = cantidad (8 bits)
    cmp cx, 0
    je  MS_Done

    xor si, si                 ; SI = idx

MS_Siguiente_Estud:
    ; ---- imprimir nombre ----
    ; DI = &nombres_Estud[idx * NOMBRE_LEN]
    mov ax, si
    mov bx, NOMBRE_LEN
    mul bx
    mov di, OFFSET nombres_Estud
    add di, ax

    ; CL = len(nombre)
    mov bx, OFFSET NOMBRE_LEN_ARR
    add bx, si
    mov cl, [bx]
    xor ch, ch

    mov dx, di

MS_Print_Nombre:
    jcxz MS_Siguiente_Nombre
    mov dl, [di]
    mov ah, 02h
    int 21h
    inc di
    dec cx
    jmp short MS_Print_Nombre

MS_Siguiente_Nombre:
    ; espacio
    mov dl, ' '
    mov ah, 02h
    int 21h

    ; ---- imprimir nota ----
    ; DI = &notas[idx * NOTA_LEN]
    mov ax, si
    mov bx, NOTA_LEN
    mul bx
    mov di, OFFSET notas
    add di, ax

    ; CL = len(nota)
    mov bx, OFFSET NOTAS_LEN_ARR
    add bx, si
    mov cl, [bx]
    xor ch, ch

    mov dx, di

MS_Print_Nota:
    jcxz MS_Nueva_Linea
    mov dl, [di]
    mov ah, 02h
    int 21h
    inc di
    dec cx
    jmp short MS_Print_Nota

MS_Nueva_Linea:
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10
    mov ah, 02h
    int 21h

    inc si

    ; quedan?  (contador_Estud - si)
    xor ax, ax
    mov al, contador_Estud
    sub ax, si
    mov cx, ax
    jcxz MS_Done
    jmp short MS_Siguiente_Estud

MS_Done:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
MostrarEstudiantes ENDP


; ------- Mostrar estadisticas -------
Opcion2:
    mov dx, OFFSET msg_Stats_Promedio
    mov ah, 09h
    int 21h
    mov dx, OFFSET msg_Stats_Aprob
    mov ah, 09h
    int 21h
    mov dx, OFFSET msg_Stats_Aprob_Porc
    mov ah, 09h
    int 21h
    mov dx, OFFSET msg_Stats_Desaprob
    mov ah, 09h
    int 21h
    mov dx, OFFSET msg_Stats_Desaprob_Porc
    mov ah, 09h
    int 21h

    jmp Menu_Principal


; ------- Buscar estudiante por idx -------
Opcion3:
    mov dx, OFFSET msg_Buscar_Idx
    mov ah, 09h
    int 21h
    jmp Menu_Principal


; ------- Ordenar calificaciones -------
Opcion4:
    mov dx, OFFSET msg_Ordenar_Asc_Desc
    mov ah, 09h
    int 21h
    jmp Menu_Principal


; ------- Terminar programa -------
Opcion5:
    mov dx, OFFSET msg_End
    mov ah, 09h
    int 21h
    jmp Fin_Programa


; ------- Manejo error en menu -------
Opcion6: 
    mov dx, OFFSET msg_Error_Menu
    mov ah, 09h
    int 21h
    jmp Inputs 

; ------------------ SALIDA ------------------
Fin_Programa:
    mov ax, 4C00h
    int 21h

END start