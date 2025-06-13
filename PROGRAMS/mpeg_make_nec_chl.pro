; $Id: mpeg_make_nec_chl.pro,  J.E.O'Reilly Exp $

PRO mpeg_make_nec_chl
;+
; NAME:
;       mpeg_make_nec_chl
;
; PURPOSE:
;
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;      mpeg_make_nec_chl
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

 FILES = [$
'f:\seawifs\nec\chl\SD_SEAWIFS_CHLOR_A_GMEAN_Y_1998_M_4_MEDIAN_FILL_x.gif',$
'f:\seawifs\nec\chl\SD_SEAWIFS_CHLOR_A_GMEAN_Y_1998_M_5_MEDIAN_FILL_x.gif',$
'f:\seawifs\nec\chl\SD_SEAWIFS_CHLOR_A_GMEAN_Y_1998_M_6_MEDIAN_FILL_x.gif',$
'f:\seawifs\nec\chl\SD_SEAWIFS_CHLOR_A_GMEAN_Y_1998_M_7_MEDIAN_FILL_x.gif',$
'f:\seawifs\nec\chl\SD_SEAWIFS_CHLOR_A_GMEAN_Y_1998_M_8_MEDIAN_FILL_x.gif',$
'f:\seawifs\nec\chl\SD_SEAWIFS_CHLOR_A_GMEAN_Y_1998_M_9_MEDIAN_FILL_x.gif', $
'f:\seawifs\nec\chl\SD_SEAWIFS_CHLOR_A_GMEAN_Y_1998_M_10_MEDIAN_FILL_x.gif',$
'f:\seawifs\nec\chl\SD_SEAWIFS_CHLOR_A_GMEAN_Y_1998_M_11_MEDIAN_FILL_x.gif',$
'f:\seawifs\nec\chl\SD_SEAWIFS_CHLOR_A_GMEAN_Y_1998_M_12_MEDIAN_FILL_x.gif', $
'f:\seawifs\nec\chl\SD_SEAWIFS_CHLOR_A_GMEAN_Y_1999_M_1_MEDIAN_FILL_x.gif',$
'f:\seawifs\nec\chl\SD_SEAWIFS_CHLOR_A_GMEAN_Y_1999_M_2_MEDIAN_FILL_x.gif',$
'f:\seawifs\nec\chl\SD_SEAWIFS_CHLOR_A_GMEAN_Y_1999_M_3_MEDIAN_FILL_x.gif',$
'f:\seawifs\nec\chl\SD_SEAWIFS_CHLOR_A_GMEAN_Y_1999_M_4_MEDIAN_FILL_x.gif',$
'f:\seawifs\nec\chl\SD_SEAWIFS_CHLOR_A_GMEAN_Y_1999_M_5_MEDIAN_FILL_x.gif',$
'f:\seawifs\nec\chl\SD_SEAWIFS_CHLOR_A_GMEAN_Y_1999_M_6_MEDIAN_FILL_x.gif',$
'f:\seawifs\nec\chl\SD_SEAWIFS_CHLOR_A_GMEAN_Y_1999_M_7_MEDIAN_FILL_x.gif',$
'f:\seawifs\nec\chl\SD_SEAWIFS_CHLOR_A_GMEAN_Y_1999_M_8_MEDIAN_FILL_x.gif',$
'f:\seawifs\nec\chl\SD_SEAWIFS_CHLOR_A_GMEAN_Y_1999_M_9_MEDIAN_FILL_x.gif']

;;MPEG_MAKE,FILES=FILES,PAL='PAL_SW3',SCALE=0.5

  FILES=FILES(0:2)
  TEST,FILES=FILES,PAL='PAL_SW3',SCALE=0.25



 END; OF PROGRAM