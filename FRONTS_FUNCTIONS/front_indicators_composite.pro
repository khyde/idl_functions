; $ID:	FRONT_INDICATORS_COMPOSITE.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO FRONT_INDICATORS_COMPOSITE, FILES, DIR_OUT=DIR_OUT, PRODS=PRODS, MAP_OUT=MAP_OUT, MASK_CODES=MASK_CODES, MASK_NAMES=MASK_NAMES,$
                                  ADD_ORIGINAL=ADD_ORIGINAL, ADD_BATHY=ADD_BATHY, BATHY_DEPTHS=BATHY_DEPTHS, OVERLAY_DATA=OVERLAY_DATA, NO_COLORBAR=NO_COLORBAR, $
                                  NROWS=NROWS, NCOLS=NCOLS, BUFFER=BUFFER, OVERWRITE=OVERWRITE, ADD_DAILY=ADD_DAILY, _EXTRA=_EXTRA

;+
; NAME:
;   FRONT_INDICATORS_COMPOSITE
;
; PURPOSE:
;   Create a composite image from the front data in a netcdf file
;
; CATEGORY:
;   Visualization
;
; CALLING SEQUENCE:
;   Result = FRONT_INDICATORS_COMPOSITE(FILES,DIR_OUT=DIR_OUT,PROD=PROD,MAP_OUT=MAP_OUT,NROWS=NROWS,NCOLS=NCOLS)
;
; REQUIRED INPUTS:
;   FILES......... SAV files with the frontal indicator data
;
; OPTIONAL INPUTS:
;   DIR_OUT....... The output directory
;   PROD.......... Product name (used for scaling and lables)
;   MAP_OUT....... The output map projection 
;   NROWS......... The number of rows in the composite
;   NCOLS......... The number of columns in the composite
;
; KEYWORD PARAMETERS:
;   OVERWRITE..... Overwrite existing composite figures
;   ADD_DAILY..... Option to add the daily input files
;
; OUTPUTS:
;   OUTPUT........ Image files 
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
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on March 08, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Mar 24, 2021 - KJWH: Initial code written
;   Oct 26, 2021 - KJWH: Updated the input directory location from SAVE to STACKED_FILES
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'FRONT_INDICATORS_COMPOSITE'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
 
  ; ===> SET UP DEFAULTS
  IF N_ELEMENTS(FILES) EQ 0 THEN MESSAGE, 'ERROR: Must provide input files.'
  IF N_ELEMENTS(PRODS) EQ 0 THEN PRODS = ['FMEAN','FPROB','FINTENSITY','FPERSIST']
  IF KEYWORD_SET(NO_COLORBAR) THEN ADD_CB=0 ELSE ADD_CB=1
  IF NONE(FONT_SIZE)      THEN FONT_SIZE  = 16
  IF NONE(CFONT_SIZE)     THEN CFONT_SIZE = 10
  IF NONE(FONT_STYLE)     THEN FONT_STYLE = 'BOLD'
  IF NONE(PAL)            THEN PAL = 'PAL_DEFAULT' & RGB = CPAL_READ(PAL)
  IF NONE(LAND_COLOR)     THEN LAND_COLOR  = 252
  IF NONE(COAST_COLOR)    THEN COAST_COLOR = 0
  IF N_ELEMENTS(BATHY_DEPTHS) GT 0 THEN BEGIN
    OK = WHERE(BATHY_DEPTHS GT 0, COUNT)
    IF COUNT GT 0 THEN BATHY_DEPTHS[OK] = BATHY_DEPTHS[OK]*(-1)
  ENDIF

  IF ANY(DIMS) THEN BEGIN
    DIMS = STRSPLIT(STRUPCASE(DIMS),'X',/EXTRACT)
    IF NONE(NCOLS) THEN NCOLS = DIMS[0]
    IF NONE(NROWS) THEN NROWS = DIMS[1]
  ENDIF

  ; ===> Set up default plot spacing
  IF NONE(BUFFER) THEN BUFFER = 0 ; Do plotting in the foreground
  IF NONE(SPACE)  THEN SPACE  = 10
  IF NONE(LEFT)   THEN LEFT   = SPACE * 3
  IF NONE(RIGHT)  THEN RIGHT  = SPACE * 3
  IF NONE(TOP)    THEN TOP    = SPACE * 4
  IF NONE(BOTTOM) THEN BOTTOM = SPACE * 3
  IF KEYWORD_SET(ADD_CB) THEN BEGIN
    IF KEYWORD_SET(ADD_DAILY) THEN CBSPACE=SPACE*7 ELSE CBSPACE = SPACE * 6 
  ENDIF ELSE CBSPACE = 0
  
  ; ===> Set up default masking codes
  MASK = [] & MCODE = []
  IF NONE(MASK_NAMES) THEN MNAMES = 'MISSING_DATA' ELSE MNAMES = MASK_NAMES
  
  ; ===> Loop through input files
  FOR FTH=0, N_ELEMENTS(FILES)-1 DO BEGIN
    FILE = FILES[FTH]
    FP = PARSE_IT(FILE,/ALL)
    
    IF N_ELEMENTS(MAP_OUT) EQ 0 THEN MP = FP.MAP ELSE MP = MAP_OUT
    IF IS_L3B(MP) THEN MESSAGE, 'ERROR: Must provide MAP_OUT for the L3B files'
    
    ; ===> Create the output direcgory if not provided
    IF N_ELEMENTS(DIR_OUT) NE 1 THEN BEGIN
      IF HAS(FP.DIR,'STACKED_SAVE') EQ 0 THEN MESSAGE, 'ERROR: Need to update the output directory code that is looking for "STACKED_FILES" in the directory name.'
      DIR = REPLACE(FP.DIR,SL+'STACKED_SAVE'+SL,SL+'COMPOSITE'+SL)
      IF KEYWORD_SET(ADD_DAILY) THEN DIR = REMOVE_LAST_SLASH(DIR) + '-DAILY' + SL
    ENDIF ELSE DIR = DIR_OUT
    IF MP NE FP.MAP THEN DIR = REPLACE(DIR,FP.MAP,MP)
    DIR_TEST, DIR
    
    ; ===> Check the input file
    IF STRUPCASE(FP.EXT) EQ 'NC' THEN BEGIN
      D = READ_NC(FILE)
      SDAT = D.SD
      IF HAS_TAG(SDAT,'MASK') THEN BEGIN
        MASK = SDAT.MASK
        CODES = LONG(STR_BREAK(MASK.MASK_CODES,';'))
        NAMES = REPLACE(STRUPCASE(STR_BREAK(MASK.MASK_NAMES,';')),['-',' '],['_','_'])
        OK = WHERE_MATCH(NAMES, MNAMES, COUNTMN)
        MCODE = CODES[OK]   
        FCODE = CODES[WHERE(NAMES EQ 'FRONT', /NULL)]
      ENDIF
      INFILES = STRSPLIT(D.GLOBAL.INPUT_FILENAMES,';',/EXTRACT)
      NC = 1
      FA = PARSE_IT(INFILES,/ALL)
      FL = REPLICATE(FP.NAME,N_ELEMENTS(INFILES))
      FOR F=0, N_ELEMENTS(INFILES)-1 DO FL[F] = REPLACE(FL[F],FP.PERIOD,FA[F].PERIOD)
    ENDIF ELSE BEGIN
      D3 = IDL_RESTORE(FILE)
      IF IDLTYPE(D3) EQ 'STRUCT' THEN BEGIN
        MASK = D3.MASK.MASK
        INFO = D3.INFO
        KEYS = TAG_NAMES(D3)
        DB   = D3.DB
        BINS = D3.BINS
      ENDIF ELSE BEGIN
        KEYS = D3.KEYS() & KEYS = KEYS.TOARRAY()
        INFO = D3['INFO']
        BINS = D3['BINS']
        DB = D3['FILE_DB'].TOSTRUCT()
  ;      MASK = D3['MASK']
      ENDELSE
      FL = DB.FULLNAME
      FA = PARSE_IT(FL,/ALL)
      IF HAS(KEYS,'MASK') THEN BEGIN
        CODES = INFO.MASK.MASK_CODES
        NAMES = STRUPCASE(INFO.MASK.MASK_NAMES)
        MCODE = CODES[WHERE(NAMES EQ 'MISSING DATA',/NULL)]
        FCODE = CODES[WHERE(NAMES EQ'FRONT' OR NAMES EQ 'PERSISTENT FRONT',/NULL)] 
        PCODE = CODES[WHERE(NAMES EQ 'PERSISTENT FRONT',/NULL)]
      ENDIF
      NC = 1
    ENDELSE
  
    ; ===> Loop through the internal files
    LAND = []
    FOR NTH=0, N_ELEMENTS(FL)-1 DO BEGIN
      AFILE = FL[NTH]
      IF AFILE EQ '' THEN CONTINUE
      FA = PARSE_IT(AFILE,/ALL)
      CASE FA.PROD OF
        'GRADSST_INDICATORS': BEGIN & OPROD='SST'     & FTAG = 'GRADSST_' & GPROD = 'GRAD_SST' & END
        'GRADCHL_INDICATORS': BEGIN & OPROD='CHLOR_A' & FTAG = 'GRADCHL_' & GPROD = 'GRAD_CHL' & END
      ENDCASE
      FPRODS = [FTAG+PRODS]
      FPRODS = REPLACE(FPRODS,[FTAG+OPROD,FTAG+'MASK',FTAG+'GRAD_MAG'],[OPROD,'MASK',GPROD])
      
      IF KEYWORD_SET(ADD_DAILY) THEN OUTFILE = DIR+FA.NAME+'-DAILY.png' ELSE OUTFILE = DIR + FA.NAME + '.png'
      OUTFILE = REPLACE(OUTFILE,[FA.MAP,'PXY_'+FA.PX+'_'+FA.PY], [MP,''])
      
      IF HAS(OUTFILE,'SUBSET') THEN BEGIN
        FP = STRSPLIT(OUTFILE,'-',/EXTRACT)
        OK = WHERE_STRING(FP,'SUBSET')
        OUTFILE = REPLACE(OUTFILE,FP[OK],'')
      ENDIF
      WHILE STRPOS(OUTFILE,'--') GE 0 DO OUTFILE = REPLACE(OUTFILE,'--','-')
      IF FILE_MAKE(FILE,OUTFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE                     ; Skip if the output file already exists
      
      IF LAND EQ [] THEN LAND = READ_LANDMASK(MP,/STRUCT)
      IF LAND.MAP_NAME NE MP THEN LAND = READ_LANDMASK(MP,/STRUCT)                             ; Confirm the LANDMASK is correct
      
      IF NC EQ 1 THEN BEGIN
        IF ~KEYWORD_SET(ADD_DAILY) THEN FPRODS = [OPROD,FPRODS]
        OK = WHERE_MATCH(KEYS,FPRODS,COUNT)
        IF COUNT EQ 0 THEN MESSAGE, 'ERROR: ' + STRJOIN(FPRODS,', ') + ' not found in ' + FILES
      ENDIF ELSE BEGIN
        D = STRUCT_READ(AFILE, STRUCT=S)
        IF IS_L3B(S.MAP) THEN IF HAS(S,'BINS') EQ 0 THEN MESSAGE, 'ERROR: Structure must have the L3B bins array.'
        IF HAS(S,'BINS') THEN BINS=S.BINS
        OK = WHERE_MATCH(TAG_NAMES(S),FPRODS,COUNT)
        IF COUNT EQ 0 THEN MESSAGE, 'ERROR: ' + STRJOIN(FPRODS,', ') + ' not found in ' + AFILE
        SD = STRUCT_COPY(S,OK)
      ENDELSE  
      
      DS = DATE_2JD(FA.DATE_START) & DE = DATE_2JD(FA.DATE_END)
      IF N_ELEMENTS(OVERLAY_DATA) GT 0 THEN BEGIN
        OK = WHERE(DATE_2JD(OVERLAY_DATA.DATE) GE DS AND DATE_2JD(OVERLAY_DATA.DATE) LE DE,COUNT_SHIP)
        IF COUNT_SHIP GT 0 THEN BEGIN
          BLK = MAPS_BLANK(MP,FILL=0)
          ODAT = OVERLAY_DATA[OK] 
          MAPS_SET, MP
          SLL = MAP_DEG2IMAGE(BLK,ODAT.START_LON,ODAT.START_LAT,X=SLONS,Y=SLATS)
          ELL = MAP_DEG2IMAGE(BLK,ODAT.END_LON,  ODAT.END_LAT,  X=ELONS,Y=ELATS)
          ZWIN  
        ENDIF ELSE ODAT = []
      ENDIF ELSE ODAT = []
          
      NTAGS = N_ELEMENTS(FPRODS)
      IF N_ELEMENTS(NROWS) EQ 0 THEN NROWS = 1
      IF N_ELEMENTS(NCOLS) EQ 0 THEN BEGIN
        NCOLS = NTAGS
        IF NTAGS GT 5 THEN BEGIN
           CASE NTAGS OF
             6:  BEGIN & NCOLS = 3 & NROWS = 2 & END
             7:  BEGIN & NCOLS = 4 & NROWS = 2 & END
             8:  BEGIN & NCOLS = 4 & NROWS = 2 & END
             9:  BEGIN & NCOLS = 3 & NROWS = 3 & END
             10: BEGIN & NCOLS = 5 & NROWS = 2 & END
             11: BEGIN & NCOLS = 4 & NROWS = 3 & END
             12: BEGIN & NCOLS = 4 & NROWS = 3 & END
             ELSE: MESSAGE, 'Need to update the composite layout (NCOLS, NROWS).'
           ENDCASE
        ENDIF
      ENDIF  
      
      IF KEYWORD_SET(ADD_DAILY) THEN BEGIN
        IF FA.PERIOD_CODE NE 'W' THEN MESSAGE, 'ERROR: Only works with weekly data'
        OFILES = STR_BREAK(DB.ORIGINAL_FILES[NTH],'; ')
        FO = PARSE_IT(OFILES,/ALL)
        SSET = WHERE_SETS(FO.SENSOR)
        PSET = WHERE_SETS(FO.PERIOD)
        NCOLS = 8  
        NROWS = 3
        IFILES = STR_BREAK(DB.INPUT_FILES[NTH],'; ')
      ENDIF
          
      MS = MAPS_SIZE(MP,PX=PX,PY=PY)
      XNSPACE = NCOLS-1 & YNSPACE = NROWS-1
      IF N_ELEMENTS(XDIM)  EQ 0 THEN XDIM   = PX
      IF N_ELEMENTS(YDIM)  EQ 0 THEN YDIM   = PY
      IF KEYWORD_SET(ADD_DAILY) THEN BEGIN
        WIDTH   = LEFT   + NCOLS*XDIM + XNSPACE*SPACE + RIGHT*2 + CBSPACE
        HEIGHT  = BOTTOM*2 + NROWS*YDIM + YNSPACE*SPACE + TOP
      ENDIF ELSE BEGIN
        WIDTH   = LEFT   + NCOLS*XDIM + XNSPACE*SPACE + RIGHT
        HEIGHT  = BOTTOM + NROWS*YDIM + YNSPACE*SPACE + TOP + CBSPACE*NROWS
      ENDELSE  
      SCL = 1
      WHILE WIDTH GT 1400 DO BEGIN
        XDIM = PX/SCL
        YDIM = PY/SCL
        IF KEYWORD_SET(ADD_DAILY) THEN BEGIN
          WIDTH   = LEFT   + NCOLS*XDIM + XNSPACE*SPACE + RIGHT*2 + CBSPACE
          HEIGHT  = BOTTOM*2 + NROWS*YDIM + YNSPACE*SPACE + TOP
        ENDIF ELSE BEGIN  
          WIDTH   = LEFT   + NCOLS*XDIM + XNSPACE*SPACE + RIGHT
          HEIGHT  = BOTTOM + NROWS*YDIM + YNSPACE*SPACE + TOP + CBSPACE*NROWS
        ENDELSE  
        SCL = SCL + 1
        IF SCL GT 12 THEN MESSAGE, 'ERROR: Unable to get the correct image dimensions'
      ENDWHILE
         
      WIMG = WINDOW(DIMENSIONS=[WIDTH,HEIGHT],BUFFER=BUFFER)
      TXT = TEXT(0.5,0.96,FA.PERIOD,FONT_STYLE='BOLD',FONT_SIZE=14,ALIGNMENT=0.5)
      COUNTER = 0
      R = 0
      
      IF KEYWORD_SET(ADD_DAILY) THEN BEGIN
        FOR O=0, N_ELEMENTS(PSET)-1 DO BEGIN
          XPOS = LEFT + O*XDIM + O*SPACE  ; Determine the left side of the image
          YPOS1 = HEIGHT - TOP 
          YPOS2 = HEIGHT - TOP - YDIM - SPACE ; Determine the top position of the image
          POS1 = [XPOS,YPOS1-YDIM,XPOS+XDIM,YPOS1]
          POS2 = [XPOS,YPOS2-YDIM,XPOS+XDIM,YPOS2]

          CASE OPROD OF
            'SST': BEGIN 
              STAT_PROD = 'SST'
              IMGPROD1='SST_0_30' & IMGPROD2='GRAD_SST_0.1_1.0' 
              PAL1='PAL_BLUE_RED' & PAL2='PAL_DEFAULT' 
              CBTICKNAME1=[0,5,10,15,20,25,30] & CBTICKNAME2=['0.1','0.2','0.3','0.5','0.7','1.0']
              CBTITLE1=UNITS('SST') & CBTITLE2='Grad SST' + UNITS(GPROD,/NO_NAME)
              MPROD='GRADSST_FMEAN'
            END
            'CHLOR_A': BEGIN 
              STAT_PROD='CHLOR_A-OCI'
              IMGPROD1='CHLOR_A_0.1_30' & IMGPROD2='GRAD_CHL_1_1.2' 
              PAL1='PAL_OCEAN_RELIEF' & & PAL2='PAL_OCEAN_RELIEF' & 
              CBTICKNAME1=[] & CBTICKNAME2=[]
              CBTITLE1='CHL'+UNITS(OPROD,/NO_NAME) & CBTITLE2='Grad CHL' + UNITS(GPROD,/NO_NAME)
              MPROD='GRADCHL_FMEAN'
            END
          ENDCASE
          
          DFILES = OFILES[WHERE_SETS_SUBS(PSET[O])] & FD = PARSE_IT(DFILES,/ALL)
          STATS_ARRAYS_PERIODS, DFILES, PERIOD_CODE_OUT='D', STAT_PROD=STAT_PROD, OUTSTRUCT=OS, /SKIP_SAVE         
          PRODS_2PNG, DATA_IMAGE=MAPS_REMAP(OS.MEAN,MAP_IN=FD[0].MAP,MAP_OUT=MP,BINS=OS.BINS), OBJ=OBJ, PROD=OPROD, SPROD=IMGPROD1, ADD_CB=0, PAL=PAL1, IMG_POS=POS1, MAPP=MP, DEPTH=BATHY_DEPTHS, OUTLINE_IMG=OUTLINE, OUT_COLOR=250, OUT_THICK=1, /CURRENT, /DEVICE, BUFFER=BUFFER
          
          PRODS_2PNG, IFILES[O], OBJ=OBJ, PROD=GPROD, SPROD=IMGPROD2, ADD_CB=0, PAL=PAL2, IMG_POS=POS2, MAPP=MP, DEPTH=BATHY_DEPTHS, OUTLINE_IMG=OUTLINE, OUT_COLOR=250, OUT_THICK=1, /CURRENT, /DEVICE, BUFFER=BUFFER
          TXT = TEXT(XPOS+5,YPOS1-5,'Day ' + NUM2STR(O+1),FONT_SIZE=14,VERTICAL_ALIGNMENT=1,/DEVICE)
        ENDFOR
        
        XPOS = LEFT + O*XDIM + O*SPACE  ; Determine the left side of the image
        YPOS1 = HEIGHT - TOP
        YPOS2 = HEIGHT - TOP - YDIM - SPACE ; Determine the top position of the image
        POS1 = [XPOS,YPOS1-YDIM,XPOS+XDIM,YPOS1]
        POS2 = [XPOS,YPOS2-YDIM,XPOS+XDIM,YPOS2]
        
        IF IDLTYPE(D3) EQ 'STRUCT' THEN DAT = D3.(WHERE(TAG_NAMES(D3) EQ OPROD)) ELSE DAT = D3[OPROD,*,*,NTH]
        IF MP NE FA.MAP THEN DAT = MAPS_REMAP(DAT,MAP_IN=FA.MAP,MAP_OUT=MP,BINS=BINS)
        PRODS_2PNG, DATA_IMAGE=DAT, OBJ=OBJ, PROD=OPROD, SPROD=IMGPROD1, ADD_CB=0, PAL=PAL1, IMG_POS=POS1, MAPP=MP, DEPTH=BATHY_DEPTHS, OUTLINE_IMG=OUTLINE, OUT_COLOR=250, OUT_THICK=1, /CURRENT, /DEVICE, BUFFER=BUFFER
        IF IDLTYPE(D3) EQ 'STRUCT' THEN DAT = D3.(WHERE(TAG_NAMES(D3) EQ MPROD)) ELSE DAT = D3[MPROD,*,*,NTH]
        IF MP NE FA.MAP THEN DAT = MAPS_REMAP(DAT,MAP_IN=FA.MAP,MAP_OUT=MP,BINS=BINS)
        PRODS_2PNG, DATA_IMAGE=DAT, OBJ=OBJ, PROD=GPROD, SPROD=IMGPROD2, ADD_CB=0, PAL=PAL2, IMG_POS=POS2, MAPP=MP, DEPTH=BATHY_DEPTHS, OUTLINE_IMG=OUTLINE, OUT_COLOR=250, OUT_THICK=1, /CURRENT, /DEVICE, BUFFER=BUFFER
        TXT = TEXT(XPOS+5,YPOS1-5,'7-Day Mean',FONT_SIZE=14,VERTICAL_ALIGNMENT=1,/DEVICE)
        
        
        CBPOS = FLOAT([XPOS+XDIM+SPACE,YPOS1-YDIM+SPACE,XPOS+XDIM+SPACE+CBSPACE/3,YPOS1-SPACE])
        CBPOS = [CBPOS[0]/WIDTH,CBPOS[1]/HEIGHT,CBPOS[2]/WIDTH,CBPOS[3]/HEIGHT] ; Convert to NORMAL values
        CBAR, IMGPROD1, CB_TICKNAME=CBTICKNAME1, CB_TITLE=CBTITLE1, PAL=PAL1, OBJ=WIMG, FONT_SIZE=CFONT_SIZE, FONT_STYLE=FONT_STYLE, CB_TYPE=5, CB_POS=CBPOS

        CBPOS = FLOAT([XPOS+XDIM+SPACE,YPOS2-YDIM+SPACE,XPOS+XDIM+SPACE+CBSPACE/3,YPOS2-SPACE])
        CBPOS = [CBPOS[0]/WIDTH,CBPOS[1]/HEIGHT,CBPOS[2]/WIDTH,CBPOS[3]/HEIGHT] ; Convert to NORMAL values
        CBAR, IMGPROD2, CB_TICKNAME=CBTICKNAME2, CB_TITLE=CBTITLE2, PAL=PAL2, OBJ=WIMG, FONT_SIZE=CFONT_SIZE, FONT_STYLE=FONT_STYLE, CB_TYPE=5, CB_POS=CBPOS
   
        COUNTER=16
      ENDIF
      
      FOR W=0, NTAGS-1 DO BEGIN
        APROD = FPRODS[W]
        IMGPROD = APROD
        CB_TICKVALUES = [] & CB_TICKNAMES = []
        CBTITLE = UNITS(APROD)   ; Title for the colorbar
        PAL = 'PAL_OCEAN_RELIEF'
        DISCRETE = 0

        CASE APROD OF 
          'SST':           BEGIN & IMGPROD = 'SST_0_30' & PAL='PAL_BLUE_RED4' & END
          'GRADSST_FMEAN': BEGIN & IMGPROD = 'GRADSST_FMEAN_0.1_1.0' & CB_TICKVALUES = [0.1,0.2,0.3,0.5,1.0] & END
          'GRADSST_FPROB': BEGIN & IMGPROD = 'GRADSST_FPROB_0_1' & CBTITLE = 'SST Front Probability' & PAL='PAL_BLUE_RED4' & END
          'GRADSST_FPERSIST': BEGIN & IMGPROD = 'NUM_1_2' & PAL = 'PAL_BLUE_RED4' & CBTITLE = 'SST Front Persistence' & CB_TICKNAMES=['','Persistent'] & CB_TICKVALUES=[1,2] & DISCRETE=2 & END
          'GRADSST_FINTENSITY': BEGIN & IMPROD = 'GRADSST_INTENSITY_0_5' & CBTITLE = 'SST Front Intensity' & END
          'GRADSST_FPERSISTPROB': BEGIN & CBTITLE = 'SST Front !CProbability of Persistence' & END
          'GRADSST_FPERSISTCUM': BEGIN & CBTITLE = 'SST Front !CCumulative Persistence (days)' & IMGPROD='CNUM_1_1000' & END
          'GRADSST_FVALID': BEGIN
            PAL='PAL_BLUE_RED4'
            CBTITLE = '# of Frontal Days'
            CASE FA.PERIOD_CODE OF
              'M': BEGIN & DISCRETE=31 & CB_TICKNAMES=STRING(INDGEN(30),FORMAT='(I0)') & END
              'W': BEGIN & DISCRETE=8 & CB_TICKNAMES=STRING(INDGEN(7),FORMAT='(I0)') & END
            ENDCASE
          END    
          'GRADSST_FCLEAR': BEGIN
            PAL='PAL_BLUE_RED4'
            CBTITLE = '# of Clear Days'
            CASE FA.PERIOD_CODE OF
              'M': BEGIN & DISCRETE=31 & CB_TICKNAMES=STRING(INDGEN(30),FORMAT='(I0)') & END
              'W': BEGIN & DISCRETE=8 & CB_TICKNAMES=STRING(INDGEN(7),FORMAT='(I0)') & END
            ENDCASE
          END
          'CHLOR_A': IMGPROD = 'CHLOR_A_0.03_30'
          'GRADCHL_FMEAN':      BEGIN & IMGPROD = 'GRADCHL_FMEAN_1_1.2'    & CBTITLE = 'CHL Fronts ' + UNITS(APROD,/NO_NAME) & END
          'GRADCHL_FSTD':       BEGIN & IMGPROD = 'GRADCHL_STD_0_2'      & CBTITLE = 'CHL Front STDev' & END
          'GRADCHL_FPROB':      BEGIN & IMGPROD = 'GRADCHL_FPROB_0_1'      & CBTITLE = 'CHL Front Probability' & END
          'GRADCHL_FINTENSITY': BEGIN & IMGPROD = 'GRADCHL_FINTENSITY_0_2' & CBTITLE = 'CHL Front Intensity' & END
          'GRADCHL_FPERSIST':   BEGIN & IMGPROD = 'GRADCHLT_FPERSIST_0_1'  & CBTITLE = 'CHL Front Persistence' & END
          'GRADCHL_FVALID':     BEGIN
            CBTITLE = '# of Frontal Days'
            CASE FA.PERIOD_CODE OF
              'M': BEGIN & DISCRETE=31 & CB_TICKNAMES=STRING(INDGEN(30),FORMAT='(I0)') & END
              'W': BEGIN & DISCRETE=8 & CB_TICKNAMES=STRING(INDGEN(7),FORMAT='(I0)') & END
            ENDCASE
          END
          'GRADCHL_FCLEAR': BEGIN
            CBTITLE = '# of Clear Days'
            CASE FA.PERIOD_CODE OF
              'M': BEGIN & DISCRETE=31 & CB_TICKNAMES=STRING(INDGEN(30),FORMAT='(I0)') & END
              'W': BEGIN & DISCRETE=8 & CB_TICKNAMES=STRING(INDGEN(7),FORMAT='(I0)') & END
            ENDCASE
          END
          'MASK': BEGIN & DISCRETE=4 & CB_TICKNAMES=REPLICATE('',DISCRETE) & PAL='PAL_BLUE_RED4_STEP_4' & END
          ELSE: IMGPROD = APROD
        ENDCASE
            
        ; ===> Get the data and remap 
        IF IDLTYPE(D3) EQ 'STRUCT' THEN DAT = D3.(WHERE(TAG_NAMES(D3) EQ APROD)) ELSE DAT = D3[APROD,*,*,NTH]
        IF MP NE FA.MAP THEN DAT = MAPS_REMAP(DAT,MAP_IN=FA.MAP,MAP_OUT=MP,BINS=BINS)
        
        ; ===> Get the mask data
        IF MASK NE [] THEN BEGIN
          MSK = MASK[*,*,NTH] 
          IF MSK NE [] THEN MSK = MAPS_REMAP(MSK,MAP_IN=FA.MAP,MAP_OUT=MP,BINS=BINS)
          IF WHERE(MSK LT 1,/NULL) EQ [] THEN BEGIN
            MSK[LAND.LAND] = CODES[WHERE(STRUPCASE(NAMES) EQ 'LAND')]
          ENDIF  
        ENDIF
        
        ; ===> Create the final mask based on the mask codes desired
        IF MSK NE [] THEN BEGIN
          CMSK = MSK & CMSK[*] = 0 & FMSK = CMSK
          FOR CM=0, N_ELEMENTS(MCODE)-1 DO CMSK[WHERE(MSK EQ MCODE[CM],/NULL)] = 1
          FOR C=0, N_ELEMENTS(FCODE)-1 DO FMSK[WHERE(MSK EQ FCODE[C],/NULL)] = 1
          OKMASK = WHERE(CMSK EQ 1,COUNT_MASK)
        ENDIF ELSE COUNT_MASK = 0
        
        IF APROD EQ 'MASK' THEN BYT_IMAGE = MSK ELSE BEGIN
          IF KEYWORD_SET(DISCRETE) THEN BYT_IMAGE = BYTE(DAT)+1 ELSE $
                                        BYT_IMAGE = PRODS_2BYTE(DAT,PROD=IMGPROD)
          OKMISS = WHERE(DAT EQ MISSINGS(DAT) OR FIX(DAT) EQ MISSINGS(FIX(DAT)),COUNT_MISS)
          IF COUNT_MISS GT 0 THEN BYT_IMAGE[OKMISS] = 254
          IF COUNT_MASK GT 0 THEN BYT_IMAGE[OKMASK] = 255
          IF HAS(APROD,'FPERSISTCUM') THEN BYT_IMAGE[WHERE(DAT EQ 0,/NULL)] = 254
        ENDELSE  
        IF APROD EQ OPROD AND MSK NE [] THEN OUTLINE=WHERE(FMSK NE 0,/NULL) ELSE OUTLINE = []
        
        C = COUNTER MOD NCOLS           ; Number of columns is associated with the number of products so C represents the column number
        IF KEYWORD_SET(ADD_DAILY) THEN XPOS=LEFT*1.+SPACE*C+XDIM*C+CBSPACE*C*.9 ELSE XPOS = LEFT + C*XDIM + C*SPACE  ; Determine the left side of the image
        IF C EQ 0 THEN R = COUNTER/NCOLS  ; When C = 0, start a new row
        IF C EQ 0 OR N_ELEMENTS(YPOS) EQ 0 THEN BEGIN
          IF KEYWORD_SET(ADD_DAILY) THEN YPOS = HEIGHT-TOP-R*YDIM-R*SPACE ELSE YPOS = HEIGHT - TOP - R*YDIM - R*SPACE -R*CBSPACE  
        ENDIF ELSE YPOS = YPOS ; Determine the top position of the image
        
        POS = [XPOS,YPOS-YDIM,XPOS+XDIM,YPOS]
        BATHY_COLOR=255
        PRODS_2PNG, BYT_IMAGE=BYT_IMAGE, OBJ=OBJ, PROD=APROD, SPROD=IMGPROD, ADD_CB=0, PAL=PAL, IMG_POS=POS, MAPP=MP, DEPTH=BATHY_DEPTHS, BATHY_COLOR=BATHY_COLOR, $
                    OUTLINE_IMG=OUTLINE, OUT_COLOR=250, OUT_THICK=1, /CURRENT, /DEVICE, DISCRETE=DISCRETE, BUFFER=BUFFER 
                           
        IF KEYWORD_SET(ADD_DAILY) THEN TXT = TEXT(XPOS+SPACE+XDIM/2.,YPOS-YDIM-15,CBTITLE,FONT_SIZE=10,ALIGNMENT=0.5,/DEVICE)

        CBPOS = [POS[0]+XDIM*.1,POS[1]-YDIM*.05, POS[2]-XDIM*.1, POS[1]-YDIM*.01]
        HCBPOS = [CBPOS[0]/WIDTH,CBPOS[1]/HEIGHT,CBPOS[2]/WIDTH,CBPOS[3]/HEIGHT] ; Convert to NORMAL values
        CBPOS = FLOAT([XPOS+XDIM+SPACE,YPOS-YDIM+SPACE,XPOS+XDIM+SPACE+CBSPACE/3,YPOS-SPACE])
        VCBPOS = [CBPOS[0]/WIDTH,CBPOS[1]/HEIGHT,CBPOS[2]/WIDTH,CBPOS[3]/HEIGHT] ; Convert to NORMAL values
        IF APROD EQ 'MASK' THEN BEGIN          
          FOR N=0, N_ELEMENTS(NAMES)-1 DO BEGIN
            NAME = NAMES[N]
            CODE = CODES[N]
            CASE STRUPCASE(NAME) OF
              'MISSING DATA':     BEGIN & LNAME = 'No data'          & MPOS = [POS[0]+XDIM*.01,POS[1]-YDIM*.08] & END
              'NON-FRONT':        BEGIN & LNAME = 'No front'         & MPOS = [POS[0]+XDIM*.45,POS[1]-YDIM*.08] & END
              'FRONT':            BEGIN & LNAME = 'Front'            & MPOS = [POS[0]+XDIM*.01,POS[1]-YDIM*.18] & END
              'PERSISTENT FRONT': BEGIN & LNAME = 'Persistent front' & MPOS = [POS[0]+XDIM*.45,POS[1]-YDIM*.18] & END
              ELSE: LNAME = ''
            ENDCASE
            IF LNAME NE '' THEN BEGIN
              CLR = RGB_COLOR(PRODS_2BYTE(CODE,PROD=STRJOIN(['NUM',NUM2STR([MIN(CODES),MAX(CODES)])],'_')),PAL=PAL)
              WIDTH = ROUND(250/FLOAT(DISCRETE))
              RGB_TABLE = RGBS([0,255],PAL=PAL)
              RGB = RGB_TABLE[*,WIDTH + WIDTH*INDGEN(DISCRETE)]
              RGB_TABLE[*,1:DISCRETE] = RGB
              TXT = TEXT(MPOS[0],MPOS[1],LNAME,FONT_COLOR=CLR,FONT_SIZE=13.5,/DEVICE)
            ENDIF
          ENDFOR  
        ENDIF ELSE BEGIN  
          IF KEYWORD_SET(ADD_DAILY) THEN CBAR, IMGPROD, CB_TITLE='',      PAL=PAL2, OBJ=WIMG, FONT_SIZE=CFONT_SIZE, FONT_STYLE=FONT_STYLE, CB_TYPE=5, CB_POS=VCBPOS, CB_TICKNAMES=CB_TICKNAMES, CB_TICKVALUES=CB_TICKVALUES, DISCRETE=DISCRETE $
                                    ELSE CBAR, IMGPROD, CB_TITLE=CBTITLE, PAL=PAL,  OBJ=WIMG, FONT_SIZE=CFONT_SIZE, FONT_STYLE=FONT_STYLE, CB_TYPE=3, CB_POS=HCBPOS, CB_TICKNAMES=CB_TICKNAMES, CB_TICKVALUES=CB_TICKVALUES, DISCRETE=DISCRETE
        ENDELSE
        COUNTER = COUNTER + 1
      ENDFOR ; NTAGS
          
      WIMG.SAVE, OUTFILE, RESOLUTION=RESOLUTION
      WIMG.CLOSE
      
      PRINT, 'Writing ' + OUTFILE
        
    ENDFOR ; FILES
  ENDFOR ; INPUT_FILES
    


END ; ***************** End of ILLEX_NETCDF_COMPOSITE *****************
