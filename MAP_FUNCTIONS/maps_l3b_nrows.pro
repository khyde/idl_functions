; $ID:	MAPS_L3B_NROWS.PRO,	2020-06-30-17,	USER-KJWH	$
; #########################################################################; 
FUNCTION MAPS_L3B_NROWS, L3BMAP, VERBOSE=VERBOSE
;+
; PURPOSE:  THIS SIMPLE FUNCTION RETURNS THE NUMBER OF BINS IN A L3BMAP 
;
; CATEGORY: MAPS FAMILY
;
;
; INPUTS: L3BMAP NAME ['L3B1','L3B2','L3B4',OR 'L3B9', OR 'L3B10']
;
;
; KEYWORDS:  
;    VERBOSE..... Print out the number of rows associated with each L3B map         
;
; OUTPUTS: NUMBER OF BINS IN A L3BMAP
;
;; EXAMPLES:
;          PRINT,MAPS_L3B_NROWS('L3B9')
;          PRINT,MAPS_L3B_NROWS('L3B4')
;          PRINT,MAPS_L3B_NROWS('L3B2')
;          PRINT,MAPS_L3B_NROWS('L3B1')
;          PRINT,MAPS_L3B_NROWS()
;          PRINT,MAPS_L3B_NROWS('L3B10')
;          PRINT,MAPS_L3B_NROWS(['L3B4','L3B10'])
;
; MODIFICATION HISTORY:
;     FEB 22, 2017 WRITTEN BY: K.J.W. HYDE & J.E. O'REILLY - N_ROWS FOR ALL MAPS WHEN L3BMAP NOT PROVIDED
;     FEB 24, 2017 - JEOR: FOR NTH = 0,NOF(L3BMAPS)-1 DO BEGIN 
;     FEB 24, 2017 - KJWH: Removed the IF L3BMAP NE 'L3B1'AND L3BMAP NE 'L3B2' AND L3BMAP NE 'L3B4' AND L3BMAP NE 'L3B9' THEN MESSAGE,'ERROR: NOT A L3BMAP' statement because it is redundant with the ERROR message returned by the CASE statement
;     MAR 01, 2017 - JEOR: ADDED L3B10  TO MATCH EXAMPLE IN : INTEGERIZED SINUSOIDAL BINNING SCHEME FOR LEVEL 3 DATA-NASA
;     MAR 13, 2017 - KJWH: Made it so that you loop through the input L3BMAP(s) and return and array of N_ROWS if needed.
;                          Added keyword VERBOSE
;-
; #########################################################################

;***************************
  ROUTINE = 'MAPS_L3B_NROWS'
;***************************
  IF NONE(L3BMAP) THEN L3BMAPS = ['L3B25','L3B10','L3B9','L3B5','L3B4','L3B2','L3B1'] ELSE L3BMAPS = STRUPCASE(L3BMAP)
 ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    N_ROWS = []
    FOR NTH = 0,NOF(L3BMAPS)-1 DO BEGIN
      CASE L3BMAPS[NTH] OF
        'L3B1':N_ROWS  = [N_ROWS,17280UL]
        'L3B2':N_ROWS  = [N_ROWS, 8640UL]
        'L3B2N': N_ROWS = [N_ROWS, 8640UL]
        'L3B4':N_ROWS  = [N_ROWS, 4320UL]
        'L3B5':N_ROWS  = [N_ROWS, 3600UL]
        'L3B9':N_ROWS  = [N_ROWS, 2160UL]
        'L3B10':N_ROWS = [N_ROWS,   18UL]
        'L3B25': BEGIN & N_ROWS = [N_ROWS,0L] & STOP & END ; Need to figure out the NROWS for the L3B25 map
        ELSE: MESSAGE, 'ERROR: MUST PROVIDE VALID L3B (L3B1, L3B2, L3B4, L3B9) MAP.'  ; MAY WANT TO CONSIDER CHANGING THIS TO BE N_ROWS = [N_ROWS,0L] (OR -1)
      ENDCASE
      IF KEY(VERBOSE) THEN PRINT, L3BMAPS[NTH] + ':  '+ROUNDS(N_ROWS)
    ENDFOR;FOR NTH = 0,NOF(L3BMAPS)-1 DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  IF N_ELEMENTS(N_ROWS) EQ 1 THEN N_ROWS = N_ROWS[0] ; IF A SINGLE ELEMENT, THEN CONVERT THE ARRAY BACK TO SCALAR
  RETURN, N_ROWS
  
  DONE:
END; #####################  END OF ROUTINE ################################
