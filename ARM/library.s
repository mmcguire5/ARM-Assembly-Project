		AREA    library, CODE, READWRITE ;AREA is library, C, R

	;;;;;;;;;;;;;;;EXPORT EVERYTHING;;;;;;;;;;;;
    EXPORT  uart_init
    EXPORT    output_string
    EXPORT    output_character
    EXPORT    input_string
    EXPORT    read_character
    EXPORT    convert_to_num
	EXPORT	LEDs
	EXPORT  display_digit
	EXPORT RGB_LED 
	EXPORT read_push_btns
	EXPORT interrupt_init  
	EXPORT read_character_no_output	

	;;;;;;;; lookup table ;;;;;;;;;;
digits_SET	
		DCD 0x00001F80  ; 0
		DCD 0x00000300  ; 1 
		DCD 0x02D80	;2
		DCD 0x02780	;3
		DCD 0x03300	;4
		DCD 0x03680	;5
		DCD 0x03E80	;6
		DCD 0x00380	;7
		DCD 0x03F80	;8
		DCD 0x03380	;9
		DCD 0x03B80	;A
		DCD 0x03E00	;B
		DCD 0x01C80	;C
		DCD 0x02F00	;D
		DCD 0x03C80	;E
		DCD 0x00003880  ; F
		DCD 0x00000000  ;G

					   ;;;;;;;;;;;;;;;ALIGN EVERYTHING;;;;;;;;;;;;;;;
display_digit_prompt = "Please enter a digit (in decimal) to be displayed \n\r",0  	 ;display_digit_prompt
	ALIGN
led_prompt = "Please enter a pattern\n\r",0		   ;led_prompt
	ALIGN
rgb_prompt = "Enter:\n\r 1->Red\n\r2->Blue\n\r3->Green\n\r4->Purple\n\r5->White\n\r6->Yellow\n\r",0	   ;rgb_prompt
	ALIGN
answer = "        ",0		  ;answer
	ALIGN
button_answer = "\n\rHere is your number:  ",0	  ;button_answer
	ALIGN

uart_init
    STMFD SP!,{LR} 
    
    LDR r0, =0xE000C00C;load the address 0xE000C00C into r0
    LDR r1, =0xE000C000;load the address 0xE000C000 into r1
    LDR r2, =0xE000C004;load the address 0xE000C004 into r2
    
    MOV r3, #131;initialize r3 to 131
    MOV r4, #120;initialize r3 to 120
    MOV r5, #0;initialize r3 to 0
    MOV r6, #3;initialize r3 to 3
    
    STR r3, [r0];store r3 into r0
    STR r4, [r1];store r4 into r1
    STR r5, [r2];store r5 into r2
    STR r6, [r0];store r6 into r0
    
    LDMFD SP!,{LR}
    BX lr
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
output_string
    STMFD SP!, {R0 - R3, R5 - R12, LR};{R0 - R3, R5 - R12, LR}
    MOV R5, R4;move r4 into r5
os_loop;os_loop
    LDRB r3, [r4], #1  ;load into r3, r4; increment r4;; pointer to ,char load into r3

    CMP r3, #0       ;compares char to null (ascii 0)
    BEQ os_end       ;if equal (null) end

    BL output_character         ;else branch and link to output_character;;else get the char
    B os_loop;branch to os_loop
os_end
    LDMFD SP!, {R0 - R3, R5 - R12, LR}
    BX LR




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; R4 = base address of where you store string
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
input_string
    STMFD SP!, {R0 - R3, R5 - R12, LR};R0 - R3, R5 - R12, LR
    MOV R5, R4;Move r4 into r5;; Save base of string
is_loop
    BL read_character;branch and link to read_character
    CMP r3, #0x0D;compare r3 to ascii enter (0x0D)
    BEQ terminate;if equal branch to terminate
    STRB R3, [R4], #1;Store r3 into r4; increment r4;;    Store in memory location; increment address
    B is_loop;branch to is_loop
terminate
    MOV R3, #0;move into r3 the null character
    STRB R3, [R4];store into r4 r3
    MOV R4, R5;move into r4 r5;;restore r4 to the base address of the string
    LDMFD SP!, {R0 - R3, R5 - R12, LR}
    BX LR
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;will output whatever character is in r3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
output_character;outputs register r3
    STMFD SP!, {R0 - R2, R4 - R12, lr};R0 - R2, R4 - R12, lr
getchar
    LDR r4, =0xE000C014;store into r4  =0xE000C014;;address of status reg
    LDRB r5,[r4];load byte at r4 into r5;;r1 value of status reg
    AND r5, r5, #0x00000020;mask the 5th bit of r5 (0x020)
    CMP r5, #0;compare r5 with 0
    BLE getchar;is less than equal branch to getchar
    LDR r6, =0xE000C000;load r6 to 0xE000C000;;address to be stored
    STRB r3, [r6];store byte r3 into r6
    LDMFD sp!, {R0 - R2, R4 - R12, lr}
    BX lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;will read whatever character is in input from the keyboard
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
read_character
    STMFD SP!, {lr}
readchar
    LDR r0, =0xE000C014;load inot r0 0xE000C014;;address of status reg
    LDRB r1,[r0];load byte r0 into r1;;r1 value of status reg
    AND r1, r1, #0x00000001;and r1 with the first bit
    CMP r1, #0;compare r1 to null(0)
    BLE readchar;if less than equal branch to readchar
    LDR r5, =0xE000C000;load into r2 0xE000C000;; address to be stored
    LDR r3, [r5];load from r2 into r3
    BL output_character  ;branch and link into output_character 
    LDMFD sp!, {lr}
    BX lr  
	
read_character_no_output
    STMFD SP!, {lr}
readchar1
    LDR r0, =0xE000C014;load inot r0 0xE000C014;;address of status reg
    LDRB r1,[r0];load byte r0 into r1;;r1 value of status reg
    AND r1, r1, #0x00000001;and r1 with the first bit
    CMP r1, #0;compare r1 to null(0)
    BLE readchar1;if less than equal branch to readchar
    LDR r5, =0xE000C000;load into r2 0xE000C000;; address to be stored
    LDR r3, [r5];load from r2 into r3
    ;BL output_character  ;branch and link into output_character 
    LDMFD sp!, {lr}
    BX lr  


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;r4 is the string coming in and then r4 contains the number coming out
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
convert_to_num
    STMFD SP!, {R0 - R3, R5 - R12, lr};R0 - R3, R5 - R12, lr
    ;number returned in r4, temporary number in r8
    MOV r8, #0;initialize r8 to 0
    SUB r4, r4, #1;subtract 1 from r4, this way when it adds 1 at the beginning of the loop it starts at the first digit
    MOV r10, #10;r10 is the constant 10
numloop
    ADD r4, r4, #1;increment r4 1;;increment r4 to the next digit
    LDRB r6, [r4];load from r4 into r6;;load the digit
    CMP r6, #0x2D;check if r6 is "-" or ascii value (0x2D)
    BEQ numloop;branch if equal to numloop;;don't evaluate it
    SUB r6, r6, #0x30;subtract hex 30 (0x30) from the number (r6) to convert it to a decimal number
    LDRB r7, [r4, #1];load into r7 r4+1;;check the next number and increment r4
    CMP r7, #0x0;compare r7 to 0;;is the next number the null character?
    BEQ stopnum;if equal branch to stopnum;;if the next number isnt enter, continue going through the string
    ADD r8, r8, r6;add the digit (r6) to the current tmp number (r8)
    MUL r8, r10,r8;multiply r8 by 10 (so by r10)
    B numloop;branch to numloop
stopnum
    ADD r8, r8, r6;add r6 to r8;;add the last digit
    MOV r4, r8;move into r4 r8;;move into r4 the number
    
    LDMFD sp!, {R0 - R3, R5 - R12, lr}
    BX lr

LEDs
		STMFD SP!, {r1-r3, r5-r10,lr}
		MOV r4, r0;move into r4, r0
		;set the direction of port 1
        LDR r2, =0xE0028018;IO1DIR
        MOV r3, #0x0F0000;move into r3 1s in positions 16-19
        STR r3, [r2] ;store r3 into r2

		;;;;;;;;;;;;;;;   initialize LEDs ;;;;;;;;;;;;;;;;;;;
		;set the values of the LEDs
        LDR r5,  =0xE0028014;IO1SET
        MOV r6, #0x0F0000 ;move into r3 1s in positions 16-19
        STR r6, [r5] ;store into r5, r6
      
        ;clr the values of the LEDs
        LDR r7, =0xE002801C;IO0CLR
        MOV r8, #0x0F0000 ;move into r3 1s in positions 16-19
        STR r8, [r7]	 ;store into r7, r8

		;turn off the LEDs
        LDR r5,  =0xE0028014;IO1SET
        MOV r6, #0x0F0000 ;move into r3 1s in positions 16-19
        STR r6, [r5]   ;store inot r5, r6
        

		MOV r0, #-1;r0 is what digit we're on. r0 intialized to -1
		MOV r7, #15	 ;move into r7, #15
		MOV r10, #0;r10=>string to build, initialized to #0
loop1	ADD r0, r0, #1	  ;incremnet r0 by 1
		ADD r7, r7, #1	  ;increment r7 by 1
		LDRB r1, [r4], #1 ;load into r1, the byte at r4, increment r4 by 1 afterwards
		SUB r1, r1, #0x30 ;subtract #0x30 from r1 
		
        MOV r1, r1, LSL r7	;move into r1, r1 logically shifted left r7
		ADD r10, r10, r1	;add to r10, r1
		CMP r7, #19			;compare r7 to #19
		BLT loop1			;branch less than to loop1

		;;;; Here r10 contains what the board wants
        LDR r2,  =0xE0028014;IO1SET
		STR r10, [r2]       ;store into r2, r10
		LDR r3, =0xE002801C	;IO1CLR
        STR r10, [r3]		;store into r3, r10
		LDMFD sp!, {r1-r3, r5-r10,lr}
		BX lr

;----------------------------------------
;display_digit->digit passed in as r0
;----------------------------------------
display_digit
	STMFD SP!,{r2-r10,lr}

	;;;reset inputs;;;;;
;set the direction on port 0
        LDR r4, =0xE0028008;IO0DIR
        MOV r5, #0x3F80	   ;7-seg is 1s (3F80)
        STR r5, [r4]	   ;store into r0, r1

	
	;;;;;;clear the 7-Seg ;;;;;
		MOV r5, #0x3F80		   ;Move 1s into positions 7-13
		LDR r6, =0xE002800C	   ;IO0CLR 
		STR r5, [r6]		   ;store into r6, r5
	  
		
		LDR r1, =0xE0028000;base address
		LDR r3, =digits_SET			 ;load into r3, digits_SET
		MOV r0, r0, LSL #2			 ;LSL r0 by #2
		LDR r2, [r3,r0]				 ;load into r2, r3 incremented by r0 beforehand
		STR r2, [r1, #4]			 ;store into r1 + #4, r2
		
		MOV r0, r4;put number back in r0
		
	LDMFD SP!, {r2-r10,lr}
	BX lr
 
   
RGB_LED   
        STMFD SP!,{r1-r10,lr}
		MOV r4, r0
        

        ;Setup PIN connect block
        LDR r0, =0xE002C004 ;PINSEL1
        MOV r1, #0x260000	;set pins 18, 19, and 21 to 1s
        STR r1, [r0]		;store into r1, r0

        ;IO0DIR
        LDR r1, =0xE0028008	;IO0DIR
        MOV r10, #0x260000	;set pins 18, 19, and 21 to 1s
        STR r10, [r1]		;store r10 into r9

        ;IO0SET
        LDR r0, =0xE0028004	;IO0SET
        MOV r1, #0x260000	;set pins 18, 19, and 21 to 1s
        STR r1, [r0]		;store r1 into r0

        CMP r4, #2			;comapre r4 to 0
        BLT Red				;branch less than to red
        BEQ Blue			;branch equal to blue

        CMP r4, #3			;compare r4 to 3
        BEQ Green			;branch equal to green

        CMP r4, #4			;compare r4 to 4
        BEQ Purple			;branch equal to purple

        CMP r4, #5			;compare r4 to 5
        BEQ White			;branch equal to white
        BGT Yellow			;branch greater than to yellow


Red
        ;write to IO0CLEAR a 1 in slot 17
        LDR r2, =0xE002800C	;IO0CLR
        MOV r3, #0x20000	;move into r2 1s in postion 17
        STR r3, [r2]		;store r3 into r2

        B STOP

Blue
        ;Write to IO0Clear a 1 in slot 18
        LDR r4, =0xE002800C	 ;IO0CLR
        MOV r5, #0x40000
        STR r5, [r4]
        B STOP    

Green
        ;write to IO0Clear a 1 in slot 21
        LDR r6, =0xE002800C	 ;IO0CLR
        MOV r7, #0x200000
        STR r7, [r6]		 ;store into r6, r7
        B STOP				 ;branch to stop

Purple	;write to IO0Clear a 1 in slot 17 and 18
        LDR r2, =0xE002800C	 ;IO0CLR
        MOV r3, #0x60000	 
        STR r3, [r2]		 ;store into r2, r3
		B STOP

White	;write to IO0Clear a 1 in slot 17, 18, and 21
        LDR r2, =0xE002800C	 ;IO0CLR
        MOV r3, #0x260000
        STR r3, [r2]		 ;store into r2, r3
		B STOP				 ;branch to stop

Yellow	;write to IO0Clear a 1 in slot 17 and 21
        LDR r4, =0xE002800C	 ;IO0CLR
        MOV r5, #0x220000
        STR r5, [r4]		 ;store into r4, r5
        B STOP  			 ;branch to stop

        B STOP				 ;branch to stop

STOP
        LDMFD SP!,{r1-r10,lr}
        BX lr 


read_push_btns
		STMFD SP!,{r1-r10,lr}
		;;;;;;;;;;;;;;turn off the LEDs ;;;;;;;;;;;;;;
		;set the values of the LEDs	
        LDR r5,  =0xE0028014;IO1SET
        MOV r6, #0x0F0000	;1s into positions 16-19
        STR r6, [r5]		;store r6 into r5
      
        ;clr the values of the LEDs
        LDR r7, =0xE002801C ;IO1CLR
        MOV r8, #0x0F0000	;1s into positions 16-19
        STR r8, [r7]		;store into r7, r8

		;turn off the LEDs
        LDR r5,  =0xE0028014;IO1SET
        MOV r6, #0x0F0000	;1s into positions 16-19
        STR r6, [r5]		;store into r5, r6
        


     	;set the direction of port 1
        LDR r2, =0xE0028018;IO1DIR
        MOV r3, #0x0000000 ;move all zeros into r3
        STR r3, [r2]	   ;store into r2, r3

		;;read from IO1PIN
		LDR r2, =0xE0028010
		LDR r3, [r2];the value at the pins go into r3
		
		MOV r3, r3 ,LSR #20	 ;LSL r3 by #20
		AND r3, r3, #0x0F	 ;AND r3 with #0xF

		;;;;;;output a answer message
		LDR r4, =button_answer ;load into r4, button_answer
		 BL output_string	   ;brnach and link to output_string

		;;;now to flip the bits
		MOV r5, #0			   ;move into r5, #0
		AND r4, r3, #1		   ;AND into r4, r3 and #1
		CMP r4, #0			   ;compare r4 to #0
		BEQ addeight		   ;branch equal addeight

flip1	AND r4, r3, #2		   ;AND into r4, r3 and #2
		CMP r4, #0			   ;compare r4 to #0
		BEQ addfour			   ;branch equal addfour

flip2	AND r4, r3, #4		   ;AND into r4, r3 and #4
		CMP r4, #0			   ;compare r4 to #0
		BEQ addtwo			   ;branch equal addtwo

flip3	AND r4, r3, #8		   ;AND into r4, r3 and #8
		CMP r4, #0			   ;compare r4 to #0
		BEQ addone			   ;branch equal addone
		BNE flipend			   ;branch not equal to flipend
		
addone  ADD r5, r5, #1		   ;increment r5 by #1
		B flipend			   ;branch to flipend

addtwo  ADD r5, r5, #2		   ;increment r5 by #2
		B flip3				   ;branch to flipend

addfour ADD r5, r5, #4		   ;increment r5 by #4
		B flip2				   ;branch to flipend

addeight ADD r5, r5, #8		   ;increment r5 by #8
		B flip1				   ;branch to flipend

		;;;;;number they input is now in r5
		MOV r0, r5 ;;;move r5 into r0, so when it returns its in r0
flipend
		 ;;;now how to print the decimal value
		 CMP r5, #9			   ;compare r5 to #9
		 BGT ten			   ;branch greater than 10 to ten

printsingledigit
		 ;;;now the number is a single digit
		 ADD r5, r5, #0x30	   ;increment r5 by #0x30
		 MOV r3, r5			   ;move into r3, r5
		 BL output_character   ;branch and link to output_character
		 B	endbutton		   ;branch to endbutton

ten      MOV r3, #0x31		   ;Move into r3, #0x31
		 BL output_character   ;branch and link to output_character
		 SUB r5, r5, #10	   ;decrement r5 by #10
		 B printsingledigit	   ;branch to printsingledigit
		 

endbutton					   ;endbutton
		LDMFD SP!,{r1-r10,lr}
        BX lr
	

	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;STOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
;STOP	;LDMFD r13!, {r2-r12, r14}
        ;LDMFD   SP!, {lr}
		;BX lr      ; Return to the C program	
 
	LDMFD sp!, {lr}
	BX lr
	

interrupt_init       
		STMFD SP!, {r0-r1, lr}   ; Save registers above and including r2 
		MOV r4, #0x8000;move into r4 #0x8000
		ADD r4, r4, #0x40;increment r4 by #0x40

		; Push button setup		 
		LDR r0, =0xE002C000;load into r0 the address 0xE002C000 
		LDR r1, [r0];load into r1 the value stored at address r0
		ORR r1, r1, #0x20000000;orr r1 with #0x20000000
		BIC r1, r1, #0x10000000; bit clear r1 with #0x10000000
		STR r1, [r0]  ; PINSEL0 bits 29:28 = 10;;store at the adress r0 the value in r1

		; Classify sources as IRQ or FIQ
		LDR r0, =0xFFFFF000;load into r0 the address 0xFFFFF000
		LDR r1, [r0, #0xC];load into r1 the value at address r0 + #0xC
		ORR r1, r1, r4;orr r1 with r4 and store into r1
		STR r1, [r0, #0xC];store the value of r1 at the address of r0 + #0xC
		
		; Enable Interrupts
		LDR r0, =0xFFFFF000;load into r0 the address 0xFFFFF000
		LDR r1, [r0, #0x10];load into r1 the value at address r0 + #0x10
		ORR r1, r1, r4;orr r1 with r4 and store into r1
		STR r1, [r0, #0x10];store the value of r1 at the address of r0 + #0x10

		; External Interrupt 1 setup for edge sensitive
		LDR r0, =0xE01FC148;load into r0 the address 0x0xE01FC148
		LDR r1, [r0];load into r1 the value at address r0 
		ORR r1, r1, #2  ; EINT1 = Edge Sensitive;;orr r1 with #2
		STR r1, [r0];store the value of r1 at the address of r0

		; UART0
		LDR r0, =0xE000C004;load into r0 the address 0xE000C004
		LDR r1, [r0];load into r1 the value at address r0 
		ORR r1, r1, #1  ; RDA 1;; orr r1 with #1
		STR r1, [r0];store the value of r1 at the address of r0

		; Enable FIQ's, Disable IRQ's
		MRS r0, CPSR;mrs r0 with the CPSR
		BIC r0, r0, #0x40;bit clear r0 with #0x40
		ORR r0, r0, #0x80;orr r0 with #0x80
		MSR CPSR_c, r0;msr the CPSR_c with r0

		LDMFD SP!, {r0-r1, lr} ; Restore registers
		BX lr             	   ; Return


timer_init       
		STMFD SP!, {r0-r1, lr}   ; Save registers above and including r2 
		MOV r4, #0x8000;move into r4 #0x8000
		ADD r4, r4, #0x50;increment r4 by #0x50

		; Push button setup		 
		;LDR r0, =0xE002C000;load into r0 the address 0xE002C000 
		;LDR r1, [r0];load into r1 the value stored at address r0
		;ORR r1, r1, #0x20000000;orr r1 with #0x20000000
		;BIC r1, r1, #0x10000000; bit clear r1 with #0x10000000
		;STR r1, [r0]  ; PINSEL0 bits 29:28 = 10;;store at the adress r0 the value in r1

		; Classify sources as IRQ or FIQ
		LDR r0, =0xFFFFF000;load into r0 the address 0xFFFFF000
		LDR r1, [r0, #0xC];load into r1 the value at address r0 + #0xC
		ORR r1, r1, r4;orr r1 with r4 and store into r1
		STR r1, [r0, #0xC];store the value of r1 at the address of r0 + #0xC
		
		; Enable Interrupts
		LDR r0, =0xFFFFF000;load into r0 the address 0xFFFFF000
		LDR r1, [r0, #0x10];load into r1 the value at address r0 + #0x10
		ORR r1, r1, r4;orr r1 with r4 and store into r1
		STR r1, [r0, #0x10];store the value of r1 at the address of r0 + #0x10

		; External Interrupt 1 setup for edge sensitive
		;LDR r0, =0xE01FC148;load into r0 the address 0x0xE01FC148
		;LDR r1, [r0];load into r1 the value at address r0 
		;ORR r1, r1, #2  ; EINT1 = Edge Sensitive;;orr r1 with #2
		;STR r1, [r0];store the value of r1 at the address of r0

		; Timers
		LDR r0, =0xE0004014;T0MCR load into r0 the address 0xE000C004
		LDR r1, [r0];load into r1 the value at address r0 
		ORR r1, r1, #0x10  ; Timer0= Bit 4
		STR r1, [r0];store the value of r1 at the address of r0

		; Enable FIQ's, Disable IRQ's
		MRS r0, CPSR;mrs r0 with the CPSR
		BIC r0, r0, #0x40;bit clear r0 with #0x40
		ORR r0, r0, #0x80;orr r0 with #0x80
		MSR CPSR_c, r0;msr the CPSR_c with r0

		LDMFD SP!, {r0-r1, lr} ; Restore registers
		BX lr             	   ; Return






	END