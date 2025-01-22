;****************** main.s ***************
; Program written by: Matthew DeSouza & Matthew Guerrero
; Brief description of the program: 5 key piano Lab using out put at PE0 and buttons connected externally on PE1-PE5
;	
  

 ; ********************************************************************
 ; ********************* EQU Label Definitions ************************
 ; ********************************************************************

; Port E Data registers
GPIO_PORTE_DATA_R  	EQU 0x400243FC  ; to read all bits on Port E
GPIO_PORTE_DATA_INS	EQU	0x400240F8	; read input pins on Port E
GPIO_PORTE_DATA_OUT	EQU	0x40024004	; write to output pins on Port E
	
; SysTick Timer addresses
NVIC_ST_CTRL_R 		EQU 0xE000E010	; SysTick Control and Status Register (STCTRL)
NVIC_ST_RELOAD_R	EQU 0xE000E014	; SysTick Reload Value register (STRELOAD)
NVIC_ST_CURRENT_R	EQU 0xE000E018	; SysTick Current Value Register (STCURRENT)

FREQ_C5    EQU 523    ; C5
FREQ_D5    EQU 587    ; D5
FREQ_E5    EQU 659    ; E5
FREQ_G5    EQU 784    ; G5
FREQ_A5    EQU 880    ; A5
	THUMB
		
; *********************************************************************
; ************************* ROM CONSTANTS AREA ************************
; *********************************************************************
; Constants and code area starts at address 0x0000.0000
	AREA    MyConstants, DATA, READONLY, ALIGN=2		; Flash EEPROM

		 
	ALIGN
		 
		 
; *********************************************************************
; ************************* RAM VARIABLES AREA ************************
; *********************************************************************
; SRAM variables area starts at address 0x2000.0000
	AREA    MyVariables, DATA, READWRITE, ALIGN=2		; SRAM

	ALIGN		  
		  
		  
; *********************************************************************
; *************************** CODE AREA IN ROM ************************
; *********************************************************************
	AREA    |.text|, CODE, READONLY, ALIGN=2		; Flash ROM
		    
	ALIGN
		  
	EXPORT  Start
		  
Start


Prog_Init

; Configure 80 MHz Clock System (uncomment next two lines if you want 80MHz clock)
;	IMPORT	SysClock80MHz_Config
;	BL		SysClock80MHz_Config
	NOP
; Configure Port E
	IMPORT	PortE_Config
	BL		PortE_Config
	NOP
; Configure SysTick Timer
	IMPORT	SysTick_Config
	BL		SysTick_Config
	NOP
	
	
; ******************************************************************
; ********************** MAIN PROGRAM ******************************
; ******************************************************************
;	f = 16MHz	-->	T = 62.5 ns
;	f = 80MHz	-->	T = 12.5 ns

Main_Loop
	LDR R1,=GPIO_PORTE_DATA_R
	LDR R9,[R1]
	CMP R9,#0x02
	BNE Check_2

	; Button 1 is Pressed
	MOV R10, #FREQ_C5
	BL Generate_Tone
	B Main_Loop
Check_2
	CMP R9,#0x04
	BNE Check_3
	
	; Button 2 is Pressed
	MOV R10, #FREQ_D5
	BL Generate_Tone
	B Main_Loop
Check_3	
	CMP R9,#0x08
	BNE Check_4
	
	;Button 3 is Pressed
	MOV R10, #FREQ_E5
	BL Generate_Tone
	B Main_Loop
Check_4	
	CMP R9,#0x10
	BNE Check_5
	
	;Button 4 is Pressed
	MOV R10, #FREQ_G5
	BL Generate_Tone
	B Main_Loop
Check_5	
	CMP R9,#0x20
	BNE Not_Pressed
	
	;Button 5 is Pressed
	MOV R10, #FREQ_A5
	BL Generate_Tone
	B Main_Loop
Not_Pressed
	MOV R9,#0
	LDR R2, =GPIO_PORTE_DATA_R
	LDR R3, [R2]
	BIC R3, R3, #0x01
	B Main_Loop



Generate_Tone
	MOV32 R8, #80000
	UDIV R8, R8, R9
Tone_Loop
	; Turn on PE0 (buzzer)
	LDR R2, =GPIO_PORTE_DATA_R
	LDR R3, [R2]
	EOR R3, R3, #0x01
	STR R3, [R2]
	
	MOV R0,R8
	BL SysTick_Wait
	
	LDR R2, =GPIO_PORTE_DATA_R
	LDR R3, [R2]
	AND R3, R3, #0x3F
	CMP R3, #0x0
	BEQ Stop_Tone
	
	B Tone_Loop

Stop_Tone
	LDR R3, [R2]
	BIC R3, R3, #0x01
	STR R3, [R2]
	B Main_Loop
	NOP
	

;************************ SUBROUTINES *****************************
;******************************************************************

SysTick_Wait
	; load counter with desired number of ticks
	LDR	R1,	=NVIC_ST_RELOAD_R	; R1 = &NVIC_ST_RELOAD_R
	
	; counter ticks N + 1 times so need to subtract 1
	SUB	R0,	#1					
	STR	R0,	[R1]
	
	; reset count bit
	LDR	R1, =NVIC_ST_CURRENT_R
	STR	R1, [R1]
	
	; get address of register that has COUNT bit
	LDR	R1,	=NVIC_ST_CTRL_R		; R1 = & NVIC_ST_CTRL_R


SysTick_Wait_loop
	LDR	R3,	[R1]
	ANDS R3, R3, #0x00010000	; COUNT bit is bit 16
	BEQ	SysTick_Wait_loop		; if COUNT == 0, the counter has not hit zero, so keep waiting
	BX	LR
	
	
; ******************** SysTick Wait 10ms ********************	
; Time delay using busy wait. This assumes 80MHz clock
; Input: R0 --> # of times to wait 10 ms before returning
; Output: none
; Modifies: R0, R4
; Function Calls: YES

DELAY10MS EQU	800000			; 800,000 ticks of 80MHz clock = 10ms
	
SysTick_Wait10ms
	PUSH {R4, LR}				; save current value of R4 and LR
	MOVS R4, R0					; R4 = R0 = remainingWaits
	BEQ SysTick_Wait10ms_done	; R4 == 0, done
SysTick_Wait10ms_loop
	LDR R0, =DELAY10MS			; R0 = DELAY10MS
	BL SysTick_Wait				; expects R0 to hold # of ticks to time
	SUBS R4, R4, #1				; R4 = R4 -1; remaining10msWaits--
	BHI SysTick_Wait10ms_loop	; if (R4 > 0), wait another 10ms
SysTick_Wait10ms_done			
	POP {R4, LR}
	BX	LR
	
	
;*********************** END SUBROUTINES **************************
      
    ALIGN      ; make sure the end of this section is aligned
    END        ; end of file

