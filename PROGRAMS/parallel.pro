; $ID:	TEMPLATE_KH.PRO,	2018-08-01-16,	USER-KJWH	$

  PRO PARALLEL, CMD, LOOP=LOOP, SERVERS=SERVERS, NPROCESS=NCPROCESS

;+
; NAME:
;   PARALLEL
;
; PURPOSE:
;   This procedure will "LOOP" through a variable (e.g. YEAR) and run a command in parallel on multiple servers
;
; CATEGORY:
;   Processing
;
; CALLING SEQUENCE:
;   PARALLEL, CMD, LOOP=LOOP, SERVERS=SERVERS, NPROCESS=NPROCESS
;
; INPUTS:
;   CMD.......... The IDL command that will be run in parallel
;   
; OPTIONAL INPUTS:
;   LOOP......... The variable on which to loop the parallel processes (default=YEAR)
;   SERVERS...... The names of the servers to use for the various processes
;   NPROCESS..... The number of processes to start on each server (default=
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;   The output is dependent on the input CMD
;
; OPTIONAL OUTPUTS:
;
; EXAMPLE:
;   PARALLEL, "BATCH_L3,DO_STATS='Y'"
;   PARALLEL, "BATCH_L3,DO_STATS='Y_1997_2018'"
;   PARALLEL, "BATCH_L3,DO_STATS='Y',BATCH_DATERANGE='2000_2012'"
;   PARALLEL, "BATCH_L3,DO_STATS='Y',DO_ANOMS='Y[SEAWIFS]',BATCH_DATERANGE='2000_2012'"
;   PARALLEL, "BATCH_L3,DO_STATS='Y',BATCH_DATERANGE='2000_2012'", LOOP='YEAR'
;   PARALLEL, "BATCH_L3,DO_STATS='Y',BATCH_DATERANGE='2000_2012'", LOOP='YEAR', SERVERS=['satdata','satbackup1']
;   PARALLEL, "BATCH_L3,DO_STATS='Y',BATCH_DATERANGE='2000_2012'", LOOP='YEAR', SERVERS=['satdata','satbackup1'], NPROCESS=6
;   PARALLEL, "BATCH_L3,DO_STATS='Y',BATCH_DATERANGE='2000_2012'", NPROCESS=12
;
; NOTES:
;   
; COPYRIGHT: 
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;          with assistance from John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;    
;
; MODIFICATION HISTORY:
;			Written:  Oct 31, 2018 by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;			Modified: Nov 01, 2018 - KJWH: 
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'PARALLEL'
	
	DP = DATE_PARSE(DATE_NOW())
	IF NONE(CMD)      THEN MESSAGE, 'ERROR: Must provide input command'
	IF NONE(LOOP)     THEN LOOP = '1997_' + DP.YEAR
	IF NONE(NPROCESS) THEN NPROCESS = NUM2STR(INDGEN(6)) ELSE NPROCESS = NUM2STR(INDGEN(NPROCESS))
	IF NONE(SERVERS)  THEN SERVERS = ['satdata','satbackup1','satbackup2','seadas','modis'] 
	
	SER = SERVERS + '_0'
	FOR I=1, N_ELEMENTS(NPROCESS)-1 DO SER = [SER,SERVERS+'_'+NPROCESS(I)]
	
	
	
	POS = STRPOS(CMD, SEARCH)
	

STOP
END; #####################  End of Routine ################################
