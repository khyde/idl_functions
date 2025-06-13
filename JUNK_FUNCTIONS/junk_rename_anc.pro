pro junk_rename_anc

  dir = !S.scripts + 'SEADAS/seadas_anc/'
  files = file_search(dir + 'temp/' + '*' + ['.anc','.atteph'])
  
  for n=0, n_elements(files)-1 do begin
    d = read_txt(files(n))
    d = replace(d, '/usr/local/seadas_anc/', dir)
    write_txt, files(n), d
    file_move, files(n), dir, /verbose  
  endfor
  
end