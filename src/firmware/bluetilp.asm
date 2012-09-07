 .include "tn85def.inc"

;***** Macros
.MACRO CALL_DELAY
	ldi		r16, @0
	rcall	delay
.ENDMACRO

;***** Constants
.equ	BUFF_END	= $60 + 100

;***** Pin definitions

.equ	PIN_RING	= PB3
.equ	PIN_TIP		= PB4

.equ	PIN_RESET	= PB0
.equ	PIN_TX		= PB1
.equ	PIN_RX		= PB2

.cseg
.org 0
	rjmp	reset
	rjmp	int_uart	//INT0

int_uart:
	cli

	push	r16
	push	r17
	push	r18

	in		r16, SREG
	push	r16

	ldi  r17,9;8 data bit + 1 stop bit

	rcall uart_delay;0.5 bit delay

int_uart2:	
	rcall uart_delay;1 bit delay
	rcall uart_delay  

	clc  ;clear carry
	sbic  PINB, PIN_RX;if RX pin high
	sec  ;

	dec  r17	;If bit is stop bit
	breq  int_uart3;   return
	;else
	ror  r16	;   shift bit into Rxbyte
	rjmp  int_uart2;   go get next

int_uart3:
	;sbis	PINB, PIN_RX	//make sure it has ended
	;rjmp	int_uart3

	rcall	uart_write_buff

	ldi		r16, 1<<INTF0
	out		GIFR, r16

	pop		r16
	out		SREG, r16
	
	pop		r18
	pop		r17
	pop		r16

	sei
	reti

;***** RING CONTROL
ring_set_high:
	cbi		DDRB, PIN_RING
	sbi		PORTB, PIN_RING
	ret

ring_set_low:
	cbi		PORTB, PIN_RING
	sbi		DDRB, PIN_RING
	ret

ring_wait_high:
	sbis	PINB, PIN_RING
	rjmp	ring_wait_high
	ret

ring_wait_low:
	sbic	PINB, PIN_RING
	rjmp	ring_wait_low
	ret

;**** TIP CONTROL
tip_set_high:
	cbi		DDRB, PIN_TIP
	sbi		PORTB, PIN_TIP
	ret

tip_set_low:
	cbi		PORTB, PIN_TIP
	sbi		DDRB, PIN_TIP
	ret

tip_wait_high:
	sbis	PINB, PIN_TIP
	rjmp	tip_wait_high
	ret

tip_wait_low:
	sbic	PINB, PIN_TIP
	rjmp	tip_wait_low
	ret

;**** CALC RECEIVE
;OUTPUT: r16 data
calc_receive:
	ldi		r17, 8

calc_receive_wait:
	in		r18, PINB
	andi	r18, (1<<PIN_RING)|(1<<PIN_TIP)
	cpi		r18, (1<<PIN_RING)|(1<<PIN_TIP)
	breq	calc_receive_wait

calc_receive_fork:
	sbis	PINB, PIN_TIP
	rjmp	calc_receive_zero
calc_receive_one:
	sec
	ror		r16

	rcall	uart_delay

	rcall	tip_set_low
	rcall	ring_wait_high
	rcall	tip_set_high

	rjmp	calc_receive_repeat
calc_receive_zero:
	clc
	ror		r16

	rcall	uart_delay

	rcall	ring_set_low
	rcall	tip_wait_high
	rcall	ring_set_high
calc_receive_repeat:
	dec		r17
	brne	calc_receive_wait
	
	rcall	ring_set_high
	rcall	tip_set_high

	ret

;**** CALC SEND
;INPUT: r16 byte to send
calc_send:
	ldi		r17, 8

	lsr		r16
calc_send_fork:
	brcc	calc_send_zero
calc_send_one:
	rcall	ring_set_low
	rcall	uart_delay
	rcall	tip_wait_low
	rcall	uart_delay
	rcall	ring_set_high
	rcall	uart_delay
	rcall	tip_wait_high
	rcall	uart_delay

	rjmp	calc_send_repeat
calc_send_zero:
	rcall	tip_set_low
	rcall	uart_delay
	rcall	ring_wait_low
	rcall	uart_delay
	rcall	tip_set_high
	rcall	uart_delay
	rcall	ring_wait_high
	rcall	uart_delay
	
calc_send_repeat:
	lsr		r16
	
	dec		r17
	brne	calc_send_fork
	
	rcall	ring_set_high
	rcall	tip_set_high

	ret

;**** UART READ BUFF
uart_read_buff:
	//check if empty
	cp		XH, YH
	brne	uart_read_buff0
	cp		XL, YL
	brne	uart_read_buff0

	clr		r16
	ret

uart_read_buff0:
	ld		r16, X+

	//check if past end of buffer
	cpi		XH, high(BUFF_END)
	brge	uart_read_buff_exit
	cpi		XL, low(BUFF_END)
	brge	uart_read_buff_exit

	//reset read ptr
	clr		XH
	ldi		XL, $60

uart_read_buff_exit:
	ret
	

;**** UART WRITE BUFF
;INPUT: r16 data
uart_write_buff:
	st		Y+, r16

	//check if past end of buffer
	cpi		YH, high(BUFF_END)
	brge	uart_write_buff_next
	cpi		YL, low(BUFF_END)
	brge	uart_write_buff_next

	//reset write ptr
	clr		YH
	ldi		YL, $60
uart_write_buff_next:
	//check if we need to push read ptr forward
	cp		YH, XH
	brne	uart_write_buff_exit
	cp		YL, XL
	brne	uart_write_buff_exit

	//push read ptr forward
	ld		r17, X+

	//check if past end of buffer
	cpi		XH, high(BUFF_END)
	brge	uart_write_buff_exit
	cpi		XL, low(BUFF_END)
	brge	uart_write_buff_exit

	//reset read ptr
	clr		XH
	ldi		XL, $60
uart_write_buff_exit:
	ret

;**** UART TX
.equ sb=1	;Number of stop bits (1, 2, ...)

uart_tx:
	cli
	ldi	r17,9+sb ;1+8+sb (sb is # of stop bits)	1
	com	r16	    ;Invert everything				1
	sec             ;Start bit						1

uart_tx0:	
	brcc uart_tx1	;if carry set					1 or 2
	cbi	 PORTB,PIN_TX	;send a '0'						1
	rjmp uart_tx2 	;else							2

uart_tx1:	
	sbi	PORTB,PIN_TX  	;send a '1'						2
	nop				;								1

uart_tx2:
	rcall uart_delay ;One bit delay					2
	rcall uart_delay

	lsr	r16	     ;Get next bit					1
	dec	r17	     ;If not all bit sent			1
	brne	uart_tx0 ;send next						1 or 2
   ;else
   	sei
 	ret  ;   return									4

;**** UART RX
;OUTPUT: r16 data
uart_rx:
	cli
	ldi  r17,9;8 data bit + 1 stop bit

uart_rx1:
	sbic  PINB, PIN_RX;Wait for start bit
	rjmp  uart_rx1
	rcall uart_delay;0.5 bit delay

uart_rx2:	
	rcall uart_delay;1 bit delay
	rcall uart_delay  

	clc  ;clear carry
	sbic  PINB, PIN_RX;if RX pin high
	sec  ;

	dec  r17	;If bit is stop bit
	breq  uart_rx3;   return
	;else
	ror  r16	;   shift bit into Rxbyte
	rjmp  uart_rx2;   go get next

uart_rx3:
	sei
	ret

;**** UART DELAY
.equ b=3 ;112500 bps @ 8 MHz crystal


uart_delay:
	ldi	r18,b			;1

uart_delay1:
	dec		r18		;1
	nop					;1
	nop					;1
	nop					;1
	nop					;1
	nop					;1
	brne 	uart_delay1	;1 or 2
	ret					;4      

;INPUT: r16 time
;DESTROYS: r0, r1, r2
delay:
	clr		r0
	clr		r1
delay0: 
	dec		r0
	brne	delay0
	dec		r1
	brne	delay0
	dec		r16
	brne	delay0
	ret

;***** Program Execution Starts Here

reset:
	//SETUP STACK
	ldi		r16, low(RAMEND)
	out		SPL, r16

	//SETUP PIN DIRECTIONS
	ldi		r16, (1<<PIN_RESET)|(1<<PIN_TX)
	out		DDRB, r16

	//TURN ON BLUETOOTH
	sbi		PORTB, PIN_RESET

	//RESET CALC CONNECTION
	rcall	ring_set_high
	rcall	tip_set_high

	//SETUP SERIAL INTERRUPT
	ldi		r16, (1<<ISC00)
	out		MCUCR, r16
	ldi		r16, (1<<INT0)
	out		GIMSK, r16

	//SET SERIAL PIN
	sbi		PORTB, PIN_TX

	clr		XH
	ldi		XL, $60
	clr		YH
	ldi		YL, $60

	sei
forever:
	//check if calc is talking to us
	in		r18, PINB
	andi	r18, (1<<PIN_RING)|(1<<PIN_TIP)
	cpi		r18, (1<<PIN_RING)|(1<<PIN_TIP)
	breq	check_buff	;no message - send out stored data

	rcall	calc_receive
	rcall	uart_tx

check_buff:
	cp		XL, YL
	brne	respond
	cp		XH, YH
	brne	respond

	rjmp	forever		;buffer empty

respond:
	rcall	uart_read_buff
	rcall	calc_send

	rjmp	forever

/*
Copyright (c) 2012 Owen Trueblood

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
