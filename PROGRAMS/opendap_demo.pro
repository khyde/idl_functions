; $ID:	OPENDAP_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$

	PRO OPENDAP_DEMO, ERROR = error

;+
; NAME:
;		OPENDAP_DEMO
;
; PURPOSE:
;
;		This procedure is a demo for testing the OPENDAP
;
; CATEGORY:
;		CATEGORY
;
; CALLING SEQUENCE:
;
;		OPENDAP_DEMO
;
;
; OUTPUTS:
;		This function returns the
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;

;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)

;		Citations or any other useful notes
;
;
; MODIFICATION HISTORY:
;			Written June 8, 2007 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'OPENDAP_DEMO'


	DO_FNOC1 = 0
	DO_TEST  = 0
	DO_SIGNORINI_EXAMPLE = 0
	DO_NENA = 1
	DO_URI_BUOYS =0

	IF DO_FNOC1 GE 1 THEN BEGIN
		url = 'http://test.opendap.org/opendap/nph-dods/data/nc/fnoc1.nc'
		stat = OPENDAP_GET(url, data)
		st,data
	ENDIF


	IF DO_TEST GE 1 THEN BEGIN
		url = 'http://test.opendap.org/opendap/nph-dods/data/nc/fnoc1.nc'
		stat = OPENDAP_GET(url, data)
		st,data
	ENDIF


 	IF DO_SIGNORINI_EXAMPLE GE 1 THEN BEGIN
;#!/bin/csh
;# Desired (i,j) for chosen lat, lon, obtained with get_roms_lat_lon.pro
;#         Lon             Lat        xi_rho  eta_rho
;#       -76.00           35.00      145,243 87,112
;#       -70.00           42.00
;#      April 18 to May 1, 1994; 107,120
;set	url="http://tashtego.marine.rutgers.edu:8080/thredds/dodsC/nena/hycom_801/averages"
;set	t1="0"
;set	t2="116"
;set	eta1="0"
;set	eta2="129"
;set	x1="0"
;set	x2="385"
;
;# Get Temperature
;ncks -v temp -d ocean_time,$t1,$t2 -d eta_rho,$eta1,$eta2 -d xi_rho,$x1,$x2 $url -O temp.nc
;# Get chlorophyll
;ncks -v chlorophyll -d ocean_time,$t1,$t2 -d eta_rho,$eta1,$eta2 -d xi_rho,$x1,$x2 $url -O chl.nc
;# Get Salinity
;ncks -v salt -d ocean_time,$t1,$t2 -d eta_rho,$eta1,$eta2 -d xi_rho,$x1,$x2 $url -O salt.nc
;# Get parameters to calculate geophysical depth (z)
;ncks -v zeta -d ocean_time,$t1,$t2 -d eta_rho,$eta1,$eta2 -d xi_rho,$x1,$x2 $url -O zeta.nc
;ncks -v Cs_r $url -O Cs_r.nc
;ncks -v hc $url -O hc.nc
;ncks -v h -d eta_rho,$eta1,$eta2 -d xi_rho,$x1,$x2 $url -O h.nc
;ncks -v lat_rho -d eta_rho,$eta1,$eta2 -d xi_rho,$x1,$x2 $url -O lat.nc
;ncks -v lon_rho -d eta_rho,$eta1,$eta2 -d xi_rho,$x1,$x2 $url -O lon.nc
;ncks -v h -d eta_rho,$eta1,$eta2 -d xi_rho,$x1,$x2 $url -O h.nc
;ncks -v mask_rho -d eta_rho,$eta1,$eta2 -d xi_rho,$x1,$x2 $url -O mask.nc
;ncks -v s_rho $url -O s_rho.nc
ENDIF


	IF DO_NENA GE 1 THEN BEGIN
	; http://tashtego.marine.rutgers.edu:8080/thredds/dodsC/nena/hycom_823/averages
 ; "../in/roms_nena_rivers_8_bio_sybil_dom.nc"


; *** data netcdf are at:  /home/om/dods-data/thredds/roms/nena

url = 'http://tashtego.marine.rutgers.edu:8080/thredds/catalogServices?catalog=http://tashtego.marine.rutgers.edu:8080/thredds/dodsC/nena/hycom_823/catalog.xml'
URL = 'http://tashtego.marine.rutgers.edu:8080/thredds/dodsC/nena/hycom_823/averages/chlorophyll'

; 9-30-2008
URL = 'http://tashtego.marine.rutgers.edu:8080/thredds/dodsC/projects/usecos/nena_0_rerun/avg'

; 11-25-08
URL = 'http://tashtego.marine.rutgers.edu:8080/thredds/dodsC/roms/usecos/nena-0-fasham/avg'

;    url = 'http://tashtego.marine.rutgers.edu:8080/thredds/dodsC/nena/hycom_823/averages/';?rivers' ;in/roms_nena_rivers_8_bio_sybil_dom.nc/.das'
;    url='http://tashtego.marine.rutgers.edu:8080/thredds/dodsC/nena/hycom_823/averages/in/roms_nena_rivers_8_bio_sybil_dom.nc"'
  ;  url=url+'frc_file_01.nc';: ../in/roms_nena_rivers_8_bio_sybil_dom.nc'
;;This is the URL to obtain the model output for Jean-Noel's run 823 (with DOM):
;; http://tashtego.marine.rutgers.edu:8080/thredds/dodsC/nena/hycom_823/averages.html
;;
;;
;;Variable of interest:  semilabileDOC
;;
;;It is located near the bottom of the list between alkalinity and oxygen.
;;
;;It appears that ~3 day averages are available for download.  It will take quite a bit of time
;;to download all 118 time steps.  I am able to download ascii files (see attached file -
;;>46MB) for a few time steps by replacing the 117 that appears in the ocean_time box
;; when you check the parameter of interest.  I could not find a description of the rho, eta
;;and xi, but I believe they represent pixel/line number and something else.

; 1-6-09
;URL = 'http://tashtego.marine.rutgers.edu:8080/thredds/dodsC/roms/usecos/nena-0-fasham/avg/avg_nena_0_0001.nc'
;url='http://tashtego.marine.rutgers.edu:8080/thredds/dodsC/projects/usecos/idltest/avg_nena_0_0080.nc'
    print,url
    PRODUCTS = ['GLOBAL,LAT_RHO,LON_RHO,TEMP,SWRAD,MASK_RHO,OCEAN_TIME']

timer
    stat = OPENDAP_GET(url, data,ce='temp[0:*][0]')
timer,/stop
		st,data.(0)
STOP

	ENDIF

	IF DO_URI_BUOYS GE 1 THEN BEGIN
	URL='http://dods.gso.uri.edu/cgi-bin/nph-nc/data/buoys.nc'
	URL='http://oceans.univ.edu/cgi-bin/nc/expl/buoys.nc?temp'
	stat = OPENDAP_GET(url, DATA)
		st,data
	ENDIF
STOP
	END; #####################  End of Routine ################################
