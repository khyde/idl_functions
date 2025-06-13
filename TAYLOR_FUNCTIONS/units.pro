; $Id:	units.pro,	February 10 2011	$

	FUNCTION UNITS, Name,  NO_PAREN=NO_PAREN,NO_UNIT=NO_UNIT,NO_NAME=NO_NAME,STACK=stack
;+
; NAME:
;		UNITS
;
; PURPOSE:;
;		This Function Generates a Name and Units for various Scientific Data Types
;
; CATEGORY:
;		MISC
;
; CALLING SEQUENCE:
;
;		Result = UNITS(Name)
;
; INPUTS:
;		Name:	The Name (Recognized by this Routine) of the Data Type
;
; KEYWORD PARAMETERS:
;		NO_PAREN:	Do not enclose the Units part of the returned text string in parentheses
;		NO_UNIT:  Do not return the Units
;		NO_NAME:	Do not return the Name
;		STACK:		Return a string with a '!C' separating the Name from the Units so that IDL will plot it on 2 lines (Using XYOUTS)
;
;
; OUTPUTS:
;		A String with the Standardized Name and Units
;
; RESTRICTIONS:
;		Only Names recognized by this program.  Add more if needed.
;
; EXAMPLE:
;		 Result = UNITS('CEL') ; Celsius label
;
; MODIFICATION HISTORY:
;			Written Jan 3,1995 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
; Aug 7, 2001  TD, Added more czcs products
; Apr 23,2002  TD, Added seawifs flags
; Nov 7, 2002  par > Ein ; added EINS (Einsteins per sec).
; Jan 15, 2003 td, add
;     KEYWORD STACK ADDED
;	April 13,2002 jor ok = WHERE(STRPOS(LABELS,'()') GE 0,COUNT) & IF COUNT GE 1 THEN LABELS(OK) = ''
;	July 14, 2003 td change label for PNEG from '%' to 'probability'
;	Aug 10, 2004 changed all !E TO !U
;	July 10, 2006 jor DOC, DOC_MANNINO
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'UNITS'

  IF KEYWORD_SET(NO_PAREN) THEN DELIM=['',''] ELSE delim = ['(',')']
  IF KEYWORD_SET(STACK) THEN _STACK = '!C' ELSE _STACK = ''

; Array for output units
  LABELS = REPLICATE('',N_ELEMENTS(Name))

; ===> The first correct case will be the choice
  FOR Nth=0L,N_ELEMENTS(LABELS)-1L DO BEGIN
    datum = STRUPCASE(Name(nth))
    IF STRPOS(datum,'SLOPE') GE 0 THEN datum='SLOPE'
  CASE 1 OF

;		*** Time  ***
		datum EQ 'H' OR DATUM EQ 'HOUR' OR DATUM EQ 'HOURS' 							: txt = 'Hours'
		datum EQ 'MIN' OR DATUM EQ 'MINUTE' OR DATUM EQ 'MINUTES' 				: txt = 'Minutes'


;		*** Solar ***
		datum EQ 'AU' 																										: txt ='AU'

;   *** Mean Extraterrestrial Solar Irradiance ***
    datum EQ 'E0'  																										: txt ='uW cm!u-2!N nm!U-1!N'
    datum EQ 'ES'  																										: txt ='uW cm!u-2!N nm!U-1!N'

;   *** PAR ***
    datum EQ 'PARS' OR (datum) EQ 'MW CM^-2 UM^-1'										: txt ='!7u!NW cm!U-2!N nm!U-1!N'
    datum EQ 'PAR' 	OR datum EQ 'EIN' OR datum EQ 'EMD' 							: txt ='E m!U-2!Nd!U-1!N'
    datum EQ 'EMS'  																									: txt ='uEi m!U-2!Ns!U-1!N'
    datum EQ 'EINST_HR'  																							: txt ='Ei m!U-2!Nh!U-1!N'

;   *** Watts, Langley ***
    datum EQ 'WATTSM2' OR datum EQ 'WM2'  														: txt ='Watts m!U-2!N'

    datum EQ 'LANGLEY_DAY'  																					: txt ='Cal cm!U-2!Nd!U-1!N''

    datum EQ 'ELEVATION' OR datum EQ 'EL'  OR STRUPCASE(datum) EQ 'ELEV': txt ='!uo!N'
    datum EQ 'CELSIUS' 	 OR datum EQ 'CEL' OR STRUPCASE(datum) EQ 'C' 	: txt ='!uo!NC'
    datum EQ 'SALINITY'  OR datum EQ 'SAL'   													: txt ='psu'
    datum EQ 'SIGMA_T' 		   																					: txt ='kg m!U-3!N'

    datum EQ 'SST' OR datum EQ 'TEMPERATURE' or datum EQ 'TEMP'       : txt ='!Uo!NC'
    datum EQ 'DEG' OR datum EQ 'DEGREE' OR datum eq 'SENZ'						: txt= '!uo' + '!N'
    datum EQ 'SOLEL'  																								: txt= '!uo' + '!N'
    datum EQ 'LAT'																										: txt= '!uo' + '!NN'
    datum EQ 'LON'																										: txt= '!uo' + '!NW'

 		datum EQ 'GRAD_MAG'																								: txt= ' '
 		datum EQ 'GRAD_MAG_RATIO'																					: txt= ' '
 		datum EQ 'GRAD_DIR'																								: txt= ' '

    datum EQ 'PROB' OR datum EQ 'EPSILON' OR datum EQ 'ANCIL' OR datum EQ 'SUNGLINT' OR datum EQ 'SATZEN' $
                    OR datum EQ 'CLDICE'  OR datum EQ 'COCCOLITH' OR datum EQ 'SOLZEN' OR datum EQ 'HIGHTAU' $
                    OR datum EQ 'LOWLW'   OR datum EQ 'NEGLW'			OR datum EQ 'BOTTOM' : txt ='Probability'

    datum EQ 'FREQ_Y' OR datum EQ 'FREQUENCY_Y' or datum EQ 'FPY'  		: txt ='Yr!U-1!N'
    datum EQ 'FREQ'  																									: txt ='Freq!U-1!N'

		datum EQ 'PERIOD_Y' OR datum EQ 'PER_Y' 													: txt ='Yr'
		datum EQ 'PERIOD_M' OR datum EQ 'PER_M' 													: txt ='Month'

;		*** Statistics ***
		datum EQ 'PERCENT'                                       	       	: txt ='%'
		datum EQ 'PCT_LIGHT'                                            	: txt ='%'
		datum EQ 'CV'                                                  		: txt ='%'
		datum EQ 'STD'                                                  	: txt =' '
		datum EQ 'NUM'                                                  	: txt =' '
		datum EQ 'CNUM'                                                  	: txt =' '
		datum EQ 'LOG10' 																									: txt ='Log!D10!N'


;   *** Chlorophyll and Pigment ***
    datum EQ 'CHLL' 																									: txt ='!18u!Ng l!U-1!N'

    datum EQ 'IN_SITU' 																								: txt ='!8in situ!X!N'

    datum EQ 'CHLOR_A' OR datum EQ 'CHL' OR datum EQ 'CHLOROPHYLL' OR datum EQ 'CHLM3' OR datum EQ 'MG M^-3' OR datum EQ 'CSAT' : txt ='mg m!U-3!N'
    datum EQ 'CZCS_PIGMENT' OR datum EQ 'PIGMENT' OR (datum) EQ 'PIG' : txt ='mg m!U-3!X!N'
    datum EQ 'CHLA' OR datum EQ 'CHLB' OR datum EQ 'CHLC' OR datum EQ 'CARO' OR datum EQ 'ALLO' OR datum EQ 'FUCO' OR $
      datum EQ 'PERID' OR datum EQ 'DIA' OR datum EQ 'ZEA' OR datum EQ 'LUT' OR datum EQ 'NEO' OR datum EQ 'VIOLA' : txt ='mg m!U-3!N' 

    datum EQ 'CHLOR_EUPHOTIC' 																				: txt ='mg m!U-2!N'
    datum EQ 'ZEU' OR DATUM EQ 'EUPHOTIC_DEPTH'												: txt ='m!N'
    datum EQ 'Z' OR DATUM EQ 'DEPTH' OR DATUM EQ 'BATHY' OR DATUM EQ 'TOPO': txt ='m!N'

    datum EQ 'OC3C' 																									: txt ='mg m!U-3!N'
    datum EQ 'OC3M_4' 																								:	txt ='mg m!U-3!N'
    datum EQ 'OC3G' 																									: txt ='mg m!U-3!N'
    datum EQ 'OC4_4'																									: txt ='mg m!U-3!N'

;   *** Particulate Organic Carbon ***
 		datum EQ 'POC' 																										: txt ='mg m!U-3!N'

;   *** Phytoplankton (nitrogen) ***
    datum EQ 'PHYTO_N'                                                : txt = 'mmol m!U-3!N'

;		*** Dissolved Organic Carbon ***
		datum EQ 'DOC'                                                    : txt = 'mg m!U-3!N'
		datum EQ 'DOC_SEMILABILE'	                                        : txt = '!9m!7M C!N'
		datum EQ 'DOC_G' 																									: txt = 'g m!U-3!N'

;   *** Primary Production   ***
		datum EQ 'PP_HR' or datum EQ 'MGCM3H' 														: txt = 'mgC m!U-3!N h!U-1!N' ;
		datum EQ 'PP_MGCM3D' 																							: txt = 'mgC m!U-3!N d!U-1!N' ;
		datum EQ 'PP_MCM3D' 																							: txt = 'mols C m!U-3!N d!U-1!N' ;
		datum EQ 'P_B_HR' 																								: txt = 'mgC mgChla!U-1!N h!U-1' ;
    datum EQ 'PPD' or datum EQ 'GCM2D' or datum EQ 'PRIMARY_PRODUCTION'	: txt = 'gC m!U-2!N d!U-1!N' ;
    datum EQ 'PPM' or datum EQ 'GCM2M' 																: txt = 'gC m!U-2!N Month!U-1!N' ; 'Primary Production (gC m!U-2!N Month!U-1!N)
    datum EQ 'PPY' or datum EQ 'GCM2Y' 																: txt = 'gC m!U-2!N y!U-1!N' ;

;   *** ZOOPLANKTON   ***
    datum EQ 'LOG7'   : txt = 'Log' ;
    datum EQ '10M2'   : txt = '10m!U2!N'
    datum EQ '100M3'  : txt = '100m!U3!N'
    datum EQ 'CCM2'   : txt = '10m!U2!N'
    datum EQ 'CCM3'   : txt = '100m!U3!N'

;   *** Algorithms ***
    datum EQ 'OC2A' : txt ='Rrs!S!U412!R!D555!N'
    datum EQ 'OC2B' : txt ='Rrs!S!U443!R!D555!N'
    datum EQ 'OC2'  : txt ='Rrs!S!U490!R!D555!N'
    datum EQ 'OC2C' : txt ='Rrs!S!U490!R!D555!N'
    datum EQ 'OC2D' : txt ='Rrs!S!U510!R!D555!N'
    datum EQ 'OC4'  : txt ='Rrs!S!U443!R!D555!N>R!S!U490!R!D555!N>R!S!U510!R!D555!N'
    datum EQ 'OC3M' : txt ='Rrs!S!U443!R!D550!N>R!S!U490!R!D550!N'

;   *** Raleigh ***
    datum EQ 'RAYLEIGH_443' or  datum EQ 'RAY' : txt ='!7u!NW cm!U-2!N sr!U-1!N nm!U-1!N'

;   *** Aerosol ***
    datum EQ 'LA_670' OR datum EQ 'LA_' : txt ='!7u!NW cm!U-2!N sr!U-1!N nm!U-1!N'

;   *** Angstrom ***
    datum EQ 'ANGSTROM_510' OR (datum) EQ 'ANG' OR (datum) EQ  'ANGSTROM': txt ='' ; UNITLESS

;   *** Tau ***
    datum EQ 'TAUA_865' OR (datum) EQ 'TAUA_510' : txt ='' ; UNITLESS

;   *** PNEG  ***
    datum EQ 'PNEG' 													  : txt ='probability'

    datum EQ 'PNEG412' OR (datum) EQ 'PNEG_412' : txt ='probability'
    datum EQ 'PNEG443' OR (datum) EQ 'PNEG_443' : txt ='probability'
    datum EQ 'PNEG485' OR (datum) EQ 'PNEG_485' : txt ='probability'
    datum EQ 'PNEG490' OR (datum) EQ 'PNEG_490' : txt ='probability'
    datum EQ 'PNEG510' OR (datum) EQ 'PNEG_510' : txt ='probability'
    datum EQ 'PNEG520' OR (datum) EQ 'PNEG_520' : txt ='probability'
    datum EQ 'PNEG550' OR (datum) EQ 'PNEG_550' : txt ='probability'
    datum EQ 'PNEG555' OR (datum) EQ 'PNEG_555' : txt ='probability'
    datum EQ 'PNEG560' OR (datum) EQ 'PNEG_560' : txt ='probability'
    datum EQ 'PNEG565' OR (datum) EQ 'PNEG_565' : txt ='probability'
    datum EQ 'PNEG570' OR (datum) EQ 'PNEG_570' : txt ='probability'
    datum EQ 'PNEG650' OR (datum) EQ 'PNEG_650' : txt ='probability'
    datum EQ 'PNEG670' OR (datum) EQ 'PNEG_670' : txt ='probability'
    datum EQ 'PNEG765' OR (datum) EQ 'PNEG_765' : txt ='probability'
    datum EQ 'PNEG865' OR (datum) EQ 'PNEG_865' : txt ='probability'


;   *** Normalized Water-Leaving Radiance ***
    STRMID(datum,0,3) EQ 'LWN' OR STRMID(datum,0,3) EQ 'NLW' OR STRMID(datum,0,3) EQ 'LWN' OR STRUPCASE(datum) EQ 'MW CM^-2 UM^-1 SR^-1': txt ='!9m!7!NW cm!U-2!N sr!U-1!N nm!U-1!N'

;   *** Remote Sensing Reflectance ***
		STRMID(datum,0,3) EQ 'RRS': txt = 'sr!U-1!N'

    datum EQ 'K_PAR' 														: txt ='m!U-1!N'
    datum EQ 'K_490' 														: txt ='m!U-1!N'
    datum EQ 'MB'   														: txt = ''        ;
    datum EQ 'CLOUDRING' 												: txt = ''

    datum EQ 'EPS34' OR (datum) EQ 'E(550,670)'	:  txt ='!18e!X!N!D520,670!N'
    datum EQ 'ABS'   OR datum   EQ 'ABSORPTION'	:  txt = 'm!U-1!N'
    datum EQ 'CHLOR_A_K_490'										:  txt = 'm!U-1!N'

    datum EQ 'K_CDOM'   							 					:  txt = 'm!U-1!N'
    datum EQ 'A_CDOM'   							 	        :  txt = 'm!U-1!N'
    datum EQ 'A_CDOM_300'   							 	    :  txt = 'm!U-1!N'
    datum EQ 'A_CDOM_355'   							 	    :  txt = 'm!U-1!N'
    datum EQ 'A_CDOM_443'   							 	    :  txt = 'm!U-1!N'
    datum EQ 'CDOM_INDEX'   							 	    :  txt = ' ' ; UNITLESS

    datum EQ 'TURBIDITY'                        :  txt = ' '

    datum EQ 'AW'                              	:  txt = 'm!U-1!N'

		datum EQ 'PHI'                             	:  txt = ' '
    datum EQ 'PHIMAX'                          	:  txt = ' '
    datum EQ 'APHI'  OR datum EQ 'AP'          	:  txt = 'm!U-1!N'
    datum EQ 'APHI*'                           	:  txt = 'm!U2!N mg!U-1!N'

    datum EQ 'AP_PIG'                          	:  txt = 'm!U-1!N'

    datum EQ 'WL' OR DATUM EQ 'LAM'  OR datum EQ 'LAMBDA'       	:  txt = 'nm'
    datum EQ 'ABS'                             	:  txt = 'm!U-1!X!N '
    datum EQ 'MBR'                             	:  txt = ' '
    datum EQ 'MB'                              	:  txt = ' '
    datum EQ 'RATIO'                           	:  txt = ' '
		datum EQ 'JD_MIN'       OR datum EQ 'JD_MAX'           :  txt = ' '
		datum EQ 'M_JD_MIN'     OR datum EQ 'M_JD_MAX'         :  txt = ' '
		datum EQ 'MONTH_JD_MIN' OR datum EQ 'MONTH_JD_MAX'     :  txt = ' '
		datum EQ 'Y_JD_MIN'     OR datum EQ 'Y_JD_MAX'         :  txt = ' '

;		*** FLOWS ***
		datum EQ 'RIVER_FLOW_CMS'      			       	:  txt = 'm!U3!Ns!U-1!N'
		datum EQ 'RIVER_FLOW_CFS'      			       	:  txt = 'cfs'
		datum EQ 'RIVER_FLOW_CFS_1000'      			  :  txt = '1000 cfs'

    ELSE : txt=''
  ENDCASE

    LABELS(NTH) = ' '+delim(0)+txt+delim(1)

    IF NOT KEYWORD_SET(NO_NAME) THEN BEGIN

       ANAME=''
       CASE 1 OF
       ;		===> Time
			 datum EQ 'H' 	OR DATUM EQ 'HOUR' OR DATUM EQ 'HOURS' : ANAME = 'hour'
			 datum EQ 'MIN' OR DATUM EQ 'MINUTE' OR DATUM EQ 'MINUTES' : ANAME = 'minute'

       datum EQ 'AU' 											: ANAME ='Astronomical Unit'
       datum EQ 'ELEVATION' OR datum EQ 'EL' OR STRUPCASE(datum) EQ 'ELEV' : ANAME = 'Elevation'
       datum EQ 'CHLOR_A' OR datum EQ 'CHL' OR datum EQ 'CHLM3' OR datum EQ 'MG M^-3' :   ANAME = '!8Chl!X!N '

       datum EQ 'CHLOROPHYLL'  :          ANAME = 'Chlorophyll !8a!X!N '
       datum EQ 'CHLOR_EUPHOTIC' :   ANAME = '!8C!DEU!X!N '
       datum EQ 'ZEU' OR DATUM EQ 'EUPHOTIC_DEPTH' :   ANAME = '!8Z!DEU!X!N '
       datum EQ 'Z' OR DATUM EQ 'DEPTH' OR DATUM EQ 'BATHY'  :   ANAME = 'Depth!X!N '
       datum EQ 'TOPO':   ANAME = 'Height!X!N '

       datum EQ 'POC' 													: ANAME = 'POC'
       datum EQ 'POC_STRAMSKI' 									: ANAME = 'POC-Stramski'
       datum EQ 'POC' 									        : ANAME = 'POC-Clark'

       datum EQ 'PHYTO_N'                       : ANAME = 'Phytoplankton Nitrogen'
       
			 datum EQ 'DOC' 											    : ANAME = 'DOC'
			 datum EQ 'DOC_SEMILABILE' 								: ANAME = 'Semilabile DOC'
			 datum EQ 'DOC_G' 												: ANAME = 'DOC'

       datum EQ 'PP_HR' or datum EQ 'MGCM3H' or datum EQ 'PP_MGCM3D' OR datum EQ 'PP_MCM3D'  : 			ANAME = 'PP'
       datum EQ 'P_B_HR'  									    : ANAME = 'PB'


			 datum EQ 'PPD' or datum EQ 'GCM2D'       : ANAME = 'PP'
			 datum EQ 'PRIMARY_PRODUCTION'            : ANAME = 'Primary Production'
       datum EQ 'PPM' or datum EQ 'GCM2M'       : ANAME = 'PP'

       datum EQ 'PHYSAT'                        : ANAME = 'PHYSAT'
       datum EQ 'PHYSAT_NANOEUKARYOTES'         : ANAME = 'Nanoeukaryotes'
       datum EQ 'PHYSAT_PROCHLOROCOCCUS'        : ANAME = 'Prochlorococcus'
       datum EQ 'PHYSAT_SYNECHOCOCCUSS'         : ANAME = 'Synechococcuss'
       datum EQ 'PHYSAT_DIATOMS'                : ANAME = 'Diatoms'
			 datum EQ 'PHYSAT_PHAEOCYSTIS'            : ANAME = 'Phaeocystis'
			 datum EQ 'PHYSAT_COCCOLITHES'            : ANAME = 'Coccolithes'
			 datum EQ 'PHYSAT_UNCLASSIFIED'           : ANAME = 'PHYSAT_Unclassified'
			 
       datum EQ 'LOG7'                          : ANAME = ''
       datum EQ 'NLW_412' OR datum EQ 'LWN412'  : ANAME = '!8L!DWN!X!N(412)'
       datum EQ 'NLW_443' OR datum EQ 'LWN443'  : ANAME = '!8L!DWN!X!N(443)'
       datum EQ 'NLW_485' OR datum EQ 'LWN485'  : ANAME = '!8L!DWN!X!N(485)'
       datum EQ 'NLW_490' OR datum EQ 'LWN490'  : ANAME = '!8L!DWN!X!N(490)'
       datum EQ 'NLW_510' OR datum EQ 'LWN510'  : ANAME = '!8L!DWN!X!N(510)'
       datum EQ 'NLW_520' OR datum EQ 'LWN520'  : ANAME = '!8L!DWN!X!N(520)'
       datum EQ 'NLW_531' OR datum EQ 'LWN531'  : ANAME = '!8L!DWN!X!N(531)'
       datum EQ 'NLW_550' OR datum EQ 'LWN550'  : ANAME = '!8L!DWN!X!N(550)'
       datum EQ 'NLW_551' OR datum EQ 'LWN551'  : ANAME = '!8L!DWN!X!N(551)'
       datum EQ 'NLW_555' OR datum EQ 'LWN555'  : ANAME = '!8L!DWN!X!N(555)'
       datum EQ 'NLW_560' OR datum EQ 'LWN560'  : ANAME = '!8L!DWN!X!N(560)'
       datum EQ 'NLW_565' OR datum EQ 'LWN565'  : ANAME = '!8L!DWN!X!N(565)'
       datum EQ 'NLW_570' OR datum EQ 'LWN570'  : ANAME = '!8L!DWN!X!N(570)'
       datum EQ 'NLW_650' OR datum EQ 'LWN650'  : ANAME = '!8L!DWN!X!N(650)'
       datum EQ 'NLW_670' OR datum EQ 'LWN670'  : ANAME = '!8L!DWN!X!N(670)'
       datum EQ 'NLW_765' OR datum EQ 'LWN765'  : ANAME = '!8L!DWN!X!N(765)'
       datum EQ 'NLW_865' OR datum EQ 'LWN865'  : ANAME = '!8L!DWN!X!N(865)'

			 datum EQ 'RRS_412': ANAME = 'R!DRS!X!N(412)'
			 datum EQ 'RRS_443': ANAME = 'R!DRS!X!N(443)'
			 datum EQ 'RRS_469': ANAME = 'R!DRS!X!N(469)'
			 datum EQ 'RRS_488': ANAME = 'R!DRS!X!N(488)'
			 datum EQ 'RRS_490': ANAME = 'R!DRS!X!N(490)'
			 datum EQ 'RRS_510': ANAME = 'R!DRS!X!N(510)'
			 datum EQ 'RRS_530': ANAME = 'R!DRS!X!N(530)'
			 datum EQ 'RRS_551': ANAME = 'R!DRS!X!N(551)'
			 datum EQ 'RRS_645': ANAME = 'R!DRS!X!N(645)'
			 datum EQ 'RRS_667': ANAME = 'R!DRS!X!N(667)'
			 datum EQ 'RRS_670': ANAME = 'R!DRS!X!N(670)'
			 datum EQ 'RRS_678': ANAME = 'R!DRS!X!N(678)'
			 
			 datum EQ 'CHLA'  : ANAME ='Chlorophyll !8a!X!N '
			 datum EQ 'CHLB'  : ANAME ='Chlorophyll !8b!X!N '
			 datum EQ 'CHLC'  : ANAME ='Chlorophyll !8c!X!N '
			 datum EQ 'CARO'  : ANAME ='Carotene'
			 datum EQ 'ALLO'  : ANAME ='Alloxanthin'
			 datum EQ 'FUCO'  : ANAME ='Fucoxanthin'
       datum EQ 'PERID' : ANAME ='Peridinin'
       datum EQ 'DIA'   : ANAME ='Diadinoxanthin + Diztoxanthin'
       datum EQ 'ZEA'   : ANAME ='Zeaxanthin'
       datum EQ 'LUT'   : ANAME ='Lutein'
       datum EQ 'NEO'   : ANAME ='Neoxanthin'
       datum EQ 'VIOLA' : ANAME ='Violaxanthin' 
			 

       datum EQ 'K_PAR' 												: ANAME = 'K!DPAR!X!N'
       datum EQ 'K_490'   											: ANAME = 'K!D!X!N(490)'
       datum EQ 'CHLOR_A_K_490'  								: ANAME = '!8C!Da!X!N K!D!X!N(490)'
       datum EQ 'PAR'  													: ANAME =	'PAR'
			 datum EQ 'EINST_HR'  										: ANAME = 'PAR'

			 datum EQ 'LANGLEY_DAY'  											: ANAME = 'Langley'

;     Angstrom *******************************************************************************
      datum EQ 'ANGSTROM_510' OR (datum) EQ 'ANG' OR (datum) EQ  'ANGSTROM': ANAME =DATUM ; UNITLESS

;     Tau   ***********************************************************
      datum EQ 'TAUA_865' OR (datum) EQ 'TAUA_510' : ANAME =DATUM

      datum EQ 'PNEG'                           	: ANAME = '!8P!X!N!Dneg!X!N'
      datum EQ 'PNEG412' OR (datum) EQ 'PNEG_412' : ANAME = '!8P!X!N!Dneg!X!N(412)'
      datum EQ 'PNEG443' OR (datum) EQ 'PNEG_443' : ANAME = '!8P!X!N!Dneg!X!N(443)'
      datum EQ 'PNEG485' OR (datum) EQ 'PNEG_485' : ANAME = '!8P!X!N!Dneg!X!N(485)'
      datum EQ 'PNEG490' OR (datum) EQ 'PNEG_490' : ANAME = '!8P!X!N!Dneg!X!N(490)'
      datum EQ 'PNEG510' OR (datum) EQ 'PNEG_510' : ANAME = '!8P!X!N!Dneg!X!N(510)'
      datum EQ 'PNEG520' OR (datum) EQ 'PNEG_520' : ANAME = '!8P!X!N!Dneg!X!N(520)'
      datum EQ 'PNEG550' OR (datum) EQ 'PNEG_550' : ANAME = '!8P!X!N!Dneg!X!N(550)'
      datum EQ 'PNEG555' OR (datum) EQ 'PNEG_555' : ANAME = '!8P!X!N!Dneg!X!N(555)'
      datum EQ 'PNEG560' OR (datum) EQ 'PNEG_560' : ANAME = '!8P!X!N!Dneg!X!N(560)'
      datum EQ 'PNEG565' OR (datum) EQ 'PNEG_565' : ANAME = '!8P!X!N!Dneg!X!N(565)'
      datum EQ 'PNEG570' OR (datum) EQ 'PNEG_570' : ANAME = '!8P!X!N!Dneg!X!N(570)'
      datum EQ 'PNEG650' OR (datum) EQ 'PNEG_650' : ANAME = '!8P!X!N!Dneg!X!N(650)'
      datum EQ 'PNEG670' OR (datum) EQ 'PNEG_670' : ANAME = '!8P!X!N!Dneg!X!N(670)'
      datum EQ 'PNEG765' OR (datum) EQ 'PNEG_765' : ANAME = '!8P!X!N!Dneg!X!N(765)'
      datum EQ 'PNEG865' OR (datum) EQ 'PNEG_865' : ANAME = '!8P!X!N!Dneg!X!N(865)'

      datum EQ 'SST'  									          : ANAME = 'SST'
      datum EQ 'SST' OR datum EQ 'TEMPERATURE' or datum EQ 'TEMP': ANAME = 'Temperature'
      datum EQ 'SALINITY' OR datum EQ 'SAL'       : ANAME = 'Salinity'
      datum EQ 'SIGMA_T' 		   										: ANAME = 'Sigma-!8t!X!N'

      datum EQ 'DEG' OR datum EQ 'DEGREE' OR datum EQ 'SENZ'   : ANAME = 'Degrees'
      datum EQ 'SOLEL'           									: ANAME = 'Degrees'
      datum EQ 'LAT'                              : ANAME = 'Lat'
      datum EQ 'LON'                             	: ANAME = 'Lon'
 			datum EQ 'GRAD_MAG'                         : ANAME = 'Gradient Magnitude'
 			datum EQ 'GRAD_MAG_RATIO'                   : ANAME = 'Gradient Magnitude (Ratio)'
 			datum EQ 'GRAD_DIR'													: ANAME = 'Azimuth (Degrees)'

      datum EQ 'PROB' OR datum EQ 'EPSILON' OR datum EQ 'ANCIL' OR datum EQ 'SUNGLINT' OR datum EQ 'SATZEN' $
       								 OR datum EQ 'CLDICE' OR datum EQ 'COCCOLITH' OR datum EQ 'SOLZEN' OR datum EQ 'HIGHTAU' $
       								 OR datum EQ 'LOWLW' OR datum EQ 'NEGLW' :ANAME= datum+' '+ANAME

       datum EQ 'PHI'                              :  ANAME = '!Mf!X!N '
       datum EQ 'PHIMAX'                           :  ANAME = '!Mf!X!N!DMAX!X!N '

       datum EQ 'APHI'                             :  ANAME = 'a!D!Mf!X!N '
       datum EQ 'AP_PIG'                           :  ANAME = 'a!Dph!X!N Pigment '
       datum EQ 'ABS'                              :  ANAME = 'Absorption '
       datum EQ 'AW'                               :  ANAME = 'a!DW!X!N '
       datum EQ 'AP'                               :  ANAME = 'a!DP!X!N '
       datum EQ 'APHI'                             :  ANAME = 'a!D!Mf!X!N '
       datum EQ 'APHI*'                            :  ANAME = 'a!S!D!Mf!R*!X!N '

			 datum EQ 'K_CDOM'                   				 :  ANAME = 'k!DCDOM(PAR)!X!N '
		;	 datum EQ 'A_CDOM'                   				 :  ANAME = 'a!DCDOM!X!N '
			 datum EQ 'A_CDOM'                   				 :  ANAME = 'A_CDOM '
			 datum EQ 'A_CDOM_300'                   		 :  ANAME = 'A_CDOM_300 '
			 datum EQ 'A_CDOM_355'                   		 :  ANAME = 'A_CDOM_355 '
			 datum EQ 'A_CDOM_443'                   		 :  ANAME = 'A_CDOM_443 '
			 datum EQ 'CDOM_INDEX'                   		 :  ANAME = 'Cdom Index'

			 datum EQ 'TURBIDITY'                        :  ANAME = 'Turbidity Index'

       datum EQ 'WL' OR DATUM EQ 'LAM'  OR datum EQ 'LAMBDA'        :  ANAME = '!Ml!X '
       datum EQ 'ABS'                              :  ANAME =  'a!Dw!X!N'
       datum EQ 'FREQ' OR datum EQ 'FREQ_Y' OR datum EQ 'FREQUENCY_Y' OR datum EQ 'FPY' :  ANAME = 'Frequency '
			 datum EQ 'PERIOD_Y' OR datum EQ 'PER_Y' 		 : ANAME ='Period'
			 datum EQ 'PERIOD_M' OR datum EQ 'PER_M' 		 : ANAME ='Period'

;			 Statistics *************************
       datum EQ 'PERCENT'  												                   :  ANAME = ''
       datum EQ 'PCT_LIGHT'  											                   :  ANAME = 'Percent Light'
       datum EQ 'CV'                                                 :  ANAME = 'C.V.'
       datum EQ 'STD'                                                :  ANAME = 'Std'
       datum EQ 'NUM'                                                :  ANAME = 'Number'
       datum EQ 'CNUM'                                               :  ANAME = 'Cumulative Number'
       datum EQ '10M2'   :  ANAME = ''
       datum EQ '100M3'   : ANAME = ''

      datum EQ 'WATTSM2' OR datum EQ 'WM2'  :    ANAME = 'Solar Radiation'
    	datum EQ 'MBR'                        :     ANAME = 'MBR'
    	datum EQ 'MB'                         :     ANAME = 'MB'
    	datum EQ 'RATIO'                      :     ANAME = 'Ratio'
    	datum EQ 'SLOPE'                      :     ANAME = 'Slope'
     	datum EQ 'SLOPE_D'                    :     ANAME = 'Slope'
     	datum EQ 'SLOPE_M'                    :     ANAME = 'Slope'


			datum EQ 'JD_MIN'       OR datum EQ 'JD_MAX'           :  ANAME = 'JD'
			datum EQ 'M_JD_MIN'     OR datum EQ 'M_JD_MAX'         :  ANAME = 'M'
			datum EQ 'MONTH_JD_MIN' OR datum EQ 'MONTH_JD_MAX'     :  ANAME = 'MONTH'
			datum EQ 'Y_JD_MIN'     OR datum EQ 'Y_JD_MAX'         :  ANAME = 'Y'

			datum EQ 'RIVER_FLOW_CFS'               :  ANAME = 'River Flow'
			datum EQ 'RIVER_FLOW_CMS'               :  ANAME = 'River Flow'
			datum EQ 'RIVER_FLOW_CFS_1000'					:  ANAME = 'River Flow'

    ELSE : ANAME = ANAME
     ENDCASE
   ENDIF

   IF NOT KEYWORD_SET(NO_NAME) AND NOT KEYWORD_SET(NO_UNIT) THEN LABELS(NTH)= ANAME + _STACK + LABELS(NTH)
   IF NOT KEYWORD_SET(NO_NAME) AND  KEYWORD_SET(NO_UNIT) THEN LABELS(NTH)= ANAME
;	 ===> EDIT OUT INSTANCES OF  '( )'  E.G. NUM, STD
   LABELS(NTH) = REPLACE(LABELS(NTH),'( )','')
  ENDFOR



  ok = WHERE(STRPOS(LABELS,'()') GE 0,COUNT) & IF COUNT GE 1 THEN LABELS(OK) = ''


    IF N_ELEMENTS(LABELS) EQ 1 THEN LABELS=LABELS(0)

  RETURN,LABELS

END; #####################  End of Routine ################################

