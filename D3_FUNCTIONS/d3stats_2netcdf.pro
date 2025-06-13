; $ID:	D3STATS_2NETCDF.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO D3STATS_2NETCDF, D3FILES, DIR_OUT=DIR_OUT, MAP_OUT=MAP_OUT, OVERWRITE=OVERWRITE, OUTFILE=OUTFILE

;+
; NAME:
;   D3STATS_2NETCDF
;
; PURPOSE:
;   Merge multiple D3 "stats" files into a single netcdf
;
; CATEGORY:
;   D3_FUNCTIONS
;
; CALLING SEQUENCE:
;   D3STATS_2NETCDF, D3_FILES
;
; REQUIRED INPUTS:
;   D3FILES.......... The D3 file(s) creating from STATS .sav files 
;
; OPTIONAL INPUTS:
;   DIR_OUT....... Directory for writing output nc file
;   MAP_OUT....... Name of the map for the output structure 
;
; KEYWORD PARAMETERS:
;   OVERWRITE..... Overwrite output nc file
;
; OUTPUTS:
;   Netcdf files saved in DIR_OUT
;
; OPTIONAL OUTPUTS:
;   OUTFILE....... The name of the output nc file
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
;   Adapted from D3_2NETCDF
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on June 04, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jun 04, 2021 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'D3STATS_2NETCDF'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  COMMON _D3_2NETCDF, GLOBAL_STR, MTIME
  MASTER = !S.MAINFILES + 'NETCDF_MAIN.csv'
  IF NONE(MTIME) THEN MTIME = GET_MTIME(MASTER)
  IF GET_MTIME(MASTER) GT MTIME THEN INIT = 1 ELSE INIT = 0
  IF NONE(GLOBAL_STR) OR KEY(INIT) THEN BEGIN & GLOBAL_STR = CSV_READ(MASTER) & TIME = GET_MTIME(MASTER) & ENDIF





END ; ***************** End of D3STATS_2NETCDF *****************
