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
