;Archivo: Lab2.s
;Dispositivo: PIC16F887
;Autor: Jimena de la Rosa
;Compilador: pic-as (v2.30). MPLABX v5.40
;Programa: laboratorio 1
;Hardware: LEDs en el puerto A
;Creado: 31 ene, 2022
;Ultima modificacion: 03 ene, 2022
    
PROCESSOR 16F887

; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = ON            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.
#include <xc.inc>
    
PSECT resVect, class=CODE, abs, delta=2
ORG 000h ; posicion del vector de reseteo

resVect:
    GOTO main

PSECT CODE, delta=2, abs
ORG 100h
 
;configuraciones

main:
    CALL CONFIG_RELOJ
    CALL CONFIG_TMR0
    BSF	    STATUS, 5
    BSF	    STATUS, 6; BANCO 3 
    CLRF    ANSEL
    CLRF    ANSELH
    
    BCF	    STATUS,6 ; BANCO 1 
    MOVLW   0xF0     ; usar 11110000 para dejar solo 4 bits de salida
    MOVWF   TRISB    ; usar esa configuracion en la salida B
    BCF	    STATUS, 5; banco 00
    CLRF    PORTB    ; se quita lo que exista en la salida B

;RUTINA PRINCIPAL
RUTINA:
    BTFSS T0IF; SE REVISA SI ESTA ENCENDIDO
    GOTO RUTINA ; SI NO ESTA ENCENDIDO REGRESA AL INICIO
    CALL REINICIO_TMR0; SI ESTA ENCENDIDO, SE REINICIA EL TMR0
    INCF PORTB, F; SE INCREMENTA 1
    GOTO RUTINA; SE VUELVE AL INICIO DE LA RUTINA
    
;subrutinas
CONFIG_RELOJ:
    BANKSEL OSCCON
    BSF OSCCON, 0; RELOJ INTERNO
    BCF OSCCON, 4; OSCILADOR DE 1MH
    BCF OSCCON, 5
    BSF OSCCON, 6
    RETURN
    
CONFIG_TMR0:
    BANKSEL OPTION_REG
    BCF PSA
    BCF PS0; PRESCALER DE 1:128
    BSF PS1
    BSF PS2 
    BCF T0CS ; RELOJ INTERNO
    MOVLW 61 ; 100MS
    
    BANKSEL TMR0
    MOVWF TMR0 ; CARGAMOS EL VALOR INICIAL
    BCF   T0IF; LIMPIAMOS LA BANDERA
    RETURN
    
REINICIO_TMR0:
    BANKSEL TMR0
    MOVLW   61		; 100 ms 
    MOVWF   TMR0	; Cargamos valor inicial
    BCF	    T0IF	; Limpiamos bandera
    RETURN
End
