; $Id:	duplicate.pro,	October 18 2007	$

	FUNCTION DUPLICATE, ARRAY, COUNT

;+
; NAME:
;		DUPLICATE
;
; PURPOSE:;
;		This procedure will REPLICATE an array with multiple variables
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;
;		ARRAY = ['A','B','C']
;		COUNT = 5
;		RESULT = DUPLIATE(ARRAY,COUNT)
;
;
; INPUTS:
;		ARRAY: A one dimensional array to be replicated
;		COUNT: Number of replications for the array
;
; OPTIONAL INPUTS:
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;		This function returns the result = 'A','B','C','A','B','C','A','B','C','A','B','C','A','B','C'
;
;
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written Oct 18, 2007 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'DUPLICATE'

;	===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;			 The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
	ERROR = ''


	FOR NTH = 0L, COUNT-1 DO BEGIN
		IF NTH EQ 0 THEN NEWARR = ARRAY ELSE NEWARR = [NEWARR,ARRAY]
	ENDFOR
	RETURN, NEWARR




	END; #####################  End of Routine ################################
