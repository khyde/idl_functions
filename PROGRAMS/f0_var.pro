  PRO F0_VAR, F0=F0
  ; FROM DSP

   DAY = INDGEN(365)+1

;   F0_VAR = (1.0 +0.0167*COS(2*!PI*(DAY-3)/365.))^2
;   PLOT,F0_VAR

; ======================
; from seadas 3.2 anly8dbl.rat
;#f0var(fday) = (1+.0167*cos(2*$PI*(fday-3)/365))**2 # 7 % yearly variation
;# WDR this old vers with .1% error replaced by below with .001% error
 f0_var   = 1.0/(1.00014 - $
              0.01671*COS(2.0*!PI*(0.9856002831*day-3.4532868)/360.0) - $
              0.00014*COS(4.0*!PI*(0.9856002831*day-3.4532868)/360.0))^2



   F0=F0_VAR

  END
