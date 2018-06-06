

.nolist
.include "m328pdef.inc"
.list
.include "T2_Blink_MACRO_Enhanced.asm"

.def	TEMP = r16

.ORG	$0000
		rjmp	RESET

.ORG	INT_VECTORS_SIZE
RESET:
		nop

STACK_POINTER_INIT

		nop

T2_BLINK PORTD, PD7

		nop

		nop
		sei

; DELAY_QUARTER_SEC 3

		nop

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
		ldi 	TEMP, (0<<WGM22)|(0<<CS02)|(0<<CS01)|(1<<CS00)
		sts 	TCCR2B, TEMP
		sbi 	GPIOR0, 7
		ldi 	TEMP, 3
DEL_Q_WAIT:
		sbic	GPIOR0, 7
		rjmp	DEL_Q_WAIT
		rjmp	DELAY_END
T2_DEL_Q:
		sbi 	TIFR2, OCIE2A
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

		nop

MAIN:
		nop
		nop
		nop
		nop
		nop
		rjmp	MAIN




