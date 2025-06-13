

; PLATT_MODEL Function K.J.W.Hyde 30 June 2006

   FUNCTION PMAXCALC, ALPHA=ALPHA, BETA=BETA, PSB=PSB
;+
; NAME:
;       PLATT_MODEL
;
; PURPOSE:
;       Calculates light saturated maximum production (pmax) according to Lorhenz et a. (1994) from ALPHA, BETA, and PSB.
;				These terms are derived from carbon 14 incubations and fit to the Platt et al (1980) P-I model
;
; CATEGORY:
;				Productivity modeling
;
; CALLING SEQUENCE:
;				Pmax = PMAXCALC(ALPHA=ALPHA, BETA=BETA, PSB=PSB)
;
; INPUTS:
;				ALPHA	= initial slope of the curve
;				BETA	=	photoinhibition term
;				PSB		= theoretical maximum productivity without photoinhibition
;
; KEYWORD PARAMETERS:
;				NONE
;
; OUTPUTS:
;       PMAX 	= light saturated maximum production
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:			K.J.W. Hyde		30 June 2006
;
; ****************************************************************************************************************************
;

	P = PSB * (ALPHA/(ALPHA+BETA)) * (BETA/(ALPHA+BETA))^(BETA/ALPHA)

  RETURN, P

END ; END OF PROGRAM