list p=16f84a
include <p16f84.inc>

__CONFIG _CP_OFF&_WDT_OFF&_PWRTE_ON&_XT_OSC

;-------------------------------------------------------------------------------
;------------ IF4000 - ARQUITECTURA DE COMPUTADORES - PROYECTO -----------------
;-------------------------------------------------------------------------------
;Estudiantes:
;	Alisson Rodríguez Mora - C06679
;	Jesner Melgara Murillo - C14644

;--------------------------------------------------------
;---- COMBINACIONES DE SALIDAS PARA LAS DIRECCIONES -----
;--------------------------------------------------------

;RB2 y RB3 controlan el giro Motor 1
;RB4 y RB5 controlan el giro Motor 2

; MOTOR1 - MOTOR2 = SALIDA
; RB0 (0) RB1 (0) RB2 (1) RB3 (0)  -  RB4 (0) RB5 (1) RB6 (0) RB7 (0) = ADELANTE  B'00100100'
; RB0 (0) RB1 (0) RB2 (0) RB3 (0)  -  RB4 (0) RB5 (0) RB6 (0) RB7 (0) = DETENER   B'00000000'
; RB0 (0) RB1 (0) RB2 (0) RB3 (1)  -  RB4 (1) RB5 (0) RB6 (0) RB7 (0) = RETROCESO B'00011000'
; RB0 (0) RB1 (0) RB2 (0) RB3 (0)  -  RB4 (0) RB5 (1) RB6 (0) RB7 (0) = DERECHA   B'00000100'
; RB0 (0) RB1 (0) RB2 (1) RB3 (0)  -  RB4 (0) RB5 (0) RB6 (0) RB7 (0) = IZQUIERDA B'00100000'

;----------- DECLARACIÓN DE VARIABLES -------------------
#define posiciones .50 		 ; # de posiciones a ocupar en los registros
#define inicial 0x13   		 ; Primera dirección a almacenar
#define minInstrucciones .40 ; Funciona como el mínimo de instrucciones libres que deben quedar para comenzar a ejecutar la secuencia (10 instrucciones)

CONTADOR equ 0x0C 			 ; Cuenta el # de instrucciones guardadas
NUMERO equ 0x0D 			 ; Variable que almacena el número a guardar
MIN_NUMERO equ 0x0E

;------------ GRABACIÓN SECUENCIA MEMORIA ---------------
BanderaSecGuardada equ 0x0F
BanderaSecIngresada equ 0x10

;--------------- CONTADORES PARA RETARDOS ---------------
Contador equ 0x11
Contador_2 equ 0x12 

;--------------------------------------------------------
;------------ INICIO DEL PROGRAMA PRINCIPAL -------------
;--------------------------------------------------------
org 0x00 ; Posición de memoria de prog. que comienza

Inicio 
; -------------- CONFIGURACIÓN DE PUERTOS ---------------
	BSF	STATUS,RP0
	clrf PORTA
	movlw b'00000000'
	movwf PORTA

	clrf PORTB
	MOVLW B'00000000'
	movwf PORTB
	BCF	STATUS,RP0 

	MOVLW B'00000000'
	MOVWF PORTB
	MOVWF PORTA
	
; -------------- LIMPIEZA DE VARIABLES ------------------
	clrw
	movwf CONTADOR
	movwf NUMERO
	movwf Contador
	movwf Contador_2 

;------------------- ESCRITURA DE VARIABLES -------------------	
	movlw minInstrucciones
	movwf MIN_NUMERO

	movlw .1					; Significa que no hay 10 instrucciones minimo
	movwf BanderaSecIngresada  

	movlw posiciones
	movwf BanderaSecGuardada	

	movlw posiciones
	movwf CONTADOR 				; Cargo en CONTADOR el numero de posiciones
	movlw inicial-1
	movwf FSR 					; puntero = posición anterior a la inicial

	movlw 0
	call Limpiar

	movlw posiciones
	movwf CONTADOR
	movlw inicial-1
	movwf FSR 

	call START

;------------------------ LIMPIAR REGISTROS --------------------
Limpiar 
	incf FSR 		; Apunta a la siguiente posición 
	movwf INDF 		; Dato --> INDF
	decf CONTADOR 	; Decremento el contador
	btfss STATUS,Z 	; Si llega a cero salta
	goto Limpiar
	RETURN

;------------------------ PULSADORES --------------------
START
	
	CALL PULSADOR_ADELANTE

	CALL PULSADOR_COMENZAR
	
	CALL PULSADOR_DETENER
	
	CALL PULSADOR_RETROCEDER

	CALL PULSADOR_DERECHA

	CALL PULSADOR_IZQUIERDA
	
	GOTO START

PULSADOR_ADELANTE
	BTFSC PORTA,0 
	GOTO ADELANTE
	RETURN

PULSADOR_DETENER 	; Instrucción detener dentro de la secuencia
	BTFSC PORTA,1
	GOTO DETENER	
	RETURN 

PULSADOR_RETROCEDER
	BTFSC PORTA,2 
	GOTO ATRAS
	RETURN

PULSADOR_DERECHA
	BTFSC PORTA,3 
	GOTO DERECHA
	RETURN

PULSADOR_IZQUIERDA
	BTFSC PORTA,4  
	GOTO IZQUIERDA
	RETURN

PULSADOR_COMENZAR
	BTFSC PORTB, 1 
	GOTO COMENZAR
	RETURN

PULSADOR_STOP 		; Detiene la secuencia por completo
	BTFSC PORTA,1
	GOTO STOP
	RETURN

; ------------------------------ Manejo de direcciones -------------------------------------------
ADELANTE
	BTFSC PORTA,0	; While hasta que sea 0.
	GOTO ADELANTE
MOV_ADELANTE
	MOVLW B'00100100'
	movwf NUMERO	
	incf FSR 		; Apunta a la siguiente posición
	movwf INDF 		; Dato --> INDF	decf NUMERO
	movf NUMERO,W   ; W = NUMERO
	decf CONTADOR   ; Decremento el contador

	movf CONTADOR, w		   
	subwf MIN_NUMERO, w
	btfsc STATUS, Z  
 	CALL SECUENCIA_INGRESADA 
	RETURN

DETENER 		
	BTFSC PORTA,1
	GOTO DETENER
MOV_DETENER
	CLRW		    ;W = 0
	MOVLW B'00000000'
	movwf NUMERO	
	incf FSR 		; Apunta a la siguiente posición
	movwf INDF 		; Dato --> INDF	decf NUMERO
	movf NUMERO,W   ; W = NUMERO
	decf CONTADOR   ; Decremento el contador

	movf CONTADOR, w		   
	subwf MIN_NUMERO, w
	btfsc STATUS, Z 
 	CALL SECUENCIA_INGRESADA

	RETURN

ATRAS
	BTFSC PORTA,2
	GOTO ATRAS
MOV_ATRAS
	movlw B'00011000'
	movwf NUMERO
	incf FSR 		; Apunta a la siguiente posición
	movwf INDF 		; Dato --> INDF	decf NUMERO
	movf NUMERO,W   ; W = NUMERO
	decf CONTADOR   ; Decremento el contador

	movf CONTADOR, w		   
	subwf MIN_NUMERO, w
	btfsc STATUS, Z 
 	CALL SECUENCIA_INGRESADA

	RETURN

DERECHA
	BTFSC PORTA,3
	GOTO DERECHA
MOV_DERECHA
	MOVLW B'00000100'
	movwf NUMERO
	incf FSR 		; Apunta a la siguiente posición
	movwf INDF 		; Dato --> INDF	decf NUMERO
	movf NUMERO,W   ; W = NUMERO
	decf CONTADOR   ; Decremento el contador

	movf CONTADOR, w		   
	subwf MIN_NUMERO, w
	btfsc STATUS, Z 
 	CALL SECUENCIA_INGRESADA

	RETURN

IZQUIERDA
	BTFSC PORTA,4
	GOTO IZQUIERDA
MOV_IZQUIERDA
	MOVLW B'00100000'
	movwf NUMERO
	incf FSR 		; Apunta a la siguiente posición
	movwf INDF 		; Dato --> INDF
	movf NUMERO,W   ; W = NUMERO
	decf CONTADOR   ; Decremento el contador

	movf CONTADOR, w		   
	subwf MIN_NUMERO, w
	btfsc STATUS, Z 
 	CALL SECUENCIA_INGRESADA
	RETURN

; ---------------------- COMENZAR Y DETENER ------------------
COMENZAR
	BTFSC PORTB,1
	GOTO COMENZAR

	movlw B'01000000'
	movwf PORTB
	
	movf CONTADOR, w       		; Mueve VALOR1 a WREG
    subwf BanderaSecGuardada, w ; Resta VALOR2 de WREG (resultado no afecta VALOR1 ni VALOR2)

    btfsc STATUS, Z       	    ; Verifica si el resultado es uno
    CALL SECUENCIA_GUARDADA  

	movf MIN_NUMERO, w		   
    subwf BanderaSecIngresada, w

	btfsc STATUS, Z 
 	CALL Leer_Secuencia_Inicial

	CALL Fin
	RETURN

STOP	
	BTFSC PORTB,1
	GOTO STOP

	movlw B'00000000'
	movwf PORTB	
	CALL START

;--------------------- SECUENCIA MEMORIA --------------------
SECUENCIA_GUARDADA
	CALL MOV_ADELANTE
	CALL MOV_IZQUIERDA
	CALL MOV_ATRAS
	CALL MOV_DERECHA
	CALL MOV_DETENER
	CALL MOV_ADELANTE
	CALL MOV_IZQUIERDA
	CALL MOV_IZQUIERDA
	CALL MOV_ADELANTE
	CALL MOV_DERECHA
	CALL MOV_ADELANTE
	CALL MOV_ATRAS
	CALL MOV_DERECHA
	CALL MOV_IZQUIERDA
	CALL MOV_ADELANTE
	CALL MOV_DETENER
	CALL MOV_DERECHA
	CALL MOV_ADELANTE
	CALL MOV_ADELANTE
	CALL MOV_ATRAS
	CALL MOV_ADELANTE
	CALL MOV_ATRAS
   	CALL Leer_Secuencia_Inicial 
	RETURN

; --------------- LECTURA DE REGISTROS -------------------------
Leer_Secuencia_Inicial
	movlw posiciones
	movwf CONTADOR  ; Cargo en CONTADOR el número de posiciones
	movlw inicial-1
	movwf FSR 	    ; puntero = posición anterior a la inicial
Leer_Secuencia 
	incf FSR 	    ; Apunta a la siguiente posición
	movf INDF, W	; Lee el valor de la posición apuntada por FSR y lo coloca en W

	movwf NUMERO 
	movwf PORTB

	CALL RETARDO_200ms
	CALL RETARDO_200ms

	decf CONTADOR
	btfsc STATUS,Z 	; Si es cero, salta 
	RETURN	
	goto Leer_Secuencia

;------------------ CAMBIO DE BANDERA ---------------

SECUENCIA_INGRESADA
	movlw .40		   
    movwf BanderaSecIngresada
	RETURN
	
;------------------------ RETARDOS -------------------

RETARDO_200ms			
    MOVLW   d'200'		
    GOTO    Retardos_ms	
RETARDO_100ms			
    MOVLW   d'100'		
    GOTO    Retardos_ms	
    
Retardos_ms   
    MOVWF   Contador_2		
Regresa_Cuenta_2
    MOVLW   d'249'				 
    MOVWF   Contador			
Regresa_Cuenta
    NOP		
	CALL PULSADOR_STOP	; VALIDA QUE SI SE PRESIONA EL PULSADOR DETENER
    DECFSZ  Contador,F		
    GOTO    Regresa_Cuenta		
    DECFSZ  Contador_2,F		
    GOTO    Regresa_Cuenta_2 	
    RETURN

;------------------------- FIN ----------------------
Fin 
	movlw B'01000000'
	movwf PORTB	
	RETURN

End 