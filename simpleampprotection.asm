;file: simpleampprotection.asm
;this is part of "Smart Amp Protection Project" - Lite Version (R)(C)2012,2013 by: d@W <daw_at_edasat_dot_com>
; Version 0.6-LA2
;Maked under GPL2.0!
#include	<p16f628a.inc>

    __CONFIG _WDT_ON & _PWRTE_ON & _INTOSC_OSC_NOCLKOUT  & _MCLRE_OFF & _BODEN_ON & _LVP_OFF 
    ;& _DATA_CP_OFF & _CP_OFF

    ERRORLEVEL -302
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   
cblock 0x70
      cntmsec
endc

;v zavisimost ot tipa na svetodioda se definira ili ne!
#define		COMMON_ANODE_RGB_LED
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#define		AC_DET		PORTA,5
#define		DC_DET		PORTA,1
#define		Relay_Out	PORTB,0
#define		R_LED		PORTB,1
#define		G_LED		PORTB,2
#define		B_LED		PORTB,3
#define		MainLoopTime	.1
#define		DCDetectDelay	.100

ifdef		COMMON_ANODE_RGB_LED
#define		ON		bcf
#define		OFF		bsf
else
#define		ON		bsf
#define		OFF		bcf
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	  org	0x2100
;	  de	0x96,0x00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	org	0x0000
	goto	Init		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Init
	clrwdt
	banksel OPTION_REG
	movlw	B'00001100' ;timer0 ps to wd = 1:16
	movwf	OPTION_REG
	banksel 0x00
	movlw	b'00001110'; for leds off
	movwf	PORTB
	clrf	PORTA
	banksel	TRISB
	movlw	B'00000000' ;RB0-RB7 Out
	movwf	TRISB
	movlw	B'00100010' ;RA1-RA5 In other Out
	movwf	TRISA
	banksel	PCON
	bsf	PCON,OSCF
	banksel	CMCON
	movlw	0x07
	movwf	CMCON
	banksel	0x00
	goto	Main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MainX
	OFF	G_LED
	OFF	B_LED
	OFF	R_LED
	bcf	Relay_Out
	clrwdt
	movlw	.250
	call	nmsec
	movlw	.250
	call	nmsec
	btfss	AC_DET
	goto	Main
	movlw	.250
	call	nmsec
	movlw	.250
	call	nmsec	
Main0
	clrwdt
	movlw	.100
	call	nmsec
Main
	clrwdt
	OFF	R_LED
	OFF	G_LED
	OFF	B_LED
	btfsc	AC_DET
	goto	Main0
	;
	ON	R_LED
	ON	B_LED
	call	sec0.5
	btfsc	AC_DET
	goto	Main0
	OFF	R_LED
	OFF	B_LED
	call	sec0.5
	btfsc	AC_DET
	goto	Main0	
	ON	R_LED
	ON	B_LED
	call	sec0.5
	btfsc	AC_DET
	goto	Main0	
	OFF	R_LED
	OFF	B_LED	
	call	sec0.5
	btfsc	AC_DET
	goto	Main0
	ON	R_LED
	ON	B_LED
	call	sec0.5
	btfsc	AC_DET
	goto	Main0
	OFF	R_LED
	OFF	B_LED
	call	sec0.5
	btfsc	AC_DET
	goto	Main0	
	ON	R_LED
	ON	B_LED
	call	sec0.5; wait 3.5 sec	
	btfsc	AC_DET
	goto	Main0
	OFF	R_LED
	OFF	G_LED
	ON	B_LED
main_loop
	btfsc	AC_DET
	goto	AC_down
	;
	btfss	DC_DET
	goto	DC_fault_yes
	bsf	Relay_Out
	movlw	MainLoopTime
	call	nmsec
	clrwdt
	goto	main_loop
DC_fault_yes
	clrwdt
	btfsc	AC_DET
	goto	MainX
	bcf	Relay_Out
	OFF	G_LED
	OFF	B_LED
	ON	R_LED
	call	msec250
	OFF	R_LED
	call	msec250	
	goto	DC_fault_yes
AC_down
	bcf	Relay_Out
	goto	Main0
;----------------------------------------------------------------------;
;                        time delay routines                           ;
;----------------------------------------------------------------------;
;Dlay160:    movlw .41                 ;  delay about 160 usec
micro4      addlw 0xFF                ;  subtract 1 from 'W'
            btfss STATUS,Z            ;  skip when you reach zero
            goto micro4               ;  more loops
            return                     
            
;
msec250:    movlw .250                 ;  delay for 250 milliseconds
	    goto  $ + 2
;
;Dlay5:      movlw .5                   ;  delay for 5 milliseconds	    
                ;*** N millisecond delay routine ***
nmsec:      movwf cntmsec              ; delay for N (in W) millisec
msecloop:   movlw .254                 ; load takes .9765625 microsec
            call micro4                ; by itself CALL takes ...
                                       ; 2 + 253 X 4 + 3 + 2 = 1019 
                                       ; 1019 * .977 = 995 microsec
            ;nop                        ; .98 microsec 
            clrwdt
            decfsz cntmsec, f          ; .98 skip not taken, else 1.95
            goto msecloop              ; 1.95 here: total ~1000 / loop
            return                     ; final time through ~999 to here
                                       ; overhead in and out ignored
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sec0.5
	movlw	.250
	call	nmsec
	movlw	.250
	call	nmsec
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;sec1
;	call	sec0.5
;	call	sec0.5
;	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 end
