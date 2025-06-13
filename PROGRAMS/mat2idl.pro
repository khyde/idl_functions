PRO MAT2IDL,FILE, HEAD,DATA
close,/all

  IF N_ELEMENTS(FILE) NE 1 THEN file= DIALOG_PICKFILE(FILTER='*.MAT;*.mat')
  PRINT,'READING: ',FILE
  OPENR,LUN,/GET_LUN,FILE
  sz=FSTAT(LUN)
  sz=sz.size

  head = BYTARR(200)
  readu,lun,head
  print,head
  print,string(head)
  ok = where(head eq 32) & print, max(ok)
STOP


END