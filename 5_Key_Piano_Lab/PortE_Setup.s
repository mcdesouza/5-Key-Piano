
; 
SYSCTL_RCGCGPIO_R  	EQU 0x400FE608

; Port E configuration registers
GPIO_PORTE_DIR_R   	EQU 0x40024400	; GPIO direction register (GPIODIR)
GPIO_PORTE_AFSEL_R 	EQU 0x40024420	; GPIO alternative function select (GPIOAFSEL)
GPIO_PORTE_PUR_R   	EQU 0x40024510	; GPIO pull-up resistor register (GPIOPUR)
GPIO_PORTE_PDR_R	EQU	0x40024514	; GPIO pull-down resistor register (GPIOPDR)
GPIO_PORTE_DEN_R   	EQU 0x4002451C	; GPIO digital enable (GPIODEN)
GPIO_PORTE_LOCK_R  	EQU 0x40024520	; GPIO lock register (GPIOLOCK)
GPIO_PORTE_CR_R    	EQU 0x40024524	; GPIO commit register (GPIOCR)
GPIO_PORTE_AMSEL_R 	EQU 0x40024528	; GPIO analog mode select (GPIOAMSEL)
GPIO_PORTE_PCTL_R  	EQU 0x4002452C	; GPIO port control (GPIOPCTL) 
GPIO_LOCK_KEY      	EQU 0x4C4F434B  ; Unlocks the GPIO_CR register




	THUMB
	
		  
; *********************************************************************
; *************************** CODE AREA IN ROM ************************
; *********************************************************************
	AREA    MyPortEConfig, CODE, READONLY, ALIGN=2		; Flash ROM
		    
	ALIGN
		  

	EXPORT	PortE_Config
		

PortE_Config
; PORT E INITIALIZATION CODE ***********************************
; step 1:  activate clock for Port E
	LDR	R1,	=SYSCTL_RCGCGPIO_R	; load R1 with address of GPIO Run Mode Clock Gating Control register
	LDR	R0, [R1]
	ORR	R0, R0, #0x00000010		; set bit 4 to turn on clock for Port E
	STR	R0, [R1]				; store bits back to RCGCGPIO register
	NOP
	NOP							; allow time for clock to configure
; step 2: unlock the lock register for Port E
	; 2a: load the key in the lock register
	LDR R1, =GPIO_PORTE_LOCK_R	; loads register R1 with address of Port E lock register
	LDR	R0, =0x4C4F434B			; loads value 0x4C4F434B into R0
	STR	R0, [R1]				; stores value 0x4C4F434B into lock register

	; 2b: give write access to GPIOAFSEL, GPIOPUR, GPIOPDR, & GPIODEN configuration registers
	LDR	R1, =GPIO_PORTE_CR_R	; loads register R1 with address of Port E commit register
	LDR	R0, [R1]				; loads register R0 with value in Port E commit register
	ORR	R0, R0, #0xFF			; sets bits 0-7 of R0 leaving other bits unchanged
	STR	R0, [R1]				; sets bits 0-7 of Port E commit register

; step 3: disable analog function --> analog function is disabled by default
	LDR	R1, =GPIO_PORTE_AMSEL_R	; analog mode select register
	LDR	R0, [R1]				; load content of GPIOAMSEL register to R0
	BIC	R0, R0, #0xFF			; clear bottom 8 bits of the GPIOAMSEL data
	STR R0, [R1]
  
; step 4: clear bits in PCTL --> most GPIO pins are set to GPIO on reset (i.e., no alternate function)
	LDR	R1, =GPIO_PORTE_PCTL_R	; load R1 with address of port control register
	MOV	R0, #0					; load 0s in all 32 bits to set all 8 pins to GPIO and not an alternate function (4 bits per pin)
	STR	R0, [R1]
 
; step 5: set direction register
	LDR	R1, =GPIO_PORTE_DIR_R	; load the address pointing to the Port E GPIO direction register(GPIODIR)
	LDR	R0,	[R1]				; load the current contents of the Port E GPIODIR
	BIC	R0,	R0, #0x3E			; clear bits ?? (make them inputs)
	ORR	R0, R0, #0x01			; set bits ?? (make them outputs) PEO OUTPUT
	STR R0, [R1]				; store the result in the Port E GPIODIR
	
	LDR	R1, =GPIO_PORTE_PDR_R
	LDR	R0,	[R1]
	ORR	R0,	#0x3E				; place pull-up resistor on input pins ??
	STR	R0, [R1]
	
; step 6: clear bits in alternate function register
	LDR	R1,	=GPIO_PORTE_AFSEL_R	; alternate function register address
	LDR	R0,	[R1]				; load AFSEL register value into R0
	BIC	R0, R0, #0x3F			; clear all port E bits 
	STR	R0, [R1]				; write back to AFSEL register
 
; step 7: enable digital port
	LDR	R1, =GPIO_PORTE_DEN_R	; load digital enable register address
	LDR	R0, [R1]				; load value of GPIODEN register into R0
	ORR	R0, R0, #0x3F			; set bits for pins ?? to enable digital pins 
	STR	R0, [R1]

	NOP
	
	BX	LR
	
    ALIGN      ; make sure the end of this section is aligned
    END        ; end of file