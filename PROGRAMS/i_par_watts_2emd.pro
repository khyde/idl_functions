; $Id: i_par_watts_2em.pro   Dec 28,1999  J.E.O'Reilly Exp $

function i_par_watts_2emd,PAR_WATTS, QW_FROUIN=qw_frouin
;+
; NAME:
;       i_par_watts_2emd
;
; PURPOSE:
;       Convert Watts (PAR) to Einsteins per M square per Day
;
;      Kirk, J.T.O, 1994, Light and photosynthesis in aquatic ecosystems,
;                          Cambridge University Press, 509pp.
;      page 5
;
; CATEGORY:
;       Light
;
; CALLING SEQUENCE:
;       Result = i_par_watts_2em(watts)
;
; INPUTS:
;       Watts (PAR)
;				QW_FROUIN (use QW factor of
;									instead of QW = 2.77e18 after Morel and Smith (1974)

; OUTPUTS:
;       EMD (PAR Einsteins per Meter Square per Day)
;
; RESTRICTIONS:
;       For PAR (assuming Morel and Smith (1974) Q:W factor of 2.77x10e18 quanta s^-1 W^-1.
;       See Kirk
;
; NOTES:

; One watt is equal to a power rate of one joule of work per second of time.
;
; http://physics.nist.gov/cgi-bin/cuu/Value?na|search_for=AVAGODRO
; AVOGADRO CONSTANT= 6.0221415 x 10^23 mol-1

;	Email from J.O'Reilly to R.Frouin, Oct 28,2003
;	The Q:W factor I have used in the past is:
;	>Morel and Smith (1974) Q:W factor of 2.77x10e18 quanta s^-1 W^-1.
;	>
;	>This may not be best for above water, so I am wondering what Q:W you
;	>recommend?
;	R.Frouin's Response:
;	We have approximately in the PAR range, PAR[E/m^2/day] =
;	RAD[W/m^2]*1.193/3 = 0.398*RAD[W/m^2].
;	SO: IF FROUIN'S QW IS 2.7745e18 THEN:
;	IDL>print, (2.7745e18/6.022e23) * 60.*60.*24
;      0.398068
;
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Dec 28,1999
;-

; ==================>
  IF N_ELEMENTS(PAR_WATTS) LT 1 THEN PAR_WATTS = 1;

; ====================>
; Q:W factor:  2.77e18 quanta s^-1  W^-1
; Einsteins M^-2 D^-1 = (QW / 6.022e23) * 60L*60L*24L
	avogadro = !CONST.NA ; = 6.0221414e+023
  IF KEYWORD_SET(QW_FROUIN) THEN QW = DOUBLE(2.7745e18) ELSE QW = DOUBLE(2.77e18)
  EMD =  PAR_WATTS * ( QW/ avogadro)* 60*60*24.0  ;      0.397357 when using Morel and Smith and 0.398 when using Frouin


  RETURN, EMD

  END; END OF PROGRAM
