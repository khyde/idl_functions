; $ID:	WHERE_NEAREST_LONLAT.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Function finds the indices in Array which are nearest to Values array AND within a tolerance (NEAR).
; Array and Values must be numeric types
;
;	Result = WHERE_NEAREST_LOnLAT(Array, Values, NEAR=near)
;
; NOTES:
;  Routie uses

; HISTORY:
;	 May 5, 2003	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION  WHERE_NEAREST_LOnLAT, LON0,LAT0, LON1,LAT1,Count, NEAR=NEAR, VALID=valid,$
												 NCOMPLEMENT=ncomplement,COMPLEMENT=complement,NINVALID=ninvalid,INVALID=invalid
  ROUTINE_NAME='WHERE_NEAREST_LOnLAT'

;	====> If NEAR is not provided then set it to zero with Data Type from Array
  IF N_ELEMENTS(NEAR) EQ 0 THEN BEGIN
    _NEAR = LON0[0]
    _NEAR(*) 	= 0
  ENDIF ELSE _NEAR = NEAR

	N_LON0 = N_ELEMENTS(LON0)
	N_LON1 = N_ELEMENTS(LON1)


;	LLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR _L0 = 0L,N_LON0-1L DO BEGIN
		METERS = REPLICATE(0.0,N_LON1)
		FOR _L1 = 0L,N_LON1-1L DO BEGIN
			METERS(_L1)  = MAP_2POINTS(LON0(_L0),LAT0(_L0), LON1(_L1),LAT1(_L1),/METERS,/RHUMB)
			STOP
		ENDFOR
	ENDFOR

; ===> Determine Size,and IDLtypes of Array and Values
  sz_Array 	= SIZE(Array,/struct)
  sz_values = SIZE(Values,/struct)

; ===> Ensure that Array and Values are both numeric
  IF NUMERIC(ARRAY) EQ 0 OR NUMERIC(VALUES) EQ 0 THEN BEGIN
  	PRINT,'ERROR: Array and Values Must Both be NUMERIC'
    COUNT = 0L

    NCOMPLEMENT = sz_Array.n_elements
    COMPLEMENT  = LINDGEN(sz_array.n_elements)
    NINVALID=sz_values.n_elements
    INVALID = LINDGEN(sz_values.n_elements)
    RETURN, []     ; Removed RETURN, -1 to be compatible with IDL 8.1 - may not be compatible with ealier versions of IDL
  ENDIF

; ===> Ensure that both Array and Values are not empty
  IF sz_Array.n_elements  EQ 0 OR sz_values.n_elements  EQ 0 THEN RETURN, -1L

; ===> Copy Array into _array (_Array must have at least 2 elements to get through VALUE_LOCATE)
  IF sz_array.n_elements EQ 1 THEN _Array = [array,array] ELSE _array = Array

; ===> Sort _Array
  index 		= LINDGEN(sz_array.N_ELEMENTS)
  srt 			= SORT(_Array)
  _Array 		= _Array(srt)
  index_array	= index(srt)

;	===> Get subscripts of the Array elements which are nearest to each element in the Values array
 	subs_arr_lower  	= VALUE_LOCATE(_Array, [Values]) ; (ensure values is an array even when only 1 value)
  subs_arr_upper    = (subs_arr_lower + 1) < (sz_array.N_ELEMENTS-1L)

  dif_lower = ABS(_ARRAY(subs_arr_lower) - [VALUES])
  dif_upper = ABS(_ARRAY(subs_arr_upper) - [VALUES])
  test_dif  = dif_lower LE dif_upper

  SUBS_nearest = LONARR(sz_values.N_ELEMENTS)
  OK = WHERE(test_dif EQ 1,COUNT)
  IF COUNT GE 1 THEN SUBS_nearest(OK) = subs_arr_lower(OK)
	OK = WHERE(test_dif EQ 0,COUNT)
  IF COUNT GE 1 THEN SUBS_nearest(OK) = subs_arr_upper(OK)


; ===> Exchange subs_nearest subscripts for array for ARRAY Sub_nearest
  subs_nearest = index_array([subs_nearest])

; ===> Determine which elements in array(subs_nearest) are within near
 	VALID = WHERE( ABS(ARRAY(SUBS_nearest) - values) LE _NEAR,N_VALID, NCOMPLEMENT=NINVALID,COMPLEMENT=INVALID)

  COUNT= N_VALID
; ===> If none of VALUES match _Array
	IF N_VALID EQ 0 THEN BEGIN
		NCOMPLEMENT = sz_array.n_elements
		COMPLEMENT = LINDGEN(sz_array.n_elements)
    RETURN, -1L ;;;
  ENDIF ELSE BEGIN
;		===> Check if original Array had only 1 element
    IF  sz_array.n_elements EQ 1 THEN BEGIN
			count = 1
			NCOMPLEMENT = 0L
			COMPLEMENT = -1L
			RETURN, 0L
		ENDIF ELSE BEGIN ; original Array had more than 1 element
  	  SUBS =  SUBS_NEAREST(VALID)
 			IN=WHERE_IN(LINDGEN(sz_array.n_elements), subs, ncomplement=ncomplement, complement=complement)
 		ENDELSE ; IF  sz_array.n_elements EQ 1 THEN BEGIN
  ENDELSE ; IF N_VALID EQ 0 THEN BEGIN
  RETURN, SUBS


END; #####################  End of Routine ################################
