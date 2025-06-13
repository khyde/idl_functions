; $ID:	GET_SENSOR_LETTER.PRO,	2020-06-26-15,	USER-KJWH	$

  FUNCTION GET_SENSOR_LETTER, SENSOR

;+
; NAME:
;   GET_SENSOR_LETTER
;
; PURPOSE:
;   This function returns the first letter of the raw data file name (prior to the file being converted into a standard NEFSC file name).
;
; CATEGORY:
;   
;
; CALLING SEQUENCE:
;   Result = GET_SENSOR_LETTER(SENSOR)
;
; INPUTS:
;   SENSOR:  The (valid) sensor names
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;   This function returns the first letter of the file based on the sensor input
;
; OPTIONAL OUTPUTS:
;
; PROCEDURE:
;
; EXAMPLE:
;   LET = GET_SENSOR_LETTER()
;   LET = GET_SENSOR('SEAWIFS')
;   LET = GET_SENSOR(['SEAWIFS','MODISA'])
;
; NOTES:
;
;   
; COPYRIGHT: 
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;          with assistance from John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
; ;   
;
; MODIFICATION HISTORY:
;			Written:  Nov 02, 2018 by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;   Jan 10, 2022 - KJWH: Changed HERMES to GLOBCOLOUR
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'GET_SENSOR_LETTER'
	
	ALLSENSORS = STRUPCASE(VALIDS('SENSORS'))
	STRUCT = REPLICATE(CREATE_STRUCT('SENSOR','','LETTER',''),N_ELEMENTS(ALLSENSORS))
	FOR A=0, N_ELEMENTS(ALLSENSORS)-1 DO BEGIN
	  STRUCT(A).SENSOR = ALLSENSORS(A)
	  CASE ALLSENSORS(A) OF
	    'MODISA':     STRUCT(A).LETTER = 'A'
	    'MODIST':     STRUCT(A).LETTER = 'T'
	    'CZCS':       STRUCT(A).LETTER = 'C'
	    'MERIS':      STRUCT(A).LETTER = 'M'
	    'SEAWIFS':    STRUCT(A).LETTER = 'S'
	    'OCCCI':      STRUCT(A).LETTER = 'E'
	    'VIIRS':      STRUCT(A).LETTER = 'V'
	    'GLOBCOLOUR': STRUCT(A).LETTER = 'G'
	    'JPSS1':      STRUCT(A).LETTER = 'V'
	    ELSE:         STRUCT(A).LETTER = ''
	  ENDCASE
	ENDFOR
	
	IF NONE(SENSOR) THEN RETURN, STRUCT
	
	LETTER = REPLICATE('',N_ELEMENTS(SENSOR))
	OK = WHERE_MATCH(STRUCT.SENSOR,STRUPCASE(SENSOR),COUNT,COMPLEMENT=COMPLEMENT,VALID=VALID)
	IF COUNT EQ 0 THEN RETURN, STRUCT
	LETTER(VALID) = STRUCT[OK].LETTER
	RETURN, LETTER
	

END; #####################  End of Routine ################################
