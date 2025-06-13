; $ID:	KS_STAT_ONE.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION KS_STAT_ONE, DATA, INTEGER=INT, ABOVE=ABV, PROB=PROB, XVAL=XVAL

;+
; NAME:
;   KS_STAT_ONE
;
; PURPOSE:
;   Compute the one-sided Kolmogorov-Smirnov statistic using the Gaussian cumulative distribution function
;
; CATEGORY:
;   STAT_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = KS_STAT_ONE(data)
;
; REQUIRED INPUTS:
;   DATA.......... A vector of data values, must contain at least 4 elements for the K-S statistic to be meaningful 
;
; OPTIONAL INPUTS:
;   Parm2......... Describe optional inputs here. If none, delete this section.
;
; KEYWORD PARAMETERS:
;   INTEGER....... Set if FUNCTION_NAME is a discrete function taking only integer values  like the Poisson distribution.
;                    FUNCTION_NAME must be defined down to min(data) - 1
;                    If the maximum distance is below the function, XVAL will return one of the data - 1
;
; OUTPUTS:
;   A floating scalar giving the Kolmogorov-Smirnov statistic. It specifies the maximum deviation between the cumulative 
;     distribution of the data and the supplied function.
;       
; OPTIONAL OUTPUTS:
;   PROB.......... A floating scalar between 0 and 1 giving the significance level of the K-S statistic.
;                     Small values of PROB show that the cumulative distribution function of DATA is significantly different from FUNC_NAME.
;   XVAL.......... A data value at which the maximum deviation occurs
;   ABOVE......... Returns 0 (false) is the maximum distance is below the expected CDF and 1 (true) if it is above
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
;   Returns the Kolmogorov-Smirnov statistic and associated probability for an array of data values being consistent with a Gaussian cumulative distribution function (CDF) of a single variable.   
;   Algorithm from the procedure of the same name in "Numerical Recipes" by Press et al. 2nd edition (1992)
;   
; COPYRIGHT: 
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on March 14, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Mar 14, 2022 - KJWH: Initial code written - adapted from ksone.pro writeen by W. Landsman and found in the IDL Astronomy User's Library (https://idlastro.gsfc.nasa.gov/)
;                        Using the GAUSS_CDF function written in ksone.pro
;                        Changed the program to a function
;                        Removed the plotting step
;                        Updated formatting
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'KS_STAT_ONE'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF ~KEYWORD_SET(INT) THEN  INT = 0
  
  DSIZE = SIZE(DATA)
  ID = DSIZE[0]
  IF INT*DSIZE[ID+1] GT 3 THEN MESSAGE, 'ERROR: If INTEGER keyword is set data values must be integer'
    
  N = DSIZE[ID+2]
  IF N LT 3 THEN MESSAGE, 'ERROR: Input data values (first param) must contain at least 3 values'  

  SORTDATA = DATA[SORT(DATA)]
  
  IF INT GT 0 THEN BEGIN
    SINGLES = [0,WHERE(SORTDATA LT SORTDATA[1:*])+1]                ; Mark duplicates
    SORTDATA = REBIN(SORTDATA,2*N,/SAMPLE)                          ; Create secondary points shifted by 1 from input
    SORTDATA[2*SINGLES] -= 1                                        ; Do not shift duplicates
  ENDIF
  
  FF = ERF(SORTDATA/SQRT(2))                                        ; The CDF of a Gaussian is the error function including a factor of 2

  IF ~KEYWORD_SET(INT) THEN BEGIN
    SORTDATA = REBIN(SORTDATA,2*N,/SAMPLE)
    FF = REBIN(FF,2*N,/SAMPLE)
  ENDIF
  
  F0 = FINDGEN(N)/ N
  F0 = [0,REBIN(F0[1:*],2*(N-1),/SAMPLE),1]

  D = MAX( ABS(F0-FF), SUB0 )
  XVAL = SORTDATA[SUB0]
  MSUB = F0[SUB0] GE FF[SUB0]
  
  PROB_KS, D, N, prob           ;Compute significance of K-S statistic
  RETURN, [D,PROB]
END ; ***************** End of KS_STAT_ONE *****************
