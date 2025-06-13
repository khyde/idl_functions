
function epsilon_2angstrom, nm, epsilon
;+
; NAME:
;       epsilon_2angstrom
;
; PURPOSE:
;       convert epsilons to angstrom exponents
;
; CATEGORY:
;        Satellite
;
; CALLING SEQUENCE:
;       Result = epsilon_2angstrom(a)
;
; INPUTS:
;       wavelength,epsilon
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
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
;       Written by:  J.E.O'Reilly, June 25, 1998.
;-

;  McClain and Yeh , equation 11, page 9, SeaWiFS Tech. Rept 13
;  and page 2 of seapak manual

;  E(nm) = (nm/670.)^ang(nm)
;  alog10(E(nm)) = alog10(nm/670.)*ang(nm))
;  alog10(E(nm))/alog10(nm/670.) = ang(nm)


; Bisagni, O'Reilly, and documentation from A. barnard (andy.doc)
; east coast epsilons 1.1442	1.1207	1.0928
; IN table 2a of Bisagni, Oreilly et al.
; nec+mab+sab epsilons 1.144    1.121   1.093

;IDL> a = epsilon_2angstrom(443,1.1442) & print, a
;    -0.325606
;IDL> a = epsilon_2angstrom(520,1.1207) & print, a
;    -0.449611
;IDL> a = epsilon_2angstrom(550,1.0928) & print, a
;    -0.449653
; a for 670 same as a for 443 ???

; NOTE GLOBAL PROCESSING USED AN EPSILON OF 0.95,1,1
; WHICH TRANSLATES TO Angstrom exponent of 0.123, 0,0
; See page 12 in:
; McClain, C.R. and E-N Yeh.
; SeaWiFS Ozone Data Analysis Study.
; In Case Studies for SeaWiFS Calibration and Validation, Part 1,
; edited by S.B. Hooker and E.R. Firestone, pp. 3-8,
;NASA Tech. Memo. 104566, Vol. 13,
;NASA Goddard Space Flight Center, Greenbelt, Maryland, 1994.


;a = epsilon_2angstrom(443,0.95) & print, a



  IF N_PARAMS() NE 2 THEN STOP

   RETURN,ALOG(epsilon)/alog(nm/670.)
  END ; END OF PROGRAM
