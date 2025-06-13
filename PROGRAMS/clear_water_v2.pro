; $ID:	CLEAR_WATER_V2.PRO,	2020-07-09-08,	USER-KJWH	$
PRO clear_water_v2, wave

;
; Program displays the aw, bbw, Kw values at the wavelength(s) used in input.
; The program reads the 'clear_water.dat' files which contains the original
; clear water values from Smith and Baker (1981) and from Pope & Fry (1997)
;
; The program interpolates to the closest wavelength (at 0.1 nm precision)
;
; Routines called : NUMLINES, OS_FAMILY, TAG_EXIST, DATATYPE, F_WORDARRAY, FILE_EXT, STR_SEP
;    rd_satl, get_1index
;
;
; Any wavelength or array of wavelengths (in the 200-800 nm range) can be used
; If the input wavelength is < 340 nm then values -1.0 is returned for Pope and Fry (no data)
; If the input wavelength is > 727.5 nm then returned values for Pope and Fry (no data) are the
; same as Smith and Baker (1981).
;
; Ex:
; IDL> clear_water, [412, 443, 490, 510, 555, 670]
; will display the aws, bbws and Kws at the seawifs wavelength on the monitor.
;
;SM - June 16, 1999
;


clear_wat = rd_satl('c:\idl\maritorena\clear_water.dat')

wl_pf = clear_wat.(1)
aw_p93 = clear_wat.(2)
aw_pf97 = clear_wat.(3)
wl_sb = clear_wat.(4)
aw_sb81 = clear_wat.(5)
bw_sb81 = clear_wat.(6)

print, 'Pure sea water values '
print, 'lambda    aw_sb81    aw_pf97    bbw        Kw_sb81    Kw_pf97'

for i = 0, n_elements(wave) - 1 do begin

 ; Extract Pope & Fry (1997) clear water aw values. Interpolate if needed (0.1 nm intervals)
 ;******************************************************************************************

 if ((wave(i) ge 340) and (wave(i) le 800.0)) then begin

  idx = get_1index(wave(i), wl_pf)

  lam1 = wl_pf(idx)
  aw1 = aw_pf97(idx)

  if lam1 eq wave(i) then begin
   pf_lam = lam1
   pf_aw = aw1
  endif else begin

   if lam1 gt wave(i) then begin
    lam2 = lam1
    lam1 = wl_pf(idx-1)
    aw2 = aw1
    aw1 = aw_pf97(idx-1)
   endif else $
   if lam1 lt wave(i) then begin
    lam2 = wl_pf(idx+1)
    aw2 = aw_pf97(idx+1)
   endif

   if lam2-lam1 gt 5.0 then nb_sub = 101 else nb_sub = 26

   lam_out = interpol([lam1, lam2], nb_sub)
   aw_out = interpol([aw1, aw2], nb_sub)

   idx = get_1index(wave(i), lam_out)

   pf_lam = lam_out(idx)
   pf_aw = aw_out(idx)


  endelse

 endif else pf_aw = -1.0


 ; Extract Smith & Baker (1981) clear water aw and bw values. Interpolate if needed (0.5 nm intervals)
 ;****************************************************************************************************

 if (wave(i) ge 200.0) then begin

  idx = get_1index(wave(i), wl_sb)
   lam1 = wl_sb(idx)
   aw1 = aw_sb81(idx)
   bw1 = bw_sb81(idx)

  if lam1 eq wave(i) then begin
   sb_lam = lam1
   sb_aw = aw1
   sb_bw = bw1
   kw_sb = aw1 + (0.5 * sb_bw)
  endif else begin

   if lam1 gt wave(i) then begin
    lam2 = lam1
    lam1 = wl_sb(idx-1)
    aw2 = aw1
    aw1 = aw_sb81(idx-1)
    bw2 = bw1
    bw1 = bw_sb81(idx-1)
   endif else $
   if lam1 lt wave(i) then begin
    lam2 = wl_sb(idx+1)
    aw2 = aw_sb81(idx+1)
    bw2 = bw_sb81(idx+1)
   endif

   lam_out = interpol([lam1, lam2], 101)
   aw_out = interpol([aw1, aw2], 101)
   bw_out = interpol([bw1, bw2], 101)


   idx = get_1index(wave(i), lam_out)

   sb_lam = lam_out(idx)
   sb_aw = aw_out(idx)
   sb_bw = bw_out(idx)
   kw_sb = sb_aw + (0.5 * sb_bw)

  endelse

  if wave(i) lt 340 then kw_pf = -1.0 else kw_pf = pf_aw + (0.5 * sb_bw)
  if wave(i) gt 727.5 then begin
   kw_pf = sb_aw + (0.5 * sb_bw)
   pf_aw = sb_aw
  endif

 endif

 if ((wave(i) le 800.0) and (wave(i) ge 200.0)) then $
  print, format = '(f5.1, tr4, 5(f9.6, tr2))', sb_lam, sb_aw, pf_aw, 0.5 * sb_bw, kw_sb, kw_pf $
 else begin
  print, ' '
  print, 'Error ! Input wavelength must be in the 200-800 nm range. Input was ', wave(i)
  print, ' '
 endelse

endfor

end
