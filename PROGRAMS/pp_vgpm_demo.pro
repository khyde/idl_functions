; $Id: PP_VGPM_DEMO.PRO  Sept 30, 2003 $

  PRO PP_VGPM_DEMO

; NAME:
;       PP_VGPM_DEMO
;
; PURPOSE:
;       DEMONSTRATES Behrenfeld-Falkowski VGPM Model (1997)
;
; KEYWORD PARAMETERS:
;        CHL_SAT:  Floating ARRAY OF SATELLITE CHLOROPHYLL DATA
;        SST_SAT:  Floating ARRAY OF SATELLITE Sea Surface Temperature DATA
;        TEMP_MODEL:  'TBF' (BEHRENFELD-FALKOWSKI);  'TMA' EXPONENTIAL(MOREL-ANTOINE)
; OUTPUTS:
;        Primary Productivity, (gC m-2 d-1)
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Jan, 2000.
;-
; ================================================================
; PP_VGPM: PP = 0.66125*Pb_opt*( PAR/(PAR+4.1)) *(Chl_sat > 0.)*Z_eu*day_length


;	===> Morel and Berthon used Ctot to mean Chl + Pha
;      Illustrate the net change between the relative influence
;			 from increasing Ctot (adding Pha to Sat Chlorophyll).  This increases Csat, but decreases Zeu

   sst_SAT=2.0
   day_length=12.0
   par = 30.0
   temp_model = 'TBF'
   CHL_SAT = [0.001,0.01,0.1,1.0,10,50]

	For i=0,1 DO BEGIN
		IF I EQ 1 THEN BEGIN
;			*** Morel and Berthon used chl plus phae ... use the MARMAP TO ESTIMATE C_TOT ?
;  		CATLAS_NETVSPHA
;			PLOTXY, DB.AVGTOT,DB.AVGTOT+DB.AVGPHA,PSYM=1,/LOGLOG,/XSTYLE,/YSTYLE, XRANGE=[0.001,30],YRANGE=[0.001,30],STATS_CHARSIZE=2,PARAMS=[1,2,3,4,8,10],DECIMALS=3,XTITLE='CHLA',YTITLE='CHLA + PHA'
;      CHLA_PHA = 10^(0.163 + 0.894*ALOG10(CHLA))
       CHL_SAT = 10^(0.163 + 0.894*ALOG10(CHL_SAT))
       PRINT, 'MARMAP: Chl+Pha'
		ENDIF




		pp = PP_VGPM(CHL_SAT=chl_SAT,   SST_SAT=sst_SAT, $
                              DAY_LENGTH=day_length, PAR=par, $
                              TEMP_MODEL=TEMP_MODEL)

PRINT, PP
;PRINT, 'EUPHOTIC DEPTH:'
;PRINT,Z_EU
;print, 'EUPHOTIC DEPTH MIKE:'
;PRINT, Z_EU_MIKE

  ENDFOR


  STOP

end


