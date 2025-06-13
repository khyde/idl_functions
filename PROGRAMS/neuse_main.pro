; $ID:	NEUSE_MAIN.PRO,	2020-06-30-17,	USER-KJWH	$
PRO NEUSE_MAIN
FILES=FILELIST('D:\PROJECTS\NEUS\DATA\Salt_neus.nc')



FILES=FILES[0]
LIST, FILES
;CDF_ATTGET, Id, Attribute, EntryNum, Value [, CDF_TYPE= variable] [, /ZVARIABLE]


ID=NCDF_OPEN(FILES)
TEMPERATURE=''
result = NCDF_ATTINQ(id, /GLOBAL, TEMPERATURE)

STOP

NCDF_ATTGET, 'TIME', /GLOBAL, name, date

name = NCDF_ATTNAME(id, /GLOBAL,4)
PRINT,NAME

; Get info about the attribute:






STOP
;NCDF_INQUIRE: Call this function to find the format of the netCDF file.
;NCDF_DIMINQ: Retrieve the names and sizes of dimensions in the file.
;NCDF_VARINQ: Retrieve the names, types, and sizes of variables in the file.
;NCDF_ATTNAME: Optionally, retrieve attribute names.
;NCDF_ATTINQ: Optionally, retrieve the types and lengths of attributes.
;NCDF_ATTGET: Optionally, retrieve the attributes.
;NCDF_VARGET: Read the data from the variables.
;NCDF_CLOSE: Close the file.

STOP



END
