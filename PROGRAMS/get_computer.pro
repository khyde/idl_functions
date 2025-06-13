; $ID:	GET_COMPUTER.PRO,	2020-06-30-17,	USER-KJWH	$

	FUNCTION GET_COMPUTER, ERROR = error

;+
; NAME:
;		GET_COMPUTER
;
; PURPOSE:
;		This function gets the name of the COMPUTER (HOSTNAME)
;
; CATEGORY:
;		UTILITY
;
; CALLING SEQUENCE:
;		Result = GET_COMPUTER()
;
; INPUTS:
;		NONE:
;
; KEYWORD PARAMETERS:
;		ERROR:	Any error messages are placed in the ERROR keyword.
;
; OUTPUTS:
;		String (The computer name)
;
;	PROCEDURE:
;		WINDOWS: Spawns the command Hostname
;
; EXAMPLE:
;		computer = GET_COMPUTER()
;
;	NOTES:
;		NEEDS TO BE EDITED TO WORK ON UNIX TO GET HOSTNAME
;
; MODIFICATION HISTORY:
;			Written Nov 14, 2000 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;			May 09, 2011  D.W.Moonan Changed "Hostname" to "hostname" for Unix/Linux compat.
;			MAR 14, 2107 - KJWH: Added a step to look for VPN in the COMPUTER name
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'GET_COMPUTER'

	ERROR = ''

	CMD = 'hostname'
	SPAWN, CMD, COMPUTER
	COMPUTER=STRUPCASE(COMPUTER)
	OK = WHERE_STRING(COMPUTER,'VPN',COUNT) 
	IF COUNT EQ 1 THEN RETURN, COMPUTER(OK[0]) 
	IF STRLEN(COMPUTER) GE 1 THEN RETURN, COMPUTER[0]


;	===> If this computer has no IP address then the above will not work (hostname not present)
;			 In this case our convention is to have a plain text file (COMPUTER_ID.TXT)
;			 with the name of the computer on the first line of the text ascii file

	OS=!VERSION.OS
	IF OS EQ 'Win32' THEN COMPUTER_ID = 'C:\COMPUTER_ID.TXT'
	IF OS EQ 'linux' THEN COMPUTER_ID = '/COMPUTER_ID.TXT'
	EXIST = FILE_TEST(COMPUTER_ID)
	IF EXIST EQ 1 THEN BEGIN
  	COMPUTER=READ_TXT(COMPUTER_ID)
		COMPUTER=STRUPCASE(COMPUTER[0])
	ENDIF

	IF COMPUTER EQ '' THEN 	ERROR='ERROR: CAN NOT IDENTIFY THE COMPUTER (host) NAME'

	RETURN, COMPUTER[0]


END; #####################  End of Routine ################################

