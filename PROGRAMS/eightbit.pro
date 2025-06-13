; $Id: eightbit.pro,v 1.0 1994/12/11 12:00:00 J.O'Reilly Exp $
FUNCTION EIGHTBIT
;+
; NAME:
;       EIGHTBIT
;
; PURPOSE:
;       This function fills an eight character
;       string array with 0's and 1's
;       to represent each bit of
;       each byte from 0 to 255.
;
; CATEGORY:
;       Misc.
;
; CALLING SEQUENCE:
;       result = eightbit()
;
; INPUTS:
;       No explicit user defined inputs.
;
; KEYWORD PARAMETERS:
;       None.
;
; OUTPUTS:
;       A string array, 256(eight character strings).
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; EXAMPLE:
;       For example, to generate a text array
;       'result' containing eight 0's and 1's for the
;       binary numbers from 0 to 255:
;
;       result = eightbit()
;
; MODIFICATION HISTORY:
;       Written by J.E. O'Reilly, December, 1994.
;		NOAA, NMFS Narragansett Laboratory, 28 Tarzwell Drive, Narragansett, RI 02882-1199
;		oreilly@fish1.gso.uri.edu
;-

    bintext = STRARR(256)
    achar = ['0','1']
      FOR i = 0,(N_ELEMENTS(bintext)-1) DO BEGIN
        num = i
        FOR j = 7,0,-1 DO BEGIN
        k = num/(2^j)
        bintext(i) = bintext(i) + achar(k)
        NUM = NUM - k*(2^j)
        ENDFOR
      ENDFOR
     a = bintext
     return,a
end
