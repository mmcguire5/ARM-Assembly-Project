			AREA    GPIO, CODE, READWRITE	  ;AREA is GPIO, C,R
     ;;;;;;IMPORT EVERYHTING;;;;;;;;;;;; 
    EXPORT lab6
    EXPORT pin_connect_block_setup_for_uart0
    EXTERN uart_init
    EXTERN output_string
    EXTERN output_character
    EXTERN input_string
    EXTERN read_character
    EXTERN convert_to_num
	EXTERN LEDs
	EXTERN display_digit
	EXTERN RGB_LED
	EXTERN read_push_btns
	EXPORT FIQ_Handler
	EXTERN div_and_mod
	EXTERN interrupt_init
	EXTERN read_character_no_output	
	;EXTERN timer_init	


board DCB "|---------------|\n\r",0;null-terminated prompt
	  DCB "|               |\n\r",0
	  DCB "|               |\n\r",0
	  DCB "|               |\n\r",0
	  DCB "|               |\n\r",0
	  DCB "|               |\n\r",0
	  DCB "|               |\n\r",0
	  DCB "|               |\n\r",0
	  DCB "|               |\n\r",0
	  DCB "|               |\n\r",0
	  DCB "|               |\n\r",0
	  DCB "|               |\n\r",0
	  DCB "|               |\n\r",0
	  DCB "|               |\n\r",0
	  DCB "|               |\n\r",0
	  DCB "|               |\n\r",0
	  DCB "|---------------|\n\r",0
	
    ALIGN;ALIGN!
 
lab6	 	
	STMFD sp!, {lr};onyl preserve the ink register and stack pointer
	BL interrupt_init
	;BL timer_init
	
	
	;LDR r4, =board;load into r4 the prompt
	
	
	MOV r5, #0
	LDR r4, =board			 ;load into r3, digits_SET
	MOV r7, r4
	
	ADD r7, r7, #168
	MOV r6, #0x2A
	STRB r6, [r7]
printloop
	
	BL output_string;branch and link to output_string
	ADD r5, r5, #1
	CMP r5, #17
	BLT printloop
	MOV r3, #0
loop
	CMP r3, #0x69
	BEQ up
	CMP r3, #0x6A
	BEQ left
	CMP r3, #0x6B
	BEQ right
	CMP r3, #0x6D
	BEQ down
	B loop


up
	MOV r3, #0xC;form feed
	BL output_character
	
	MOV r3, #0x8
	BL output_character
	
	MOV r6, #0x20;clear the previous asterix
	STRB r6, [r7]
	
	MOV r5, #0
	MOV r6, #0x2A
	LDR r4, =board			 ;load into r3, digits_SET
	SUB r7, r7, #20
	STRB r6, [r7]
printloop_up
	BL output_string;branch and link to output_string
	ADD r5, r5, #1
	CMP r5, #17
	BLT printloop_up
	
	CMP r3, #0x69
	BNE loop
	;B left
	B stop


down
	MOV r3, #0xC;form feed
	BL output_character
	
	MOV r3, #0x8
	BL output_character
	
	MOV r6, #0x20;clear the previous asterix
	STRB r6, [r7]
	
	MOV r5, #0
	MOV r6, #0x2A
	LDR r4, =board			 ;load into r3, digits_SET
	ADD r7, r7, #20
	STRB r6, [r7]
printloop_down
	BL output_string;branch and link to output_string
	ADD r5, r5, #1
	CMP r5, #17
	BLT printloop_down
	
	CMP r3, #0x6D
	BNE loop
	;B left
	B stop

left
	MOV r0, r3
	MOV r3, #0xC;form feed
	BL output_character
	
	MOV r3, #0x8
	BL output_character
	
	MOV r6, #0x20;clear the previous asterix
	STRB r6, [r7]
	
	MOV r5, #0
	MOV r6, #0x2A
	LDR r4, =board			 ;load into r3, digits_SET
	SUB r7, r7, #1
	STRB r6, [r7]

printloop_left
	BL output_string;branch and link to output_string
	ADD r5, r5, #1
	CMP r5, #17
	BLT printloop_left
	
	CMP r0, #0x6A
	BNE loop
	;;;;;;; enabling the interrupt
	LDR r0, =0xE000401C
	MOV r1, #0
	;MOV r1, r1, LSL #20 ;;the value of the timer
	STR r1, [r0]

	LDR r0, =0xE0004004;T0TCR
	LDR r1, [r0]
	CMP r1, #0
	BGT skipenable
	EOR r1, r1, #0x01;set bit 0 to enable
skipenable
	STR r1, [r0]

	B loop
	;B stop

right
	MOV r3, #0xC;form feed
	BL output_character
	
	MOV r3, #0x8
	BL output_character
	
	MOV r6, #0x20;clear the previous asterix
	STRB r6, [r7]
	
	MOV r5, #0
	MOV r6, #0x2A
	LDR r4, =board			 ;load into r3, digits_SET
	ADD r7, r7, #1
	STRB r6, [r7]
printloop_right
	BL output_string;branch and link to output_string
	ADD r5, r5, #1
	CMP r5, #17
	BLT printloop_right
	
	CMP r3, #0x6B
	BNE loop
	;B left
	B stop
stop	
	LDMFD sp!,{lr}
	BX lr

FIQ_Handler
		STMFD SP!, {r0-r2,r4-r12, lr}   ; Save registers 

		LDR r0, =0xE0004000
		LDR r1, [r0]
		AND r1, r1, #0x02 ;clear everything but Bit 1
		CMP r1, #2;was Bit 1 set?
		BLT readchar ;the interrupt came form the keyboard
		LDR r0, =0xE0004000
		LDR r1, [r0]
		EOR r1, r1, #0x02 ;write a 1 to bit 1, clearing the interrupt
		;STMFD SP!, {r0-r2,r4-r12, lr}   ; Save registers 
readchar
		BL read_character_no_output
		;LDMFD SP!, {r0-r2,r4-r12, lr}   ; Restore registers

FIQ_Exit
		LDMFD SP!, {r0-r2,r4-r12, lr}
		SUBS pc, lr, #4


pin_connect_block_setup_for_uart0
	STMFD sp!, {r0, r1, lr}
	LDR r0, =0xE002C000  ; PINSEL0
	LDR r1, [r0]
	ORR r1, r1, #5
	BIC r1, r1, #0xA
	STR r1, [r0]
	LDMFD sp!, {r0, r1, lr}
	BX lr



	
	END