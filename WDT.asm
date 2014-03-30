WDT_init:
	cli
	push OSRG
	wdr
	ldi	OSRG,(1<<WDCE)|(1<<WDE)
	out	WDTCSR,OSRG
	ldi	OSRG,(1<<WDE)|(1<<WDP2)|(1<<WDP1)|(1<<WDP0)
	out	WDTCSR,OSRG
	pop OSRG
	sei
ret

WDT_off:
	cli
	push OSRG
	wdr
	ldi OSRG, (1<<WDE)|(1<<WDCE) 
	out	WDTCSR,OSRG
	clr OSRG
	out	WDTCSR,OSRG
	pop OSRG
	sei
ret

WDT_on:
	cli
	push OSRG
	wdr
	ldi	OSRG,(1<<WDCE)|(1<<WDE)
	out	WDTCSR,OSRG
	ldi	OSRG,(1<<WDE)|(1<<WDP2)|(1<<WDP1)|(1<<WDP0)
	out	WDTCSR,OSRG
	pop OSRG
	sei
ret
