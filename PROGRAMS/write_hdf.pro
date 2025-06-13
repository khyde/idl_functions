; $Id:	WRITE_HDF.PRO.PRO,	2003 Dec 02 15:41	$

 PRO WRITE_HDF, ARR
;+
; NAME:
; 	WRITE_HDF

;		This Program writes an array to simple HDF file

; 	MODIFICATION HISTORY:
;			Written Nov 3, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

	ROUTINE_NAME='WRITE_HDF'


; Open a new HDF file. The file is ready to be accessed:


	fid = HDF_OPEN('demo.hdf', /CREATE) ; Create a new HDF file.

; Start the SD interface.
  SDinterface_id = HDF_SD_START('demo.hdf', /RDWR)

; Create a global attribute:
; HDF_SD_ATTRSET, SD_id, Attr_Name, Values [, Count] [,
	HDF_SD_ATTRSET, SDinterface_id, 'TITLE', 'SST'
; Create another global attribute:
	HDF_SD_ATTRSET, SDinterface_id, 'MAP', 'NEC'


; Create a dataset:
	SDdataset_id = HDF_SD_CREATE(SDinterface_id, 'var1', [10,20], /FLOAT)
; Add a dataset attribute:
	HDF_SD_ATTRSET, SDdataset_id, 'TITLE', 'MY TITLE SDinterface_id', 15


; Create 2 dimensions:
	SDdataset_id = HDF_SD_CREATE(SDinterface_id, 'var1', [10,20,0], /LONG)
; Select the first dimension:
	dim_id=HDF_SD_DIMGETID(SDdataset_id,0)
; Set the data strings and scale for the first dimension:
	HDF_SD_DIMSET, dim_id, NAME='d1', LABEL='l1', $
  FORMAT='f1', UNIT='u1', SCALE=FINDGEN(10)
	HDF_SD_ENDACCESS, SDdataset_id
; Close the HDF file to ensure everything is written:
;;;;HDF_SD_END, SDinterface_id




; Find the recently-created RANGE attribute:
	index=HDF_SD_ATTRFIND(SDinterface_id, 'MAP')
; Retrieve data from RANGE:
	HDF_SD_ATTRINFO,SDinterface_id,index,NAME=atn,COUNT=atc,TYPE=att,DATA=d
; Print information about the returned variables:
	HELP, atn, atc, att
; Print the data returned in variable d with the given format:
	PRINT, d, FORMAT='(F8.2,x,F8.2)'
	HDF_SD_ENDACCESS, SDdataset_id ; End access to the HDF file.
	HDF_SD_END, SDinterface_id
	HDF_CLOSE, fid






 STOP

END; #####################  End of Routine ################################



