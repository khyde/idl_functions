; $ID:	PHYTO_COMMUNITY_MODIS.PRO,	2020-07-08-15,	USER-KJWH	$
PRO phyto_community_modis

;****************************************************************************************
;*    Remote sensing of Phytoplankton Community                                         *
;*   Created by Xiaoju Pan (xpanx001@gmail.com)                                         *
;*   Updated by August 14, 2009                                                         *
;****************************************************************************************

latlon=[35.0,45.0,-77.0,-65.0]		; interested region [sLat,nLat,wLong,eLong]


x_size=round((latlon(3)-latlon(2))*90)	; 1 degree = 90 pixel
y_size=round((latlon[1]-latlon[0])*111)	; 1 degree = 111 pixel

latitude=READ_HDF_PROD('/nuwa_cluster/home/xpan/Lat_Long_GoM_SMAB_map.hdf', 'Latitude')
;latitude=reverse(latitude,2)
longitude=READ_HDF_PROD('/nuwa_cluster/home/xpan/Lat_Long_GoM_SMAB_map.hdf', 'Longitude')

;=========CHEMTAX pigment matrices============================================
;CHEMTAX ratios are separated into 12 subsets based on TChl_a ranges.
;Row: Diatoms,Cryptophytes,Dino_A,Dino_B,Hapto_A,Hapto_B,Prasino_A,Prasino_B,Chlorophytes,Cyanobacteria,Prochlorophytes
;Column:	TChl_a,Tot_Chl_b,TChl_c,Perid,Fuco,Dia,Allo,Zea,Lut,Neo,Viola

chemtax_ratio_fname='/nuwa_cluster/home/xpan/GSFC/modis_aqua/prod_pig_community/modis_phyto/chemtax_ratio_subsets.txt'
OPENR, lun, chemtax_ratio_fname, /GET_LUN
	subset=1 & min_log_chla=1.0 & max_log_chla=1.0 & f_diatom=1.0 & f_crypt=1.0 & f_dinoA=1.0 &$
		f_dinoB=1.0 & f_haptA=1.0 & f_haptB=1.0 & f_prasA=1.0 & f_prasB=1.0 & f_chlo=1.0 &$
		f_cyano=1.0 & f_proc=1.0
	header = STRARR[1]
	READF, lun, header							
	READF,lun,subset,min_log_chla,max_log_chla,f_diatom,f_crypt,f_dinoA,f_dinoB,f_haptA,f_haptB,f_prasA,f_prasB,$
		f_chlo,f_cyano,f_proc
	min_chla=[min_log_chla]
	max_chla=[max_log_chla]
	chemtax_ratio=[f_diatom,f_crypt,f_dinoA,f_dinoB,f_haptA,f_haptB,f_prasA,f_prasB,f_chlo,f_cyano,f_proc]
	WHILE ~ EOF(lun) DO BEGIN

		READF,lun,subset,min_log_chla,max_log_chla,f_diatom,f_crypt,f_dinoA,f_dinoB,f_haptA,f_haptB,f_prasA,$
			f_prasB,f_chlo,f_cyano,f_proc
		min_chla=[[min_chla],[min_log_chla]]
		max_chla=[[max_chla],[max_log_chla]]
		chemtax_ratio=[[chemtax_ratio],[f_diatom,f_crypt,f_dinoA,f_dinoB,f_haptA,f_haptB,f_prasA,$
			f_prasB,f_chlo,f_cyano,f_proc]]
	ENDWHILE
FREE_LUN,LUN
;================================================================================


all_fnames=FILE_SEARCH('/nuwa_cluster/home/xpan/GSFC/modis_aqua/prod_pig_community/modis_pigments/A*_pigments.hdf')
FILEBREAK,all_fnames,dir=path_name,file=file_name
iyear=STRMID(file_name,1,4)	; define Year
year_date=STRMID(file_name,5,3)	; define Julian date
name1=STRMID(file_name,0,17)
jdate=double(year_date)+3.5

For i=0, n_elements(all_fnames)-1 DO BEGIN
;For i=0,0 DO BEGIN

	prasinophyte_A=fltarr(x_size,y_size)-1.0
	prasinophyte_B=fltarr(x_size,y_size)-1.0
	diatom=fltarr(x_size,y_size)-1.0
	dinoflagellate_A=fltarr(x_size,y_size)-1.0
	dinoflagellate_B=fltarr(x_size,y_size)-1.0
	cryptophyte=fltarr(x_size,y_size)-1.0
	chlorophyte=fltarr(x_size,y_size)-1.0
	haptophyte_A=fltarr(x_size,y_size)-1.0
	haptophyte_B=fltarr(x_size,y_size)-1.0
	cyanobacteria=fltarr(x_size,y_size)-1.0
	prochlorophyte=fltarr(x_size,y_size)-1.0
	TChl_a=fltarr(x_size,y_size)-1.0

	brown_algae=fltarr(x_size,y_size)-1.0
	dinoflagellate=fltarr(x_size,y_size)-1.0
	green_algae=fltarr(x_size,y_size)-1.0
	pico=fltarr(x_size,y_size)-1.0

	diatom_percentage=fltarr(x_size,y_size)-1.0
	cryptophyte_percentage=fltarr(x_size,y_size)-1.0
	brown_percentage=fltarr(x_size,y_size)-1.0
	dinoflagellate_percentage=fltarr(x_size,y_size)-1.0
	green_percentage=fltarr(x_size,y_size)-1.0
	pico_percentage=fltarr(x_size,y_size)-1.0

	;=====read pigments=======================================
		chl_a= READ_HDF_PROD(all_fnames(i), 'chl_a')	
		chl_b= READ_HDF_PROD(all_fnames(i), 'chl_b')	
		chl_c= READ_HDF_PROD(all_fnames(i), 'chl_c')	
		fuco= READ_HDF_PROD(all_fnames(i), 'fuco')	
		perid= READ_HDF_PROD(all_fnames(i), 'perid')	
		zea= READ_HDF_PROD(all_fnames(i), 'zea')	
		allo= READ_HDF_PROD(all_fnames(i), 'allo')	
		dia= READ_HDF_PROD(all_fnames(i), 'dia')	
		lut= READ_HDF_PROD(all_fnames(i), 'lut')	
		neo= READ_HDF_PROD(all_fnames(i), 'neo')	
		viola= READ_HDF_PROD(all_fnames(i), 'viola')	
	;=========================================================

	FOR j=0, x_size-1 DO BEGIN
		FOR m=0,y_size-1 DO BEGIN

			y_array=[chl_a(j,m),chl_b(j,m),chl_c(j,m),perid(j,m),fuco(j,m),dia(j,m),allo(j,m),zea(j,m),$
						lut(j,m),neo(j,m),viola(j,m)]
			weight_factor=fltarr(n_elements(y_array),1)+1.0

			min_y=min(y_array)
			IF min_y gt 0.00001 THEN BEGIN
				selected_subset=where(min_chla le alog10(chl_a(j,m)) and max_chla gt alog10(chl_a(j,m)))
				x_array=chemtax_ratio(*,selected_subset)

				modified_community,phyto_community,x_array,y_array,weight_factor

				sum_chla=mean(phyto_community)*11.0
				IF sum_chla gt 0.0 THEN BEGIN
					TChl_a(j,m)=sum_chla
					diatom(j,m)=phyto_community[0]
					cryptophyte(j,m)=phyto_community[1]
					dinoflagellate_A(j,m)=phyto_community(2)
					dinoflagellate_B(j,m)=phyto_community(3)
					haptophyte_A(j,m)=phyto_community(4)
					haptophyte_B(j,m)=phyto_community(5)
					prasinophyte_A(j,m)=phyto_community(6)
					prasinophyte_B(j,m)=phyto_community(7)
					chlorophyte(j,m)=phyto_community(8)
					cyanobacteria(j,m)=phyto_community(9)
					prochlorophyte(j,m)=phyto_community(10)
	
					green_algae(j,m)=prasinophyte_A(j,m)+prasinophyte_B(j,m)+chlorophyte(j,m)
					dinoflagellate(j,m)=dinoflagellate_A(j,m)+dinoflagellate_B(j,m)
					brown_algae(j,m)=haptophyte_A(j,m)+haptophyte_B(j,m)	
					pico(j,m)=cyanobacteria(j,m)+prochlorophyte(j,m)

					diatom_percentage(j,m)=diatom(j,m)/sum_chla*100.0
					dinoflagellate_percentage(j,m)=dinoflagellate(j,m)/sum_chla*100.0
					cryptophyte_percentage(j,m)=cryptophyte(j,m)/sum_chla*100.0
					green_percentage(j,m)=green_algae(j,m)/sum_chla*100.0
					brown_percentage(j,m)=brown_algae(j,m)/sum_chla*100.0
					pico_percentage(j,m)=pico(j,m)/sum_chla*100.0
				ENDIF

			ENDIF

		ENDFOR
	ENDFOR
	
ofname='/nuwa_cluster/home/xpan/GSFC/modis_aqua/prod_pig_community/modis_phyto/'+name1(i)+'community.hdf'

;ofname='/home/xpan/data/modis/pigments_8day_mean/'+'A'+string(days_periods(0,i),format='(I7.1)')+'_'+string(days_periods(1,i),format='(I7.1)')+'_pigments.hdf'

print,ofname

Sid = HDF_SD_START(ofname, /CREATE)
HDF_SD_END, Sid 

Sid = HDF_SD_START(ofname, /RDWR)  

SD_id = HDF_SD_CREATE(Sid, 'latitude', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, latitude

SD_id = HDF_SD_CREATE(Sid, 'longitude', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, longitude

SD_id = HDF_SD_CREATE(Sid, 'Chl_a', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, TChl_a

SD_id = HDF_SD_CREATE(Sid, 'Diatom', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, diatom

SD_id = HDF_SD_CREATE(Sid, 'Crypt', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, cryptophyte

SD_id = HDF_SD_CREATE(Sid, 'Dino', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, dinoflagellate

SD_id = HDF_SD_CREATE(Sid, 'Brown', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, brown_algae

SD_id = HDF_SD_CREATE(Sid, 'Green', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, green_algae

SD_id = HDF_SD_CREATE(Sid, 'Pico', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, pico

SD_id = HDF_SD_CREATE(Sid, 'Diatom_perc', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, diatom_percentage

SD_id = HDF_SD_CREATE(Sid, 'Crypt_perc', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, cryptophyte_percentage

SD_id = HDF_SD_CREATE(Sid, 'Dino_perc', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, dinoflagellate_percentage

SD_id = HDF_SD_CREATE(Sid, 'Brown_perc', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, brown_percentage

SD_id = HDF_SD_CREATE(Sid, 'Green_perc', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, green_percentage

SD_id = HDF_SD_CREATE(Sid, 'Pico_perc', [x_size,y_size],/float)
HDF_SD_ADDDATA, SD_id, pico_percentage

HDF_SD_ENDACCESS, SD_id
HDF_SD_END, Sid 
 

ENDFOR
END
