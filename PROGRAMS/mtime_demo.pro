PRO MTIME_DEMO
	ROUTINE_NAME = 'MTIME_DEMO'



	SECS	=	SYSTIME(/SECONDS)
  SEC2DATE= JD_2DATE(SECONDS1970_2JD(SYSTIME(0,SECS,/SECONDS)))
; ===> Write out a dummy file this instant
  OPENW,1,'JUNK.DAT'
  CLOSE,1
	FA=FILE_ALL('D:\IDL\PROGRAMS\'+'JUNK.DAT')

	DT = DATE_NOW(/GMT)


	PRINT, 'SECONDS Since 1970:',SECS,FORMAT='(A,I16)'
	PRINT, 'DATE:',SEC2DATE, FORMAT = '(A,A16)'

	PRINT
	PRINT, 'FILE MTIME:'
	PRINT,  FA.MTIME,FORMAT='(I12)'
	PRINT, 'MTIME_2DATE: '
	PRINT, MTIME_2DATE(FA.MTIME)
	print, 'MTIME_2SYSTIME:'
	STIME=MTIME_2SYSTIME(FA.MTIME)
	PRINT
	PRINT, STIME,FORMAT='(I12)'
	PRINT, 'SYSTIME_2DATE'
	PRINT, JD_2DATE(MTIME_2JD(STIME))





END
