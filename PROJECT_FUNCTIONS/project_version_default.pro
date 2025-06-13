; $ID:	PROJECT_VERSION_DEFAULT.PRO,	2023-09-21-13,	USER-KJWH	$
FUNCTION PROJECT_VERSION_DEFAULT, PROJECT, VERSION=VERSION, DIR_PROJECT=DIR_PROJECT, TIMESERIES=TIMESERIES, SHAPEFILES=SHAPEFILES

  ;+
  ; NAME:
  ;   PROJECT_VERSION_DEFAULT
  ;
  ; PURPOSE:
  ;   Set up default product outputs for projects
  ;
  ; CATEGORY:
  ;   PROJECT_FUNCTIONS
  ;
  ; CALLING SEQUENCE:
  ;   Result = PROJECT_VERSION_DEFAULT()
  ;
  ; REQUIRED INPUTS:
  ;
  ;
  ; OPTIONAL INPUTS:
  ;   PROJECT......... Used to specify project specific information
  ;   VERSION........ Used for for project specific versions
  ;   DIR_PROJECT.. The output directory for the project
  ;   TIMESERIES.... Indicate the type of input data (long, temp, long+temp)
  ;   SHAPEFILES... To include project specific shapefile information
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
  ;   This program was written on August 16, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
  ;
  ; MODIFICATION HISTORY:
  ;   Aug 16, 2023 - KJWH: Initial code written
  ;   Mar 25, 2024 - KJWH: The default now returns minimal information and the output struct is based on the defined variables
  ;                          Added a loop on output structure tags then only add if the variable is defined 
  ;                          * If a new variable is desired, then it needs to be added to the ITAGS array
  ;-
  ; ****************************************************************************************************
  ROUTINE_NAME = 'PROJECT_VERSION_DEFAULT'
  COMPILE_OPT IDL2
  SL = PATH_SEP()

  DP = DATE_PARSE(DATE_NOW())
  VSTR = []

  IF ~N_ELEMENTS(PROJECT) THEN PROJ = 'DEFAULT' ELSE PROJ = PROJECT
  IF ~N_ELEMENTS(TIMESERIES) THEN SERIES = 'LONGTEMP' ELSE SERIES = TIMESERIES

  ; ===> Make the project directories
  IF ~N_ELEMENTS(DIR_PROJECT) THEN DIR_PRO = GET_PROJECT_DIR(PROJ) ELSE DIR_PRO = DIR_PROJECT
  IF DIR_PRO EQ [] THEN MESSAGE, 'ERROR: ' + PROJ + ' directories not found.'
  DIR_PRO = DIR_PRO[0]
  DIR_FILES = DIR_PRO + 'FILES' + SL
  DIR_OUTPUT =  'OUTPUTS' 
  DIRNAMES = ['PNGS']

  FULL_DATERANGE = GET_DATERANGE(['1998',DP.YEAR])
  YEAR_DATERANGE = GET_DATERANGE(DP.YEAR)                                                     ; The full date range of the current year
  PREVIOUS_DATERANGE = GET_DATERANGE(DP.YEAR-1)                                                  ; The date range of the previous year
  YEAR = DP.YEAR

  ; ===> Defaults
  MAP_OUT  = 'NES'                                                                            ; The map to be used for any plots
  
  ; ===> Default product information
  PRODS = ['SST','CHLOR_A']  
  ANIMATION_PRODS = PRODS
  CHL_DATASET = 'OCCCI' & CHL_ALG = 'CCI' & CHL_TEMP = 'GLOBCOLOUR' & CTEMP_ALG = 'GSM'
  PP_DATASET  = 'OCCCI' & PP_TEMP  = 'GLOBCOLOUR' & PP_ALG  = 'VGPM2'
  PSC_DATASET = 'OCCCI' & PSC_TEMP = 'GLOBCOLOUR' & PSC_ALG = 'TURNER'
  OCCCI_VERSION = 'V6.0'
  SST_DATASET  = 'ACSPO' & SST_TEMP = 'ACSPONRT'
  ACSPO_VERSION = 'V2.81'
  EVENTS = []
  
  ; ===> Default periods
  STAT_PERIODS = ['W','WEEK','M','MONTH']
  STAT_TEMP_PERIODS = ['W','M']
  ANOM_PERIODS=['W','M']
  PNG_PERIODS = ['W','M']
  NETCDF_PERIODS = ['W','M']

  ; ===> Change the specific product information based on the project
  ADD_MONTHSCALE = 0
  ADD_DATFILE = 0
  PROJECT_VERSION = ''
  CASE PROJ OF
    'DEFAULT': BEGIN & END
    'ANNUAL_TOTAL_PP': BEGIN
      STAT_PERIODS = ['M','A']
      PPREQ_PRODS = ['PPD-VGPM2','CHLOR_A-CCI']
      PPREQ_PERIODS = ['A','M']
      PPREQ_SHPFILE = ['NES_1REG','NES_EPU_NOESTUARIES']
      DIRNAMES = ['COMPARE']
    END  

    'SOE_PHYTOPLANKTON': BEGIN
      DIR_OUTPUT = VERSION
      PROJECT_VERSION = VERSION
      SERIES = 'LONGTEMP'
      ADD_DATFILE = 1
      DIRNAMES = ['ANIMATIONS','DATA_EXTRACTS','PPREQ_EXTRACTS','COMPARE_DATA','COMPOSITES','PLOTS','EPU_MAPS','SST','COMPARE']
      TEMP_DATERANGE = ['']                                                                       ; The date range for the "temporary" data for the end of the time series
      MAP_IN   = 'L3B2'                                                                           ; The map for the input data
      TEMP_MAP = 'L3B4'
      MAP_OUT  = 'NES'    
      NCMAP_IN = 'L3B2'
      NCMAP_OUT = 'NESGRID2'
      SHAPEFILES  = 'NES_EPU_NOESTUARIES'                                                         ; The shapefile for any data extractions or image outlines
      SUBAREAS = ['GOM','GB','MAB']                                                               ; The subareas for data extraction
      PRODS = ['CHLOR_A','PPD','SST','PSC_'+['MICRO','NANO','PICO','FMICRO','FNANO','FPICO']]
      STAT_PERIODS = ['W','WEEK','M','MONTH','M3','A','ANNUAL']
      STAT_TEMP_PERIODS = ['W','M','M3','A']
      ANOM_PERIODS=['W','M','M3','A']
      EXTRACT_PRODS = ['CHLOR_A','PPD','PSC_'+['MICRO','NANO','PICO','FMICRO','FNANO','FPICO'],'SST']
      EXTRACT_PERIODS = ['W','WEEK','M','MONTH','A','ANNUAL']
      EXTRACT_STAT = 'MEAN'
      EXTRACT_FILETYPE = ['STATS','ANOMS']
      PPREQ_PRODS = ['PPD-VGPM2','CHLOR_A-CCI']
      PPREQ_PERIODS = ['A','M']
      PPREQ_SHPFILE = ['NES_EPU_STATISTICAL_AREAS_NOEST','NES_EPU_STATISTICAL_AREAS','NES_BOTTOM_TRAWL_STRATA','NES_EPU_NOESTUARIES']
      TEMP_PRODS = PRODS
      STACKED_PRODS = LIST(['CHLOR_A'],['SST'],['CHLOR_A-ANOM'],['SST-ANOM'],['PPD-ANOM'],['CHLOR_A','PPD'],['CHLOR_A','PSC_MICRO','PPD'],['CHLOR_A','PSC_FMICRO','PPD'],'PSC_'+['MICRO','NANO','PICO'],'PSC_'+['FMICRO','FNANO','FPICO'])
      MONTHLY_TIMESERIES_PRODS = ['CHLOR_A','SST','PPD']
      COMPOSITE_PRODS = LIST(['PSC_'+['MICRO','NANO','PICO']],['PSC_'+['FMICRO','FNANO','FPICO']])
      COMPOSITE_PERIODS = ['ANNUAL','MONTH','WEEK','A','W','M']
      MOVIE_PERIODS = ['WEEK','MONTH']
      NC_PRODS = ['CHLOR_A','PPD','PSC']
      NC_PERIODS = ['M','M3']
      CASE VERSION OF
        'V2025': BEGIN
          YEAR = '2024'
          EXTRACT_PRODS = ['CHLOR_A','PPD','PSC_'+['MICRO','NANO','PICO','FMICRO','FNANO','FPICO']] ; Removing SST to reduce the total size
          PSUBAREAS = ['GOM','GB','MAB'] ; Project specific subareas (excluding SS to reduce the total file size)
          EVENTS = ['2024_UPWELLING','2024_SST_ANOMALY']
        END  
        'V2024': YEAR = '2023'
        'V2023': BEGIN
          YEAR = '2022'
          SST_DATASET = 'MUR' & SST_TEMP = 'MUR' & 
        END
        'V2022': BEGIN
          YEAR = '2021'
          TEMP_DATERANGE = ['20210430','20211231']
          MAP_IN = 'L3B2'
          EXTRACT_PRODS = ['CHLOR_A','PPD','MICRO','NANO','PICO',['MICRO','NANO','PICO']+'_PERCENTAGE']
          SST_DATASET = 'MUR' & SST_TEMP = 'MUR' & 
        END
        'V2021': BEGIN
          YEAR = '2020'
          TEMP_DATERANGE = ['20200701','20201231']
          EXTRACT_PRODS = ['CHLOR_A','PPD','PHYSIZE']
          CHL_TEMP = 'MODISA' & CTEMP_ALG = 'OCI'
          PP_TEMP = 'MODISA'
          PSZ_TEM = 'MODISA' & PSZ_ALG = 'BREWINSST_NES'
          OCCCI_VERSION = '5.0'
          SST_DATASET = 'MUR' & SST_TEMP = 'MUR' & 
        END
      ENDCASE
      FULL_DATERANGE = GET_DATERANGE('1998',YEAR)
      YEAR_DATERANGE = GET_DATERANGE(YEAR)
    END ; SOE

    'SCALLOPS': BEGIN
      SERIES = 'LONGTEMP'
      ADD_DATFILE = 1
      YEAR = '2023'
      DATERANGE = GET_DATERANGE('1998',YEAR)
      MAP_OUT = ['NES']
      PRODS = ['CHLOR_A','PPD','SST','PSC_'+['MICRO','NANO','PICO','FMICRO','FNANO','FPICO']]
      EXTRACT_PRODS = ['CHLOR_A'];,'PPD','PSC_'+['MICRO','NANO','PICO','FMICRO','FNANO','FPICO'],'SST']
      EXTRACT_PERIODS = ['A','M'];['W','WEEK','M','MONTH','A']
      EXTRACT_STAT = 'MEAN'
      EXTRACT_FILETYPE = ['STATS'];,'ANOMS']
      DIRNAMES=['PNGS','PLOTS','DATA_EXTRACTS']
      DIR_OUTPUT = 'OUTPUT'
      SHAPEFILES  = ['NES_GBK_GOME_GOMS_MABN_MABSPOLY'];,'MAB_SCALLOPS']                                                            ; The shapefile for any data extractions or image outlines
      STACKED_PRODS = LIST(['CHLOR_A','CHLOR_A-ANOM'],['SST','SST-ANOM'],['CHLOR_A','PPD'],['CHLOR_A','PSC_MICRO','PPD'],['CHLOR_A','PSC_FMICRO','PPD'],'PSC_'+['MICRO','NANO','PICO'],'PSC_'+['FMICRO','FNANO','FPICO'])
    END
    'ANIMATIONS': BEGIN
      MAP_OUT='NES'
      DIRNAMES=['ANIMATIONS']
      SST_DATASET = 'MUR'
    END       
    'GOM_CHL_2023': BEGIN
      SERIES = 'TEMP'
      YEAR = '2023'
      MAP_OUT = ['GOM']
    END
    'GOM_BLOOM_2023': BEGIN
      SERIES = 'TEMP'
      YEAR = '2024'
      DATERANGE = ['2023','2024']
      DIR_OUTPUT = 'SATELLITE_IMAGERY'
      MAP_OUT = ['GOM']
      COMP_ANIMATION_PRODS = ['CHLOR_A','SST']
      ANIMATION_PRODS = ['CHLOR_A','SST']
      DIRNAMES = ['PNGS','COMP_ANIMATIONS','ANIMATIONS','COMPOSITES']
    END
    'ILLEX_OCEAN': BEGIN
      SERIES = 'LONGTEMP'
      DATERANGE = ['2022',DP.YEAR]
      DIR_OUTPUT = 'SATELLITE_IMAGERY'
      MAP_OUT = 'MAB'
      DIRNAMES = ['PNGS','ANIMATIONS','COMPOSITES']
      ADD_MONTHSCALE = 1
    END
    'ILLEX_VIEWER': BEGIN
      SERIES = 'LONGTEMP'
      DATERANGE = GET_DATERANGE(['2020',DP.YEAR])
    END
  ENDCASE ; VER

  DNAME = 'DIR_'  + DIRNAMES                                                                      ; The tag name for the directory in the structure
  DIRS  = DIR_PRO + DIR_OUTPUT + SL + DIRNAMES + SL                                                                 ; The actual directory name
  DIR_TEST, DIRS                                                                                  ; Make the output directories if they don't already exist
  DSTR = CREATE_STRUCT('DIR_PROJECT',DIR_PRO,'DIR_FILES',DIR_FILES,'DIR_OUTPUT',DIR_OUTPUT)                               ; Create the directory structure
  FOR D=0, N_ELEMENTS(DIRS)-1 DO DSTR=CREATE_STRUCT(DSTR,DNAME[D],DIRS[D])                        ; Add each directory to the structure

  IF ~N_ELEMENTS(SHAPEFILES) THEN SHPFILE = [] ELSE SHPFILE = SHAPEFILES
  IF N_ELEMENTS(PSHAPEFILES) GE 1 THEN SHPFILE = PSHAPEFILES ; Project specified shapefiles

  HSTR = []
  FOR S=0, N_ELEMENTS(SHPFILE)-1 DO BEGIN
    SHPS = READ_SHPFILE(SHPFILE[S], MAPP=MAP_OUT)
    SUBAREAS = TAG_NAMES(SHPS) & SUBAREAS = SUBAREAS[WHERE(SUBAREAS NE 'OUTLINE' AND SUBAREAS NE 'MAPPED_IMAGE')]
    IF N_ELEMENTS(PSUBAREAS) GE 1 THEN BEGIN
      OK = WHERE_MATCH(SUBAREAS,PSUBAREAS,COUNT)
      IF COUNT GT 1 THEN SUBAREAS = SUBAREAS[OK] ; Only use the project specified subareas
    ENDIF
    OUTLINE = []
    SUBAREA_TITLES = []
    FOR F=0, N_ELEMENTS(SUBAREAS)-1 DO BEGIN
      POS = WHERE(TAG_NAMES(SHPS) EQ STRUPCASE(SUBAREAS[F]),/NULL)
      OUTLINE = [OUTLINE,SHPS.(POS).OUTLINE]
      TITLE = SHPS.(POS).SUBAREA_TITLE
      SUBAREA_TITLES = [SUBAREA_TITLES,TITLE]
    ENDFOR
    STR = CREATE_STRUCT('MAP_OUT',MAP_OUT,'SHAPEFILE',SHPFILE, 'SUBAREA_NAMES',SUBAREAS,'SUBAREA_TITLES',SUBAREA_TITLES,'SUBAREA_OUTLINE',OUTLINE)
    HSTR = CREATE_STRUCT(HSTR,SHPFILE[S],STR)
  ENDFOR

  ISTR = CREATE_STRUCT('PROJECT_VERSION',PROJECT_VERSION) 
  IF DATERANGE NE [] THEN ISTR = CREATE_STRUCT(ISTR,'DATERANGE',DATERANGE) ELSE ISTR = CREATE_STRUCT(ISTR,'DATERANGE',FULL_DATERANGE)
  ITAGS = ['YEAR','YEAR_DATERANGE','FULL_DATERANGE','PREVIOUS_DATERANGE','MAP_OUT','EVENTS','DOWNLOAD_PRODS','PROCESS_PRODS','TEMP_PRODS','NETCDF_PRODS',$
    'PNG_PRODS','ANIMATION_PRODS','COMP_ANIMATION_PRODS','ANIMATION_PERIOD','EXTRACT_PRODS','EXTRACT_PERIODS','EXTRACT_STAT','EXTRACT_FILETYPE',$
    'STAT_PERIODS','STAT_TEMP_PERIODS','ANOM_PERIODS','PNG_PERIODS','NETCDF_PERIODS','STACKED_PRODS', 'MONTHLY_TIMESERIES_PRODS']
    
  VARNAMES = SCOPE_VARNAME(LEVEL=0)
  FOR I=0, N_ELEMENTS(ITAGS)-1 DO BEGIN
;    IF HAS(VARNAMES,ITAGS[I]) THEN IF SCOPE_VARFETCH(ITAGS[I]) NE [] THEN ISTR = CREATE_STRUCT(ISTR, ITAGS[I], SCOPE_VARFETCH(ITAGS[I], LEVEL=0,/ENTER))
; Not sure if the above or below part is correct
    IF HAS(VARNAMES,ITAGS[I]) THEN IF N_ELEMENTS(SCOPE_VARFETCH(ITAGS[I])) GT 0 THEN ISTR = CREATE_STRUCT(ISTR, ITAGS[I], SCOPE_VARFETCH(ITAGS[I], LEVEL=0))
  ENDFOR
  
  IF KEYWORD_SET(ADD_DATFILE) THEN ISTR = CREATE_STRUCT(ISTR,'DATAFILE',DSTR.DIR_DATA_EXTRACTS + VERSION + '-' + SHPFILE + '-COMPILED_DATA_FILE.SAV')
  IF PPREQ_PRODS NE [] THEN ISTR = CREATE_STRUCT(ISTR,'PPREQ_PRODS',PPREQ_PRODS,'PPREQ_PERIODS',PPREQ_PERIODS,'PPREQ_SHPFILE',PPREQ_SHPFILE)

  PSTR = []
  FOR P=0, N_ELEMENTS(PRODS)-1 DO BEGIN
    SPROD = PRODS[P]
    ATITLE = ''
    MONTH_SCALE = []
    CASE SPROD OF
      'CHLOR_A':     BEGIN & DTSET=CHL_DATASET & TPSET=CHL_TEMP & SPROD=SPROD+'-'+CHL_ALG & TPROD=REPLACE(SPROD,CHL_ALG,CTEMP_ALG) & DWLPROD='CHL1' & PTAG='MED'   & PSCALE='CHLOR_A_0.1_10' & PAL='PAL_NAVY_GOLD'  & GSCALE='CHLOR_A_0.3_3' & GPAL='PAL_DEFAULT' & ASCALE='RATIO_0.1_10'  & AGSCALE='RATIO_0.5_2.0'  & APAL='PAL_BLUEGREEN_ORANGE' & ATITLE='Chlorophyll Anomaly (Ratio)' & END
      'PPD':         BEGIN & DTSET=PP_DATASET  & TPSET=PP_TEMP  & SPROD=SPROD+'-'+PP_ALG  & TPROD=SPROD                  & PTAG='MED'   & PSCALE='PPD_0.1_10'     & PAL='PAL_NAVY_GOLD'  & GSCALE='PPD_0.1_2'   & GPAL='PAL_DEFAULT' & ASCALE='RATIO'    & IMSCALE='PPD_0.1_10'  & AGSCALE='RATIO_0.5_2.0' & APAL='PAL_BLUEGREEN_ORANGE' & ATITLE='PP Ratio Anomaly' & END
      'SEALEVEL':    BEGIN & DTSET=SLA_DATASET & TPSET=SLA_TEMP & SPROD=SPROD & DWLPROD='SEALEVEL_NRT' & PTAG='' & PSCALE='' & PAL='' & ASCALE='' & APAL='' & END
      'OCEAN':       BEGIN & DTSET=OCN_DATASET & TPSET=OCN_TEMP & SPROD=SPROD & DWLPROD='OCEAN_NRT'    & PTAG='' & PSCALE='' & PAL='' & ASCALE='' & APAL='' & END
      'GRAD_CHL':   BEGIN & DTSET=GRADCHL_DATASET & TPSET=GS_TEMP & SPROD=SPROD+'-'+GCHL_ & DWLPROD='' & PTAG='' & PSCALE='' & PAL='' & ASCALE='' & APAL='' & END
      'GRAD_SST':    BEGIN & DTSET=GRADSST_DATASET & TPSET=GC_TEMP & SPROD=SPROD+'-'+GSST_ALG & DWLPROD='' & PTAG='' & PSCALE='' & PAL='' & ASCALE='' & APAL='' & END
      'PSC_FMICRO': BEGIN & DTSET=PSC_DATASET & TPSET=PSC_TEMP & SPROD=SPROD+'-'+PSC_ALG & TPROD=SPROD                  & PTAG='AMEAN' & PSCALE='NUM_0.0_1.0'    & PAL='PAL_DEFAULT'    & GSCALE=PSCALE            & GPAL='PAL_DEFAULT' & ASCALE='DIF_-5_5' & IMSCALE='NUM_0_0.8' & APAL='PAL_BLUEGREEN_ORANGE' & END
      'PSC_FNANO':  BEGIN & DTSET=PSC_DATASET & TPSET=PSC_TEMP & SPROD=SPROD+'-'+PSC_ALG & TPROD=SPROD                  & PTAG='AMEAN' & PSCALE='NUM_0.0_1.0'    & PAL='PAL_DEFAULT'    & GSCALE=PSCALE            & GPAL='PAL_DEFAULT' & ASCALE='DIF_-5_5' & IMSCALE='NUM_0_0.8' & APAL='PAL_BLUEGREEN_ORANGE' & END
      'PSC_FPICO':    BEGIN & DTSET=PSC_DATASET & TPSET=PSC_TEMP & SPROD=SPROD+'-'+PSC_ALG & TPROD=SPROD                  & PTAG='AMEAN' & PSCALE='NUM_0.0_1.0'    & PAL='PAL_DEFAULT'    & GSCALE=PSCALE            & GPAL='PAL_DEFAULT' & ASCALE='DIF_-5_5' & IMSCALE='NUM_0_0.8' & APAL='PAL_BLUEGREEN_ORANGE' & END
      'PSC_MICRO':   BEGIN & DTSET=PSC_DATASET & TPSET=PSC_TEMP & SPROD=SPROD+'-'+PSC_ALG & TPROD=SPROD                  & PTAG='MED'   & PSCALE='CHLOR_A_0.1_30' & PAL='PAL_NAVY_GOLD'  & GSCALE='CHLOR_A_0.03_3'  & GPAL='PAL_DEFAULT' & ASCALE='DIF_-5_5' & IMSCALE='CHLOR_A_0.01_10' & APAL='PAL_BLUEGREEN_ORANGE' & END
      'PSC_NANO':    BEGIN & DTSET=PSC_DATASET & TPSET=PSC_TEMP & SPROD=SPROD+'-'+PSC_ALG & TPROD=SPROD                  & PTAG='MED'   & PSCALE='CHLOR_A_0.1_30' & PAL='PAL_NAVY_GOLD'  & GSCALE='CHLOR_A_0.03_3'  & GPAL='PAL_DEFAULT' & ASCALE='DIF_-5_5' & IMSCALE='CHLOR_A_0.01_10' & APAL='PAL_BLUEGREEN_ORANGE' & END
      'PSC_PICO':       BEGIN & DTSET=PSC_DATASET & TPSET=PSC_TEMP & SPROD=SPROD+'-'+PSC_ALG & TPROD=SPROD                  & PTAG='MED'   & PSCALE='CHLOR_A_0.1_30' & PAL='PAL_NAVY_GOLD'  & GSCALE='CHLOR_A_0.03_3'  & GPAL='PAL_DEFAULT' & ASCALE='DIF_-5_5' & IMSCALE='CHLOR_A_0.01_10' & APAL='PAL_BLUEGREEN_ORANGE' & END
      'SST':              BEGIN & DTSET=SST_DATASET & TPSET=SST_TEMP & TPROD=SPROD & DWLPROD='' & PTAG='AMEAN' & PSCALE='SST_0_30' & PAL='PAL_BLUEYELLOWRED'   & GSCALE=PSCALE  & GPAL='PAL_DEFAULT' & ASCALE='DIF_-5_5' & AGSCALE='DIF_-2_2' & APAL='PAL_SUNSHINE_DIF' & ATITLE='SST Anomaly ' + UNITS('SST',/NO_NAME)
      MONTH_SCALE = CREATE_STRUCT('M01', 'SST_0_30',$
        'M02', 'SST_0_30',$
        'M03', 'SST_0_30',$
        'M04', 'SST_5_30',$
        'M05', 'SST_5_30',$
        'M06', 'SST_5_30',$
        'M07', 'SST_10_30',$
        'M08', 'SST_15_30',$
        'M09', 'SST_15_30',$
        'M10', 'SST_10_30',$
        'M11', 'SST_5_30',$
        'M12', 'SST_5_30')
    END
  ENDCASE ; SPROD

  CASE SERIES OF
    'LONG': STR = CREATE_STRUCT('DATASET',DTSET,'PROD',SPROD,'DOWNLOAD_PROD',DWLPROD,'PLOT_TAG',PTAG,'PROD_SCALE',PSCALE,'PAL',PAL,'GRID_SCALE',GSCALE,'GRID_PAL',GPAL,'ANOM_SCALE',ASCALE,'ANOM_PAL',APAL,'ANOM_TITLE',ATITLE,'VERSION','')
    'LONGTEMP': STR = CREATE_STRUCT('DATASET',DTSET,'TEMP_DATASET',TPSET,'TEMP_VERSION','','PROD',SPROD,'TEMP_PROD',TPROD,'DOWNLOAD_PROD',DWLPROD,'PLOT_TAG',PTAG,'PROD_SCALE',PSCALE,'PAL',PAL,'GRID_SCALE',GSCALE,'GRID_PAL',GPAL,'ANOM_GRID_SCALE',AGSCALE,'ANOM_SCALE',ASCALE,'ANOM_PAL',APAL,'ANOM_TITLE',ATITLE,'VERSION','')
    'TEMP': STR = CREATE_STRUCT('DATASET',TPSET,'PROD',TPROD,'DOWNLOAD_PROD',DWLPROD,'PLOT_TAG',PTAG,'PROD_SCALE',PSCALE,'PAL',PAL,'GRID_SCALE',GSCALE,'GRID_PAL',GPAL,'ANOM_SCALE',ASCALE,'ANOM_PAL',APAL,'ANOM_TITLE',ATITLE,'VERSION','')
  ENDCASE

  IF DTSET EQ 'OCCCI' THEN STR.VERSION = OCCCI_VERSION
  IF DTSET EQ 'ACSPO' OR DTSET EQ 'ACSPONRT'  THEN STR.VERSION = ACSPO_VERSION

  IF MONTH_SCALE NE [] AND KEYWORD_SET(ADD_MONTHSCALE) THEN STR = CREATE_STRUCT(STR,'MONTH_SCALE',MONTH_SCALE)
  PSTR = CREATE_STRUCT(PSTR,PRODS[P],STR)

ENDFOR ; PRODS
STR = CREATE_STRUCT('PROJECT',PROJ,'INFO',ISTR,'DIRS',DSTR,'PROD_INFO',PSTR)
IF HSTR NE [] THEN STR = CREATE_STRUCT(STR,'SHAPEFILES',HSTR)
RETURN, STR


END ; ***************** End of PROJECT_VERSION_DEFAULT *****************
