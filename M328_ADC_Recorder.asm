;M328 ADC Recorder
 
.nolist
.include "m328pdef.inc"
.list
 
.def	TEMP = R16
.def	ADCin = R24
.def	ButtonInput = R18
.def	DBcount = R17

.equ	SamplePer = 48
.equ	ADCwriteAdd = SRAM_START + $10
.equ	ADCreadAdd = SRAM_START + $12
.equ	ADCtable = SRAM_START + $20
.equ	ADCtableEnd = $07FF

.ORG	$0000
		rjmp	RESET
.ORG	INT0addr
		rjmp	Record
.ORG	INT1addr
		rjmp	Play
.ORG	OC0Aaddr
		reti
.ORG	OVF0addr
		reti
.ORG	ADCCaddr
		rjmp	ADCcomplete
.ORG	INT_VECTORS_SIZE
 
RESET:
		ldi 	TEMP, high(RAMEND)
		out 	SPH, TEMP
		ldi 	TEMP, low(RAMEND)
		out 	SPL, TEMP
		
		ldi 	YH, high(ADCwriteAdd)
		ldi 	YL, low(ADCwriteAdd)
		ldi 	TEMP, low(ADCtable)
		st  	Y+, TEMP
		ldi 	TEMP, high(ADCtable)
		st  	Y, TEMP

		sbi 	DDRB, PB0	;Record Indicator
		sbi 	PORTD, PD2	;INT0 Record Start/Stop
		sbi 	PORTD, PD3	;INT1 Play Start/Stop
		
		ldi  	TEMP, (1<<ISC11)|(1<<ISC01)
		sts 	EICRA, TEMP

		sbi 	EIMSK, INT0
		sbi 	EIMSK, INT1	

		ldi 	TEMP, (1<<REFS1)|(1<<ADLAR)
		sts 	ADMUX, TEMP
 
		ldi 	TEMP, (1<<ADTS1)|(1<<ADTS0)
		sts 	ADCSRB, TEMP
 
;		ldi 	TEMP, (1<<ADEN)|(1<<ADATE)|(1<<ADIE)|(1<<ADPS1)|(1<<ADPS0)
;		sts 	ADCSRA, TEMP
 
		ldi 	TEMP, SamplePer
		out 	OCR0A, TEMP
 
		ldi 	TEMP, (1<<WGM02)|(1<<WGM01)|(1<<WGM00)
		out 	TCCR0A, TEMP

		ldi 	TEMP, (1<<OCIE0A)|(0<<TOIE0)
		sts 	TIMSK0, TEMP

;		ldi 	TEMP, (1<<WGM02)|(1<<CS02)|(0<<CS01)|(1<<CS00)
;		out 	TCCR0B, TEMP
 
		sei
 
MAIN:
		nop
		nop
		nop
		nop
		rjmp	MAIN
;------------------------------------------------------------------------------
ADCcomplete:
		lds  	ADCin, ADCH
		ldi 	YH, high(ADCwriteAdd)
		ldi 	YL, low(ADCwriteAdd)
		ld  	XL, Y+
		ld  	XH, Y
		ldi 	TEMP, low(ADCtableEnd)
		cp  	XL, TEMP
		ldi 	TEMP, high(ADCtableEnd)
		cpc 	XH, TEMP
		breq	RecordFull
		andi	XH, $07
		st  	X+, ADCin
		st  	Y, XH
		st  	-Y, XL
		nop
		reti

RecordFull:
		clr 	TEMP
		out 	TCCR0B, TEMP
		ldi 	TEMP, (0<<ADEN)|(0<<ADATE)|(0<<ADIE)|(1<<ADPS1)|(1<<ADPS0)
		sts 	ADCSRA, TEMP
		ldi 	YH, high(ADCwriteAdd)
		ldi 	YL, low(ADCwriteAdd)
		ldi 	TEMP, low(ADCtable)
		st  	Y+, TEMP
		ldi 	TEMP, high(ADCtable)
		st  	Y, TEMP
		reti

;------------------------------------------------------------------------------
Record:
		rcall	DBint
		sbic	GPIOR0, 0
		rjmp	StopRecord
		ldi 	TEMP, (1<<ADEN)|(1<<ADATE)|(1<<ADIE)|(1<<ADPS1)|(1<<ADPS0)
		sts 	ADCSRA, TEMP
		ldi 	TEMP, (1<<WGM02)|(1<<CS02)|(0<<CS01)|(1<<CS00)
		out 	TCCR0B, TEMP

		sbi 	PORTB, PB0	;Record Indicator On
		sbi 	GPIOR0, 0
		reti
StopRecord:
		clr 	TEMP
		out 	TCCR0B, TEMP
		cbi 	PORTB, PB0	;Record Indicator Off
		cbi 	GPIOR0, 0
		reti		


;------------------------------------------------------------------------------
Play:
		rcall	DBint
		sbic	GPIOR0, 1
		rjmp	StopPlay

		ldi 	YH, high(ADCreadAdd)
		ldi 	YL, low(ADCreadAdd)
		ld  	XL, Y+
		ld  	XH, Y
		ldi 	YH, high(ADCwriteAdd)
		ldi 	YL, low(ADCwriteAdd)
		ld  	ZL, Y+
		ld  	ZH, Y
		cp  	ZL, XL
		cpc 	ZH, XH
		breq	StopPlay
		ldi 	TEMP, low(ADCtableEnd)
		cp  	XL, TEMP
		ldi 	TEMP, high(ADCtableEnd)
		cpc 	XH, TEMP
		breq	StopPlay		
;TODO  Read values and write to OCR1A

		ldi 	TEMP, (1<<WGM02)|(1<<CS02)|(0<<CS01)|(1<<CS00)
		out 	TCCR0B, TEMP		
		sbi 	GPIOR0, 1
		reti			
StopPlay:



		reti
;------------------------------------------------------------------------------
DBint:
		ldi 	DBcount, $50
		in  	ButtonInput, PIND
		andi	ButtonInput, $C0
NextRead:
		in  	TEMP, PIND
		andi	TEMP, $C0
		cp  	TEMP, ButtonInput
		brne	DBint
		dec 	DBcount
		brne	NextRead
		sbi 	EIFR, INTF0
		ret






		
