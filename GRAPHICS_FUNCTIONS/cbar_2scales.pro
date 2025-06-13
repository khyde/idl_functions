; $ID:	CBAR_2SCALES.PRO,	2025-01-28-18,	USER-KJWH	$
  FUNCTION CBAR_2SCALES, $
    POSITION=POSITION, PAL=PAL,  $
    TOP_TITLE=TOP_TITLE, $
    BOT_TITLE=BOT_TITLE

;+
; NAME:
;   CBAR_2SCALES
;
; PURPOSE:
;   Create a colorbar with 2 scales (e.g. SST with both oC and oF)
;
; CATEGORY:
;   GRAPHICS_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = CBAR_2SCALES($Parameter1$, $Parameter2$, $Keyword=Keyword$, ...)
;
; REQUIRED INPUTS:
;   Parm1.......... Describe the positional input parameters here. 
;
; OPTIONAL INPUTS:
;   Parm2.......... Describe optional inputs here. If none, delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1........... Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;   OUTPUT.......... Describe the output of this program or function
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS: 
;   None
;
; SIDE EFFECTS:  
;   None
;
; RESTRICTIONS:  
;   Currently only works with CB_1 type
;
; EXAMPLE:
; 
;
; NOTES:
;   $Citations or any other useful notes$
;   
; COPYRIGHT: 
; Copyright (C) 2025, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on January 28, 2025 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jan 28, 2025 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'CBAR_2SCALES'
  COMPILE_OPT IDL3
  SL = PATH_SEP()
  
  CB_POS = [0.065, 0.85, 0.525, 0.89]
  CBAR, PROD_SCALE, IMG=IMG, FONT_SIZE=15, CB_TYPE=1, CB_POS=CB_POS, CB_TITLE=CB1_TITLE, PAL=PAL,CB_TICKVALUES=TICKVALS, CB_TICKNAMES=TICKNAMES,_EXTRA=_EXTRA,RELATIVE=CB_RELATIVE, CB_OBJ=CB_IMG

  IMGBLK = (REPLICATE(255B,2,2))
  OBJ = IMAGE(IMGBLK,RGB_TABLE=RGB_TABLE,/NODATA,/HIDE,BACKGROUND_COLOR=BACKGROUND_COLOR,TRANSPARENCY=100,POSITION = [0,0,0.001,0.001],BUFFER=BUFFER,/CURRENT)
  CBAR, PROD_SCALE, IMG=OBJ, FONT_SIZE=15, CB_TYPE=3, CB_POS=CB_POS, CB_TITLE=CB2_TITLE, PAL=PAL, CB_TICKVALUES=FTICKVALS, CB_TICKNAMES=FTICKNAMES,RELATIVE=CB_RELATIVE, CB_OBJ=CB_IMG2

  


END ; ***************** End of CBAR_2SCALES *****************
