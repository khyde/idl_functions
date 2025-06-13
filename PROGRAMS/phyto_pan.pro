; $ID:	PHYTO_PAN.PRO,	2020-07-08-15,	USER-KJWH	$

FUNCTION PHYTO_PAN, STRUCT, VERSION=VERSION, INIT=INIT, VERBOSE=verbose

;+
; NAME:
;   PHYTO_PAN
;
; PURPOSE:;
;   This function uses Xiaoju Pan's model to estimate the phytoplankton community from remote sensing data
;
; CATEGORY:
;   Alogirthms
;
; CALLING SEQUENCE:
;   PHYTO = PHYTO_PAN(PIGMENTS_STRUCTURE)
;
; REQUIRED INPUTS:
;   STRUCT..... A structure containing the phytoplankton pigments (CHLA,CHLB,CHLC,CARO,ALLO,FUCO,PERID,NEO,VIOLA,DIA,ZEA,LUT) 
;
; OPTIONAL INPUTS:
;   VERSION.... To distinguish between different versions of the code
;
; KEYWORD PARAMETERS:
;   VERBOSE... To print the processing status
;   INIT...... To refresh the CHEMTAX ratio structure
;
; OUTPUTS:
;   This function returns a structre with the results of the Pan phytoplankton community alogirhtm
;
; EXAMPLE:
;   * Use PIGMENTS_PAN to generate the PIGMENTS STRUCTURE
;   PHYTO_PAN(PIGMENTS_PAN(SENSOR='MODISA', RRS488=0.0077,RRS547=0.00187,RRS667=0.00186,SST=5.0))
;   PHYTO_PAN(PIGMENTS_PAN(SENSOR='SEAWIFS',RRS490=0.0077,RRS555=0.00187,RRS670=0.00186,SST=5.0)
;   PHYTO_PAN(PIGMENTS_PAN(SENSOR='MODISA', RRS488=[0.0028,0.0077,0.0379],RRS547=[0.000984,0.001855,0.028217],RRS667=[0.000110,0.000186,0.00151200],SST=[5.0,5.5,6.0]))
;   PHYTO_PAN(PIGMENTS_PAN(SENSOR='SEAWIFS',RRS490=[0.0028,0.0077,0.0379],RRS555=[0.000984,0.001855,0.028217],RRS670=[0.000110,0.000186,0.00151200],SST=[5.0,5.5,6.0]))
;   PHYTO_PAN(PIGMENTS_PAN(SENSOR='MODISA', RRS488=[0.0028,0.0077,0.0379],RRS547=[0.000984,0.001855,0.028217],RRS667=[0.000110,0.000186,0.00151200],SST=[5.0,5.5,6.0],VERSION='V1_0'))
;   PHYTO_PAN(PIGMENTS_PAN(SENSOR='SEAWIFS',RRS490=[0.0028,0.0077,0.0379],RRS555=[0.000984,0.001855,0.028217],RRS670=[0.000110,0.000186,0.00151200],SST=[5.0,5.5,6.0],VERSION='V1_1'))
;   
; NOTES:
;  Original algorithm code provided by Xiaoju Pan (a former NASA post-doc for Antonio Mannino)
;  
;  Requires the input file 'chemtax_ratio_subsets.csv' 
;
;
; REFERENCES:
;   Pan X, Mannino A, Marshall HG, Filippino KC, Mulholland MR (2011) Remote sensing of phytoplankton community composition along the northeast coast of the United States. Remote Sensing of Environment 115: 3731-3747 doi 10.1016/j.rse.2011.09.011
;
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was adapted by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov (original algorithm code and chemtax_ratio_subsets.csv file provided by Xiaoju Pan).
;
;
; MODIFICATION HISTORY:
;     Written September 07, 2010 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov) - Based on IDL code from Xiaoju Pan (xpanx001@gmail.com)
;     SEP 01, 2017 - KJWH: Added POF VERBOSE step
;     MAY 02, 2018 - KJWH: Updated formatting and added some documenation
;     AUG 27, 2018 - KJWH: Updated documentation and added examples
;                          Added VERSION keyword
;                          Added INIT keyword to refresh the CHEMTAX ratios in COMMON memory
;     DEC 18, 2018 - KJWH: Now saving the percent data in a range from 0 to 1 instead of 0 to 100 in order to be consistent with the NASA PSC percent data
;-


; ===> Read the CHEMTAX Lookup Table file and put in COMMON memory
  CHEMTAX_RATIO_FILENAME = !S.MASTER + 'chemtax_ratio_subsets.csv'       ; CHEMTAX Lookup Table file
  COMMON CHEMTAX_, CHEMTAX                                               ; Set up the CHEMTAX COMMON structure
  IF NONE(CHEMTAX) OR KEY(INIT) THEN CHEMTAX=[]                          ; Determine if the CHEMTAX structure is available
  IF CHEMTAX EQ [] THEN CHEMTAX = READALL(CHEMTAX_RATIO_FILENAME)        ; If needed, read the CHEMTAX file

; ===> Check the input data
  IF IDLTYPE(STRUCT) NE 'STRUCT' THEN MESSAGE, 'ERROR: Input pigment data must be in a structure'

; ===> Convert input data to double precision  
  CHLA  = DOUBLE(STRUCT.CHLA)
  CHLB  = DOUBLE(STRUCT.CHLB)
  CHLC  = DOUBLE(STRUCT.CHLC)
  FUCO  = DOUBLE(STRUCT.FUCO)
  PERID = DOUBLE(STRUCT.PERID)
  ZEA   = DOUBLE(STRUCT.ZEA)
  ALLO  = DOUBLE(STRUCT.ALLO)
  DIA   = DOUBLE(STRUCT.DIA)
  LUT   = DOUBLE(STRUCT.LUT)
  NEO   = DOUBLE(STRUCT.NEO)
  VIOLA = DOUBLE(STRUCT.VIOLA)
  GONE, STRUCT
  TEMP  = CHLA
  
; ===> Create temp arrays for output data    
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
                

; ===> Loop through input data  
	FOR J=0, N_ELEMENTS(CHLA)-1 DO BEGIN
	  IF KEY(VERBOSE) AND J MOD 100 EQ 0 THEN POF, J-1, CHLA, /NOPRO, TXT=' (' + NUM2STR(100.0*J/N_ELEMENTS(CHLA),DECIMALS=2) + '%)'
	  
; ===> Check input pigment data	  
	  IF CHLA(J) EQ MISSINGS(CHLA) THEN CONTINUE                                                      ; If CHLA is missing, can not determine the X_ARRAY from the CHEMTAX table
		Y_ARRAY=[CHLA(J),CHLB(J),CHLC(J),PERID(J),FUCO(J),DIA(J),ALLO(J),ZEA(J),LUT(J),NEO(J),VIOLA(J)] ; Aggregate all of the pigments into a single array
		OK = WHERE(Y_ARRAY EQ MISSINGS(Y_ARRAY),COUNT)                                                  ; Find missing pigment values
		IF COUNT EQ N_ELEMENTS(Y_ARRAY) THEN CONTINUE ELSE Y_ARRAY[OK] = 0.0D                           ; Change missing values to 0. If all values are missing, skip to next pixel.  
		OK = WHERE(Y_ARRAY GT 0.0,COUNT)                                                                ; Find valid values
		IF COUNT LE 3 THEN CONTINUE                                                                     ; If there are 3 or fewer valid values, skip to next pixel. 
		WEIGHT_FACTOR=FLTARR(N_ELEMENTS(Y_ARRAY),1)+1.0                                                 ; Determine the weight factor
		
		IF MIN(Y_ARRAY) GE 0.0 AND MAX(Y_ARRAY) LT 100000. AND TOTAL(Y_ARRAY) GT 0.0 THEN BEGIN		
			SUBSET=WHERE(CHEMTAX.MIN_LOG_TCHL_A LE ALOG10(CHLA(J)) AND CHEMTAX.MAX_LOG_TCHL_A GT ALOG10(CHLA(J)),COUNT_SUBSET)
			IF COUNT_SUBSET EQ 0 THEN CONTINUE		                                                        ; If chlorophyll value out of range of the chemtax table, skip to next pixel.
			CHEMTAX_SUB=CHEMTAX(SUBSET) & CHEMTAX_SUB = STRUCT_REMOVE(CHEMTAX_SUB,[0,1,2])                ; Remove the 'SUBSET', 'MIN_LOG_TCHL_A', and 'MAX_LOG_TCHL_A' tags from the subset structure
			X_ARRAY = STRUCT_2ARR(STRUCT_2FLT(CHEMTAX_SUB),/FLT)                                          ; Convert the string values to floating point data
			
			IF ALOG10(CHLA(J)) GE 0.9 AND ALOG10(CHLA(J)) LT 1.1 THEN BEGIN
			  SUBSET1 = WHERE(CHEMTAX.MIN_LOG_TCHL_A LE (ALOG10(CHLA(J))-0.2) AND CHEMTAX.MAX_LOG_TCHL_A GT (ALOG10(CHLA(J))-0.2))
			  CHEMTAX_SUB1 = CHEMTAX(SUBSET1) & CHEMTAX_SUB1 = STRUCT_REMOVE(CHEMTAX_SUB1,[0,1,2])
        X1_ARRAY = STRUCT_2ARR(STRUCT_2FLT(CHEMTAX_SUB1),/FLT) 
			  SUBSET2 = WHERE(CHEMTAX.MIN_LOG_TCHL_A LE (ALOG10(CHLA(J))+0.2) AND CHEMTAX.MAX_LOG_TCHL_A GT (ALOG10(CHLA(J))+0.2))
			  CHEMTAX_SUB2 = CHEMTAX(SUBSET2) & CHEMTAX_SUB2 = STRUCT_REMOVE(CHEMTAX_SUB2,[0,1,2])
			  X2_ARRAY = STRUCT_2ARR(STRUCT_2FLT(CHEMTAX_SUB2),/FLT) 
			  
			  MODIFIED_COMMUNITY, PHYTO_1, X1_ARRAY, Y_ARRAY, WEIGHT_FACTOR, VERBOSE=VERBOSE
			  MODIFIED_COMMUNITY, PHYTO_2, X2_ARRAY, Y_ARRAY, WEIGHT_FACTOR, VERBOSE=VERBOSE
			  PHYTO_COMMUNITY = (PHYTO_1+PHYTO_2)/2.
			ENDIF ELSE BEGIN	 ; IF ALOG10(CHLA(J)) GE 0.9 AND ALOG10(CHLA(J)) LT 1.1 THEN BEGIN
			  MODIFIED_COMMUNITY, PHYTO_COMMUNITY ,X_ARRAY, Y_ARRAY, WEIGHT_FACTOR, VERBOSE=VERBOSE
			ENDELSE  

			SUM_CHLA=MEAN(PHYTO_COMMUNITY)*11.0  ; Should this be TOTAL(PHYTO_COMMUNITY) instead???  What if some subgroups eq 0.0???		
      IF FLOAT(SUM_CHLA) NE FLOAT(TOTAL(PHYTO_COMMUNITY)) OR N_ELEMENTS(PHYTO_COMMUNITY) LT 11 THEN STOP			
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

        DIATOM_PERCENTAGE(J)         = DIATOM(J)/SUM_CHLA
        DINOFLAGELLATE_PERCENTAGE(J) = DINOFLAGELLATE(J)/SUM_CHLA
        CRYPTOPHYTE_PERCENTAGE(J)    = CRYPTOPHYTE(J)/SUM_CHLA
        GREEN_PERCENTAGE(J)          = GREEN_ALGAE(J)/SUM_CHLA
        BROWN_PERCENTAGE(J)          = BROWN_ALGAE(J)/SUM_CHLA
        MICRO_PERCENTAGE(J)          = MICRO(J)/SUM_CHLA
        NANO_PERCENTAGE(J)           = NANO(J)/SUM_CHLA
        PICO_PERCENTAGE(J)           = PICO(J)/SUM_CHLA     
        NANOPICO_PERCENTAGE(J)      = NANOPICO(J)/SUM_CHLA
			ENDIF ; IF SUM_CHLA GT 0.0 THEN BEGIN
		ENDIF ; IF MIN(Y_ARRAY) GE 0.0 AND MAX(Y_ARRAY) LT 100000. AND TOTAL(Y_ARRAY) GT 0.0 THEN BEGIN   
	ENDFOR ; FOR J=0, N_ELEMENTS(CHLA)-1 DO BEGIN
		
; ===> RETURN PIGMENT STRUCURE
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



