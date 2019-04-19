*
*
* loop forever
*
MAIN		INC	RND				; a bit more randomness...
		INC	RND2
		INC	RND3
		LDA	bMark
		BNE	mark2
mark1		LDA	#$20
		STA	ora1+1
		LDA	#$40
		STA	ora2+1			
		JSR	DisplayMatrix
		LDA	KYBD				; loop until keypress
		BMI 	END
		LDA	#$60
		STA	ora1+1
		JSR	DisplayMatrix
		LDA	KYBD				; loop until keypress
		BMI 	END
		LDA	#$20
		STA	ora1+1
		JSR	DisplayMatrix
		LDA	KYBD				; loop until keypress
		BMI 	END
		LDA	#$60
		STA	ora1+1
		JSR	DisplayMatrix
		LDA	KYBD				; loop until keypress
		BMI 	END
		LDA	#$20
		STA	ora1+1
		JSR	DisplayMatrix
		LDA	KYBD				; loop until keypress
		BMI 	END
					
bw1     	LDA 	bMark				; wait for next part
        	BEQ 	bw1
        	JMP	MAIN				
					
mark2		JSR	DisplayRF

		LDA	KYBD				; loop until keypress
		BMI 	END
		JMP	MAIN
*										
END		SEI					; stop interrupts
		LDA	STROBE
		JSR	CLEAR_RIGHT
		JSR	CLEAR_LEFT
		JSR	RESET_RIGHT			; mute Mockingboard
		JSR	RESET_LEFT
		;BIT	$C404
		STA	$C002
		STA	$C004
		STA 	$C051      			; SWITCH TO TEXT -> end of program
        	STA 	$C052
        	STA 	$C054
          	LDA	READROM				; switch of LC
          	JSR	$FB39				; command TEXT
		JSR	HOME
		JMP	$fa62				; reset
*
*
*	HIRES screen swipe
*
DisplayMatrix
        	LDA 	#40
        	STA 	Count2
        	TAX					; reset TableAct2
        	LDA	#$FF
lpResTA2  	STA 	TableAct2,X
		STZ	TableOrd2,X
        	DEX
        	CPX	#$FF
        	BNE	lpResTA2
		STZ	Counter
					
BPb     	JSR 	WAITVBL
BP2b		LDA 	TableSpeed2,X
        	STA 	Speed

bAffColb	LDA 	TableAct2,X
        	BEQ 	suiteb    			; check if TableAct2,X = 0 -> do nothing for this coulumn
        	JSR 	RANDOM02			; get random number: 0,1,2
        	BNE 	suiteb      			; only one out of three is displayed randomly

bAffTilde	LDY 	TableOrd2,X			; get current HIRES line
bAff2     	LDA 	THB,Y				; load HIRES base adress LO-byte
        	STA 	OffDestb+1			; 
        	STA 	OffSrcb+1			;
        	LDA 	THH,Y				; load HIRES base adress HI-byte
ora2    	ORA 	#$40         			; set destination screen
sta2    	STA 	OffDestb+2
		AND	#$BF				; reset $20
ora1    	ORA	#$20				; self-modifying -> which source screen?
sta1    	STA 	OffSrcb+2
OffSrcb 	LDA 	$4000,X				; load HIRES byte
OffDestb	STA 	$2000,X     			; store HIRES byte
        	INY
        	CPY 	#192				; all done for this column?
        	BNE 	s1b				; nope
        
        	STZ 	TableAct2,X			; this column is done
        	DEC 	Count2				; all 40 columns finished?
        	BNE 	suiteb				; nope 
        	JSR	ShortWait			; yes, wait and return
        	RTS

s1b    		DEC 	Speed				; how many lines to draw per round?
        	BNE 	bAff2				; go for the remaining ones...
        	TYA
        	STA 	TableOrd2,X			; save current line number 
 
suiteb  	INX					; process next column
        	CPX 	#40
        	BNE 	s2b				; all columns processed?
        	LDX 	#00				; yes -> reset X-value
s2b     	INC 	Counter				; check for new VBL-signal after processing 15 columns!
        	LDA 	Counter
        	CMP 	#15
        	BEQ 	go1b
        	JMP 	BP2b
        
go1b    	STZ 	Counter				; reset VBL-counter
        	JMP 	BPb
*
*
* control code rainfall display
*
DisplayRF
        	LDA 	#%1111          		; 15
        	STA 	NUMBER				; set rainfall activity level
        	LDA 	#$FF
        	STA 	Count3
        
BP3     	JSR 	WAITVBL
        	JSR 	DisplayRain
        	DEC 	Count3
        	BNE 	BP3

        	LDA 	#%111           		; 07 
        	STA 	NUMBER
        	LDA 	#$FF
        	STA 	Count3
        		
BP4     	JSR 	WAITVBL
        	JSR 	DisplayRain
        	DEC 	Count3
        	BNE 	BP4
        
        	LDA 	#%11            		; 03
        	STA 	NUMBER
        	LDA 	#$FF
        	STA 	Count3
        
BP5     	JSR 	WAITVBL
        	JSR 	DisplayRain
        	LDA 	bMark				; synchronize animation with music
        	BNE 	BP5
        
RF_RTS		RTS
* ============================================================
*
* short waiting routine
*
ShortWait
		LDX	#38				; number of 512ms wait cycles
		LDA	#255
sWAITlp		JSR	WAIT
		DEX
		BPL	sWAITlp
		RTS					
* ============================================================
*
* display rainfall
*
DisplayRain
BP2r
        	LDX 	IndexCol
        	LDA 	TableSpeed,X
        	STA 	Speed
        	LDA 	TableAbs,X
        	STA 	Abs     

bAffCol 	LDX 	IndexCol
        	LDA 	TableAct,X
        	BEQ 	nada           			; nothing happens on that column
        	BPL 	display
        	LDX 	#00            			; print "empty" character (space)
        	BRA 	car

display 	JSR 	RANDOM32			; randomly choose one out of 32 characters

car    		LDA 	TOffCharL,X			; get adress for character data
        	STA 	OffChar+1
        	LDA 	TOffCharH,X
        	STA 	OffChar+2
        	LDY 	#00
        		
bAffChar	STY 	iChar				; get character data and print it on the screen
        	LDX 	IndexCol 			; get column to print to 1..40
        	LDY 	TableOrd,X			; get current Y-position of already printed chars in the selected column
        	LDA 	THB,Y				; get HIRES base-adress
        	STA 	OffDest+1		
        	LDA 	THH,Y
        	ORA	#$40				; page 2
        	STA 	OffDest+2
        	INC	TableOrd,X			; save current Y-position of last character drawn
        	LDY 	iChar
OffChar 	LDA 	$0000,Y
OffDest 	STA 	$2000,X
        	INY
        	CPY 	#07
        	BNE 	bAffChar
        	
nada   		INC 	TableHeigh,X	  		; increment current height of rain column
        	LDA 	TableHeigh,X
        	CMP 	TableHeighM,X
        	BNE 	s2r				; maximum height reached?
        	STZ 	TableHeigh,X	  		; yes -> reset current column
        	STZ 	TableOrd,X
        	JSR 	RANDOM15       			; set new random maximum column height
        	STA 	TableHeighM,X
        	JSR 	RANDOMXX       			; randomly select next action in this column
        	BEQ 	s3r            			; 0  -> display new code rain
        	CMP 	#01
        	BEQ 	s5r            			; 1  -> do nothing / leave column 
        	LDA 	#$FF           			; 2+ -> erase column
        	BRA 	s4r
s3r     	LDA 	#$01            
        	BRA 	s4r
s5r     	LDA 	#$00            
s4r     	STA 	TableAct,X		  
        	BRA 	suiter
        
s2r     	LDA 	TableRain,X    			; do not show the "full" char since we are not active in this column
        	BNE 	s6r
        	LDA 	TableAct,X     			; do not show the "full" char since we are erasing this column
        	BMI 	s6r
        	JSR 	AddDrop

s6r     	DEC 	Speed				; char display speed in a column
        	BEQ 	suiter
        	JMP 	bAffCol
        
suiter  	INX				 	; process next column
        	CPX 	#40				; all 40 columns done?
        	BNE 	s1r
        	LDX 	#00
s1r     	STX 	IndexCol

        	INC 	Counter
        	LDA 	Counter
        	CMP 	#10
        	BEQ 	go1r
        	JMP 	BP2r
go1r    	STZ 	Counter
        
        	RTS
*
*
*
*
; -----------------------------------------------------------------------------
AddDrop							; add a solid "drop" to the code rain in a column
        	LDX 	#33        			; solid "drop" char
        	LDA 	TOffCharL,X
        	STA 	OffChar2+1
        	LDA 	TOffCharH,X
	        STA 	OffChar2+2
        
        	LDX 	IndexCol 
        	LDY 	TableOrd,X
        	STY 	Temp
        
		LDY 	#00
bAffChar2	STY 	iChar
        	LDY 	Temp
        	LDA 	THB,Y
        	STA 	OffDest2+1
        	LDA 	THH,Y
        	ORA	#$40				; page 2
        	STA 	OffDest2+2
        	INY
        	STY 	Temp
        	LDY 	iChar
OffChar2	LDA 	$0000,Y
OffDest2	STA 	$2000,X
        	INY
        	CPY 	#07
        	BNE 	bAffChar2
        	RTS
; -----------------------------------------------------------------------------
RANDOM32        					; changes X-reg
        	LDA 	RND				; seed value
        	ASL
        	BCC 	noEor2R32
doEor2R32 	EOR 	#$1D
noEor2R32 	STA 	RND
        	AND 	#%11111  			; between 0 and 31
        	TAX
        	INX            				; between 1 and 32
        	RTS
; -----------------------------------------------------------------------------
RANDOM15        					; changes Accu
        	LDA 	RND2				; seed value
        	ASL
        	BCC 	noEor2R15
doEor2R15 	EOR 	#$1D
noEor2R15 	STA 	RND2
        	AND 	#%1111   			; between 0 and 15
        	CLC
        	ADC 	#12      			; between 12 and 27
        	RTS
; -----------------------------------------------------------------------------
RANDOMXX        					; changes Accu
        	LDA 	RND3				; seed value
        	ASL
        	BCC 	noEor2XX
doEor2XX	EOR 	#%1010
noEor2XX	STA 	RND3
        	AND 	NUMBER  			; between 0 and x 
        	RTS
; -----------------------------------------------------------------------------
RANDOM02        					; changes Accu
        	LDA 	RND2
        	ASL
        	BCC 	noEor2R2
doEor2R2	EOR 	#$1D
noEor2R2	STA 	RND2
        	AND 	#%1      			; between 0 and 1
        	RTS
; -----------------------------------------------------------------------------
