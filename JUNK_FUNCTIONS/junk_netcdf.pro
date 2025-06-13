pro junk_netcdf

;  file_copy, !S.datasets + 'OC-SA-1KM/L3B2_R2015/NC/Z2006001.L3B2_DAY_CHL.nc',!S.FILES, /VERBOSE,/OVERWRITE
  
  f = !S.files + 'Z2006001.L3B2_DAY_CHL.nc';'A2006089175500.L2_LAC_SUB_OC';'A2002364070500.L2_LAC_SST.nc';
  TITLE = 'SeaWiFS, MODIS Level-3 Binned Data'
  INSTR = 'SeaWiFS, MODIS'
  PLATF = 'Orbview-2, Aqua'

D = READ_NC(F,PROD='GLOBAL')

IF H5F_IS_HDF5(f) EQ 1 then begin
  TAGS = TAG_NAMES(H5_PARSE(F))
  
  FID = H5F_OPEN(F,/WRITE)
  PCID = H5G_OPEN(FID,'processing_control')
  SID = H5A_OPEN_NAME(PCID,'source')
  INFILES = H5A_READ(SID)
  H5A_CLOSE, SID
  H5G_CLOSE, PCID
  
  TID = H5A_OPEN_NAME(FID,'title')        & P, H5A_READ(TID) 
  H5A_DELETE, FID, 'title'
  datatype_id = H5T_IDL_CREATE(TITLE)
  dataspace_id = H5S_CREATE_SIMPLE(1,MAX_DIMENSIONS=-1)

  ; make the reference an attribute of the dataset
  TID = H5A_CREATE(fid,'title',datatype_id,dataspace_id)  
  H5A_WRITE,TID,TITLE & P, H5A_READ(TID) 
  h5a_close, tid
  
  H5_EDIT_ATTRIBUTE, FID, 'title',       TITLE, /VERBOSE
  H5_EDIT_ATTRIBUTE, FID, 'instrument',  INSTR, /VERBOSE
  H5_EDIT_ATTRIBUTE, FID, 'platform',    PLATF, /VERBOSE
  H5_EDIT_ATTRIBUTE, FID, 'platfrm',     PLATF, /VERBOSE
  IF H5_HAS_ATTRIBUTE(FID, 'input_files') EQ 1 THEN H5_EDIT_ATTRIBUTE, FID, 'input_files', INFILES, /VERBOSE $
                                               ELSE H5_ADD_ATTRIBUTE,  FID, 'input_files', INFILES, /VERBOSE
  H5_ADD_ATTRIBUTE,  FID, 'modification_history', 'Edited by K. Hyde ' + SYSTIME()
  
 
  H5F_CLOSE, FID
    
  d = read_nc(f,global=global)
  st, global
  
  stop

  
  
ENDIF

stop

    

end