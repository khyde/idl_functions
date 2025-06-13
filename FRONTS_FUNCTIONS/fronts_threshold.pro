; $ID:	FRONTS_THRESHOLD.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION FRONTS_THRESHOLD, IMG, PIXELBOX=PIXELBOX, VALID_PERCENT=VALID_PERCENT, SUBS=SUBS, MEDIAN_THRESHOLD=MEDIAN_THRESHOLD,$
     VERBOSE=VERBOSE, LOGLUN=LOGLUN

;+
; NAME:
;   FRONTS_THRESHOLD
;
; PURPOSE:
;   Uses a mid-range filter to first smooth the noise and create a threshold value for the determination of fronts
;
; CATEGORY:
;   FRONTS_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = FRONTS_THRESHOLD(IMG)
;
; REQUIRED INPUTS:
;   IMG.......... An input (gradient magnitude) image 
;
; OPTIONAL INPUTS:
;   PIXELBOX........ The size of the pixel array box for the filter (e.g. 9 = 9x9 box)
;   VALID_PERCENT... The minimum percent of valid pixels in a box
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   An array with just the "fronts" that were equal to or greater than the threshold
;
; OPTIONAL OUTPUTS:
;   SUBS......... The subscripts of the pixels that were equal to or greater than the threshold
;
; COMMON BLOCKS: 
;   None
;
; SIDE EFFECTS:  
;   None
;
; RESTRICTIONS:  
;   None
;
; EXAMPLE:
; 
;
; NOTES:
;   $Citations or any other useful notes$
;   
; COPYRIGHT: 
; Copyright (C) 2023, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on July 07, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jul 31, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'FRONTS_THRESHOLD'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF ~N_ELEMENTS(LOGLUN)      THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN
  
  IF ~N_ELEMENTS(VALID_PERCENT) THEN VPER = .25 ELSE VPER = VALID_PERCENT
  IF ~N_ELEMENTS(PIXELBOX) THEN BOX = 9 ELSE BOX = PIXELBOX
  IF ~ODD(BOX) THEN MESSAGE, 'ERROR: The pixel box dimensions must be ODD'
  
  BOXAROUND = (BOX-1)/2 ; Calculate the "AROUND" value used as input to BOX_AROUND
    
  IF ~N_ELEMENTS(IMG) THEN MESSAGE, 'ERROR: Must provide input image'
  SZ = SIZE(IMG)
  IF SZ[0] NE 2 THEN MESSAGE, 'ERROR: Must input a 2 dimensional image'
  IF SZ[1] LE 1 OR SZ[2] LE 1 THEN MESSAGE, 'ERROR: Must provide a 2 dimensional image with dimensions gt 1'
  LX = SZ[1]
  LY = SZ[2]

  OIMG = IMG & OIMG[*] = MISSINGS(IMG)                               ; Create a blank image array for the output image
  FIMG = IMG & FIMG[*] = MISSINGS(IMG)                               ; Create a blank image array for the filtered image
  FOR Y=BOX-1, LY-BOX DO BEGIN                                       ; Loop through the X dimension
    IF KEYWORD_SET(VERBOSE) AND Y-1 MOD 100 EQ 0 THEN BEGIN
      POF,Y,LY,OUTTXT=POFTXT,/QUIET, /NOPRO                                                                                      ; Get the text to track the pixel loop
      PLUN, LOG_LUN,'Working on row ' + POFTXT , 0                   ; Write out the details about the pixel time series
    ENDIF
    FOR X=BOX-1, LX-BOX DO BEGIN                                     ; Loop through the Y dimension
      IF IMG[X,Y] EQ MISSINGS(IMG) THEN CONTINUE
      BX=BOX_AROUND(IMG,[X,Y],SUBS=SUBS,AROUND=BOXAROUND)            ; Extract the "box" of pixels around the X & Y values
      OK = WHERE(BX NE MISSINGS(0.0),COUNT)                          ; Find where the pixels within the box are missing
      IF COUNT LT 2 THEN CONTINUE
     ; IF FLOAT(COUNT)/FLOAT(N_ELEMENTS(BX)) LT VPER THEN CONTINUE    ; If the number of valid pixels does not exceed the minimum valid percentage, then skip the mid-range filter step
      FIMG[X,Y] = (MAX(BX,/NAN)+MIN(BX,/NAN))/2                      ; Calculate the mid-range filter (MAX+MIN)/2     
    ENDFOR
  ENDFOR
  
  
  MEDIAN_THRESHOLD = MEDIAN(FIMG[WHERE(FIMG NE MISSINGS(FIMG))],/EVEN) ; Calculate the median of the image for all non-missing pixels
  SUBS = WHERE(IMG GE MEDIAN_THRESHOLD AND IMG NE MISSINGS(IMG), COUNT, COMPLEMENT=COMP)        ; Find pixels in the original image that are equal to or greater than the median
  
  OIMG[SUBS] = IMG[SUBS]                                             ; Fill the blank output image array with the pixels that are equal to or greater than the median
  
  RETURN, OIMG


END ; ***************** End of FRONTS_THRESHOLD *****************
