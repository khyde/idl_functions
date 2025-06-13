;  PRO SELF_SHADE_ZIBORDI_DEMO,    June 21,1999
;+
; NAME:
;       SELF_SHADE_ZIBORDI_DEMO
;
; PURPOSE:
;       Demonstrates SELF_SHADE_ZIBORDI Function for estimating
;       the effects of sensor shelf-shading
;       on underwater radiance and irradiance measurements
;
;       See SELF_SHADE_ZIBORDI.PRO  for complete documentation
;
; CATEGORY:
;       Light
;
; CALLING SEQUENCE:
;
;       SELF_SHADE_ZIBORDI_DEMO
;
; INPUTS:
;       NONE REQUIRED
;
;
; KEYWORD PARAMETERS:
;
;       NONE REQUIRED
;
; OUTPUTS:
;
;      Plots of Radiometer Self-Shading Error (%) versus aR similar to Fig. 1 in:
;      Zibordi, G. and G.M. Ferrari, 1995, Instrument self-shading in underwater optical measurements:
;           experimental data, Applied Optics 34(15):2750-2754.
;           Note that plots are not identical because G. Zibordi assumes a point sensor.
;
 ;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;
;
; PROCEDURE:
;
;
;
; MODIFICATION HISTORY:
;      June 7,1999 J.O'Reilly
;      June 21,1999 Modified (error with instrument diameters).
;
;-

  PRO  SELF_SHADE_ZIBORDI_DEMO

; *******************************************************
;  Table 1 from Zibordi, G. and G.M. Ferrari, 1995
   date = ['06-05-94','27-05-94','15-06-94','22-06-94']
   sol_z= [      51.1,      29.4,      46.7,      40.9] ; deg

   ap550= [     0.109,     0.163,     0.177,     0.096] ; (m-1)
   ay550= [     0.097,     0.086,     0.120,     0.092] ; (m-1)

   ap600= [     0.067,     0.140,     0.150,     0.106] ; (m-1)
   ay600= [     0.017,     0.040,     0.040,     0.040] ; (m-1)

   ap640= [     0.091,     0.160,     0.180,     0.112] ; (m-1)
   ay640= [     0.006,     0.012,     0.023,     0.011] ; (m-1)
; *******************************************************

;  ==============>
;   Smith & Baker 1981 absorption coefficiens for pure water
;             550,       600,       640
;  Aw =  [0.06380,    0.2440,    0.3290]

   PRINT, 'Aw (550,600,640nm): 0.06380,    0.2440,    0.3290 '

;  Add Absorption of water, particulate, and yellow substance for each lambda
   abs_550 = 0.0638 + ap550 + ay550
   abs_600 = 0.2440 + ap600 + ay600
   abs_640 = 0.3290 + ap640 + ay640
   PRINT, 'Total Water Absorption (550,600,640nm): '
   PRINT,abs_550,abs_600,abs_640 & print


; **************************************************************
;  Ratio of Diffuse to Direct Sunlight
;  Following table from Zibordi EMAIL to J.O'Reilly June 7,1999
;  Mean, max and min values of RATIO_DIFFUSE_DIRECT
;  under clear sun conditions as measured at the Venice tower site.
;   	lambda	mean	 	  max	 	 min
;       412     0.952       2.421      0.245
;       443     0.789       2.107      0.200
;       490     0.582       1.670      0.141
;       510     0.509       1.498      0.121
;       555     0.376       1.141      0.079
;       665     0.241       0.925      0.040
;       685     0.244       0.938      0.040

;  Since we do not have the individual ratios for diffuse/direct matching underwater
;  light measurements diffuse_direct ratio is estimated from the table above
;  Estimate RATIO_DIFFUSE_DIRECT for 600 and 640 nm
   RATIO_DIFFUSE_DIRECT = INTERPOL([0.376,0.241], [555,665], [555,600,640])
   PRINT, 'RATIO_DIFFUSE_DIRECT: (555,600,640nm) ',RATIO_DIFFUSE_DIRECT

   DIAM_INST=[0.025,0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40] ; meters
;  Personal Comm from G. Zibordi (June 21,1999) max RADIUS of inst was 0.2m

   DIAM_OPTICS= 0.01 ; meters


   !Y.OMARGIN=[0,7]
   !P.MULTI=[0,2,2]
   !P.BACKGROUND=255
   !P.COLOR = 0
   colors = [60,105,210]
   LOADCT,38

   FOR _date = 0,N_ELEMENTS(date)-1 DO BEGIN
     adate = date(_date)
     solar_zenith = sol_z(_date)
     TITLE = ADATE + ',  Sun Zenith= ' + STRTRIM(STRING(solar_zenith,FORMAT='(F4.1)'),2)
     PLOT,[0.001,0.10],[0,40],/NODATA,$
       XRANGE=[0.003,0.12],/XLOG,YRANGE=[0,40],/YSTYLE ,/XSTYLE,$
       TITLE=title, XTITLE='aR',YTITLE='Error (%)'

     FOR _WL = 0,2 DO BEGIN
       IF _WL EQ 0 THEN TABS = abs_550(_date)
       IF _WL EQ 1 THEN TABS = abs_600(_date)
       IF _WL EQ 2 THEN TABS = abs_640(_date)
       _RATIO_DIFFUSE_DIRECT = RATIO_DIFFUSE_DIRECT(_wl)

       FOR nth_diam = 0, N_ELEMENTS(diam_inst) -1 DO BEGIN
         _diam_inst = diam_inst(nth_diam)
         ar =  TABS*(_diam_inst/2.0)
         factor = self_shade_zibordi(solar_zenith, TABS, _RATIO_DIFFUSE_DIRECT,  _diam_inst, diam_optics ,/RAD)
         error = 1.0 - (1.0/factor)

         PLOTS, ar,  100*error, PSYM =  (_WL + 4) ,COLOR= colors(_wl),symsize=1,thick=2
       ENDFOR
     ENDFOR
   ENDFOR
  XYOUTS,/NORMAL,0.5,0.95,'Zibordi and Ferrari, 1995, Fig.1',charsize=2,align=0.5
  !Y.OMARGIN=0
  END ; End of Program
; ***************************************************

