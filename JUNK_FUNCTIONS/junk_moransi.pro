pro junk_moransi

z = [3,4,5,11,3,2,1,5,3,2,6,12,3,4,6,2,4]
W = [1,2,1,2, 1,2,1,2,1,2,1,2, 1,2,1,2,1]

  pysal = Python.Import('pysal')
  mi = pysal.Moran(Z, w)
  Morans_I = mi.I
  
  stop
  
end  

