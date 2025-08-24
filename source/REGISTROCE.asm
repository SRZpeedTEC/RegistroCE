; Implementacion de RegistroCE.ASM
.MODEL SMALL
.STACK 256

.DATA

;--- CONSTANTES ---
NUM_MAX_ESTU EQU 16 ; se definen 15 alumnos como maximo
NOMBRE_LEN EQU 30; tamano maximo de char del nombre
NOTA_LEN EQU 3; tamano de char de la nota

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
bufGrade    DB NOTA_LEN,0, NOTA_LEN DUP(?)

contador_Estud DB 1

nombres_Estud   DB NUM_MAX_ESTU*NOMBRE_LEN  DUP(0)
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

; ------------------ Jumps condicionales cortos ------------------
    cmp bl, '1'
    jne  _Not1
    jmp  Opcion1
_Not1:
    cmp bl, '2'
    jne  _Not2
    jmp  Opcion2
_Not2:
    cmp bl, '3'
    jne  _Not3
    jmp  Opcion3
_Not3:
    cmp bl, '4'
    jne  _Not4
    jmp  Opcion4
_Not4:
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
    xor ah, ah                ; AX = idx
    mov bl, NOMBRE_LEN        ; 30
    mul bl                    ; AX = idx*30
    mov di, OFFSET nombres_Estud
    add di, ax                ; DI = &nombres_Estud[idx*30]

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
    xor ax, ax
    mov al, cl
    add bx, ax
    mov [bx], dl

    ; Copiar nombre
    mov si, OFFSET buf_Nombre+2
    xor cx, cx
    mov cl, dl
    rep movsb

    ; ----------- Pedir NOTA -----------
O1_PedirNota:
    mov dx, OFFSET msg_In_Nota_Estud
    mov ah, 09h
    int 21h

    mov ah, 0Ch
    mov al, 0Ah
    mov dx, OFFSET bufGrade
    int 21h

    mov al, [bufGrade+1]
    cmp al, 1
    jb  O1_PedirNota

    ; len_nota = min(bufGrade[1], NOTA_LEN)
    mov al, [bufGrade+1]
    mov bl, NOTA_LEN          ; 3
    cmp al, bl
    jbe  O1_LenNota_OK
    mov al, bl

O1_LenNota_OK:
    mov dl, al                ; DL=len_nota

    ; &notas[idx*3]
    mov al, cl                ; idx
    xor ah, ah
    mov bl, NOTA_LEN          ; 3
    mul bl                    ; AX=idx*3
    mov di, OFFSET notas
    add di, ax

    ; NOTAS_LEN_ARR[idx] = len_nota
    mov bx, OFFSET NOTAS_LEN_ARR
    xor ax, ax
    mov al, cl
    add bx, ax
    mov [bx], dl

    ; Copiar nota
    mov si, OFFSET bufGrade+2
    xor cx, cx
    mov cl, dl
    rep movsb

    ; incrementar contador_Estud +1
    inc contador_Estud

    ; volver al menú
    jmp Menu_Principal


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