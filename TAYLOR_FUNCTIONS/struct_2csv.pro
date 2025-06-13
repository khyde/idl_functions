; $Id:	struct_2csv.pro,	August 11 2008	$
;+
;	This Program Writes a Comma-Delimited CSV file from an IDL Simple Structure
; SYNTAX:
;		STRUCT_2CSV,File, Struct
; OUTPUT:
;		An ascii CSV comma-delimited file with heading
; ARGUMENTS:
; 	File:	Complete name for the output csv File
;		Struct:	The simple structure to be written
; EXAMPLE:
;  	Struct = CREATE_STRUCT('AA',0B,'BB',1,'CC',2L,'DD',3.0,'EE',4.0D)
;  	Struct = Replicate(Struct,4)
;   STRUCT_2CSV,'test.csv',Struct;
; 	Open test.csv file with Excel or Word Processor ... it should look like this ...
;	AA,BB,CC,DD,EE
;	0,1,2,3.000000,4.000000000000000
;	0,1,2,3.000000,4.000000000000000
;	0,1,2,3.000000,4.000000000000000
;	0,1,2,3.000000,4.000000000000000
;
; NOTES:
;		Works with simple structures (spreadsheet or database types of structures).
;		Calls STRUCT_2CSV.PRO
;
; VERSION:
;		Jan 22,2001
; HISTORY:
;		Oct 12,2001	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO STRUCT_2CSV, File, Struct
	ROUTINE_NAME='STRUCT_2CSV'
  TXT=STRUCT_2STRING(Struct,/HEADING)
  OPENW,LUN,File,/GET_LUN
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  FOR N=0L,N_ELEMENTS(TXT)-1L DO BEGIN
    PRINTF,LUN,TXT(N)
  ENDFOR
  CLOSE,LUN & FREE_LUN,LUN
  GONE,TXT
 END; #####################  End of Routine ################################
