; $ID:	SHSTRATA_PLOT.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Program Plots Shape File Information
;	NOTES:
; RECEIVED shstr.SHP, shstr.DBF, shstr.SHX FROM D.HART
;	EDITED shstr.DBF TO ADD FIELDS STRAT_NUM, COLOR
;	RESULTING FILES: shstrat.DBF, shstr_jor.SHP, shstrat.SHX (LAST 2 SIMPLY COPIES OF HART'S FILES)

; HISTORY:
;		March 12,2003	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO SHSTRATA_PLOT,FILE,PAL=pal,COLOR=color,DIR_OUT=dir_out, SHOW=show

  ROUTINE_NAME='SHSTRATA_PLOT'

   FILE = 'D:\IDL\SHAPEFILES\shstrata.shp'
   DB_FILE = 'D:\IDL\SHAPEFILES\shstrata.dbf'


FN=PARSE_IT(FILE)
DB=READALL(DB_FILE)


LANDMASK = READALL('D:\IDL\IMAGES\MASK_NEC_NO_LAKES.PNG')
WATER = WHERE(LANDMASK EQ 255)
LAND = WHERE(LANDMASK EQ 1)
COAST = WHERE(LANDMASK EQ 0)
LANDMASK(WATER) = 254
FONT_TIMES
 	PAL_SW3,RR,GG,BB
	PAL_IDL31,R,G,B

 	HLS, 40,100,80,100, 250,30,COLR & R=COLR(*,0)&G=COLR(*,1)&B=COLR(*,2)
;  R=SHIFT(R,-SHFT) & G=SHIFT(G,-SHFT) & B=SHIFT(B,-SHFT)
	R(251:*)=RR(251:*)&G(251:*)=GG(251:*)&B(251:*)=BB(251:*)
	R[0]=RR[0]&G[0]=GG[0]&B[0]=BB[0]
	R(161) = 64 & G(161) = 128 & B(161) = 1
	R(6) = 64 & G(6) = 90 & B(6) = 66
	R(3) = 64 & G(3) = 90 & B(3) = 255
	R(26) = R(132) & G(26) = G(132) & B(26) = B(132)
	R(90) = R(84) & G(90) = G(84) & B(90) = B(84)
	R(22) = 64 & G(22) = 128 & B(22) = 5
	R(93) = 100 & G(93) = 196 & B(93) = 32
	R(50) = 245 & G(50) = 200 & B(50) = 32

  SHOW=0
  ADD_TITLE=1
	IF N_ELEMENTS(COLOR) EQ 0 THEN COLOR = 21
	IF N_ELEMENTS(PAL) NE 1 THEN PAL = 'PAL_36'
	IF N_ELEMENTS(DIR_OUT) NE 1 THEN _DIR_OUT = 'D:\IDL\SHAPEFILES\' ELSE _DIR_OUT = DIR_OUT
	IF N_ELEMENTS(FILE) EQ 0 THEN FILE = DIALOG_PICKFILE(TITLE='Pick a ShapeFile')

	FN=PARSE_IT(FILE)
	CD, FN.DIR
	SHAPEFILE = FN.NAME
SAVEFILE  = _DIR_OUT+FN.NAME+'_MASK.SAVE'


 PNGFILE = _DIR_OUT+FN.NAME+'_PLAIN.PNG'

;GOTO, CHECK_AREAS

;GOTO,NUMBERS

;	***********************************************************
; ************ DATA MASK SAVE FILE***************************
; **********************************************************
 IIMAGE = INTARR(1024,1024)
 ZWIN,LANDMASK
 MAP_NEC
;		Open the Shapefile
		myshape=OBJ_NEW('IDLffShape', shapefile)

;		Get the number of entities so we can parse through them
		myshape -> IDLffShape::GetProperty, N_ENTITIES=num_ent,ENTITY_TYPE=ent_type
 		FOR x=0L, (num_ent-1L) DO BEGIN
 		ERASE,0
;			=====>Get the Attributes for entity x
   		attr = myshape -> IDLffShape::GetAttributes(x)
      color= 1

;			=====> Get entity
      ent = myshape ->IDLffShape::GetEntity(x)
      POLYFILL, (*ent.vertices)[0,*], (*ent.vertices)[1,*], COLOR= COLOR
;			=====> Clean-up of pointers
      myshape -> IDLffShape::DestroyEntity, ent
      TEMP=TVRD()
      OK = WHERE(TEMP EQ COLOR)
      IIMAGE[OK] = ATTR.ATTRIBUTE_7
	  ENDFOR
;	=====> Close the Shapefile
	OBJ_DESTROY, myshape
  ZWIN
 SAVE,FILENAME=SAVEFILE,IIMAGE,/COMPRESS



;	***********************************************************
; ************ PLAIN PNG ************************************
;	***********************************************************
 ZWIN,LANDMASK
 MAP_NEC

 TV,LANDMASK
;		Open the Shapefile
		myshape=OBJ_NEW('IDLffShape', shapefile)

;		Get the number of entities so we can parse through them
		myshape -> IDLffShape::GetProperty, N_ENTITIES=num_ent,ENTITY_TYPE=ent_type
 		FOR x=0L, (num_ent-1L) DO BEGIN
;			=====>Get the Attributes for entity x
   		attr = myshape -> IDLffShape::GetAttributes(x)
      color=attr.attribute_8
;			=====> Get entity
      ent = myshape ->IDLffShape::GetEntity(x)
      POLYFILL, (*ent.vertices)[0,*], (*ent.vertices)[1,*], COLOR= COLOR
;			=====> Clean-up of pointers
      myshape -> IDLffShape::DestroyEntity, ent
	  ENDFOR
;	=====> Close the Shapefile
	OBJ_DESTROY, myshape
  IMAGE = TVRD()
  ZWIN
 	IMAGE(LAND) = 253
 	FONT_TIMES
	IF ADD_TITLE EQ 1 THEN BEGIN
  	txt ='NEFSC!CShellfish Sampling Strata'
  	txt=txt+'!C!CStandard NEC!CLambert Projection'
		image=MAP_ADD_TXT(image,0.05,.95,txt,CHARSIZE=2.5,COLOR=0)
		image=MAP_ADD_TXT(image,0.95,.01,"J.O'Reilly",CHARSIZE=0.5,COLOR=0)
	ENDIF
 WRITE_PNG,PNGFILE,IMAGE,R,G,B


;	***********************************************************
 NUMBERS:
; ***********************************************************
 IMAGE=READ_PNG(PNGFILE,R,G,B)
 ZWIN,IMAGE
 MAP_NEC
 TV,IMAGE
 DEFONT
;		Open the Shapefile
		myshape=OBJ_NEW('IDLffShape', shapefile)
;		Get the number of entities so we can parse through them
		myshape -> IDLffShape::GetProperty, N_ENTITIES=num_ent,ENTITY_TYPE=ent_type
 		FOR x=0L, (num_ent-1L) DO BEGIN
;			=====>Get the Attributes for entity x
   		attr = myshape -> IDLffShape::GetAttributes(x)
      color=attr.attribute_7
;			=====> Get entity
      ent = myshape ->IDLffShape::GetEntity(x)
      XPOS=DB(X).LON_CENTER & YPOS = DB(X).LAT_CENTER
      XYOUTS,/DATA,XPOS,ypos,NUM2STR(FIX(COLOR)),CHARSIZE=1,ALIGN=0.5 ,color=0,ORIENTATION=DB(X).ORIENT
;			=====> Clean-up of pointers
      myshape -> IDLffShape::DestroyEntity, ent

	  ENDFOR
;	=====> Close the Shapefile
	OBJ_DESTROY, myshape
  IMAGE = TVRD()
  PLOTGRAT,.1,SYMSIZE=0.2
  PLOTGRAT,1,SYMSIZE=0.4
  ZWIN
; 	IMAGE(LAND) = 253
 	FONT_TIMES
	IF ADD_TITLE EQ 1 THEN BEGIN
  	txt ='NEFSC!CShellfish Sampling Strata'
  	txt=txt+'!C!CStandard NEC!CLambert Projection'
		image=MAP_ADD_TXT(image,0.05,.95,txt,CHARSIZE=2.5,COLOR=0)
		image=MAP_ADD_TXT(image,0.95,.01,"J.O'Reilly",CHARSIZE=0.5,COLOR=0)
	ENDIF

 PNGFILE = _DIR_OUT+FN.NAME+'_NUM.PNG'
 WRITE_PNG,PNGFILE,IMAGE,R,G,B



; ****************************************************
; **** C H E C K    A R E A S   ON   MASK   vs  dbf
  CHECK_AREAS:
  SHSTRATA_MASK=READALL(SAVEFILE)
  X = FLTARR(95)
  Y = FLTARR(95)
  FOR NTH=0,N_ELEMENTS(X)-1 DO BEGIN
    SUBAREA = DB[NTH].STRAT_NUM
    OK_X = WHERE(DB.STRAT_NUM EQ SUBAREA)
    X[NTH] = TOTAL(DB(OK_X).A2)
    OK_Y = WHERE(SHSTRATA_MASK EQ SUBAREA)
    Y[NTH] = N_ELEMENTS(OK_Y)
  ENDFOR
  Y=Y*1.25*1.25 ; KM/PIXEL
  PSFILE = _DIR_OUT+FN.NAME+'_AREA.PS'
  PSPRINT,FILENAME=PSFILE,/HALF,/COLOR
  PLOTXY, X,Y,PSYM=1,XTITLE='SHSTR AREA',YTITLE='NEC AREA',PARAMS=[1,2,3,4,8]
  XYOUTS,X,Y,NUM2STR(FIX(DB.STRAT_NUM)),COLOR=0
  PSPRINT


END; #####################  End of Routine ################################
