; $ID:	PROJECT_COMPOSITE_ANIMATION.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO PROJECT_COMPOSITE_ANIMATION, VERSTRUCT, PROJECT=PROJECT, PRODS=PRODS, FRAMES=FRAMES, EXTENSIONS=EXTENSIONS, DATERANGE=DATERANGE, WEEKS=WEEKS, MAP_OUT=MAP_OUT, PROD_SCALE=PROD_SCALE, BUFFER=BUFFER, DIR_OUT=DIR_OUT, _REF_EXTRA=EXTRA


;+
; NAME:
;   PROJECT_COMPOSITE_ANIMATION
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   PROJECT_FUNCTIONS
;
; CALLING SEQUENCE:
;   PROJECT_COMPOSITE_ANIMATION,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
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
;   This program was written on July 31, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jul 31, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'PROJECT_COMPOSITE_ANIMATION'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF ~N_ELEMENTS(VERSTRUCT) THEN BEGIN
    IF ~N_ELEMENTS(PROJECT) THEN MESSAGE, 'ERROR: If the version structure is not provided, must include at least 1 PROJECT name.'
    VSTR = PROJECT_VERSION_DEFAULT(PROJECT)
  ENDIF ELSE VSTR = VERSTRUCT
  
  IF ~N_ELEMENTS(DATERANGE) THEN DTR =GET_DATERANGE(VSTR.INFO.YEAR) ELSE DTR = GET_DATERANGE(DATERANGE)
  IF ~N_ELEMENTS(MAP_OUT) THEN MP = VSTR.INFO.MAP_OUT ELSE MP = MAP_OUT
  IF ~N_ELEMENTS(PRODS) THEN PRDS = VSTR.INFO.COMP_ANIMATION_PRODS ELSE PRDS = PRODS
  IF ~N_ELEMENTS(FRAMES) THEN FPS = 5 ELSE FPS = FRAMES
  IF ~N_ELEMENTS(EXTENSIONS) THEN EXT = ['webm'] ELSE EXT = EXTENSIONS
  MR = MAPS_READ(MP)
  
  IF KEYWORD_SET(WEEKS) THEN OUTPERIOD='WW_'+DATE_2YEAR(DTR[0])+DATE_2WEEK(DTR[0]) + '_' +DATE_2YEAR(DTR[1])+DATE_2WEEK(DTR[1])  $
                                                  ELSE OUTPERIOD='DD_'+STRJOIN(STRMID(DTR,0,8),'_')
  
  RESIZE = []
  CASE MP OF
    'NES': BEGIN & RESIZE=.85 & END
    'MAB': BEGIN & END
    'MAB_GS': BEGIN & RESIZE=.9 & END
    'GOM': BEGIN & RESIZE=.85 & END
  ENDCASE
  
  FOR N=0, N_ELEMENTS(PRDS)-1 DO BEGIN
    IF ~N_ELEMENTS(DIR_OUT) THEN DIROUT=VSTR.DIRS.DIR_COMP_ANIMATIONS + STRJOIN(PRDS[N],'_') + SL ELSE DIROUT = DIR_OUT
    DIR_PNGS = DIROUT + 'ANIMATION_PNGS' + SL & DIR_TEST, DIR_PNGS
    PROJECT_MAKE_COMPOSITE, VSTR, PRODS=PRDS[N],WEEKS=WEEKS,DATERANGE=DTR,RESIZE=RESIZE,BUFFER=BUFFER,DIR_OUT=DIR_PNGS,_EXTRA=EXTRA
  
    FOR E=0, N_ELEMENTS(EXT)-1 DO BEGIN
      PNGS = FILE_SEARCH(DIR_PNGS + '*' + MP + '*'  + '*.PNG')
      PNGS = DATE_SELECT(PNGS, [DTR[0],DTR[-1]])
      IF PNGS EQ [] OR N_ELEMENTS(PNGS) LE 2 THEN CONTINUE
      FA = PARSE_IT(PNGS[0])
      MFILE = DIROUT + REPLACE(FA.NAME,FA.PERIOD,OUTPERIOD) 
      MOVIE_FILE = MFILE + '-FPS_'+ROUNDS(FPS)+'.'+EXT[E]    
      MAKE_MOVIE, PNGS, MOVIE_FILE=MOVIE_FILE, FRAME_SEC=FPS
    ENDFOR ; EXT
  ENDFOR ; PRDS  


END ; ***************** End of PROJECT_COMPOSITE_ANIMATION *****************
