; $ID:	ACF.PRO,	2020-06-30-17,	USER-KJWH	$

PRO  ACF,TIME,RATE,LAG,ACF,COVF=COVF

;+
; NAME:
;         ACF
;
; PURPOSE:
;         COMPUTE THE AUTOCORRELATION FUNCTION OF AN EVENLY SAMPLE LIGHTCURVE
;
;
; CATEGORY:
;         TIME SERIES ANALYSIS
;
;
; CALLING SEQUENCE:
;         ACF,TIME,RATE,LAG,ACF,COVF
;
;
; INPUTS:
;         TIME      : THE TIMES AT WHICH THE TIME SERIES WAS MEASURED
;         RATE      : THE CORRESPONDING COUNT RATES
;
;
; OPTIONAL INPUTS:
;         NONE
;
;
; KEYWORD PARAMETERS:
;         NONE
;
;
; OUTPUTS:
;         LAG       : SAMPLE TIME LAGS
;         ACF       : AUTOCORRELATION VALUES TO EACH TIME LAG GIVEN IN
;                     A TWO-DIMENSIONAL ARRAY, ONCE WITHOUT
;                     CORRECTION-FACTOR AND ONCE WITH.
;
; OPTIONAL OUTPUTS:
;         COVF      : AUTOCOVARIANCE VALUES TO EACH TIME LAG GIVEN IN
;                     A ONE-DIMENSIONAL ARRAY.
;
; COMMON BLOCKS:
;         NONE
;
;
; SIDE EFFECTS:
;         NONE
;
;
; RESTRICTIONS:
;         EVENLY TIME SERIES
;
;
; PROCEDURE:
;         THE AUTOCORRELATION FUNCTION IS COMPUTED ACCORDING TO THE
;         APPROXIMATION OF EVENLY SAMPLE GIVEN BY
;         COVF(LAG)=(1/(NPT-LAG))SUM_{J=1,..NPT-LAG}[X(J)-<X>][X(J+LAG)-<X>]
;         ACF(LAG)=COVF(LAG)/COVF[0]
;         ADDITIONALLY, A CORECTION-FACTOR GIVEN BY SUTHERLAND ET
;         AL. 1978, AJP 219, 1029P, IS ADDED.
;
; EXAMPLE:
;         ACF,TIME,RATE,LAG,ACF,COVF=COVF
;
;
; MODIFICATION HISTORY:
;         VERSION 1.0, 1998.12.21, SARA BELLOCH IAAT, JEORN WILMS IAAT.
;                                 (BENLLOCH@ASTRO.UNI-TUEBINGEN.DE)
;-

   ;;
   ;; LIGHTCURVE (LC) PARAMETERS
   ;;

   ;; DIMENSION OF LC IN BINS
   NPT = N_ELEMENTS(TIME)

   ;; AUTOCORRELATION IS DEFINED FOR SERIES WITH MEAN ZERO
   RAT = RATE-MEAN(RATE)

   ;;
   ;; AUTOCOVARIANCE FUNCTION ESTIMATE BY
   ;; COVF(LAG)=(1/(NPT-LAG))SUM_{J=1,..NPT-LAG}[X(J)-<X>][X(J+LAG)-<X>]
   ;;
   COVF = DBLARR(NPT)

   FOR LAG=0,NPT-1 DO BEGIN     ; ( LAG = 0,...,NPT-1 )
       COVF[LAG] = TOTAL(RAT[0:NPT-LAG-1]*RAT[LAG:NPT-1]) / (NPT-LAG)
   END
   LAG = (TIME[1]-TIME[0]) * FINDGEN(NPT)

   ;;
   ;; AUTOCORRELATION FUNCTION
   ;; ACF(LAG)=COVF(LAG)/COVF(0)
   ;;
   ACF = DBLARR(2,NPT)
   ACF(0,*) = COVF / COVF[0]

   ;;
   ;; CORRECTION-FACTORS  (SUTHERLAND ET AL. 1978, APJ 219, 1029P)
   ;;
   K1 = 1. / NPT
   K2 = 1. / (NPT*NPT)
   FOR I=0,NPT-1 DO BEGIN
       ACF(1,I) = ACF(0,I) + K1 - FLOAT(I)*K2
   ENDFOR
END







