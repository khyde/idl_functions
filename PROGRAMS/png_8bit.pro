; $ID:	PNG_8BIT.PRO,	2021-04-14-17,	USER-KJWH	$

  FUNCTION PNG_8BIT, PNGFILE, PAL=PAL, VERBOSE=VERBOSE, RGB=RGB

;+
; NAME:
;   TEMPLATE
;
; PURPOSE:
;   This procedure/function
;
; CATEGORY:
;   CATEGORY
;
; CALLING SEQUENCE:
;
;   TEMPLATE, Parameter1, Parameter2, Foobar
;
;   Result = TEMPLATE(Parameter1, Parameter2, Foobar)
;
; INPUTS:
;   Parm1:  Describe the positional input parameters here. Note again that positional parameters are shown with Initial Caps.
;
; OPTIONAL INPUTS:
;   Parm2:  Describe optional inputs here. If you don't have any, just delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1: Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;   This function returns the
;
; OPTIONAL OUTPUTS:
;   ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; COMMON BLOCKS: If no common blocks then delete this line
; SIDE EFFECTS:  If no side effects then delete this line
; RESTRICTIONS:  If no restrictions then delete this line
;
; PROCEDURE:
;
; EXAMPLE:
;
; NOTES:
;   This routine will display better if you set your tab to 2 spaces:
;   (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)
;
;   Citations or any other useful notes
;
;
; MODIFICATION HISTORY:
;			Written:  April 18, 2011 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			Modified:  
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'PNG_8BIT'
	COMPILE_OPT IDL2
	
	QP = QUERY_PNG(PNGFILE,INFO)
	IF INFO.CHANNELS NE 4 THEN RETURN, READ_PNG(PNGFILE)
	PNG = READ_PNG(PNGFILE,R,G,B)
	
	; If palette is unknow, make temporary palette based on the R, G, B
	IF KEYWORD_SET(PAL) THEN RGB = CPAL_READ(PAL,PALLIST=PALLIST) ELSE BEGIN
;	  CPAL_WRITE,'PAL_TEST',R,G,B
;	  RGB = CPAL_READ('PAL_TEST',PALLIST=PALLIST)
	ENDELSE
	
	RGB = BYTARR([3,256])
	RR = REFORM(PNG[0,*,*]) & PALR = REFORM(RGB[0,*])
	GG = REFORM(PNG[1,*,*]) & PALG = REFORM(RGB[1,*])
	BB = REFORM(PNG[2,*,*]) & PALB = REFORM(RGB[2,*])
	
	RGB = ROUNDS(RR) + '_' + ROUNDS(GG) + '_' + ROUNDS(BB)
	
	DD = RR & DD[*] = MISSINGS(DD)
	
	B = WHERE_SETS(RGB)
	
	FOR N=0,N_ELEMENTS(B)-1 DO BEGIN
	 SUBS = WHERE_SETS_SUBS(B[N])
	 IF KEY(VERBOSE) THEN PRINT, ROUNDS(N_ELEMENTS(SUBS)) + ' pixel were found for N = ' + ROUNDS(N) ;+ ' when RR=' + ROUNDS(PALR(N)) + ', GG=' + ROUNDS(PALG(N)) + ' & BB=' + ROUNDS(PALB(N))
	 DD[SUBS] = N  
	ENDFOR
	RETURN, DD

END; #####################  End of Routine ################################
