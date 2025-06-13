
f = file_search('/nadata/DATASETS/OC/OCCCI/L3B4/SAVE/PHYTO_SIZE-HIRATA_NES/D_*') & help, f
for n=0, n_elements(f)-1 do begin
  d = struct_read(f(n),struct=s)
  if has(tag_names(s),'PICO_PERCETNAGE') then begin
    s = struct_rename(s,'PICO_PERCETNAGE','PICO_PERCENTAGE',/struct_arrays)
    struct_write, s, file=f(n)
  endif
endfor    

end