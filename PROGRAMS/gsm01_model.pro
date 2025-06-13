PRO gsm01_model, wl_idx, A, F, dper
; X = wl_idx = wavelength index (wwww in dv's code)
; A = guess
; F = rs = rrs
; drsda = derviative array for drrs/dchl, drrs/dadm0 and drrs/dbbp0
common share_gsm01_mod
; Absorption
;***********
abs_coef = aw + aphstar_lin*(A[0]^(1.0-aphstar_exp)) + A[1] * admstar
; Backscattering
;***************
bb = bbw + A[2]*bbpstar
; Gordon et al., 1988
;********************
x = bb/(abs_coef + bb)
F = grd1*x + grd2*x^2
fact = (grd1 + 2*grd2*x)*x*x
dper = [[-fact * aphstar_lin * (1.0-aphstar_exp) * (A[0]^(-aphstar_exp))/bb], [-fact * admstar/bb], [fact * abs_coef *bbpstar/(bb*bb)]]
end