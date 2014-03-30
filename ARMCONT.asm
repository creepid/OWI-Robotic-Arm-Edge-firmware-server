.include "m8def.inc"
.include "my_macro.inc"

.def	OSRG = r17
.def	ChkSum = r22
.def  	comm = r23
.def  	temp = r24
.def  	temp1 = r25

.equ	PORT_LED	= PORTB
.equ	PIN_LED		= PINB
.equ	DDR_LED		= DDRB

.equ	DDR_RF		= DDRD

.equ	PORT_SCK	= PORTD
.equ	PIN_SCK		= PIND
.equ	DDR_SCK		= DDRD

.equ	PORT_SDI	= PORTD
.equ	PIN_SDI		= PIND
.equ	DDR_SDI		= DDRD

.equ	PORT_SEL	= PORTD
.equ	PIN_SEL		= PIND
.equ	DDR_SEL		= DDRD

.equ	PORT_nIRQ	= PORTD
.equ	PIN_nIRQ	= PIND
.equ	DDR_nIRQ	= DDRD

.equ	PORT_SDO	= PORTD
.equ	PIN_SDO		= PIND
.equ	DDR_SDO		= DDRD

.equ	LED	= 6

.equ	RFXX_SCK	= 0
.equ	RFXX_SDI	= 1
.equ	RFXX_SEL	= 2
.equ	RFXX_nIRQ	= 3
.equ	RFXX_SDO	= 4

.equ 	L 			= 7
.equ 	PORT_L		= PORTB
.equ 	DDR_L		= DDRB

.equ 	m1_en 		= 5
.equ 	right_m1 	= 6
.equ 	left_m1 	= 7
.equ 	PORT_m1		= PORTD
.equ 	DDR_m1		= DDRD

.equ 	m2_en 		= 0
.equ 	right_m2 	= 1
.equ 	left_m2 	= 2
.equ 	PORT_m2		= PORTB
.equ 	DDR_m2		= DDRB

.equ 	m3_en 		= 3
.equ 	right_m3 	= 4
.equ 	left_m3 	= 5
.equ 	PORT_m3		= PORTB
.equ 	DDR_m3		= DDRB

.equ 	m4_en 		= 0
.equ 	right_m4 	= 1
.equ 	left_m4 	= 2
.equ 	PORT_m4		= PORTC
.equ 	DDR_m4		= DDRC

.equ 	m5_en 		= 3
.equ 	right_m5 	= 4
.equ 	left_m5 	= 5
.equ 	PORT_m5		= PORTC
.equ 	DDR_m5		= DDRC


.DSEG

RFbuff1:	.byte	1

.CSEG 
; Interrupts;===================================================================
			.ORG 	0x0000
		    rjmp RESET

			.ORG	INT0addr		; External Interrupt Request 0
			RETI
			.ORG	INT1addr		; External Interrupt Request 1
				rjmp IRQn_INT
			.ORG	OC2addr			; Timer/Counter2 Compare Match
			RETI
			.ORG	OVF2addr		; Timer/Counter2 Overflow
			RETI
			.ORG	ICP1addr		; Timer/Counter1 Capture Event
			RETI
			.ORG	OC1Aaddr		; Timer/Counter1 Compare Match A
			RETI
			.ORG	OC1Baddr		; Timer/Counter1 Compare Match B
			RETI
			.ORG	OVF1addr		; Timer/Counter1 Overflow
			RETI
			.ORG	OVF0addr		; Timer/Counter0 Overflow
			RETI
			.ORG	SPIaddr			; Serial Transfer Complete
			RETI
			.ORG	URXCaddr		; USART, Rx Complete
			RETI
			.ORG	UDREaddr		; USART Data Register Empty
			RETI
			.ORG	UTXCaddr		; USART, Tx Complete
			RETI
			.ORG	ADCCaddr		; ADC Conversion Complete
			RETI 
			.ORG	ERDYaddr		; EEPROM Ready
			RETI
			.ORG	ACIaddr			; Analog Comparator
			RETI
			.ORG	TWIaddr			; 2-wire Serial Interface
			RETI
			.ORG	SPMRaddr		; Store Program Memory Ready
			RETI
; End Interrupts ==========================================

.org INT_VECTORS_SIZE
;=============================================================================
IRQn_INT:
	rcall RF01_RDFIFO
	mov comm, OSRG
	andi OSRG, $F0
	cpi OSRG, $A0
	brlo resiev_ex
	mov OSRG, comm
	andi OSRG, $0F
	cpi OSRG, $07
	brge resiev_ex

	STS RFbuff1, comm
	

	mov ChkSum, comm
	andi ChkSum, $0F

	rcall delay_mks
	rcall delay_mks
	rcall delay_mks
	rcall RF01_RDFIFO
	cp  ChkSum, OSRG
	brne resiev_ex
	set
	
resiev_ex:
	ldi		r19,$48
	ldi		r20,$ce
	rcall	RFXX_WRT_CMD	

	ldi		r19,$87
	ldi		r20,$ce
	rcall	RFXX_WRT_CMD
reti
;=============================================================================
RESET:
		LDI R16,Low(RAMEND)		
	  	OUT SPL,R16			
 
	  	LDI R16,High(RAMEND)
	  	OUT SPH,R16
RAM_Flush:	
		LDI	ZL,Low(SRAM_START)	
		LDI	ZH,High(SRAM_START)
		CLR	R16			
Flush:		
		ST 	Z+,R16			
		CPI	ZH,High(RAMEND+1)	
		BRNE	Flush			
 
		CPI	ZL,Low(RAMEND+1)	
		BRNE	Flush
 
		CLR	ZL			
		CLR	ZH

		LDI	ZL, 30		
		CLR	ZH		
		DEC	ZL		
		ST	Z, ZH		
		BRNE	PC-2
;------------------------------------------------------
	in r16, DDR_LED
	ori	r16,1<<LED		
	out	DDR_LED,r16

	in r16, DDR_L
	ori	r16,1<<L		
	out	DDR_L,r16

	in r16, DDR_RF 
	ori	r16, (1<<RFXX_SCK|1<<RFXX_SDI|1<<RFXX_SEL)
	out	DDR_RF,r16

	in r16, DDR_m1 
	ori	r16, (1<<m1_en|1<<right_m1|1<<left_m1)
	out	DDR_m1,r16

	in r16, DDR_m2 
	ori	r16, (1<<m2_en|1<<right_m2|1<<left_m2)
	out	DDR_m2,r16

	in r16, DDR_m3
	ori	r16, (1<<m3_en|1<<right_m3|1<<left_m3)
	out	DDR_m3,r16

	in r16, DDR_m4
	ori	r16, (1<<m4_en|1<<right_m4|1<<left_m4)
	out	DDR_m4,r16

	in r16, DDR_m5
	ori	r16, (1<<m5_en|1<<right_m5|1<<left_m5)
	out	DDR_m5,r16
;------------------------------------------------------
	rcall IniOfRf01

	ldi OSRG, (0<<ISC11)|(0<<ISC10)
	out MCUCR, OSRG

	rcall Sleep_INIT
	rcall WDT_init
	
	ldi OSRG, (1<<INT1)
	out GIMSK, OSRG

	sei
	
Loop:
	clr ZH
	clr ZL
	rcall ReadEEP
	cpi temp1, $AA
	brne no_L
	OUTI PORT_L, (1<<L)
	rjmp with_L 
no_L:
	OUTI PORT_L, (0<<L)
with_L:
	sei
	clt
	in 		temp,MCUCR
	sbr		temp,SE
	out		MCUCR,temp
	rcall WDT_off
	;sleep
	nop
	nop
	nop
	rcall delay_mks
	rcall WDT_on
	in 		temp,MCUCR
	cbr		temp,SE
	out		MCUCR,temp
	cli

	brtc Loop
	lds temp, RFbuff1
	MOV	temp1, temp
	ANDI 	temp1, 0xF0

	CPI temp1, 0xF0
	brlo mx_mov
	clr ZH
	clr ZL
	SBRS temp, 0
	ldi temp1, 0xFF
	SBRC temp, 0
	ldi temp1, 0xAA
	rcall WriteEEP
	rjmp Loop
	

mx_mov:
	ANDI 	temp1, 0xF0

	ldi		r16,(1<<LED)
	in		r17,PORT_LED
	eor		r17,r16
	out		PORT_LED,r17

	CPI 	temp1, 0xA0
	BREQ	M1_mov

	CPI 	temp1, 0xB0
	BREQ	M2_mov

	CPI 	temp1, 0xC0
	BREQ	M3_mov

	CPI 	temp1, 0xD0
	BREQ	M4_mov

	CPI 	temp1, 0xE0
	BREQ	M5_mov

	rjmp Loop

;=============================================================================
M1_mov:
	
	MOV		temp1, temp
	ANDI 	temp1, 0x0F
	CPI 	temp1, 4
	BRGE	M1_mov_right

	M1_mov_left:
				OUTI PORT_m1, (0<<right_m1)|(1<<left_m1)|(1<<m1_en)
				rjmp mx_delay_cycle
							
	M1_mov_right:
				OUTI PORT_m1, (1<<right_m1)|(0<<left_m1)|(1<<m1_en)
				SUBI temp1, 3
				rjmp mx_delay_cycle
;=============================================================================
M2_mov:
	
	MOV		temp1, temp
	ANDI 	temp1, 0x0F
	CPI 	temp1, 4
	BRGE	M2_mov_right

	M2_mov_left:
				OUTI PORT_m2, (0<<right_m2)|(1<<left_m2)|(1<<m2_en)
				rjmp mx_delay_cycle
							
	M2_mov_right:
				OUTI PORT_m2, (1<<right_m2)|(0<<left_m2)|(1<<m2_en)
				SUBI temp1, 3
				rjmp mx_delay_cycle
;=============================================================================
M3_mov:
	
	MOV		temp1, temp
	ANDI 	temp1, 0x0F
	CPI 	temp1, 4
	BRGE	M3_mov_right

	M3_mov_left:
				OUTI PORT_m3, (0<<right_m3)|(1<<left_m3)|(1<<m3_en)
				rjmp mx_delay_cycle
							
	M3_mov_right:
				OUTI PORT_m3, (1<<right_m3)|(0<<left_m3)|(1<<m3_en)
				SUBI temp1, 3
				rjmp mx_delay_cycle
;=============================================================================
M4_mov:
	
	MOV		temp1, temp
	ANDI 	temp1, 0x0F
	CPI 	temp1, 4
	BRGE	M4_mov_right

	M4_mov_left:
				OUTI PORT_m4, (0<<right_m4)|(1<<left_m4)|(1<<m4_en)
				rjmp mx_delay_cycle
							
	M4_mov_right:
				OUTI PORT_m4, (1<<right_m4)|(0<<left_m4)|(1<<m4_en)
				SUBI temp1, 3
				rjmp mx_delay_cycle
;=============================================================================
M5_mov:
	
	MOV		temp1, temp
	ANDI 	temp1, 0x0F
	CPI 	temp1, 4
	BRGE	M5_mov_right

	M5_mov_left:
				OUTI PORT_m5, (0<<right_m5)|(1<<left_m5)|(1<<m5_en)
				rjmp mx_delay_cycle
							
	M5_mov_right:
				OUTI PORT_m5, (1<<right_m5)|(0<<left_m5)|(1<<m5_en)
				SUBI temp1, 3
				rjmp mx_delay_cycle

;=============================================================================
mx_delay_cycle:
	rcall delay_big
	subi temp1, 1
	CPI temp1, 0
	BRNE mx_delay_cycle
	
	OUTI PORT_m1, (0<<right_m1)|(0<<left_m1)|(0<<m1_en)
	OUTI PORT_m2, (0<<right_m2)|(0<<left_m2)|(0<<m2_en)
	OUTI PORT_m3, (0<<right_m3)|(0<<left_m3)|(0<<m3_en)
	OUTI PORT_m4, (0<<right_m4)|(0<<left_m4)|(0<<m4_en)
	OUTI PORT_m5, (0<<right_m5)|(0<<left_m5)|(0<<m5_en)				
;=============================================================================
	ldi		r16,(1<<LED)
	in		r17,PORT_LED
	eor		r17,r16
	out		PORT_LED,r17
rjmp Loop

;-------------------------------------------------------------------
IniOfRf01:
	sbi		PORT_SEL,RFXX_SEL
	sbi		PORT_SDI,RFXX_SDI
	cbi		PORT_SCK,RFXX_SCK

	sbi		DDR_SEL,RFXX_SEL
	sbi		DDR_SDI,RFXX_SDI
	cbi		DDR_SDO,RFXX_SDO
	cbi		DDR_nIRQ,RFXX_nIRQ
	sbi		DDR_SCK,RFXX_SCK

	nop
	nop
	nop

	ldi		r19,$00
	ldi		r20,$00
	rcall	RFXX_WRT_CMD

	ldi		r19,$8C
	ldi		r20,$89
	rcall	RFXX_WRT_CMD	;band=433MHz, frequency deviation = 67kHz

	ldi		r19,$40
	ldi		r20,$a6
	rcall	RFXX_WRT_CMD	;f=434MHz

	ldi		r19,$47
	ldi		r20,$c8
	rcall	RFXX_WRT_CMD	;4,8kbps	

	ldi		r19,$9B
	ldi		r20,$c6
	rcall	RFXX_WRT_CMD	;AFC setting

	ldi		r19,$2a
	ldi		r20,$c4
	rcall	RFXX_WRT_CMD	;Clock recovery manual control,Digital filter

	ldi		r19,$40
	ldi		r20,$C2
	rcall	RFXX_WRT_CMD	;output 1MHz

	ldi		r19,$80
	ldi		r20,$c0
	rcall	RFXX_WRT_CMD

	ldi		r19,$84
	ldi		r20,$ce
	rcall	RFXX_WRT_CMD	;use FIFO

	ldi		r19,$87
	ldi		r20,$ce
	rcall	RFXX_WRT_CMD

	ldi		r19,$81
	ldi		r20,$c0
	rcall	RFXX_WRT_CMD	;OPEN RX

ret
;-------------------------------------------------------------------
RFXX_WRT_CMD:
	push	r16
	cbi		PORT_SCK,RFXX_SCK
	cbi		PORT_SEL,RFXX_SEL
	ldi		r16,16
R_W_C1:

	cbi		PORT_SCK,RFXX_SCK
	nop
	nop

	sbrc	r20,7
	sbi		PORT_SDI,RFXX_SDI
	sbrs	r20,7
	cbi		PORT_SDI,RFXX_SDI
	nop
	nop

	sbi		PORT_SCK,RFXX_SCK
	nop
	nop

	lsl		r19
	rol		r20
	dec		r16
	brne	R_W_C1

	cbi		PORT_SCK,RFXX_SCK
	sbi		PORT_SEL,RFXX_SEL
	pop		r16
ret
;-------------------------------------------------------------------
RF01_RDFIFO:
		push	r16

		cbi		PORT_SCK,RFXX_SCK
		cbi		PORT_SDI,RFXX_SDI
		cbi		PORT_SEL,RFXX_SEL

		nop
		nop

		ldi		r16,16
skip_status:
		sbi		PORT_SCK,RFXX_SCK
		nop

		cbi		PORT_SCK,RFXX_SCK
		nop

		dec		r16
		brne	skip_status

		clr r17
		ldi	r16,8
read_data_byte:
		lsl		r17
		sbic	PIN_SDO,RFXX_SDO
		ori 	r17,$01

		sbi		PORT_SCK,RFXX_SCK
		nop

		cbi		PORT_SCK,RFXX_SCK
		nop

		dec		r16
		brne	read_data_byte


		sbi		PORT_SEL,RFXX_SEL

		pop r16
ret
;-------------------------------------------------------------------
.include "delays_4M.asm"
.include "sleep_mode.asm"
.include "WDT.asm"
.include "EEPROM.asm"
