; $ID:	SATELLITE_MAP_DEMO.PRO,	2014-04-29	$
;#############################################################################################################
	PRO ORTHO_MAP_DEMO
	
;  PRO ORTHO_MAP_DEMO
;+
; NAME:
;		ORTHO_MAP_DEMO
;
; PURPOSE: THIS PROGRAM IS A DEMO FOR IDL'S PLOTS
;
; CATEGORY:
;		PLOT
;		 
;
; CALLING SEQUENCE: ORTHO_MAP_DEMO
;
; INPUTS: NONE
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: 
;		
;; EXAMPLES:
;
;  ORTHO_MAP_DEMO
;
; MODIFICATION HISTORY:
;			WRITTEN AUG 18,2013 J.O'REILLY
;			
;			
;			
;#################################################################################
;
;
;-
;***********************************
ROUTINE_NAME  = 'ORTHO_MAP_DEMO'
;***********************************
;
;
;SSSSS  SWITCHES SSSSS
DO_HELP_EXAMPLE         = 1
DO_NORTHEAST_US         = 0
;
;
;**********************************
IF DO_HELP_EXAMPLE GE 1 THEN BEGIN
;**********************************
PRINT,' EASTERN SEABOARD OF THE UNITED STATES FROM AN ALTITUDE OF ABOUT 160KM, ABOVE NEWBURGH, NY, WAS PRODUCED WITH THE PREVIOUS CODE.' 

ZWIN,[512,512]
ORTHOGRAPHIC
Set this keyword to select the orthographic projection. Note that this projection will display a maximum of ± 90° from the center of the projection area.

The following statements are used to produce an orthographic projection centered over Eastern Spain at a scale of 70 million to 1:

MAP_SET, /ORTHOGRAPHIC, 40, 0, SCALE=70e6, /CONTINENTS, $

   /GRID, LONDEL=15, LATDEL=15, $

   TITLE = 'Oblique Orthographic'



IM = TVRD()
ZWIN
SLIDEW,IM

ENDIF;IF DO_HELP_EXAMPLE GE 1 THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||


;**********************************
IF DO_NORTHEAST_US GE 1 THEN BEGIN
;**********************************
ZWIN,[512,512]
MAP_SET, /SATELLITE, SAT_P=[1.0251, 55, 150], 41.5, -74., $
   /ISOTROPIC, /HORIZON, $
   ;        left,     top,        right,     bottom edges of the map extent.   
   ;     [Lat0, Lon0, Lat1, Lon1, Lat2, Lon2, Lat3, Lon3]
   LIMIT=[34,   -77,  46,   -68,  46,   -62,  34, -74], $
   ;LIMIT=[32.166667,-80.333333,49.000000,-60.500000], $
   
   /CONTINENTS, TITLE='SATELLITE / TILTED PERSPECTIVE'
; SET UP THE SATELLITE PROJECTION:
MAP_GRID, /LABEL, LATLAB=-75, LONLAB=39, LATDEL=1, LONDEL=1
; GET NORTH VECTOR:
P = CONVERT_COORD(-74.5, [40.2, 40.5], /TO_NORM)
; DRAW NORTH ARROW:
ARROW, P(0,0), P(1,0), P(0,1), P(1,1), /NORMAL
XYOUTS, -74.5, 40.1, 'NORTH', ALIGNMENT=0.5
IM = TVRD()
ZWIN
SLIDEW,IM

ENDIF;IF DO_NORTHEAST_US GE 1 THEN BEGIN
;||||||||||||||||||||||||||||||||||||||


END; #####################  END OF ROUTINE ################################
