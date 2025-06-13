; $ID:	READ_HDF5.PRO,	2015-10-02	$

; MODIFICATION HISTORY
;      OCT 01, 2015 - JOR:  ADDED GONE TO SAVE MEMORY SPACE
;      OCT 02, 2015 - KJWH: ADDED H5_CLOSE TO THE END TO COMPLETELY CLOSE THE HDF5 FILE
;      NOV 16, 2016 - KJWH: Added ret=[] to the beginning of get_group_dataset to eliminate the need for "if n_elements(ret) eq 0 then..." statements
;

function get_group_dataset, structure

  FORWARD_FUNCTION get_group_dataset

  ns_tags = n_tags(structure)
  
  ret = []
  for i=0,n_tags(structure)-1 do begin
    sz = size(structure.(i))
    if ( (sz[sz[0]+1] eq 8)) then begin
      if ( structure.(i)._type eq 'DATASET') then begin
          ret = [ret, structure.(i)._path + ":" + structure.(i)._name + ':']
      endif else if ( structure.(i)._type eq 'GROUP') then begin
         IF KEY(VERBOSE) THEN  PRINT,'GROUP: ',STRUCTURE.(I)._NAME
          ret = [ret, get_group_dataset(structure.(i))]
      endif
    endif
  endfor

  return, ret

end

;########################################################################
function read_hdf5, file, dataset, group=group, band=band,VERBOSE=VERBOSE

  fid = H5F_OPEN(file)

  if (keyword_set(group)) then begin
    IF KEY(VERBOSE) THEN print,group
  endif else begin
    h5_struct = h5_parse(file)
    gd = get_group_dataset(h5_struct)

    for i=0,n_elements(gd)-1 do begin
      pos = strpos(gd[i], ':'+dataset+':')
      if (pos ne -1) then begin
        group = strmid(gd[i], 0, pos)
        break
      endif
    endfor
  endelse

  GRP_ID = H5G_OPEN(FID, GROUP)
  DSET_ID = H5D_OPEN(GRP_ID, DATASET)
  OUT = H5D_READ(DSET_ID)
  H5D_CLOSE, DSET_ID  & GONE,DSET_ID
  H5G_CLOSE, GRP_ID   & GONE,GRP_ID
  H5F_CLOSE, FID      & GONE,FID
  H5_CLOSE

  IF (KEYWORD_SET(BAND) EQ 0) THEN RETURN, OUT

  IF (BAND EQ 1) THEN OUT=REFORM(OUT[0,*])
  IF (BAND EQ 2) THEN OUT=REFORM(OUT[1,*])
  IF (BAND EQ 3) THEN OUT=REFORM(OUT[2,*])

  RETURN, OUT
END; #####################  END OF ROUTINE ################################




