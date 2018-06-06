; T2_Blink_MACRO_Enhanced.asm
;Macro magic with embedded Interrupt Vector and Interrupt
;  service routine.
; Blink LED on specified port and pin using Timer 2 Overflow Interrupt
; If there is a #define SIM statement then Timer 2 Clock Select = MCU_clk/1
;    else Timer 2 Clock Select = MCU_clk/1024
;
; Usage Example:  T2_BLINK PORTB, PB0   ;Blink Led on PORTB, Pin PB0
;

.MACRO T2_BLINK
MACRO_START: 
.ORG	OVF2addr
		rjmp	T2_isr
.ORG	MACRO_START
		sbi 	@0-1, @1    ;PORTx - 1 = DDRx
		ldi 	TEMP, (1<<TOIE2)
		sts 	TIMSK2, TEMP
#ifdef SIM
		ldi 	TEMP, (0<<CS22)|(0<<CS21)|(1<<CS20)
#else
		ldi 	TEMP, (1<<CS22)|(0<<CS21)|(1<<CS20)
#endif
		sts 	TCCR2B, TEMP
		rjmp	Macro_Return
T2_isr:
		sbi 	@0-2, @1    ;PORTx - 2 = PINx 
		reti
Macro_Return:
.ENDMACRO
;-----------------------------------------------------------------------------

.MACRO STACK_POINTER_INIT
#ifdef	SPH
		ldi 	TEMP, high(RAMEND)
		out 	SPH, TEMP
#endif
		ldi 	TEMP, low(RAMEND)
		out 	SPL, TEMP
.ENDMACRO
;-----------------------------------------------------------------------------

.MACRO DELAY_QUARTER_SEC
MACRO_DELAY_START:
.ORG	OC2Aaddr
		rjmp	T2_DEL_Q
.ORG	MACRO_DELAY_START
		lds 	TEMP, TCCR2B
		push	TEMP
		lds 	TEMP, TCCR2A
		push	TEMP
		lds 	TEMP, TIMSK2
		push	TEMP
		lds 	TEMP, OCR2A
		push	TEMP
		ldi 	TEMP, $FA
		sts 	OCR2A, TEMP
		ldi 	TEMP, (1<<OCIE2A)
		sts 	TIMSK2, TEMP
		ldi 	TEMP, (1<<WGM21)|(0<<WGM20)
		sts 	TCCR2A, TEMP
		ldi 	TEMP, (0<<WGM22)|(1<<CS02)|(0<<CS01)|(1<<CS00)
		sts 	TCCR2B, TEMP
		sbi 	GPIOR0, 7
		ldi 	TEMP, @0
DEL_Q_WAIT:
		sbic	GPIOR0, 7
		rjmp	DEL_Q_WAIT
		rjmp	DELAY_END
T2_DEL_Q:
		dec 	TEMP
		brne	CONTINUE_DELAY
		pop 	TEMP
		sts 	OCR2A, TEMP
		pop 	TEMP
		sts 	TIMSK2, TEMP
		pop 	TEMP
		sts 	TCCR2A, TEMP
		pop 	TEMP
		sts 	TCCR2B, TEMP
		cbi 	GPIOR0, 7
CONTINUE_DELAY:
		reti
DELAY_END:

.ENDMACRO
;-----------------------------------------------------------------------------
.LISTMAC


