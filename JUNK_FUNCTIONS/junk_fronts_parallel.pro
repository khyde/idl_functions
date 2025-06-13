pro junk_fronts_parallel

batch_l3_parallel, "BATCH_L3,DO_OCCCI='Y'"

;batch_l3_parallel, "BATCH_L3, DO_FRONTS='YRF',DO_STAT_FRONTS='YRF'", NPROCESS=3, R_YEAR=1,servers=['satdata','modis','luna']
;amapps_main
; 
;batch_l3_parallel, "BATCH_L3, DO_FRONTS='YRF', DO_STAT_FRONTS='Y'", NPROCESS=3, R_YEAR=0, servers=['satdata','modis','luna']

end