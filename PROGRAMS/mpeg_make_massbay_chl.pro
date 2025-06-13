; $Id: mpeg_make_MASSBAY_chl.pro,  J.E.O'Reilly Exp $

PRO mpeg_make_MASSBAY_chl
;+
; NAME:
;       mpeg_make_MASSBAY_chl
;
; PURPOSE:
;
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;      mpeg_make_MASSBAY_chl
;
; INPUTS:
;
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
;       Written by:  J.E.O'Reilly, Jan, 1995.
;-

 FILES = FILELIST('H:\SEAWIFS\BROWSE\MASS_BAY\*.PNG')


  MPEG_MAKE,FILES=FILES,PAL='PAL_SW3',SCALE=1





 END; OF PROGRAM
