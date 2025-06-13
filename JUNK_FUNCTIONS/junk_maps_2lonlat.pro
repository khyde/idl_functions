; $ID:	MAPS_L3B1_2GEQ_DEMO.PRO,	2016-07-18,	USER-JOR	$
; #########################################################################; 
PRO JUNK_MAPS_2LONLAT
  
  MP = 'GEQ1'
  MS = MAPS_SIZE(MP)
  
  OVERWRITE = 1
  
  G = MAPS_2LONLAT(MP,/OVERWRITE)

  LON = G.LON(*,0)
  LAT = G.LAT(0,*) & LAT = REFORM(LAT)
  
  PMM, LON
  PMM, LAT
  
  STOP

END; #####################  END OF ROUTINE ################################
