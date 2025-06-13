; $ID:	IMG_DILATE.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION IMG_DILATE, IMG, TARGET=TARGET, BOX=BOX, X0=X0, Y0=Y0, SUBS=SUBS, DATA=DATA

;+
; PURPOSE: 
;   Return a dilated image from the input 2-d image array using the IDL DILATE command to enlarge specified areas of the image (clouds, bathymetry, boundary outlines, etc.).
;
; CATEGORY:
;   IMAGE_FUNCTIONS
;
; CALLING SEQUENCE:
; 
;
; REQUIRED INPUTS:
;   IMG ......... A two dimensional image array
;
; OPTIONAL INPUTS:
;   BOX.......... The width (or width and length) of the "box" in pixels to dilate the specified feature in the image. NOTE: For a symmetrical dilation use odd values (3,5,7,9,11).
;   X0........... The X location of origin of the dilation box
;   Y0........... The Y location of origin of the dilation box
;   SUBS......... Subscripts for all pixels that were dilated (including the original input pixels)
;   
; KEYWORD PARAMETERS  
;   DATA......... Returns the input data (with the dilated pixels set to missings) instead of a byte mask
;                                            
; OUTPUTS: 
;   Either a 2D byte image with the specified feature dilated (i.e. mask) 
;
; OPTIONAL OUTPUTS:
;   If they keyword DATA is set, the 2D data image with the dilated area set to missings
;
; COMMON BLOCKS:
;   None
;
; SIDE EFFECTS:
;   WARNING: If they keyword DATA is set, then the region of dilated pixels in the input image is altered with the value of the target (usually set to the missing code)
;
; RESTRICTIONS:
;   None
;
; EXAMPLES:
; ==> Read the NEC landmask [where OCEAN=1 and LAND=0] then dilate the missing value of 0 
;   IM = READ_LANDMASK('NEC',/OCEAN) & NEW = IMG_DILATE(IM, BOX=7) 
;         
; ===> Now dilate missings data using the DATA keyword
;   IM = READ_LANDMASK('NEC',/OCEAN) & PMM,IM & IM = FLOAT(IM) & IM(512,512) = MISSINGS(IM)
;   OK = WHERE(FINITE(IM) EQ 0,COUNT) & PRINT,COUNT
;   NEW = IMG_DILATE(IM, BOX=25,/DATA)
;   OK = WHERE(FINITE(NEW) EQ 0,COUNT) & IMGR,NEW & P,COUNT ; [COUNT= 625]
;   
; NOTES:
;
;
; COPYRIGHT:
; Copyright (C) 2017, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on June 15, 2017 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
;
; MODIFICATION HISTORY:
;  JUN 15, 2017 - KJWH: Inital code written, adapted from J.E.O'Reilly's CLOUDIER program
;  JUL 14, 2017 - KJWH: Changed SUBS = WHERE(NEW EQ CLR, COUNT) TO SUBS = WHERE(NEW EQ 1, COUNT)  
;  MAR 01, 2018 - JEOR: Updated formatting
;                       Changed keyword COLOR to TARGET and added TARGET example  
;                       Added logic to automatically determine TARGET value 
;                       Added keyword DATA     
;  MAR 06, 2018 - KJWH: Updated formatting   
;  OCT 13, 2021 - KJWH: Updated formatting and documentation
;                       Moved to IMAGE functions  
;                       Added COMPILE_OPT IDL2
;                       Changed all subscript () to []        
;                       Removed some shortcut functions such as NONE and KEY     
; - 
; ******************************************************************************************************************************
  ROUTINE = 'IMG_DILATE'
  COMPILE_OPT IDL2
  

; ===> Check the input information
  IF ~N_ELEMENTS(IMG) OR IS_2D(IMG) EQ 0 THEN MESSAGE,'ERROR: Must provide a 2-D image as input'

  IF KEYWORD_SET(BOX) THEN BEGIN                                                            ;  Evaluate keyword box and generate default parameters for the dilation box
    IF N_ELEMENTS(BOX) EQ 1 THEN BX = [BOX,BOX] ELSE BX = BOX
    IF N_ELEMENTS(BOX) GE 3 THEN MESSAGE,'ERROR: Box must have 1 or 2 dimensions'
  ENDIF ELSE BX = [3,3]

  IF ~N_ELEMENTS(X0) THEN X0 = BX[0]/2                                                      ; If the user does not supply X0 then make X0 the middle of the dilation box WIDTH
  IF ~N_ELEMENTS(Y0) THEN Y0 = BX[1]/2                                                      ; If the user does not supply X0 then make X0 the middle of the dilation box HEIGHT

  IF ~N_ELEMENTS(TARGET) THEN BEGIN                                                         ; Check if user supplied a target value for the feature to be dilated. if not then determine target value automatically 
    CASE [1] OF 
      ISA(IMG,/INT):    TARGET = 0                                                          ; If the image is a BYTE, INTEGER, LONG, ULONG or LONG64 then the target is 0 
      ISA(IMG,/FLOAT):  TARGET = MISSINGS(IMG)                                              ; If the image is FLOAT or DOUBLE then the target is the "MISSING" value of the image    
      ELSE: MESSAGE,'ERROR: Input image is not a number (byte, integer, float or double)'   ; If a missing value is not found then the targe should be provided 
    ENDCASE;CASE (1) OF  
 ENDIF

; ===> Check whether the origin of the dilation box (X0,Y0) is inside the dilation box
  IF X0 LT 0 OR X0 GE BX[0] THEN MESSAGE,'ERROR: Parameter X0 is outside dilation box, try again'
  IF Y0 LT 0 OR Y0 GE BX[1] THEN MESSAGE,'ERROR: Parameter Y0 is outside dilation box, try again'
  
  BOX_OF_ONES = REPLICATE(1,BX[0],BX[1])                                                    ; Create a matrix of dimension (box*box) and fill it with one's
  IMG_COPY = IMG                                                                            ; Make a copy of the image
  MASK = IMG_COPY EQ TARGET                                                                 ; Make a binary (0's and 1's) mask with 1's where there are clouds
  NEW = DILATE(MASK,BOX_OF_ONES,X0,Y0)                                                      ; Grow the feature using idl function dilate
  SUBS = WHERE(NEW EQ 1, COUNT)                                                             ; Get the subscripts for all pixels that were dilated (including the original input pixels)
  
  IF KEYWORD_SET(DATA) THEN BEGIN
     IMG[SUBS] = TARGET 
     RETURN, IMG
  ENDIF ELSE RETURN, NEW  

END; #####################  END OF ROUTINE ################################

