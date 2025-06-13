; $Id:	SHMAP_DEMO.PRO,	2003 Dec 02 15:41	$

 PRO SHMAP_DEMO, COLORS
;+
; NAME:
; 	PNT_LINE_DEMO

;		This Program demonstrates IDL'S PNT_LINE PROGRAM

; MODIFICATION HISTORY:
;		Written jAN 31, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-



;GOTO, SKIP


;Create the same shared memory segment as the previous example, but let IDL choose the segment name::

SHMMAP, 'SHMAP_NUM',/FLOAT, DIMENSION=[1024*8,1024*4], GET_NAME=segname
NUM_SH = SHMVAR(segname)
NUM_SH(*,*) = -MISSINGS(0.0)

STOP

SHMMAP, SHMVAR('MIN_SHNAME',/FLOAT, DIMENSION=[1024*8,1024*4], GET_NAME=segname)
MIN_SH = SHMVAR(segname)
MIN_SH(*,*) = -MISSINGS(0.0)

SHMMAP, 'SHMAP_MAX',/FLOAT, DIMENSION=[1024*8,1024*4], GET_NAME=segname
MAX_SH = SHMVAR(segname)
MAX_SH(*,*) = -MISSINGS(0.0)

SHMMAP, 'SHMAP_SUM',/FLOAT, DIMENSION=[1024*8,1024*4], GET_NAME=segname
SUM_SH = SHMVAR(segname)
SUM_SH(*,*) = -MISSINGS(0.0)

SHMMAP, 'SHMAP_SUM',/FLOAT, DIMENSION=[1024*8,1024*4], GET_NAME=segname
SUM_SH = SHMVAR(segname)
SUM_SH(*,*) = -MISSINGS(0.0)
stop


HELP,/SHARED_MEMORY
SHMUNMAP,SEGNAME
HELP,/SHARED_MEMORY

help,z
stop
z = ''
print,'z=0'
HELP,/SHARED_MEMORY
PRINT,'DONE'

STOP

SKIP:
STOP


filename = 'D:\IDL\PROGRAMS\JUNK.DAT'
OPENW, unit, filename, /GET_LUN
WRITEU, unit, FINDGEN(1024UL*8,1024UL*4)
CLOSE, unit
SHMMAP, /DOUBLE, DIMENSION=[1024UL*8,1024UL*4], GET_NAME=segname,FILENAME=filename, OS_HANDLE='idl_scratch'
z = SHMVAR(segname)
HELP,/SHARED_MEMORY
HELP,Z
SHMUNMAP, SEGNAME
HELP,/SHARED_MEMORY

PRINT,'DONE'





END; #####################  End of Routine ################################



