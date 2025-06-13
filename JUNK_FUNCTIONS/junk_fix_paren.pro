pro junk_fix_paren


abc = alphabet()
num = num2str(bindgen(10))
txt = [abc,num]
ftxt = ['OK',abc+'th'] ;;,abc,num,
FULLLIST = []
for n=0, n_elements(ftxt)-1 do begin
  for t=0, n_elements(txt)-1 do begin
    OLD = txt[t]+'('+ftxt(n)+')'
    NEW = txt[t]+'['+ftxt(n)+']'
    print, 'Searching for: ' + OLD + ')...'
    pro_replace,old, new;,/test
    
  ;  find_text,txt[t]+'('+ftxt(n)+')',/EXCLUDE_COMMENT,VERBOSE=0, FILELIST=FLIST
  ;  wait, 1
  ;  FULLLIST = [FULLLIST, FLIST]
  ENDFOR
endfor

stop



end