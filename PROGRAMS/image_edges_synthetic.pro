; $ID:	IMAGE_EDGES_SYNTHETIC.PRO,	2020-06-30-17,	USER-KJWH	$

	PRO IMAGE_EDGES_SYNTHETIC, ERROR = error

;+
; NAME:
;		IMAGE_EDGES_SYNTHETIC
;
; PURPOSE:;
;
;		This procedure Reads Synthetic Edge Images and Makes standard NARR Scientific Data Save files
;
; CATEGORY:
;		IMAGE
;
; CALLING SEQUENCE:

;
;		IMAGE_EDGES_SYNTHETIC

; INPUTS:
;		Files are read
;
; OPTIONAL INPUTS:
;
;
; OUTPUTS:
;		Standard Scientific Data Save files are written
;

;	NOTES:
;		http://www.prettyview.com/edge/nsedge.shtml
;
;
; MODIFICATION HISTORY:
;			Written Nov 21, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'IMAGE_EDGES_SYNTHETIC'

;	===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;			 The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
	ERROR = ''

	files=FILE_SEARCH('D:\IDL\IMAGES\NSTP*.GIF')
	LIST, FILES

	SOURCE = 'http://www.prettyview.com/edge/nsedge.shtml'
	NOTES='Synthetic images were created with a step edge (height S) and added Gaussian noise (sigma N).  Signal to noise ratio SNR is defined as the square of S/N, or SNR = (S/N)^2. '

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR NTH=0,N_ELEMENTS(FILES)-1 DO BEGIN
		AFILE=FILES[NTH]
		FN=FILE_PARSE(AFILE)

		TXT=STRSPLIT(FN.FIRST_NAME,'nstp',/EXTRACT)
		 SIGNAL_TO_NOISE=TXT[0]

		 NAME =   'NSTP_' +  STRING(TXT,FORMAT='(I03)')

		 READ_GIF,AFILE,IMAGE,R,G,B
		 SAVEFILE = 'D:\IDL\IMAGES\SYNTHETIC_EDGES-'+NAME+'.SAVE'
		 PNGFILE  = 'D:\IDL\IMAGES\SYNTHETIC_EDGES-'+NAME+'.PNG'
		 GIFFILE  = 'D:\IDL\IMAGES\SYNTHETIC_EDGES-'+NAME+'.GIF'
		 STRUCT_SD_WRITE,SAVEFILE,IMAGE=IMAGE, SIGNAL_TO_NOISE=SIGNAL_TO_NOISE,NOTES=NOTES, SOURCE=SOURCE,INFILE=AFILE
		 WRITE_PNG,PNGFILE,IMAGE,R,G,B
		 WRITE_GIF,GIFFILE,IMAGE,R,G,B
ENDFOR




	END; #####################  End of Routine ################################
