; $ID:	PLATT_MODEL.PRO,	2020-07-08-15,	USER-KJWH	$
; PLATT_MODEL Function K.J.W.Hyde 30 June 2006

   PRO PLATT_MODEL, X, A , F
;+
; NAME:
;       PLATT_MODEL
;
; PURPOSE:
;       Calculates productivity (mgC/h) for a given irradiance based on the Platt productivity model
;				PI = PSB * (1-EXP((-ALPHA*IRRADIANCE)/PSB)) * EXP((-BETA*IRRADIANCE)/PSB)
;
; CATEGORY:
;				Productivity modeling
;
; CALLING SEQUENCE:
;				PLATT_MODEL, X, A
;
; INPUTS:
;				X		 = LIGHT 	= LIGHT values that correspond to the DPM values
;				A[0] = PSB		= theoretical maximum productivity without photoinhibition
;				A[1] = ALPHA	= initial slope of the curve
;				A(2) = BETA		=	photoinhibition term

;
; KEYWORD PARAMETERS:
;				NONE
;
; RETURNS:
;				Return a vector appropriate for CURVEFIL (see FUNCT in IDL library)
;
;       The function being fit is of the following form:
;          F(x) = A[0] * (1-EXP(-(A[1]*X)/A[0])) * EXP(-(A(2)*X)/A[0])
;
;
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
;
	F = A[0] * (1-EXP(-(A[1]*X)/A[0])) * EXP(-(A(2)*X)/A[0])
;;	RETURN,F

;  IF N_PARAMS() LE 3 THEN RETURN

;	If the procedure is called with four parameters, calculate the partial derivatives.
; 	PDER = FLTARR(N_ELEMENTS(X),3)
; Compute the partial derivatives with respect to A0 and place in the FIRST row of PDER:
;	PDER[*, 0] = (EXP((-X * (A[1] + A(2))) / A[0]) * (A[0] + (X * (A[1] + A(2))))) / A[0]

; Compute the partial derivatives with respect to A1 and place in the SECOND row of PDER:
;	PDER[*, 1] = -X * EXP((-X * (A[1] + A(2))) / A[0])

; Compute the partial derivatives with respect to A2 and place in the THIRD row of PDER:
;	PDER[*, 2] = -X * EXP((-X * (A[1] + A(2))) / A[0])


END ; END OF PROGRAM
