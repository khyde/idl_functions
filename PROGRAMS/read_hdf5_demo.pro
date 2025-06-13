; $ID:	READ_HDF5_DEMO.PRO,	2020-07-08-15,	USER-KJWH	$


;########################################################################
function read_hdf5_demo, file, prods=prods

  h5_list, file, output=out
  sz = size(out,/dimensions)
 
  group = ''
  dataset = '' 
  for n=0, sz[1]-1 do begin
    s = out(*,n)
    if s[0] eq 'dataset' then begin
      pos = strpos(s[1],'/',/reverse_search)
      name = strmid(s[1],pos+1)
      ok_prod = where(strupcase(prods) eq strupcase(name),count_prod)
      if count_prod eq 1 then if dataset[0] eq '' then dataset = s[1] else dataset = [dataset,+s[1]]
    endif
  endfor
  
  fid = H5F_OPEN(file)
  h5_struct = h5_parse(file)
  tags = strupcase(tag_names(h5_struct))
  for n=0, n_elements(dataset)-1 do begin
    set = strsplit(dataset(n),'/',/extract)
    grp = set[0]
    name =set[1]
    pos = where(tags eq strupcase(grp),count) & if count eq 0 then stop
    h5_tags = strupcase(tag_names(h5_struct.(pos)))
    npos = where(h5_tags eq strupcase(name),count) & if count eq 0 then stop  
    str = h5_struct.(pos).(npos)
    grp_id = h5g_open(fid, grp)
    dset_id = h5d_open(grp_id, name)
    data = h5d_read(dset_id)
    if where(strupcase(tag_names(str)) eq 'IMAGE') ge 0 then outstruct = struct_copy(str,'IMAGE',/remove) ; REMOVE IMAGE TAG IF FOUND
    outstruct = struct_merge(str,create_struct('IMAGE',data))
    if n eq 0 then SD = create_struct(strupcase(name),outstruct) else SD = struct_merge(sd,create_struct(strupcase(name),outstruct))
    
  endfor

  h5d_close, dset_id
  h5g_close, grp_id
  h5f_close, fid
  return, SD

  end
