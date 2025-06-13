; $Id: PB_OPT.pro $  VERSION: March 26,2002
;+
;
;		Aug 24, 2002	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO PB_OPT,SST_SAT,MODEL=model
  ROUTINE_NAME='PB_OPT'

  IF N_ELEMENTS(MODEL) NE 1 THEN MODEL = 'MA'
  IF N_ELEMENTS(MODEL) EQ 0 THEN SST_SAT = FINDGEN(320)*.1

 IF TEMP_MODEL EQ 'MA' THEN BEGIN
   print,'Calculating Pb_opt Using Morel-Antoine Temperature Response'
	 Pb_opt = 1.54*10.^(0.0275*SST_SAT-0.07)		;For Morel's Temperature model
 ENDIF


 IF TEMP_MODEL EQ 'BF' THEN BEGIN
;   print,'Calculating Pb_opt Using Behrenfeld & Falkowski Temperature Response'
	c0=1.2956
  c1=2.75 ;c1=0.2749
  c2=6.17 ;c2=6.17e-2
  c3=-20.5 ;c3=-2.05e-2
  c4=24.62 ;c4=2.46e-3
  c5=-13.48 ;c5=-1.35e-4
  c6=3.4132 ;c6=3.42e-6
  c7=-0.327 ;c7=-3.28e-8
    Pb_opt=4.*(SST_SAT gt 28.5)+1.13*(SST_SAT lt -1.)*(SST_SAT gt -10.)
    logic_arr=(SST_SAT le 28.5)*(SST_SAT ge -1.)
;    WAS:    SST_SAT=(0.1*SST_SAT > 1.e-5) ; THIS ALTERED THE SST PERMANENTLY
     _SST_SAT=(0.1*SST_SAT > 1.e-5)

    Pb_opt=float(logic_arr eq 0)*Pb_opt+float(logic_arr)* $
           (c7*_SST_SAT^7.+c6*_SST_SAT^6.+c5*_SST_SAT^5. $
           +c4*_SST_SAT^4.+c3*_SST_SAT^3.+c2*_SST_SAT^2. $
           +c1*_SST_SAT+c0)
   ENDIF

END; #####################  End of Routine ################################
