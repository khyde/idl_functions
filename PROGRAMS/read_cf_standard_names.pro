; $ID:	TEMPLATE_KH.PRO,	2018-08-01-16,	USER-KJWH	$

  FUNCTION READ_CF_STANDARD_NAMES

;+
; NAME:
;   READ_CF_STANDARD_NAMES
;
; PURPOSE:
;   This function reads the CF_STANDARD_NAMES xml file and converts it to a working structure
;
; CATEGORY:
;   
;
; CALLING SEQUENCE:
;
;   Result = READ_CF_STANDARD_NAMES()
;
; INPUTS:
;   
;
; OPTIONAL INPUTS:
;   
;
; KEYWORD PARAMETERS:
;   
;
; OUTPUTS:
;   This function returns a structure of CF Standard Names
;   
;
; OPTIONAL OUTPUTS:
;   
;   
; PROCEDURE:
;
;
; EXAMPLE:
;
;
; NOTES:
;   The XML file was obtained from http://cfconventions.org/standard-names.html.  
;   Current version v64 was acquired on 6 March 2019.
;
;   
; COPYRIGHT: 
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;   
;
; MODIFICATION HISTORY:
;			Written:  March 07, 2019 by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;			Modified:  - KJWH: 
;			          
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'READ_CF_STANDARD_NAMES'
	
	FILE = !S.NETCDF + 'cf-standard-name-table.xml'
	
	


END; #####################  End of Routine ################################
