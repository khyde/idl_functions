; $ID:	H5_ADD_DATASTRUCT_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$
PRO H5_ADD_DATASTRUCT_DEMO

  ROUTINE = 'H5_ADD_DATASTRUCT_DEMO'

  SL = PATH_SEP()
  DIR_OUT = !S.DEMO + ROUTINE + SL & DIR_TEST, DIR_OUT

  FILES = FILE_SEARCH(!S.FILES + 'A2*L3B4*CHL*')
  FP = FILE_PARSE(FILES)
  LI, FILES
  
  h5 = h5_parse(files[0],read_data=0)
  gd = get_group_dataset(h5)
  hd = read_hdf5(files[0])
  
  stop ; THIS PROGRAM IS INCOMPLETE
  
  
  OUTFILE = DIR_OUT + FP[0].FIRST_NAME + '.TESTFILE.nc'
  IF EXISTS(OUTFILE) THEN FILE_DELETE, OUTFILE, /VERBOSE
;  FID = H5F_CREATE(OUTFILE)
  
  tags = tag_names(h5)
  name = h5._name
  icontype = h5._icontype
  type = h5._type
  file = h5._file
  path = h5._path
  comment = h5._comment
  for n=0, n_tags(h5)-1 do begin
    atag = tags(n)
    ityp = idltype(h5.(n))
    if ityp eq 'STRUCT' then begin
      str = h5.(n)

      
      case str._type of
        'ATTRIBUTE': h5_putdata, outfile, str._name, str._data
        'GROUP': BEGIN
            gname = str._name
            for g=0, n_tags(str)-1 do begin
              if idltype(str.(n)._type) eq 'DATASET' then begin
                dt = get_group_dataset(str.(n))
                h5_putdata, outfile, gname+'/'+str._name, str.(n)
              endif
              
            endfor
          END 
         ELSE: stop
      endcase 
      skip:
    endif
    
    
    
  endfor
 
 
 stop 
  
  
  
  D = READ_NC(FILES[0],GLOBAL=GLOBAL)
  CHL = D.SD.CHLOR_A
  CHL = CREATE_STRUCT('PROD','CHLOR_A',CHL)
  
  
  

  H5_ADD_ATTRIBUTE, FID, 'testfile', FILES[0]
 ; H5F_CLOSE, FID
  
  GID = H5G_CREATE(FID, 'chl')

  h5_add_attribute, gid, 'prod', chl.prod
  h5_add_attribute, gid, 'nrows', chl.nrows
  h5_add_attribute, gid, 'bins', chl.bins
  h5_add_attribute, gid, 'data', chl.data

  h5g_close, gid
  h5f_close, fid
  
  stop

  
  id = 'l3b/chl'
  data = CHL
  
  groups = STRSPLIT(id, '/', /EXTRACT)
  nGroups = N_ELEMENTS(groups)-1
  if (nGroups eq 0) then begin
    gid = fid
  endif

  ; Check for or create groups
  gid = fid
  for i=0,nGroups-1 do begin
    catch, err
    if (err eq 0) then begin
      gid = H5G_OPEN(gid, groups[i])
    endif else begin
      catch, /cancel
      gid = H5G_CREATE(gid, groups[i])
    endelse
  endfor



  ; Add dataset to group
  dtid = H5T_IDL_CREATE(data)
  if (N_ELEMENTS(data) eq 1) && ~SIZE(data, /N_DIMENSIONS) then begin
    dsid = H5S_CREATE_SCALAR()
  endif else begin
    dsid = H5S_CREATE_SIMPLE(SIZE(data, /DIMENSIONS) > 1)
  endelse
  datasetname = groups[-1]
  
  ; Does the dataset exist?
  exists = 0b
  nObjs = H5G_GET_NUM_OBJS(gid)
  for i=0,nObjs-1 do begin
    if (H5G_GET_MEMBER_NAME(gid, '/', i) eq datasetname) then begin
      exists = 1b
      break
    endif
  endfor
  if (~exists) then begin
    ; Create the dataset
    did = H5D_CREATE(gid, datasetname, dtid, dsid)
  endif else begin
    ; Open the dataset
    did = H5D_OPEN(gid, datasetname)
  endelse
  ; Write the data to the dataset
  H5D_WRITE, did, data
  ; Close the identifiers
  H5S_CLOSE, dsid
  H5T_CLOSE, dtid
  H5D_CLOSE, did

 
    H5F_CLOSE, fid
  
  
  
 ; H5_PUTDATA, OUTFILE, 'chl', CHL.prod
  
  h5_list, outfile, output=out
  li, out
  
  h5 = h5_parse(outfile)
  stop
  
END  
