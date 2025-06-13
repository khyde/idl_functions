; $ID:	CHLOR_A_XIAOJU.PRO,	2020-07-08-15,	USER-KJWH	$
PRO CHLOR_A_XIAOJU

;+
; NAME:
;   CHLOR_A_XIAOJU
;
; PURPOSE:;
;   This procedure uses Xiaoju Pan's model to produce regional chlorophyll a using SeaWiFS and MODIS. 
;
; CATEGORY:
;   CATEGORY
;
; CALLING SEQUENCE:
;
;   Result = FUNCTION_NAME(Parameter1, Parameter2, Foobar)
;
; INPUTS:
;   Parm1:  Describe the positional input parameters here. Note again that positional parameters are shown with Initial Caps.
;
; OPTIONAL INPUTS:
;   Parm2:  Describe optional inputs here. If you don't have any, just delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1: Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
;
; OUTPUTS:
;   This function returns the
;
; OPTIONAL OUTPUTS:  ;
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
; EXAMPLE:
;
; NOTES:
;  Algorithm provided by Xiaoju Pan (a former post-doc for Antonio Mannino)
;
; MODIFICATION HISTORY:
;     Written Mar 22, 2010 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov) 
;     
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'TEMPLATE'

; ===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;      The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
  ERROR = ''


;latlon=[35.0,45.0,-77.0,-65.0]		; interested region [sLat,nLat,wLong,eLong]

;x_size=round((latlon(3)-latlon(2))*90)	; 1 degree = 90 pixel
;y_size=round((latlon[1]-latlon[0])*111)	; 1 degree = 111 pixel

;pigment distribution for 8 day mean
;days_periods=[[2005133, 2005140],[2005213, 2005220],[2005302, 2005309],[2006041, 2006048],[2006133,2006140],[2006213,2006220],[2006302,2006309]]

;selected_year=2005.
;days_periods=fltarr(2,46)
;For m=0,45 DO BEGIN
;	begin_day=selected_year*1000+(8*m+1)
;	final_day=selected_year*1000+(8*m+8)
;	days_periods(*,m)=[begin_day, final_day]
;ENDFOR

;=====algorithms========
;based on 3rd-order polynomial function
;log[pigment]=A+B*X+C*X^2+D*X^3
;X=log[Rrs(lambda1)/Rrs(lambda2)]
;=======================================================================

;latitude=READ_HDF_PROD('/home/xpan/NEcoast_longitude_latitude.hdf', 'Latitude')
;latitude=reverse(latitude,2)
;longitude=READ_HDF_PROD('/home/xpan/NEcoast_longitude_latitude.hdf', 'Longitude')

;all_fnames=FILE_SEARCH('/dataTB/xpan/modis_aqua/modis_l2mapped/*_map.hdf')
;FILEBREAK,all_fnames,dir=path_name,file=file_name
;satellite_type=STRMID(file_name,0,1)	;define SeaWiFS or MODIS files
;iyear=STRMID(file_name,1,4)	; define Year
;jdate=STRMID(file_name,5,3)	; define Julian date
;yeardate=STRMID(file_name,1,7) ; define YYYYDDD
;gmt=STRMID(file_name,8,4)	; define GMT
;name1=STRMID(file_name,0,14)

;all_fnames_sst4=FILE_SEARCH('/dataTB/xpan/modis_aqua/modis_aqua_sst4_mapped/A*sst4_map.hdf')
;FILEBREAK,all_fnames_sst4,dir=path_name_sst4,file=file_name_sst4
;yeardate_sst4=STRMID(file_name_sst4,1,7) ; define YYYYDDD

For i=0, n_elements(days_periods(0,*))-1 DO BEGIN
;For i=0, 0 DO BEGIN
	day_start=days_periods(0,i)
	day_end=days_periods(1,i)
	day_interval=day_end-day_start
	good_yeardate=WHERE(yeardate ge day_start AND yeardate le day_end)
	selected_images=all_fnames(good_yeardate)
	selected_jdate=jdate(good_yeardate)

	good_yeardate_sst4=WHERE(yeardate_sst4 ge day_start AND yeardate_sst4 le day_end)
	selected_images_sst4=all_fnames_sst4(good_yeardate_sst4)

	chlor_a_8=fltarr(x_size,y_size)
	chla_8=fltarr(x_size,y_size)
	chlb_8=fltarr(x_size,y_size)
	chlc_8=fltarr(x_size,y_size)
	caro_8=fltarr(x_size,y_size)
	allo_8=fltarr(x_size,y_size)
	fuco_8=fltarr(x_size,y_size)
	perid_8=fltarr(x_size,y_size)
	perid_ite_8=fltarr(x_size,y_size)
	neo_8=fltarr(x_size,y_size)
	viola_8=fltarr(x_size,y_size)
	dia_8=fltarr(x_size,y_size)
	zea_8=fltarr(x_size,y_size)
	lut_8=fltarr(x_size,y_size)
	count_chlor_a=fltarr(x_size,y_size)
	count_chla=fltarr(x_size,y_size)
	count_chlb=fltarr(x_size,y_size)
	count_chlc=fltarr(x_size,y_size)
	count_caro=fltarr(x_size,y_size)
	count_allo=fltarr(x_size,y_size)
	count_fuco=fltarr(x_size,y_size)
	count_perid=fltarr(x_size,y_size)
	count_perid_ite=fltarr(x_size,y_size)
	count_neo=fltarr(x_size,y_size)
	count_viola=fltarr(x_size,y_size)
	count_zea=fltarr(x_size,y_size)
	count_lut=fltarr(x_size,y_size)
	count_dia=fltarr(x_size,y_size)

	sst4_8=fltarr(x_size,y_size)
	count_array_sst=fltarr(x_size,y_size)

	
;===========calculate sst4 8 day mean==============================================================================
	For j=0, n_elements(selected_images_sst4)-1 DO BEGIN
		sst4_image=READ_HDF_PROD(selected_images_sst4(j),'sst4')
		good_stn_sst4=WHERE(sst4_image gt -4.5 AND sst4_image lt 40.0) ;assume -4.5<sst<40
		IF good_stn_sst4[0] ne -1 THEN BEGIN
			sst4_8(good_stn_sst4)=sst4_8(good_stn_sst4)+sst4_image(good_stn_sst4)
			count_array_sst(good_stn_sst4)=count_array_sst(good_stn_sst4)+1.0
		ENDIF
	ENDFOR
	sst4=sst4_8/count_array_sst
	bad_stn=where(count_array_sst lt 1.0)
	sst4(bad_stn)=-4.995
	sst4=reverse(sst4,2)
	
;assume sst4 in black pixels to those of mean for same latitutude.
;	For k=0, y_size-1 DO BEGIN
;		sst4_k_sum=0.0
;		count_k_sum=0.0
;		For m=0,x_size-1 DO BEGIN
;			IF sst4(m,k) gt -4.9 and sst4(m,k) lt 50.0 THEN BEGIN
;				sst4_k_sum=sst4_k_sum+sst4(m,k)
;				count_k_sum=count_k_sum+1.0
;			ENDIF
;		ENDFOR
;		IF count_k_sum gt 0.0 THEN mean_k=sst4_k_sum/count_k_sum ELSE mean_k=-4.995
;		For m=0,x_size-1 DO BEGIN
;			IF sst4(m,k) le -4.5 or sst4(m,k) ge 40.0 THEN sst4(m,k)=mean_k
;		ENDFOR
;	ENDFOR
;====================================================================================================================


;========Calculate mean values of Chl_a from OC4V4 or OC3M========================================================
	For p=0, n_elements(selected_images)-1 DO BEGIN
prinT,selected_images(p)
		chlor_a= READ_HDF_PROD(selected_images(p), 'chlor_a')	
		chlor_a=reverse(chlor_a,2)
		good_8_stn=where(chlor_a gt 0.0 and chlor_a lt 200.0)
		IF good_8_stn[0] ne -1 THEN BEGIN
			chlor_a_8(good_8_stn)=chlor_a_8(good_8_stn)+chlor_a(good_8_stn)
			count_chlor_a(good_8_stn)=count_chlor_a(good_8_stn)+1.0
		ENDIF
	ENDFOR
	chlor_a_mean=chlor_a_8/count_chlor_a
		bad_stn=where(count_chlor_a lt 1.0)
		IF bad_stn[0] ne -1.0 THEN chlor_a_mean(bad_stn)=-1.0
;==================================================================================================================


;===============fill in the black sst4 pixels with the mean from adjacent n*n pixels, where n<=20=============
sst4_refill=fltarr(x_size,y_size)-4.995
	For k=0, y_size-1 DO BEGIN
		FOR m=0, x_size-1 DO BEGIN
			IF sst4(m,k) le -4.995 and chlor_a_mean(m,k) gt 0.0 THEN BEGIN
				sum_sst4=-4.995
				count_sst4=0.0
				sst4_new=-4.995
				adj_pixel_n=1.0
				WHILE (sst4_new lt -4.9) and adj_pixel_n le 20.0 DO BEGIN
					min_pixel_x=m-adj_pixel_n
					max_pixel_x=m+adj_pixel_n
					min_pixel_y=k-adj_pixel_n
					max_pixel_y=k+adj_pixel_n
					IF min_pixel_x le 0.0 THEN min_pixel_x=0.0
					IF max_pixel_x ge m THEN max_pixel_x=m
					IF min_pixel_y le 0.0 THEN min_pixel_y=0.0
					IF max_pixel_y ge k THEN max_pixel_y=k
					For j=min_pixel_x,max_pixel_x DO BEGIN
						FOR q=min_pixel_y,max_pixel_y DO BEGIN
							IF sst4(j,q) gt -4.9 and sst4(j,q) lt 40.0 THEN BEGIN
								sum_sst4=sum_sst4+sst4(j,q)
								count_sst4=count_sst4+1.0
							ENDIF
						ENDFOR
					ENDFOR
					IF count_sst4 gt 0.0 THEN sst4_new=(sum_sst4+4.995)/count_sst4 
					adj_pixel_n=adj_pixel_n+1
					; print, m, k, count_sst4,adj_pixel_n, sst4_new
				ENDWHILE
				sst4(m,k)=sst4_new
			ENDIF
		ENDFOR
	ENDFOR
;====================================================================================================================


	For p=0, n_elements(selected_images)-1 DO BEGIN
prinT,selected_images(p)
	chl_a=fltarr(x_size,y_size)-1.0
	chl_b=fltarr(x_size,y_size)-1.0
	chl_c=fltarr(x_size,y_size)-1.0
	caro=fltarr(x_size,y_size)-1.0
	allo=fltarr(x_size,y_size)-1.0
	fuco=fltarr(x_size,y_size)-1.0
	perid=fltarr(x_size,y_size)-1.0
	neo=fltarr(x_size,y_size)-1.0
	viola=fltarr(x_size,y_size)-1.0
	dia=fltarr(x_size,y_size)-1.0
	zea=fltarr(x_size,y_size)
	lut=fltarr(x_size,y_size)

		Rrs412= READ_HDF_PROD(selected_images(p), 'Rrs_412')
		Rrs443= READ_HDF_PROD(selected_images(p), 'Rrs_443')
		Rrs488= READ_HDF_PROD(selected_images(p), 'Rrs_488')
		Rrs532= READ_HDF_PROD(selected_images(p), 'Rrs_531')
		Rrs551= READ_HDF_PROD(selected_images(p), 'Rrs_551')
		Rrs667= READ_HDF_PROD(selected_images(p), 'Rrs_667')
	;	chlor_a= READ_HDF_PROD(selected_images(p), 'chlor_a')
	
		Rrs488=reverse(Rrs488,2)
		Rrs532=reverse(Rrs532,2)
		Rrs551=reverse(Rrs551,2)
		Rrs667=reverse(Rrs667,2)
	;	chlor_a=reverse(chlor_a,2)



		;bad_stn_rrs=WHERE(Rrs443 lt 0.0 or Rrs488 le 0.0001 or Rrs532 le 0.0001 or Rrs551 le 0.0001 or Rrs667 le 0.0001 or Rrs488 ge 0.1 or Rrs532 ge 0.1 or Rrs551 ge 0.1 or Rrs667 ge 0.1)
		bad_stn_rrs=WHERE(Rrs443 lt 0.0 or Rrs488 le 0.0 or Rrs532 le 0.0 or Rrs551 le 0.0 or Rrs667 le 0.00)
		r488_551=Rrs488/Rrs551
		bad_stn_r488_551=WHERE(r488_551 lt 0.1 or r488_551 gt 10.0)	;valid Rrs(488/551) ratio range 0.1-10
		r488_667=Rrs488/Rrs667
		bad_stn_r488_667=WHERE(r488_667 lt 0.1 or r488_667 gt 10000.0)	;valid Rrs(488/667) ratio range 0.1-10000.0 	
		log_R488_551=ALOG10(r488_551)
		log_R488_667=ALOG10(r488_667)		

;=========define coefficients================================================================================
			chla_coeff_1=[0.03664,	-3.451,	2.276,	-1.096] ; 488/551
			chla_coeff_2=[1.351,	-2.427,	0.9395,	-0.2432]	;490/670
			chlb_coeff=[-1.097,	-2.348,	0.9633,	-9.374] ;488/551
			chlc_coeff_1=[	-0.7584,	-3.511,	0.4116,	-0.4283] ;488/551
			chlc_coeff_2=[	0.4424,	-2.291,	1.19,	-0.5307] ;490/670
			caro_coeff_1=[-1.341,	-2.952,	3.802,	-4.256] ;488/551
			caro_coeff_2=[	-0.01909,	-2.775,	1.703,	-0.5496] ;490/670
			allo_coeff_1=[-1.401,	-4.816,	-1.264,	5.838] ;488/551
			allo_coeff_2=[0.04234,	-2.747,	1.562,	-0.8771] ;490/670
			fuco_coeff_1=[-0.6208,	-3.928,	1.339,	0.0] ;488/551
			fuco_coeff_2=[0.6908,	-2.053,	0.2658,	0.0] ;490/670
			perid_coeff_1=[-1.401,	-2.817,	2.634,	-2.396] ;488/551
			perid_coeff_2=[-0.01038,	-3.807,	3.612,	-1.489] ;490/670
			neo_coeff=[	-1.983,	-2.151,	2.134,	-12.67] ;488/551
			viola_coeff=[-1.947,	-1.601,	3.258,	-17.31] ;488/551
			dia_coeff=[	-0.9963,	-3.113,	1.635,	-2.164] ;488/551
			zea_coeff=[-9.885, -14.84, -9.23, -1.998] ; log(488/551)-1.5log(Tw)
			lut_coeff=[-2.188,	-2.037,	2.179,	-10.16] ; 488/551
;================================================================================================================

	;		good_8_stn=where(chlor_a gt 0.0 and chlor_a lt 200.0)
	;		IF good_8_stn[0] ne -1 THEN BEGIN
	;			chlor_a_8(good_8_stn)=chlor_a_8(good_8_stn)+chlor_a(good_8_stn)
	;			count_chlor_a(good_8_stn)=count_chlor_a(good_8_stn)+1.0
	;		ENDIF
		
		x1=log_R488_551
		x2=log_R488_667

		chl_a_1=10.^(chla_coeff_1[0]+chla_coeff_1[1]*x1+chla_coeff_1(2)*x1^2+chla_coeff_1(3)*x1^3)
		chl_a_2=10.^(chla_coeff_2[0]+chla_coeff_2[1]*x2+chla_coeff_2(2)*x2^2+chla_coeff_2(3)*x2^3)
			max_chla=chl_a_1
			chl_a=chl_a_1
			For k=0, y_size-1 DO BEGIN
				For m=0,x_size-1 DO BEGIN
					IF chl_a_2(m,k) gt chl_a_1(m,k) Then max_chla(m,k)=chl_a_2(m,k)
					IF x1(m,k) le 0.15 THEN chl_a(m,k)=max_chla(m,k)
				ENDFOR
			ENDFOR
			
			IF bad_stn_rrs[0] ne -1 THEN chl_a(bad_stn_rrs)=-1.0
			IF bad_stn_r488_551[0] ne -1 THEN chl_a(bad_stn_r488_551)=-1.0
			IF bad_stn_r488_667[0] ne -1 THEN chl_a(bad_stn_r488_667)=-1.0	
			good_8_stn=where(chl_a gt 0.0 and chl_a lt 200.0)
			IF good_8_stn[0] ne -1 THEN BEGIN				
				chla_8(good_8_stn)=chla_8(good_8_stn)+chl_a(good_8_stn)
				count_chla(good_8_stn)=count_chla(good_8_stn)+1.0
			ENDIF

		chl_b=10.^(chlb_coeff[0]+chlb_coeff[1]*x1+chlb_coeff(2)*x1^2+chlb_coeff(3)*x1^3)
			IF bad_stn_rrs[0] ne -1 THEN chl_b(bad_stn_rrs)=-1.0
			IF bad_stn_r488_551[0] ne -1 THEN chl_b(bad_stn_r488_551)=-1.0			
			good_8_stn=where(chl_b gt 0.0 and chl_b lt 200.0)
			IF good_8_stn[0] ne -1 THEN BEGIN	
				chlb_8(good_8_stn)=chlb_8(good_8_stn)+chl_b(good_8_stn)
				count_chlb(good_8_stn)=count_chlb(good_8_stn)+1.0	
			ENDIF

		chl_c_1=10.^(chlc_coeff_1[0]+chlc_coeff_1[1]*x1+chlc_coeff_1(2)*x1^2+chlc_coeff_1(3)*x1^3)
		chl_c_2=10.^(chlc_coeff_2[0]+chlc_coeff_2[1]*x2+chlc_coeff_2(2)*x2^2+chlc_coeff_2(3)*x2^3)
			max_chlc=chl_c_1
			chl_c=chl_c_1
			For k=0, y_size-1 DO BEGIN
				For m=0,x_size-1 DO BEGIN
					IF chl_c_2(m,k) gt chl_c_1(m,k) Then max_chlc(m,k)=chl_c_2(m,k)
					IF x1(m,k) le 0.15 THEN chl_c(m,k)=max_chlc(m,k)
				ENDFOR
			ENDFOR
			IF bad_stn_rrs[0] ne -1 THEN chl_c(bad_stn_rrs)=-1.0
			IF bad_stn_r488_551[0] ne -1 THEN chl_c(bad_stn_r488_551)=-1.0	
			IF bad_stn_r488_667[0] ne -1 THEN chl_c(bad_stn_r488_667)=-1.0	
			good_8_stn=where(chl_c gt 0.0 and chl_c lt 200.0)
			IF good_8_stn[0] ne -1 THEN BEGIN	
				chlc_8(good_8_stn)=chlc_8(good_8_stn)+chl_c(good_8_stn)
				count_chlc(good_8_stn)=count_chlc(good_8_stn)+1.0	
			ENDIF

		caro_1=10.^(caro_coeff_1[0]+caro_coeff_1[1]*x1+caro_coeff_1(2)*x1^2+caro_coeff_1(3)*x1^3)
		caro_2=10.^(caro_coeff_2[0]+caro_coeff_2[1]*x2+caro_coeff_2(2)*x2^2+caro_coeff_2(3)*x2^3)
			max_caro=caro_1
			caro=caro_1
			For k=0, y_size-1 DO BEGIN
				For m=0,x_size-1 DO BEGIN
					IF caro_2(m,k) gt caro_1(m,k) Then max_caro(m,k)=caro_2(m,k)
					IF x1(m,k) le 0.15 THEN caro(m,k)=max_caro(m,k)
				ENDFOR
			ENDFOR
			IF bad_stn_rrs[0] ne -1 THEN caro(bad_stn_rrs)=-1.0
			IF bad_stn_r488_551[0] ne -1 THEN caro(bad_stn_r488_551)=-1.0
			IF bad_stn_r488_667[0] ne -1 THEN caro(bad_stn_r488_667)=-1.0	
			good_8_stn=where(caro gt 0.0 and caro lt 200.0)
			IF good_8_stn[0] ne -1 THEN BEGIN	
				caro_8(good_8_stn)=caro_8(good_8_stn)+caro(good_8_stn)
				count_caro(good_8_stn)=count_caro(good_8_stn)+1.0	
			ENDIF
			
		allo_1=10.^(allo_coeff_1[0]+allo_coeff_1[1]*x1+allo_coeff_1(2)*x1^2+allo_coeff_1(3)*x1^3)
		allo_2=10.^(allo_coeff_2[0]+allo_coeff_2[1]*x2+allo_coeff_2(2)*x2^2+allo_coeff_2(3)*x2^3)
			allo=allo_1
			For k=0, y_size-1 DO BEGIN
				For m=0,x_size-1 DO BEGIN
					IF x1(m,k) le 0.15 THEN allo(m,k)=allo_2(m,k)
				ENDFOR
			ENDFOR
			IF bad_stn_rrs[0] ne -1 THEN allo(bad_stn_rrs)=-1.0
			IF bad_stn_r488_667[0] ne -1 THEN allo(bad_stn_r488_667)=-1.0	
			IF bad_stn_r488_551[0] ne -1 THEN allo(bad_stn_r488_551)=-1.0	
			good_8_stn=where(allo gt 0.0 and allo lt 200.0)
			IF good_8_stn[0] ne -1 THEN BEGIN	
				allo_8(good_8_stn)=allo_8(good_8_stn)+allo(good_8_stn)
				count_allo(good_8_stn)=count_allo(good_8_stn)+1.0	
			ENDIF
			
		fuco_1=10.^(fuco_coeff_1[0]+fuco_coeff_1[1]*x1+fuco_coeff_1(2)*x1^2+fuco_coeff_1(3)*x1^3)
		fuco_2=10.^(fuco_coeff_2[0]+fuco_coeff_2[1]*x2+fuco_coeff_2(2)*x2^2+fuco_coeff_2(3)*x2^3)
			max_fuco=fuco_1
			fuco=fuco_1
			For k=0, y_size-1 DO BEGIN
				For m=0,x_size-1 DO BEGIN
					IF fuco_2(m,k) gt fuco_1(m,k) Then max_fuco(m,k)=fuco_2(m,k)
					IF x1(m,k) le 0.15 THEN fuco(m,k)=max_fuco(m,k)
				ENDFOR
			ENDFOR
			IF bad_stn_rrs[0] ne -1 THEN fuco(bad_stn_rrs)=-1.0
			IF bad_stn_r488_551[0] ne -1 THEN fuco(bad_stn_r488_551)=-1.0	
			IF bad_stn_r488_667[0] ne -1 THEN fuco(bad_stn_r488_667)=-1.0	
			good_8_stn=where(fuco gt 0.0 and fuco lt 200.0)
			IF good_8_stn[0] ne -1 THEN BEGIN	
				fuco_8(good_8_stn)=fuco_8(good_8_stn)+fuco(good_8_stn)
				count_fuco(good_8_stn)=count_fuco(good_8_stn)+1.0	
			ENDIF
			
		perid_1=10.^(perid_coeff_1[0]+perid_coeff_1[1]*x1+perid_coeff_1(2)*x1^2+perid_coeff_1(3)*x1^3)
		perid_2=10.^(perid_coeff_2[0]+perid_coeff_2[1]*x2+perid_coeff_2(2)*x2^2+perid_coeff_2(3)*x2^3)
			perid=perid_1
			For k=0, y_size-1 DO BEGIN
				For m=0,x_size-1 DO BEGIN
					IF x1(m,k) le 0.15 THEN perid(m,k)=perid_2(m,k)
				ENDFOR
			ENDFOR
			IF bad_stn_rrs[0] ne -1 THEN perid(bad_stn_rrs)=-1.0
			IF bad_stn_r488_667[0] ne -1 THEN perid(bad_stn_r488_667)=-1.0	
			IF bad_stn_r488_551[0] ne -1 THEN perid(bad_stn_r488_551)=-1.0	
			good_8_stn=where(perid gt 0.0 and perid lt 200.0)
			IF good_8_stn[0] ne -1 THEN BEGIN	
				perid_8(good_8_stn)=perid_8(good_8_stn)+perid(good_8_stn)
				count_perid(good_8_stn)=count_perid(good_8_stn)+1.0
			ENDIF



	
;===========recalculate Peridinin=============================================================

;			perid_ite=fltarr(x_size,y_size)-1.0	
		;	x_perid=x1-0.13*(-0.8)	

;			For k=0, y_size-1 DO BEGIN
;				For m=0,x_size-1 DO BEGIN	
;
;					IF fuco(m,k) gt 0.0 THEN BEGIN
;						x_perid=x1(m,k)-0.13*(-0.8)	; initial guess of x_perid
;						perid_diff=1.0	
;						count_ite=0.0
;						WHILE perid_diff gt 0.000001 and count_ite le 200.0 DO BEGIN
;					
;							log_perid_old=-1.043-3.644*x_perid+2.654*x_perid^2-2.013*x_perid^3	;LOG scale
;							perid_fuco=log_perid_old-alog10(fuco(m,k))	;log(perid/fuco)
;							x1_new=x1(m,k)-0.13*perid_fuco
;							log_perid_new=-1.043-3.644*x1_new+2.654*x1_new^2-2.013*x1_new^3
;							perid_diff=abs(log_perid_new-log_perid_old)
;							x_perid=x1_new	
;							count_ite=count_ite+1.0	
;						ENDWHILE
;						IF perid_diff le 0.000001 THEN perid_ite(m,k)=10.^log_perid_new	
;					ENDIF	
;				ENDFOR
;			ENDFOR
;			IF bad_stn_rrs[0] ne -1 THEN perid_ite(bad_stn_rrs)=-1.0
;			IF bad_stn_r488_551[0] ne -1 THEN perid_ite(bad_stn_r488_551)=-1.0	
;			good_8_stn=where(perid_ite gt 0.0 and perid_ite lt 200.0)
;			IF good_8_stn[0] ne -1 THEN BEGIN	
;				perid_ite_8(good_8_stn)=perid_ite_8(good_8_stn)+perid_ite(good_8_stn)
;				count_perid_ite(good_8_stn)=count_perid_ite(good_8_stn)+1.0
;			ENDIF
;=============================================================================================

						
																		
																													
		neo=10.^(neo_coeff[0]+neo_coeff[1]*x1+neo_coeff(2)*x1^2+neo_coeff(3)*x1^3)
			IF bad_stn_rrs[0] ne -1 THEN neo(bad_stn_rrs)=-1.0
			IF bad_stn_r488_551[0] ne -1 THEN neo(bad_stn_r488_551)=-1.0
			good_8_stn=where(neo gt 0.0 and neo lt 200.0)
			IF good_8_stn[0] ne -1 THEN BEGIN	
				neo_8(good_8_stn)=neo_8(good_8_stn)+neo(good_8_stn)
				count_neo(good_8_stn)=count_neo(good_8_stn)+1.0	
			ENDIF
				
		viola=10.^(viola_coeff[0]+viola_coeff[1]*x1+viola_coeff(2)*x1^2+viola_coeff(3)*x1^3)
			IF bad_stn_rrs[0] ne -1 THEN viola(bad_stn_rrs)=-1.0
			IF bad_stn_r488_551[0] ne -1 THEN viola(bad_stn_r488_551)=-1.0
			good_8_stn=where(viola gt 0.0 and viola lt 200.0)
			IF good_8_stn[0] ne -1 THEN BEGIN	
				viola_8(good_8_stn)=viola_8(good_8_stn)+viola(good_8_stn)
				count_viola(good_8_stn)=count_viola(good_8_stn)+1.0	
			ENDIF	

		dia=10.^(dia_coeff[0]+dia_coeff[1]*x1+dia_coeff(2)*x1^2+dia_coeff(3)*x1^3)
			IF bad_stn_rrs[0] ne -1 THEN dia(bad_stn_rrs)=-1.0
			IF bad_stn_r488_551[0] ne -1 THEN dia(bad_stn_r488_551)=-1.0	
			good_8_stn=where(dia gt 0.0 and dia lt 200.0)
			IF good_8_stn[0] ne -1 THEN BEGIN	
				dia_8(good_8_stn)=dia_8(good_8_stn)+dia(good_8_stn)
				count_dia(good_8_stn)=count_dia(good_8_stn)+1.0	
			ENDIF

		lut=10.^(lut_coeff[0]+lut_coeff[1]*x1+lut_coeff(2)*x1^2+lut_coeff(3)*x1^3)
			IF bad_stn_rrs[0] ne -1 THEN lut(bad_stn_rrs)=-1.0
			IF bad_stn_r488_551[0] ne -1 THEN lut(bad_stn_r488_551)=-1.0	
			good_8_stn=where(lut gt 0.0 and lut lt 200.0)
			IF good_8_stn[0] ne -1 THEN BEGIN	
				lut_8(good_8_stn)=lut_8(good_8_stn)+lut(good_8_stn)
				count_lut(good_8_stn)=count_lut(good_8_stn)+1.0	
			ENDIF




		x_zea=x1-1.5*alog10(sst4)	
		zea=10.^(zea_coeff[0]+zea_coeff[1]*x_zea+zea_coeff(2)*x_zea^2+zea_coeff(3)*x_zea^3)
			IF bad_stn_rrs[0] ne -1 THEN zea(bad_stn_rrs)=-1.0
			IF bad_stn_r488_551[0] ne -1 THEN zea(bad_stn_r488_551)=-1.0	
			good_8_stn=where(zea gt 0.0 and zea lt 200.0)
			IF good_8_stn[0] ne -1 THEN BEGIN	
				zea_8(good_8_stn)=zea_8(good_8_stn)+zea(good_8_stn)
				count_zea(good_8_stn)=count_zea(good_8_stn)+1.0	
			ENDIF
			
	ENDFOR

;	chlor_a_mean=chlor_a_8/count_chlor_a
;		bad_stn=where(count_chlor_a lt 1.0)
;		IF bad_stn[0] ne -1.0 THEN chlor_a_mean(bad_stn)=-1.0
	chla_mean=chla_8/count_chla
		bad_stn=where(count_chla lt 1.0)
		IF bad_stn[0] ne -1.0 THEN chla_mean(bad_stn)=-1.0
	chlb_mean=chlb_8/count_chlb
		bad_stn=where(count_chlb lt 1.0)
		IF bad_stn[0] ne -1.0 THEN chlb_mean(bad_stn)=-1.0
	chlc_mean=chlc_8/count_chlc
		bad_stn=where(count_chlc lt 1.0)
		IF bad_stn[0] ne -1.0 THEN chlc_mean(bad_stn)=-1.0
	caro_mean=caro_8/count_caro
		bad_stn=where(count_caro lt 1.0)
		IF bad_stn[0] ne -1.0 THEN caro_mean(bad_stn)=-1.0
	allo_mean=allo_8/count_allo
		bad_stn=where(count_allo lt 1.0)
		IF bad_stn[0] ne -1.0 THEN allo_mean(bad_stn)=-1.0
	fuco_mean=fuco_8/count_fuco
		bad_stn=where(count_fuco lt 1.0)
		IF bad_stn[0] ne -1.0 THEN fuco_mean(bad_stn)=-1.0
	dia_mean=dia_8/count_dia
		bad_stn=where(count_dia lt 1.0)
		IF bad_stn[0] ne -1.0 THEN dia_mean(bad_stn)=-1.0
	zea_mean=zea_8/count_zea
		bad_stn=where(count_zea lt 1.0)
		IF bad_stn[0] ne -1.0 THEN zea_mean(bad_stn)=-1.0
	lut_mean=lut_8/count_lut
		bad_stn=where(count_lut lt 1.0)
		IF bad_stn[0] ne -1.0 THEN lut_mean(bad_stn)=-1.0
	perid_mean=perid_8/count_perid
		bad_stn=where(count_perid lt 1.0)
		IF bad_stn[0] ne -1.0 THEN perid_mean(bad_stn)=-1.0
;	perid_ite_mean=perid_ite_8/count_perid_ite
;		bad_stn=where(count_perid_ite lt 1.0)
;		IF bad_stn[0] ne -1.0 THEN perid_ite_mean(bad_stn)=-1.0
	neo_mean=neo_8/count_neo
		bad_stn=where(count_neo lt 1.0)
		IF bad_stn[0] ne -1.0 THEN neo_mean(bad_stn)=-1.0
	viola_mean=viola_8/count_viola
		bad_stn=where(count_viola lt 1.0)
		IF bad_stn[0] ne -1.0 THEN viola_mean(bad_stn)=-1.0

;==============percentage to [Chl_a]==========================================================================
	chlor_percent=chlor_a_mean/chla_mean*100.0
		bad_stn=where(chlor_a_mean le 0.0 or chla_mean le 0.0)
		IF bad_stn[0] ne -1.0 THEN chlor_percent(bad_stn)=-99.0
	chlb_percent=chlb_mean/chla_mean*100.0
		bad_stn=where(chlb_mean le 0.0 or chla_mean le 0.0)
		IF bad_stn[0] ne -1.0 THEN chlb_percent(bad_stn)=-99.0
	chlc_percent=chlc_mean/chla_mean*100.0
		bad_stn=where(chlc_mean le 0.0 or chla_mean le 0.0)
		IF bad_stn[0] ne -1.0 THEN chlc_percent(bad_stn)=-99.0
	caro_percent=caro_mean/chla_mean*100.0
		bad_stn=where(caro_mean le 0.0 or chla_mean le 0.0)
		IF bad_stn[0] ne -1.0 THEN caro_percent(bad_stn)=-99.0
	allo_percent=allo_mean/chla_mean*100.0
		bad_stn=where(allo_mean le 0.0 or chla_mean le 0.0)
		IF bad_stn[0] ne -1.0 THEN allo_percent(bad_stn)=-99.0
	fuco_percent=fuco_mean/chla_mean*100.0
		bad_stn=where(fuco_mean le 0.0 or chla_mean le 0.0)
		IF bad_stn[0] ne -1.0 THEN fuco_percent(bad_stn)=-99.0
	dia_percent=dia_mean/chla_mean*100.0
		bad_stn=where(dia_mean le 0.0 or chla_mean le 0.0)
		IF bad_stn[0] ne -1.0 THEN dia_percent(bad_stn)=-99.0
	zea_percent=zea_mean/chla_mean*100.0
		bad_stn=where(zea_mean le 0.0 or chla_mean le 0.0)
		IF bad_stn[0] ne -1.0 THEN zea_percent(bad_stn)=-99.0
	lut_percent=lut_mean/chla_mean*100.0
		bad_stn=where(lut_mean le 0.0 or chla_mean le 0.0)
		IF bad_stn[0] ne -1.0 THEN lut_percent(bad_stn)=-99.0
	perid_percent=perid_mean/chla_mean*100.0
		bad_stn=where(perid_mean le 0.0 or chla_mean le 0.0)
		IF bad_stn[0] ne -1.0 THEN perid_percent(bad_stn)=-99.0
;	perid_ite_percent=perid_ite_mean/chla_mean*100.0
;		bad_stn=where(perid_ite_mean le 0.0 or chla_mean le 0.0)
;		IF bad_stn[0] ne -1.0 THEN perid_ite_percent(bad_stn)=-99.0
	neo_percent=neo_mean/chla_mean*100.0
		bad_stn=where(neo_mean le 0.0 or chla_mean le 0.0)
		IF bad_stn[0] ne -1.0 THEN neo_percent(bad_stn)=-99.0
	viola_percent=viola_mean/chla_mean*100.0
		bad_stn=where(viola_mean le 0.0 or chla_mean le 0.0)
		IF bad_stn[0] ne -1.0 THEN viola_percent(bad_stn)=-99.0
	perid_fuco_ratio=perid_mean/fuco_mean*100.0
		bad_stn=where(perid_mean le 0.0 or fuco_mean le 0.0)
		IF bad_stn[0] ne -1.0 THEN perid_fuco_ratio(bad_stn)=-99.0
;	perid_ite_fuco_ratio=perid_ite_mean/fuco_mean*100.0
;		bad_stn=where(perid_ite_mean le 0.0 or fuco_mean le 0.0)
;		IF bad_stn[0] ne -1.0 THEN perid_ite_fuco_ratio(bad_stn)=-99.0

ofname='/home/xpan/bin/modis_pigment_images/'+'A'+string(days_periods(0,i),format='(I7.1)')+'_'+string(days_periods(1,i),format='(I7.1)')+'_pigments_new.hdf'

;ofname='/home/xpan/data/modis/pigments_8day_mean/'+'A'+string(days_periods(0,i),format='(I7.1)')+'_'+string(days_periods(1,i),format='(I7.1)')+'_pigments.hdf'

print,ofname
Sid = HDF_SD_START(ofname, /CREATE)
HDF_SD_END, Sid 

Sid = HDF_SD_START(ofname, /RDWR)  

SD_id = HDF_SD_CREATE(Sid, 'latitude', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, latitude

SD_id = HDF_SD_CREATE(Sid, 'longitude', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, longitude

SD_id = HDF_SD_CREATE(Sid, 'sst4', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, sst4

SD_id = HDF_SD_CREATE(Sid, 'chlor_a', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, chlor_a_mean

SD_id = HDF_SD_CREATE(Sid, 'chl_a', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, chla_mean

SD_id = HDF_SD_CREATE(Sid, 'chl_b', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, chlb_mean

SD_id = HDF_SD_CREATE(Sid, 'chl_c', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, chlc_mean

SD_id = HDF_SD_CREATE(Sid, 'caro', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, caro_mean

SD_id = HDF_SD_CREATE(Sid, 'allo', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, allo_mean

SD_id = HDF_SD_CREATE(Sid, 'fuco', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, fuco_mean

SD_id = HDF_SD_CREATE(Sid, 'neo', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, neo_mean

SD_id = HDF_SD_CREATE(Sid, 'viola', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, viola_mean

SD_id = HDF_SD_CREATE(Sid, 'dia', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, dia_mean

SD_id = HDF_SD_CREATE(Sid, 'zea', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, zea_mean

SD_id = HDF_SD_CREATE(Sid, 'lut', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, lut_mean

SD_id = HDF_SD_CREATE(Sid, 'perid', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, perid_mean

;SD_id = HDF_SD_CREATE(Sid, 'perid_ite', [x_size,y_size],/float)
;HDF_SD_ADDDATA, SD_id, perid_ite_mean

SD_id = HDF_SD_CREATE(Sid, 'chlor_percent', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, chlor_percent

SD_id = HDF_SD_CREATE(Sid, 'chlb_percent', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, chlb_percent

SD_id = HDF_SD_CREATE(Sid, 'chlc_percent', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, chlc_percent

SD_id = HDF_SD_CREATE(Sid, 'caro_percent', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, caro_percent

SD_id = HDF_SD_CREATE(Sid, 'allo_percent', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, allo_percent

SD_id = HDF_SD_CREATE(Sid, 'fuco_percent', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, fuco_percent

SD_id = HDF_SD_CREATE(Sid, 'dia_percent', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, dia_percent

SD_id = HDF_SD_CREATE(Sid, 'zea_percent', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, zea_percent

SD_id = HDF_SD_CREATE(Sid, 'perid_percent', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, perid_percent

;SD_id = HDF_SD_CREATE(Sid, 'perid_ite_percent', [x_size,y_size],/float)
;HDF_SD_ADDDATA, SD_id, perid_ite_percent

SD_id = HDF_SD_CREATE(Sid, 'lut_percent', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, lut_percent

SD_id = HDF_SD_CREATE(Sid, 'viola_percent', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, viola_percent

SD_id = HDF_SD_CREATE(Sid, 'neo_percent', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, neo_percent

SD_id = HDF_SD_CREATE(Sid, 'perid_fuco_ratio', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, perid_fuco_ratio

;SD_id = HDF_SD_CREATE(Sid, 'perid_ite_fuco_ratio', [x_size,y_size],/float)
;HDF_SD_ADDDATA, SD_id, perid_ite_fuco_ratio


HDF_SD_ENDACCESS, SD_id
HDF_SD_END, Sid 
 

ENDFOR
END
