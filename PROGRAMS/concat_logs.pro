pro concat_logs
files_a = filelist('F:\seawifs\z\S*_REPRO4_NEC.log')
files_b = filelist('F:\seawifs\z\S*_repro4.log')
fn_a = parse_it(files_a)
fn_b = parse_it(files_b)

stop
for n=0,n_elements(files_b)-1l do begin
  iname= strmid(fn_b(n).first_name,7,13)
  ok = where(strmid(fn_a.first_name,1,13) eq iname,count)
  if count eq 1 then begin
    result_b=read_txt(fn_b(n).fullname)
    result_a=read_txt(fn_a(ok).fullname)
    result_a = [result_a,result_b]
    log=fn_a(ok).fullname
    OPENW,LUN,log,/GET_LUN
    PRINTF,LUN,result_a
    CLOSE,LUN & FREE_LUN,LUN
  endif
endfor

end