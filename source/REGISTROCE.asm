; Implementacion de RegistroCE.ASM
.MODEL SMALL
.STACK 256

.DATA

;--- CONSTANTES ---
NUM_MAX_ESTU EQU 15 ; se definen 15 alumnos como maximo
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
msg_Opciones  DB 13,10, 'Ingrese una opcion (1-5) y presione Enter: $'

;mensajes de error
msg_Error_Menu DB 13, 10, 'Se ha ingresado un valor fuera del rango. Por favor ingresar un valor entre 1-5', 13, 10, '$'

;mensajes de ingresar estudiante
msg_In_Nombre_Estud DB 13, 10, 'Ingrese el nombre del estudiante o ingrese 0 para salir al menu:', 13, 10, '$'
msg_In_Nota_Estud DB 13, 10, 'Ingrese la nota del estudiante:', 13, 10, '$'

;mensajes de mostrar estadisticas
msg_Stats_Promedio DB 13, 10, 'Promedio:', 13, 10, '$'
msg_Stats_Nota_Max DB 13, 10, 'Nota Maxima:', 13, 10, '$'
msg_Stats_Nota_Min DB 13, 10, 'Nota Minima:', 13, 10, '$'
msg_Stats_Aprob DB 13, 10, 'Cantidad de estudiantes aprobados:', 13, 10, '$'
msg_Stats_Aprob_Porc DB 13, 10, 'Porcentaje aprobacion:', 13, 10, '$'
msg_Stats_Desaprob DB 13, 10, 'Cantidad de estudiantes desaprobados:', 13, 10, '$'
msg_Stats_Desaprob_Porc DB 13, 10, 'Porcentaje desaprobacion:', 13, 10, '$'

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

; buffer para AH=0Ah (line input): [max][count][data...]
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

    ; limpiar buffer y leer UNA LÍNEA (espera Enter)
    mov ah, 0Ch         ; flush buffer
    mov al, 0Ah         ; line input
    mov dx, OFFSET buf_Opcion
    int 21h             ; buf[1]=count ; buf+2=primer char

    ; ¿ingresó al menos 1 carácter?
    mov al, [buf_Opcion+1]
    cmp al, 1
    jb  Inputs

    ; tomar el primer carácter y GUARDARLO en BL
    mov bl, [buf_Opcion+2]

    ; muestra digito del usuario
    mov dl, bl
    mov ah, 02h
    int 21h
    mov dl, 13          ; CR
    mov ah, 02h
    int 21h
    mov dl, 10          ; LF
    mov ah, 02h
    int 21h

    ; ------------------ DECISIÓN ------------------
    cmp bl, '1'
    je  Opcion1
    cmp bl, '2'
    je  Opcion2
    cmp bl, '3'
    je  Opcion3
    cmp bl, '4'
    je  Opcion4
    cmp bl, '5'
    je Opcion5

    ; si no es 1–5 → Opcion6
    jmp Opcion6  

; ------------------ RUTINAS DE OPCIÓN ------------------
Opcion1:
    mov dx, OFFSET msg_In_Nombre_Estud
    mov ah, 09h
    int 21h
    jmp Fin_Programa

Opcion2:
    mov dx, OFFSET msg_Mostrar_Stats
    mov ah, 09h
    int 21h
    jmp Fin_Programa

Opcion3:
    mov dx, OFFSET msg_Buscar_Estud
    mov ah, 09h
    int 21h
    jmp Fin_Programa

Opcion4:
    mov dx, OFFSET msg_Ordenar_Calid
    mov ah, 09h
    int 21h
    jmp Fin_Programa

Opcion5:
    mov dx, OFFSET msg_End
    mov ah, 09h
    int 21h
    jmp Fin_Programa

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