; Implementacion de RegistroCE.ASM
.MODEL SMALL
.STACK 256

.DATA

;--- CONSTANTES ---
NUM_MAX_ESTU EQU 15 ; se definen 15 alumnos como maximo
NOMBRE_LEN EQU 30; tamano maximo de char del nombre
NOTA_LEN EQU 9; tamano de char de la nota
tmpNota DB NOTA_LEN DUP(0)

;temporales para hacer swap en el bubblesort
tmpNombre DB NOMBRE_LEN DUP(0)
tmpNotaTxt DB NOTA_LEN DUP(0)

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
msg_Error_Indice DB 13, 10, 'Se ha ingresado un valor fuera del rango. No existe un estudiante con ese indice', 13, 10, '$'


;mensajes de ingresar estudiante
msg_In_Nombre_Estud DB 13, 10, 'Ingrese el nombre del estudiante o ingrese 0 para salir al menu:', 13, 10, '$'
msg_In_Nota_Estud DB 13, 10, 'Ingrese la nota del estudiante:', 13, 10, '$'
msg_Max_Alcanzado DB 13,10,'Se alcanzo el maximo de 15 estudiantes.',13,10,'$'
msg_Nota_Inc DB 13,10,'Las notas solo pueden estar entre 0 y 100.',13,10,'$'
msg_Listado DB 13,10,'--- Estudiantes registrados ---',13,10,'$'



;mensajes de mostrar estadisticas
msg_NoEstudiantes DB 13, 10, 'No hay estudiantes registrados', 13, 10,'$'
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


; --- mensaje minimo ordenamiento ---
msg_No_Suf_Orden DB 13,10,'No hay suficientes estudiantes para ordenar (se requieren al menos 2).',13,10,'$'

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


; ----------------- VARIABLES PARA ESTADISTICAS ----------------------------

; PROMEDIO

notas_val_lo DW NUM_MAX_ESTU DUP(0) ; Arreglo para guardar los numeros flotantes en formato entero 
notas_val_hi DW NUM_MAX_ESTU DUP(0)   

sum_notas_lo DW 0 
sum_notas_hi DW 0

promedio_lo DW 0
promedio_hi DW 0  


; MAX Y MIN

max_lo DW 0
max_hi DW 0

min_lo DW 0
min_hi DW 0

; APROBADOS Y DESAPROBADOS

APROB_HI   EQU 006Ah ; Valor a comparar
APROB_LO   EQU 0CFC0h

aprob_cnt  DB 0
desap_cnt  DB 0


digits_buf DB 12 DUP(0)   ; buffer temporal para imprimir 

; buffer para AH=0Ah: [max][count][data...]
; max=2 -> permitimos 1 caracter + CR
buf_Opcion   DB 2,0, 2 DUP(0)  


; buffer para leer opcion de ordenamiento
buf_Orden DB 2,0, 2 DUP(0)

; 0 = ascendente, 1 = descendente
orden_modo DB 0



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
    mov al, [si]
    cmp al, '.'
    je _MalF1
    jmp O1_Anadir_Punto_Ceros

O1_Nota_Inf_100:
    ; primer dígito 
    lodsb ; LoadStringByte
    cmp al, '0'
    jb  _MalF1           
    cmp al, '9'
    ja  _MalF1
    mov [di], al

    mov al, [si]            ; mirar SIN consumir
    cmp al, '.'             
    je  O1_ConUnDigito      ; ej: 9.xxx
    cmp al, 13              
    je  O1_ConUnDigito      ; ej: 9<Enter> → 9.00000

    ; aquí esperamos segundo dígito (caso 10..99)
    lodsb                   ; consumir 2º carácter
    cmp al, '0'
    jb  _MalF2
    cmp al, '9'
    ja  _MalF2
    mov [di+1], al          ; guarda 2º dígito
    mov bx, 2               ; longitud parcial: 2
    jmp O1_CheckSiguiente

O1_ConUnDigito:
    mov bx, 1               ; longitud parcial: 1 (solo 1 dígito)
    jmp O1_CheckSiguiente          

_MalF1: jmp O1_Mala_Nota         
_MalF2: jmp O1_Mala_Nota

O1_CheckSiguiente:
    mov al, [si]
    cmp al, 13                 
    je  O1_Anadir_Punto_Ceros

    ; numero decimal '.'
    cmp al, '.'
    jne _MalF2
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
    jb  _MalF1
    cmp al, '9'
    ja  _MalF1
    cmp cx, 5
    jae _MalF1             ; >5 decimales => inválido
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
    
    mov bp, ax ; BP = idx guardamos idx para el futuro
    shl bp, 1 ; Contemplamos offset de los DWORD (Ocupan 2 espacios de memoria cada parte low y high) 
    
    push ds
    pop  es

    ; copiar tmpNota -> notas[idx] 
    mov si, OFFSET tmpNota
    rep movsb
    
        
    mov si, OFFSET tmpNota     ; SI = base
    xor ax, ax                 ; AX = 0
    mov al, dl                 ; AL = len (extiende a AX)
    add si, ax                 ; SI = &tmpNota[len]
    mov byte ptr [si], 0       ; tmpNota[len] = 0
    
    mov si, OFFSET tmpNota     
    call ParseNota_5dec     ; DX:AX = valor entero  
          
    ; Guardar LO
    mov  bx, OFFSET notas_val_lo
    add  bx, bp
    mov  [bx], ax

    ; Guardar HI
    mov  bx, OFFSET notas_val_hi
    add  bx, bp
    mov  [bx], dx            ; HI (DX)  
                     
    call UpdateAprobDesap ; Actualizamos aprob y desap
    call UpdateMinMax ; Actualizamos Max y Min
    
                      
    inc contador_Estud
    call MostrarEstudiantes
    jmp Menu_Principal 
    
    
    
  
ParseNota_5dec PROC NEAR
    push bx
    push si

    xor dx, dx          ; DX:AX = 0
    xor ax, ax

PN5_NextChar:
    mov bl, [si]
    cmp bl, 13          ; por si llegara CR 
    je  PN5_Done
    cmp bl, 0
    je  PN5_Done
    inc si

    cmp bl, '.'         ; omitir el punto
    je  PN5_NextChar

    ; bl debe ser '0'..'9' 
    sub bl, '0'         ; bl = d�gito (0..9)
    xor bh, bh

    ; val = val*10 + bl
    call DWordMul10 
       
    
    add ax, bx          ; AX += d�gito
    adc dx, 0           ; acarreo a DX si hay overflow de AX

    jmp short PN5_NextChar

PN5_Done:
    pop si
    pop bx
    ret   
    
ParseNota_5dec ENDP 




    
    
DWordMul10 PROC NEAR 
    
    ; usa: AX,BX,CX,DX
    push bx
    push cx

    ; temp = val<<1
    mov bx, ax
    mov cx, dx
    shl ax, 1
    rcl dx, 1            ; DX:AX = num*2  con xchg intercambiamos valores
    xchg bx, ax          ; BX = low*2, AX = original low
    xchg cx, dx          ; CX = high*2, DX = original high

     
    shl ax, 1            ; Se desplaza un bit a la izquierda, esto equivale a hacer num*2
    rcl dx, 1            ; Se va un bit de acarreo y lo obtenemos en dx por medio de rlc 
    shl ax, 1            
    rcl dx, 1            ;  num*2*2 = num*4
    shl ax, 1
    rcl dx, 1            ;  num*2*2*2 = num*8

    ; val = (CX:BX) + (DX:AX)  = num*8 + num*2 = num*10
    add ax, bx
    adc dx, cx
    
    ; De esta manera se crea un numero a traves de potencias

    pop cx
    pop bx
    ret
DWordMul10 ENDP  


    
    
  
    
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
    mov cl, contador_Estud ; CL = cantidad (8 bits)
    cmp cx, 0
    je  MS_Done

    xor si, si ; SI = idx

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

    ; quedan estudiantes?
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

_NoHayEstudiantes:   ; caso base de lista vacia

    ; si no hay estudiantes registrados, se imprime un mensaje de error
    mov dx, OFFSET msg_NoEstudiantes
    mov ah, 09h
    int 21h
    xor dx, dx
    xor ax, ax
    
    
    pop cx
    jmp Menu_Principal



Opcion2:   
    push cx
    xor cx, cx
    call SumNotas32
    mov  cl, contador_Estud
    jcxz _NoHayEstudiantes
    call Div32by16U      

    ; guardar promedio mientras imprimes el texto
    push dx
    push ax

    ; --- imprimir "Promedio: " ---
    mov dx, OFFSET msg_Stats_Promedio
    mov ah, 09h
    int 21h

    ; recuperar promedio y ahora sí formatear
    pop ax
    pop dx
    call PrintNumber_DXAX

    ; Se guarda el promedio
    mov promedio_lo, ax
    mov promedio_hi, dx
    
    ; Nota Maxima:
    mov dx, OFFSET msg_Stats_Nota_Max
    mov ah, 09h
    int 21h
    mov ax, max_lo
    mov dx, max_hi
    call PrintNumber_DXAX
    

    ; Nota Minima:
    mov dx, OFFSET msg_Stats_Nota_Min
    mov ah, 09h
    int 21h
    mov ax, min_lo
    mov dx, min_hi
    call PrintNumber_DXAX
   
    ; Cantidad de aprobados
    mov dx, OFFSET msg_Stats_Aprob
    mov ah, 09h
    int 21h
    mov al, aprob_cnt
    call PrintCountFromAL


    ; % de aprobacion
    mov dx, OFFSET msg_Stats_Aprob_Porc
    mov ah, 09h
    int 21h
    mov cl, contador_Estud ; total en CL/CX
    mov al, aprob_cnt
    call PercentFromCounts ; DX:AX = porcentaje x100000
    call PrintNumber_DXAX
    
    

    ; Cantidad de desaprobados
    mov dx, OFFSET msg_Stats_Desaprob
    mov ah, 09h
    int 21h
    mov al, desap_cnt
    call PrintCountFromAL


    ; % de desaprobacion
    mov dx, OFFSET msg_Stats_Desaprob_Porc
    mov ah, 09h
    int 21h
    mov cl, contador_Estud
    mov al, desap_cnt
    call PercentFromCounts
    call PrintNumber_DXAX 
    
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10
    mov ah, 02h
    int 21h 
    

    pop cx
    jmp Menu_Principal
    
    
    
    
; -------------------- FUNCIONES ESTADISTICAS ------------------------------

SumNotas32 PROC NEAR  
    
    push bx
    push cx
    push si
    push di  
    
    ; acumulador = 0
    
    xor ax, ax ; Limpiamos AX:DX
    xor dx, dx
    mov sum_notas_lo, ax  
    mov sum_notas_hi, dx    
    
    ; CX = Cantidad de estudiantes
    
    xor cx, cx
    mov cl, contador_Estud ; Cargamos el contador
    jcxz SumNotasDone
    
    mov si, OFFSET notas_val_lo
    mov di, OFFSET notas_val_hi
                 
SumNotas_Loop:  

    ; Se carga el acumulador actual   
    mov ax, sum_notas_lo
    mov dx, sum_notas_hi
    
    ; AX:DX += valor[idx]
    
    add ax, [si]
    adc dx, [di]
    
    mov sum_notas_lo, ax
    mov sum_notas_hi, dx
    
    add si, 2
    add di, 2
    loop SumNotas_Loop 
    
    
SumNotasDone:
    ; Retorna en DX:AX  
    mov ax, sum_notas_lo
    mov dx, sum_notas_hi

    pop di
    pop si
    pop cx
    pop bx
    ret    
    
SumNotas32 ENDP 
   

; Si CX = 0, usa 1 para evitar #DE (divide error).
Div32by16U PROC NEAR
    push bx
    push bp

    mov  bp, cx              ; 
    or   bp, bp              ; divisor? 0
    jnz  short D32_do        ; 
    mov  bp, 1               ; si divisor=0 usar divisor=1

D32_do:
    mov  bx, ax              ; 

    ; dividir la parte alta (DX) entre BP
    mov  ax, dx
    xor  dx, dx
    div  bp                  ; AX = cociente alto, DX = DX
    mov  cx, ax              ; CX = cociente alto

    ; dividir la parte baja usando DX
    mov  ax, bx              ; recuperar parte baja
    ; DX ya contiene DX
    div  bp                  ; AX = cociente bajo, DX = residuo final

    ; armar el resultado: DX = cociente alto, AX = cociente bajo
    xchg dx, cx              ; DX = c_hi, CX = resto

    pop  bp
    pop  bx
    ret
Div32by16U ENDP
 
 
   

UpdateMinMax PROC NEAR ; Comparamos valor de entrada con los actuales almacenados
    push bx

    ; Caso: Primera nota
    mov  bl, contador_Estud
    cmp  bl, 0
    jne  nota_not_first
    
    ; inicializamos ambas variables con la primera nota
    mov  max_lo, ax
    mov  max_hi, dx
    mov  min_lo, ax
    mov  min_hi, dx
    jmp  nota_done

nota_not_first:
    
    mov  bx, max_hi
    cmp  dx, bx ; Comparamos partes alta
    ja   nota_set_max ; Es mayor al anterior
    jb   nota_check_min ; Comprobamos si es menor que el minimo
    
    ; si hi iguales entonces se compara low
    mov  bx, max_lo
    cmp  ax, bx
    jbe  nota_check_min 
    
nota_set_max:
    mov  max_lo, ax
    mov  max_hi, dx

nota_check_min:
    
    mov  bx, min_hi ; Misma logica anterior
    cmp  dx, bx
    jb   nota_set_min          
    ja   nota_done             
    
    mov  bx, min_lo
    cmp  ax, bx
    jae  nota_done 
    
nota_set_min:
    mov  min_lo, ax
    mov  min_hi, dx

nota_done:
    pop  bx
    ret
UpdateMinMax ENDP 


UpdateAprobDesap PROC NEAR
    push bx

    ; comparamos DX:AX (nuestro numero ingresado con 7000000)
    mov  bx, APROB_HI
    cmp  dx, bx ; Comparamos parte alta
    ja   _aprob                 
    jb   _desap                 
    ; hi iguales comparamos parte baja
    mov  bx, APROB_LO
    cmp  ax, bx
    jae  _aprob
         
_desap:
    inc  desap_cnt
    jmp  short _fin 
    
_aprob:
    inc  aprob_cnt 
    
_fin:
    pop  bx
    ret        
    
UpdateAprobDesap ENDP 

  
; Funcion que retorna porcentaje
PercentFromCounts PROC NEAR
    push si
    xor ah, ah ; AX = count
    xor dx, dx ; DX:AX = count 
    mov si, 7   
    
_pfc_mul10:
    call DWordMul10 ; escalamos a e7
    dec si
    jnz _pfc_mul10 
    
    
    call Div32by16U ; DX:AX = (count*1e7)/total = %e7
    pop si
    ret    
    
PercentFromCounts ENDP    


PrintCountFromAL PROC NEAR
    push si
    xor ah, ah ; AX = AL
    xor dx, dx ; DX:AX = count

    ; escalamos a e5
    mov si, 5  
    
.pc_mul10:

    call DWordMul10
    dec si
    jnz .pc_mul10

    
    call PrintNumber_DXAX  ; De esta manera ya podemos reutilizar nuestra funcion
    pop si
    ret      
    
PrintCountFromAL ENDP


; Convierte numero 82393492 en formato 82,393492 
   
PrintNumber_DXAX PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov  bx, OFFSET digits_buf ; base del buffer (12 bytes)
    mov  di, 11 ; escribimos desde el final 
    xor  bp, bp                  

    ; 5 decimales: N % 10, N/=10 
    mov  si, 5 
    
PN_decimal:
    mov  cx, 10
    call Div32by16U ; (DX:AX)/10 = cociente en DX:AX y residuo en CX = N%10
    add  cl, '0' ; a ASCII
    mov  [bx+di], cl ; escribimos en el buffer de derecha a izquierda
    dec  di
    dec  si
    jnz  PN_decimal

    ; Colocamos el punto despues de colocado los 5 decimales
    
    mov  byte ptr [bx+di], '.'
    dec  di

    ;  rellenamos con la parte entera 
PN_int_loop:

    ; si el cociente es 0, se acaba
    cmp  dx, 0
    jne  PN_do_div
    cmp  ax, 0
    je   PN_int_done  
    
PN_do_div:
    mov  cx, 10
    call Div32by16U ; (DX:AX)/10
    add  cl, '0'
    mov  [bx+di], cl
    dec  di
    mov  bp, 1 ; flag para verificar enteros
    jmp  PN_int_loop

PN_int_done: 

    ; si no hubo parte entera, imprime '0'
    cmp  bp, 1
    je   PN_print
    mov  byte ptr [bx+di], '0'
    dec  di

PN_print:
    ; se imprime desde [bx+di+1] hasta el final del buffer usado
    mov  si, bx
    add  si, di ; SI = bx + di
    inc  si ; SI = inicio de la cadena
    mov  cx, bx
    add  cx, 12 ; CX = fin del buffer (bx+12)

PN_out:
    cmp  si, cx
    jae  PN_end
    mov  dl, [si]
    mov  ah, 02h
    int  21h
    inc  si
    jmp  PN_out

PN_end:
    pop  bp ; Retornamos todo a la normalidad
    pop  di
    pop  si
    pop  dx
    pop  cx
    pop  bx
    pop  ax
    ret    
    
PrintNumber_DXAX ENDP
      

; Buscar estudiante por indice
Opcion3:     

    ; si no hay estudiantes volvemos al menu
    mov  al, contador_Estud
    cmp  al, 0
    jnz  O3_Leer           ; si hay estudiantes, sigue

    ; si no hay estudiantes
    mov  dx, OFFSET msg_NoEstudiantes
    mov  ah, 09h
    int  21h
    jmp  Menu_Principal

O3_Leer:
    mov  dx, OFFSET msg_Buscar_Idx
    mov  ah, 09h
    int  21h

    ; leemos el digito ingresado
    mov  ah, 0Ch
    mov  al, 0Ah
    mov  dx, OFFSET buf_Contador
    int  21h

    ; Comprobamos que haya al menos un caracter
    mov  al, [buf_Contador+1] ; len
    cmp  al, 1
    jb   O3_Leer

    ; convertimos a ASCII  
    xor  ax, ax
    mov  bl, [buf_Contador+2] ; primer digito
    sub  bl, '0'
    cmp  bl, 9
    ja   O3_Invalido
    mov  al, bl 

    mov  cl, [buf_Contador+1] ; len
    cmp  cl, 1
    je   O3_TieneUno

    ; hay 2 digitos: AL = (d1*10) + d2
    mov  bh, 10
    mul  bh ; AX = AL*10
    mov  bl, [buf_Contador+3]
    sub  bl, '0'
    cmp  bl, 9
    ja   O3_Invalido
    add  al, bl
    jmp  short O3_TieneValor

O3_TieneUno:        
    
    
O3_TieneValor:

    ; Comprobamos que sea rango valido 1 hasta contadorEstud
    cmp  al, 1
    jb   O3_Invalido
    cmp  al, contador_Estud
    ja   O3_Invalido

    ; Convertir a indice
    dec  al

    ; Se imprime nombre nota del indice AL
    call PrintStudentAtIndex

    jmp  Menu_Principal

O3_Invalido: 

    ; Mandamos el mensaje de error
    mov  dx, OFFSET msg_Error_Indice
    mov  ah, 09h
    int  21h
    jmp  O3_Leer



; ---------------- FUNCION PRINTEAR SEGUN INDEX ---------------------- 
 

PrintStudentAtIndex PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    xor  ah, ah
    mov  si, ax ; SI = idx 

    ; Se imprime el nombre segun los offset y el idx
    mov  ax, si
    mov  bx, NOMBRE_LEN
    mul  bx ; AX = idx*NOMBRE_LEN
    mov  di, OFFSET nombres_Estud
    add  di, ax ; DI = &nombres_Estud[idx*30]

    mov  bx, OFFSET NOMBRE_LEN_ARR
    add  bx, si
    mov  cl, [bx] ; CL = len(nombre)
    xor  ch, ch

PSI_PrintNombre:
    jcxz PSI_Next
    mov  dl, [di]
    mov  ah, 02h
    int  21h
    inc  di
    dec  cx
    jmp  short PSI_PrintNombre

PSI_Next:
    ; Agregamos un espacio
    mov  dl, ' '
    mov  ah, 02h
    int  21h

    ; Se imprime la nota con la misma logica anterior
    mov  ax, si
    mov  bx, NOTA_LEN
    mul  bx ; AX = idx*NOTA_LEN
    mov  di, OFFSET notas
    add  di, ax ; DI = &notas[idx*9]

    mov  bx, OFFSET NOTAS_LEN_ARR
    add  bx, si
    mov  cl, [bx]              ; CL = len(nota)
    xor  ch, ch

PSI_PrintNota:
    jcxz PSI_NewLine
    mov  dl, [di]
    mov  ah, 02h
    int  21h
    inc  di
    dec  cx
    jmp  short PSI_PrintNota

PSI_NewLine: 

    mov  dl, 13
    mov  ah, 02h
    int  21h
    mov  dl, 10
    mov  ah, 02h
    int  21h

    pop  di
    pop  si
    pop  dx
    pop  cx
    pop  bx
    pop  ax
    ret
    
PrintStudentAtIndex ENDP


; ------- Ordenar calificaciones -------
Opcion4:
    mov al, contador_Estud
    cmp al, 2
    jb O4_NoSuficientes

O4_PreguntarModo:
    mov dx, OFFSET msg_Ordenar_Asc_Desc
    mov ah, 09h
    int 21h
    
    mov ah, 0Ch
    mov al, 0Ah
    mov dx, OFFSET buf_Orden
    int 21h   
    
    mov al, [buf_Orden+1]
    cmp al, 1
    jb O4_PreguntarModo
    
    mov bl, [buf_Orden+2]
    
    cmp bl, '1' 
    je O4_Asc
    cmp bl, '2'
    je O4_Desc
    jmp O4_PreguntarModo

O4_Asc: 
    mov byte ptr orden_modo, 0 
    mov dl, '1'
    mov ah, 02h
    int 21h
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10
    mov ah, 02h
    int 21h  
    ; ordenar
    call BubbleSort
    ;mostrar resultado
    call MostrarEstudiantes
    jmp Menu_Principal  

O4_Desc: 
    mov byte ptr orden_modo, 1
    mov dl, '2'
    mov ah, 02h
    int 21h
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10
    mov ah, 02h
    int 21h
    ; ordenar
    call BubbleSort
    ; mostrar resultado
    call MostrarEstudiantes
    jmp Menu_Principal  
    
O4_NoSuficientes:
    mov dx, OFFSET msg_No_Suf_Orden
    mov ah, 09h
    int 21h
    jmp Menu_Principal
    
    
; ------------------------------------------------------------
; SwapAdj: Intercambia i y j en cada regsitro por estudiante (parte del bubble)
; ------------------------------------------------------------         

SwapNext PROC NEAR
    pushf
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    push bp

    cld

    ; Guardar i en BP (16 bits)
    xor  ah, ah
    mov  bp, ax                 ; BP = i

    ; --- Validación: i < contador_Estud-1 ---
    mov  bl, contador_Estud
    cmp  bl, 2
    jb   short SN_EarlyExit     ; <2 estudiantes -> salir cerca

    dec  bl                     ; last = n-1
    mov  ax, bp                 ; AX = i
    cmp  al, bl
    jae  short SN_EarlyExit     ; i >= last -> salir cerca

    jmp  short SN_AfterGuards   ; *** saltar el stub en flujo normal ***

SN_EarlyExit:
    jmp  SN_Done                ; salto near (al epílogo común)

SN_AfterGuards:
    ; ES = DS por si en otra parte se cambió
    mov  ax, ds
    mov  es, ax

    ; 1) NOMBRE (30 bytes): BX = i*30  (MUL para 8086)
    mov  ax, bp
    mov  bx, 30
    push dx
    mul  bx                     ; DX:AX = i*30
    mov  bx, ax
    pop  dx

    mov  si, OFFSET nombres_Estud
    add  si, bx
    mov  di, si
    add  di, NOMBRE_LEN
    mov  cx, NOMBRE_LEN
SN_SwapNombreLoop:
    lodsb
    xchg al, [di]
    mov  [si-1], al
    inc  di
    loop SN_SwapNombreLoop

    ; 2) NOMBRE_LEN_ARR (1 byte)
    mov  ax, bp
    mov  di, OFFSET NOMBRE_LEN_ARR
    add  di, ax
    mov  dl, [di]
    xchg dl, BYTE PTR [di+1]
    mov  [di], dl

    ; 3) NOTAS (9 bytes): BX = i*9  (MUL para 8086)
    mov  ax, bp
    mov  bx, 9
    push dx
    mul  bx                     ; DX:AX = i*9
    mov  bx, ax
    pop  dx

    mov  si, OFFSET notas
    add  si, bx
    mov  di, si
    add  di, NOTA_LEN
    mov  cx, NOTA_LEN
SN_SwapNotaLoop:
    lodsb
    xchg al, [di]
    mov  [si-1], al
    inc  di
    loop SN_SwapNotaLoop

    ; 4) NOTAS_LEN_ARR (1 byte)
    mov  ax, bp
    mov  di, OFFSET NOTAS_LEN_ARR
    add  di, ax
    mov  dl, [di]
    xchg dl, BYTE PTR [di+1]
    mov  [di], dl

    ; 5) notas_val_lo (word)
    mov  ax, bp
    shl  ax, 1                  ; i*2
    mov  di, OFFSET notas_val_lo
    add  di, ax
    mov  dx, [di]
    xchg dx, WORD PTR [di+2]
    mov  [di], dx

    ; 6) notas_val_hi (word)
    mov  ax, bp
    shl  ax, 1
    mov  di, OFFSET notas_val_hi
    add  di, ax
    mov  dx, [di]
    xchg dx, WORD PTR [di+2]
    mov  [di], dx

SN_Done:
    pop  bp
    pop  es
    pop  di
    pop  si
    pop  dx
    pop  cx
    pop  bx
    pop  ax
    popf
    ret
SwapNext ENDP


    

; ------------------------------------------------------------
; CmpNotaIdxVsNext: compara nota[i] con nota[i+1] (32-bit)
; ------------------------------------------------------------
CmpNotaIdxVsNext PROC NEAR
    push bx
    push cx
    push dx
    push si
    push di

    ; ---- offset = i*2 ----
    xor  ah, ah          ; AH=0 para que AX=i
    mov  si, ax          ; SI = i
    shl  si, 1           ; SI = i*2

    ;cargar v1 = DX:AX = nota[i]
    mov  di, OFFSET notas_val_lo
    add  di, si
    mov  ax, [di]        ; AX = LO[i]

    mov  di, OFFSET notas_val_hi
    add  di, si
    mov  dx, [di]        

    
    mov  bp, si
    add  bp, 2           ; (i+1)*2
    mov  di, OFFSET notas_val_lo
    add  di, bp
    mov  bx, [di]        ; BX = LO[i+1]

    mov  di, OFFSET notas_val_hi
    add  di, bp
    mov  cx, [di]        ; CX = HI[i+1] -> v2 = CX:BX

   
    sub  ax, bx
    sbb  dx, cx

    jc   CNI_Less        

    
    or   dx, ax
    jz   CNI_Equal        

    ; Mayor
    mov  al, 2
    jmp  CNI_Done

CNI_Less:
    mov  al, 0
    jmp  CNI_Done

CNI_Equal:
    mov  al, 1

CNI_Done:
    xor  ah, ah          
    pop  di
    pop  si
    pop  dx
    pop  cx
    pop  bx
    ret
CmpNotaIdxVsNext ENDP

; ------------------------------------------------------------
; BubbleSort: ordena segun orden_modo (0=asc, 1=desc)
; ------------------------------------------------------------
BubbleSort PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; n = contador_Estud
    xor ax, ax
    mov al, contador_Estud
    cmp al, 2
    jb  BS_Done

    mov bl, al         ; BL = n
    dec bl             ; last = n-1

BS_Outer:
    xor bh, bh         ; swapped = 0
    xor cx, cx         ; CL = i = 0

BS_Inner:
    ; while (i < last)
    mov al, bl         ; AL = last
    cmp cl, al
    jae BS_AfterInner

    ; comp = cmp(nota[i], nota[i+1])
    mov al, cl         ; AL = i
    call CmpNotaIdxVsNext   ; AL = 0(<),1(=),2(>)
    mov dl, al              ; DL = comp

    ; decidir swap segun orden_modo
    mov al, orden_modo
    cmp al, 0
    jne BS_Desc

    ; ascendente: swap si comp==2
    cmp dl, 2
    jne BS_NoSwap
    mov al, cl              ; AL = i
    call SwapNext
    mov bh, 1 
    ;mov dl, '*'          ; DEBUG: marca que hubo swap
    ;mov ah, 02h
    ;int 21h
    jmp BS_NoSwap

BS_Desc:
    ; descendente: swap si comp==0
    cmp dl, 0
    jne BS_NoSwap
    mov al, cl
    call SwapNext
    mov bh, 1
    ;mov dl, '*'          ; DEBUG: marca que hubo swap
    ;mov ah, 02h
    ;int 21h

BS_NoSwap:
    inc cl
    jmp BS_Inner

BS_AfterInner:
    cmp bh, 0               ; early-exit si no hubo swaps
    je  BS_Done

    dec bl                  ;
    cmp bl, 0
    ja  BS_Outer

BS_Done:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
BubbleSort ENDP




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