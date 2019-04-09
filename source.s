MAIN
					LDA	  bMark
					BNE	  mark2
mark1			JSR	  DisplayMatrix
					LDA	  KYBD				; loop until keypress
					BMI 	END
					JSR	  DisplayGuys
					LDA	  KYBD				; loop until keypress
					BMI 	END
					JSR	  DisplayMatrix
					LDA	  KYBD				; loop until keypress
					BMI 	END
					JSR	  DisplayGuys
					LDA	  KYBD				; loop until keypress
					BMI 	END
					JSR	  DisplayMatrix
					LDA	  KYBD				; loop until keypress
					BMI 	END
					
bw1     	LDA 	bMark				; wait for next part
        	BEQ 	bw1
        	JMP	  MAIN				
					
mark2			JSR	  DisplayRF

					LDA	  KYBD				; loop until keypress
					BMI 	END
					JMP	  MAIN
