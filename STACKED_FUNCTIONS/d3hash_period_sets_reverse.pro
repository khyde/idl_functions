; $ID:	D3HASH_PERIOD_SETS_REVERSE.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION D3_PERIOD_SETS_REVERSE, PERIOD

;+
; NAME:
;   D3_PERIOD_SETS_REVERSE
;
; PURPOSE:
;   Deconstruct the period of a "stacked" file (e.g. go from a single WW period for a year to 52 W periods (weeks) for a year)
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = D3_PERIOD_SETS_REVERSE(PERIOD)
;
; REQUIRED INPUTS:
;   PERIOD.......... The period for the input file
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
;   This program was written on January 27, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jan 27, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'D3_PERIODS_REVERSE'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF N_ELEMENTS(PERIOD) NE 1 THEN MESSAGE, 'ERROR: Must provide a single inputer period'
  PSTR = PERIOD_2STRUCT(PERIOD)
  PERIOD_CODE = PSTR.PERIOD_CODE 
  PR = PERIODS_READ(PERIOD_CODE)
  IF PR.STACKED_PERIOD_INPUT EQ '' THEN MESSAGE, 'ERROR: Input period ' + PERIOD + ' is not a "stacked" period'
  PEROUT = PR.STACKED_PERIOD_INPUT
  
  CASE PERIOD_CODE OF 
    'DD': BEGIN & DATES = CREATE_DATE(PSTR.DATE_START,PSTR.DATE_END) & PERIOD_CODE = 'D' & END
    'DD3': BEGIN & DATES = CREATE_DATE(PSTR.DATE_START,PSTR.DATE_END) & PERIOD_CODE = 'D' & END
    'DD8': BEGIN & DATES = CREATE_DATE(PSTR.DATE_START,PSTR.DATE_END) & PERIOD_CODE = 'D' & END
    'WW': DATES = YEAR_WEEK_RANGE(PSTR.DATE_START,PSTR.DATE_END)
    'MM': DATES = YEAR_MONTH_RANGE(PSTR.DATE_START,PSTR.DATE_END)
    'AA': DATES = YEAR_RANGE(PSTR.YEAR_START,PSTR.YEAR_END)
  ENDCASE
    
  PSETS = PERIOD_SETS(DATE_2JD(DATES),PERIOD_CODE=PERIOD_CODE)
  PSTR = PERIOD_2STRUCT(PSETS.PERIOD)
  OUTSTR = REPLICATE(CREATE_STRUCT('PERIOD','','DATE_START','','DATE_END',''),N_ELEMENTS(PSTR))
  IF N_ELEMENTS(PSETS) EQ 1 OR PEROUT EQ 'W' THEN OUTSTR.PERIOD = PSETS.PERIOD $
                                                                                      ELSE OUTSTR.PERIOD = PERIOD_CODE + '_' + STRMID(PSTR.DATE_START,0,PR.FIRST_LENGTH) + '_' + STRMID(PSTR.DATE_END,0,PR.SECOND_LENGTH)

  OUTSTR.DATE_START = PSTR.DATE_START
  OUTSTR.DATE_END   = PSTR.DATE_END
  RETURN, OUTSTR
  



END ; ***************** End of D3_PERIODS_REVERSE *****************
