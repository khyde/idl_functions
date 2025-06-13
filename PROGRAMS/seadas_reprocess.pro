; $ID:	SEADAS_REPROCESS.PRO,	2020-06-30-17,	USER-KJWH	$
pro seadas_reprocess

DIR_L1A = 'J:\SEAWIFS_L1A\Z\'
DIR_HDF = 'j:\SEAWIFS-NEC\Z\'
DIR_REPROCESS_Z = 'H:\SEAWIFS_L1A\Z_REPROCESS\'
DIR_LOG='J:\SEAWIFS_L1A\LOG\'




STOP

l1a=FILELIST(DIR_L1A+'S*.l1a*.*')
fn_l1a=parse_it(l1a)
l1as=fn_l1a.first_name
date=satdate_2date(l1as)

hdf=FILELIST(DIR_HDF+'!S_*.hdf.gz')
fn_hdf=parse_it(hdf)
hdfs=fn_hdf.first_name
hdf_date=strmid(hdfs,3,14)


REPROCESS_CSV=DIR_LOG+'REPROCESS_L1A.CSV'
reprocess=''

for n=0,n_elements(date)-1l do begin
 ok=where(hdf_date eq date(n), count)
 if count ne 1 then begin
   print, 'missing hdf for l1a',date(n) ,'        ',l1a(n) & reprocess=[reprocess,l1a(n)]
 endif
endfor

reprocess= reprocess(1:*)


STOP


IF REPROCESS[0] NE '' THEN BEGIN
	temp   = CREATE_STRUCT('file_name','') & temp=REPLICATE(temp,N_ELEMENTS(reprocess))
	temp.file_name=reprocess
	STRUCT_2CSV,REPROCESS_CSV,TEMP

	names=read_csv(REPROCESS_CSV)
	names=names.file_name
	file_update,names,DIR_REPROCESS_Z
ENDIF

DONE:
END
