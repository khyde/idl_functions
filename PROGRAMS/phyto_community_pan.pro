; $ID:	PHYTO_COMMUNITY_PAN.PRO,	2020-07-08-15,	USER-KJWH	$

FUNCTION PHYTO_COMMUNITY_PAN,CHLA=chla,CHLB=chlb,CHLC=chlc,FUCO=fuco,PERID=perid,ZEA=zea,ALLO=allo,DIA=dia,LUT=lut,NEO=neo,VIOLA=viola,$
                      VERBOSE=verbose, ERROR=ERROR, ERR_MSG=ERR_MSG, MISSING=missing

;+
; NAME:
;   PHYTO_COMMUNITY_PAN
;
; PURPOSE:;
;   This procedure uses Xiaoju Pan's model to estimate the phytoplankton community from remote sensing data
;
; CATEGORY:
;   CATEGORY
;
; CALLING SEQUENCE:
;
;   Result = FUNCTION_NAME(Parameter1, Parameter2)
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
;
; OUTPUTS:
;   This function returns the
;
; OPTIONAL OUTPUTS:  ;
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
; EXAMPLE:
;
; NOTES:
;  Algorithm provided by Xiaoju Pan (a former post-doc for Antonio Mannino)
;
;
; MODIFICATION HISTORY:
;     Written September 07, 2010 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov) - Based on IDL code from Xiaoju Pan (xpanx001@gmail.com)
;     
;     
;-


;****************************************************************************************
;*    Remote sensing of Phytoplankton Community                                         *
;*   Created by Xiaoju Pan (xpanx001@gmail.com)                                         *
;*   Updated by August 14, 2009                                                         *
;****************************************************************************************

; CONVERT INPUT DATA TO DOUBLE PRECISION  
  TEMP  = DOUBLE(CHLA)
  CHLA  = DOUBLE(CHLA)
  CHLB  = DOUBLE(CHLB)
  CHLC  = DOUBLE(CHLC)
  FUCO  = DOUBLE(FUCO)
  PERID = DOUBLE(PERID)
  ZEA   = DOUBLE(ZEA)
  ALLO  = DOUBLE(ALLO)
  DIA   = DOUBLE(DIA)
  LUT   = DOUBLE(LUT)
  NEO   = DOUBLE(NEO)
  VIOLA = DOUBLE(VIOLA)
  
; CREATE TEMP ARRAYS FOR OUTPUT DATA    
  TEMP(*)                   = MISSINGS(TEMP)
  PRASINOPHYTE_A            = TEMP
  PRASINOPHYTE_B            = TEMP
  DIATOM                    = TEMP
  DINOFLAGELLATE_A          = TEMP
  DINOFLAGELLATE_B          = TEMP
  CRYPTOPHYTE               = TEMP
  CHLOROPHYTE               = TEMP
  HAPTOPHYTE_A              = TEMP
  HAPTOPHYTE_B              = TEMP
  CYANOBACTERIA             = TEMP
  PROCHLOROPHYTE            = TEMP
  TCHL_A                    = TEMP

  BROWN_ALGAE               = TEMP
  DINOFLAGELLATE            = TEMP
  GREEN_ALGAE               = TEMP
  MICRO                     = TEMP
  NANO                      = TEMP
  PICO                      = TEMP
  NANOPICO                 = TEMP
  
  DIATOM_PERCENTAGE         = TEMP
  CRYPTOPHYTE_PERCENTAGE    = TEMP
  BROWN_PERCENTAGE          = TEMP  
  DINOFLAGELLATE_PERCENTAGE = TEMP
  GREEN_PERCENTAGE          = TEMP
  MICRO_PERCENTAGE          = TEMP
  NANO_PERCENTAGE           = TEMP
  PICO_PERCENTAGE           = TEMP
  NANOPICO_PERCENTAGE      = TEMP
  
;  OK_GOOD = WHERE(CHLA  NE MISSINGS(CHLA)  AND $             
;                  CHLB  NE MISSINGS(CHLB)  AND $
;                  CHLC  NE MISSINGS(CHLC)  AND $
;                  FUCO  NE MISSINGS(FUCO)  AND $
;                  PERID NE MISSINGS(PERID) AND $
;                  ZEA   NE MISSINGS(ZEA)   AND $
;                  ALLO  NE MISSINGS(ALLO)  AND $
;                  DIA   NE MISSINGS(DIA)   AND $
;                  LUT   NE MISSINGS(LUT)   AND $
;                  NEO   NE MISSINGS(NEO)   AND $
;                  VIOLA NE MISSINGS(VIOLA) AND $                                                                        
;                  CHLA  GE 0d              AND $
;                  CHLB  GE 0d              AND $
;                  CHLC  GE 0d              AND $
;                  FUCO  GE 0d              AND $
;                  PERID GE 0d              AND $
;                  ZEA   GE 0d              AND $
;                  ALLO  GE 0d              AND $
;                  DIA   GE 0d              AND $
;                  LUT   GE 0d              AND $
;                  NEO   GE 0d              AND $
;                  VIOLA GE 0d              AND $                 
;                  FINITE(CHLA)             AND $
;                  FINITE(CHLB)             AND $
;                  FINITE(CHLC)             AND $
;                  FINITE(FUCO)             AND $
;                  FINITE(PERID)            AND $
;                  FINITE(ZEA)              AND $
;                  FINITE(ALLO)             AND $
;                  FINITE(DIA)              AND $
;                  FINITE(LUT)              AND $
;                  FINITE(NEO)              AND $                  
;                  FINITE(VIOLA), COUNT_GOOD)
;
;  IF COUNT_GOOD LT 1 THEN BEGIN
;    ERROR = 1
;    ERR_MSG = 'No valid input data to calculate PHYTO_COMMUNITY-PAN.'
;    RETURN, []   ; If no valid input data, then return empty array
;  ENDIF                  

  CHEMTAX_RATIO_FILENAME = !S.PROGRAMS + 'chemtax_ratio_subsets.csv'
  CHEMTAX = READALL(CHEMTAX_RATIO_FILENAME)                                       ; Read the chemtax file

	FOR J=0, N_ELEMENTS(CHLA)-1 DO BEGIN
	  IF CHLA(J) EQ MISSINGS(CHLA) THEN CONTINUE                                    ; If CHLA is missing, can not determine the X_ARRAY from the CHEMTAX table
	;	PHYTO_COMMUNITY = FLTARR(11)-1.0
		Y_ARRAY=[CHLA(J),CHLB(J),CHLC(J),PERID(J),FUCO(J),DIA(J),ALLO(J),ZEA(J),LUT(J),NEO(J),VIOLA(J)]
		OK = WHERE(Y_ARRAY EQ MISSINGS(Y_ARRAY),COUNT)
		IF COUNT EQ N_ELEMENTS(Y_ARRAY) THEN CONTINUE ELSE Y_ARRAY[OK] = 0.0D         ; Change missing values to 0. If all values are missing, skip to next pixel.  
		OK = WHERE(Y_ARRAY GT 0.0,COUNT)
		IF COUNT LE 3 THEN CONTINUE                                                   ; If there are 3 or fewer valid values, skip to next pixel. 
		WEIGHT_FACTOR=FLTARR(N_ELEMENTS(Y_ARRAY),1)+1.0
		IF MIN(Y_ARRAY) GE 0.0 AND MAX(Y_ARRAY) LT 100000. AND TOTAL(Y_ARRAY) GT 0.0 THEN BEGIN		
			SUBSET=WHERE(CHEMTAX.MIN_LOG_TCHL_A LE ALOG10(CHLA(J)) AND CHEMTAX.MAX_LOG_TCHL_A GT ALOG10(CHLA(J)),COUNT_SUBSET)
			IF COUNT_SUBSET EQ 0 THEN CONTINUE		                                      ; If chlorophyll value out of range of the chemtax table, skip to next pixel.
			CHEMTAX_SUB=CHEMTAX(SUBSET) & CHEMTAX_SUB = STRUCT_REMOVE(CHEMTAX_SUB,TAGS=[0,1,2])
			X_ARRAY = STRUCT_2ARR(STRUCT_2FLT(CHEMTAX_SUB),/FLT)
			
			IF ALOG10(CHLA(J)) GE 0.9 AND ALOG10(CHLA(J)) LT 1.1 THEN BEGIN
			  SUBSET1 = WHERE(CHEMTAX.MIN_LOG_TCHL_A LE (ALOG10(CHLA(J))-0.2) AND CHEMTAX.MAX_LOG_TCHL_A GT (ALOG10(CHLA(J))-0.2))
			  CHEMTAX_SUB1 = CHEMTAX(SUBSET1) & CHEMTAX_SUB1 = STRUCT_REMOVE(CHEMTAX_SUB1,TAGS=[0,1,2])
        X1_ARRAY = STRUCT_2ARR(STRUCT_2FLT(CHEMTAX_SUB1),/FLT) 
			  SUBSET2 = WHERE(CHEMTAX.MIN_LOG_TCHL_A LE (ALOG10(CHLA(J))+0.2) AND CHEMTAX.MAX_LOG_TCHL_A GT (ALOG10(CHLA(J))+0.2))
			  CHEMTAX_SUB2 = CHEMTAX(SUBSET2) & CHEMTAX_SUB2 = STRUCT_REMOVE(CHEMTAX_SUB2,TAGS=[0,1,2])
			  X2_ARRAY = STRUCT_2ARR(STRUCT_2FLT(CHEMTAX_SUB2),/FLT) 
			  
			  MODIFIED_COMMUNITY,PHYTO_1,X1_ARRAY,Y_ARRAY,WEIGHT_FACTOR,VERBOSE=verbose
			  MODIFIED_COMMUNITY,PHYTO_2,X2_ARRAY,Y_ARRAY,WEIGHT_FACTOR,VERBOSE=verbose
			  PHYTO_COMMUNITY = (PHYTO_1+PHYTO_2)/2.
			ENDIF ELSE BEGIN	  
			  MODIFIED_COMMUNITY,PHYTO_COMMUNITY,X_ARRAY,Y_ARRAY,WEIGHT_FACTOR,VERBOSE=verbose
			ENDELSE  

			SUM_CHLA=MEAN(PHYTO_COMMUNITY)*11.0  ; Should this be TOTAL(PHYTO_COMMUNITY) instead???  What if some subgroups eq 0.0???		
if FLOAT(SUM_CHLA) NE FLOAT(TOTAL(PHYTO_COMMUNITY)) OR n_elements(phyto_community) lt 11 then stop			
;if abs((float(sum_chla)-float(chla(j)))/chla(j)) gt 0.2 then stop
			
			IF SUM_CHLA GT 0.0 THEN BEGIN
				TCHL_A(J)=SUM_CHLA
        DIATOM(J)=PHYTO_COMMUNITY[0]
        CRYPTOPHYTE(J)=PHYTO_COMMUNITY[1]
        DINOFLAGELLATE_A(J)=PHYTO_COMMUNITY(2)
        DINOFLAGELLATE_B(J)=PHYTO_COMMUNITY(3)
        HAPTOPHYTE_A(J)=PHYTO_COMMUNITY(4)
        HAPTOPHYTE_B(J)=PHYTO_COMMUNITY(5)
        PRASINOPHYTE_A(J)=PHYTO_COMMUNITY(6)
        PRASINOPHYTE_B(J)=PHYTO_COMMUNITY(7)
        CHLOROPHYTE(J)=PHYTO_COMMUNITY(8)
        CYANOBACTERIA(J)=PHYTO_COMMUNITY(9)
        PROCHLOROPHYTE(J)=PHYTO_COMMUNITY(10)

        GREEN_ALGAE(J)    = PRASINOPHYTE_A(J)+PRASINOPHYTE_B(J)+CHLOROPHYTE(J)
        DINOFLAGELLATE(J) = DINOFLAGELLATE_A(J)+DINOFLAGELLATE_B(J)
        BROWN_ALGAE(J)    = HAPTOPHYTE_A(J)+HAPTOPHYTE_B(J)  
        MICRO(J)          = DIATOM(J)+DINOFLAGELLATE(J)
        NANO(J)           = GREEN_ALGAE(J)+BROWN_ALGAE(J)+CRYPTOPHYTE(J)
        PICO(J)           = CYANOBACTERIA(J)+PROCHLOROPHYTE(J)
        NANOPICO(J)      = NANO(J) + PICO(J)

        DIATOM_PERCENTAGE(J)         = DIATOM(J)/SUM_CHLA*100.0
        DINOFLAGELLATE_PERCENTAGE(J) = DINOFLAGELLATE(J)/SUM_CHLA*100.0
        CRYPTOPHYTE_PERCENTAGE(J)    = CRYPTOPHYTE(J)/SUM_CHLA*100.0
        GREEN_PERCENTAGE(J)          = GREEN_ALGAE(J)/SUM_CHLA*100.0
        BROWN_PERCENTAGE(J)          = BROWN_ALGAE(J)/SUM_CHLA*100.0
        MICRO_PERCENTAGE(J)          = MICRO(J)/SUM_CHLA*100.0
        NANO_PERCENTAGE(J)           = NANO(J)/SUM_CHLA*100.0
        PICO_PERCENTAGE(J)           = PICO(J)/SUM_CHLA*100.0     
        NANOPICO_PERCENTAGE(J)      = NANOPICO(J)/SUM_CHLA*100.0
			ENDIF

		ENDIF

	ENDFOR
		
	; RETURN PIGMENT STRUCURE
  RETURN, CREATE_STRUCT('BROWN_ALGAE',              FLOAT(BROWN_ALGAE),$
                        'BROWN_PERCENTAGE',         FLOAT(BROWN_PERCENTAGE),$
                        'DIATOM',                   FLOAT(DIATOM),$
                        'DIATOM_PERCENTAGE',        FLOAT(DIATOM_PERCENTAGE),$
                        'DINOFLAGELLATE_A',         FLOAT(DINOFLAGELLATE_A),$
                        'DINOFLAGELLATE_B',         FLOAT(DINOFLAGELLATE_B),$
                        'DINOFLAGELLATE',           FLOAT(DINOFLAGELLATE),$
                        'DINOFLAGELLATE_PERCENTAGE',FLOAT(DINOFLAGELLATE_PERCENTAGE),$
                        'CHLOROPHYTE',              FLOAT(CHLOROPHYTE),$
                        'CRYPTOPHYTE',              FLOAT(CRYPTOPHYTE),$
                        'CRYPTOPHYTE_PERCENTAGE',   FLOAT(CRYPTOPHYTE_PERCENTAGE),$
                        'CYANOBACTERIA',            FLOAT(CYANOBACTERIA),$
                        'GREEN_ALGAE',              FLOAT(GREEN_ALGAE),$
                        'GREEN_PERCENTAGE',         FLOAT(GREEN_PERCENTAGE),$
                        'HAPTOPHYTE_A',             FLOAT(HAPTOPHYTE_A),$
                        'HAPTOPHYTE_B',             FLOAT(HAPTOPHYTE_B),$   
                        'MICRO',                    FLOAT(MICRO),$
                        'MICRO_PERCENTAGE',         FLOAT(MICRO_PERCENTAGE),$
                        'NANO',                     FLOAT(NANO),$
                        'NANO_PERCENTAGE',          FLOAT(NANO_PERCENTAGE),$  
                        'NANOPICO',                FLOAT(NANOPICO),$
                        'NANOPICO_PERCENTAGE',     FLOAT(NANOPICO_PERCENTAGE),$                     
                        'PICO',                     FLOAT(PICO),$
                        'PICO_PERCENTAGE',          FLOAT(PICO_PERCENTAGE),$
                        'PRASINOPHYTE_A',           FLOAT(PRASINOPHYTE_A),$
                        'PRASINOPHYTE_B',           FLOAT(PRASINOPHYTE_B),$
                        'PROCHLOROPHYTE',           FLOAT(PROCHLOROPHYTE),$
                        'TCHL_A',                   FLOAT(TCHL_A))

END



