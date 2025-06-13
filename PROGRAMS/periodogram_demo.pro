PRO periodogram_demo

  set_pmulti,2
  t = findgen(1000)
  x = sin(2.0*!dpi*t/27.0)
  power=periodogram(t,x,per=[20,30],npts=100)
  plot,power(0,*),power(1,*)


 t = findgen(1000)
  x = sin(2.0*!dpi*t/27.0)
  power=periodogram(t,x,per=[20,30],npts=1000)
  plot,power(0,*),power(1,*)
stop
END