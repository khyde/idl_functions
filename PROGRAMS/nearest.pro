; $ID:	NEAREST.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Function Uses IDL's VALUE_LOCATE to find the indices in Array which match the Values array.
; NEAREST works like IDL's WHERE (but finds multiple items provided by user in the Values)
;
;	Result = NEAREST(Vector, Values)

;	DT
; NOTES:
;  The original order of elements in Array and Values is not changed by this program
;	 IDL's Value_Locate requires at least 2 elements in Array (Vector)
;	 If Array has only one element then this program duplicates _Array to get through Value_Locate

; HISTORY:
;	 May 5, 2003	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION  NEAREST, Array,Values,Count,NCOMPLEMENT=ncomplement,COMPLEMENT=complement, NEAR=NEAR
  ROUTINE_NAME='NEAREST'

;	=====> If NEAR isnot provided then set it to zero with Data Type from Array
  IF N_ELEMENTS(NEAR) EQ 0 THEN BEGIN
    _NEAR = Array[0]
    _NEAR(*) 	= 0
  ENDIF ELSE _NEAR = NEAR

; =====> Determine Size,and IDLtypes of Array and Values
  sz_Array = SIZE(Array,/struct)
  sz_values = SIZE(Values,/struct)

; =====> Ensure that both Array and Values are not empty
  IF sz_Array.n_elements  EQ 0 OR sz_values.n_elements  EQ 0 THEN RETURN, -1L

; =====> Copy Array into _array (_Array must have at least 2 elements to get through VALUE_LOCATE)
  IF sz_array.n_elements EQ 1 THEN _Array = [array,array] ELSE _array = Array

; =====> Sort _Array
  index 		= LINDGEN(N_ELEMENTS(_array))
  srt 			= SORT(_Array)
  _Array 		= _Array(srt)
  index 		= index(srt)

; =====> Copy and Sort Values into _values
  srt 			= SORT(Values)
  _Values 	= values(srt)

;	=====> Get subscripts of the Array elements which are nearest to each element in the Values array
  subs_arr_lower  	= VALUE_LOCATE(_Array, _Values)
  subs_arr_upper    = (subs_arr_lower + 1) < (N_ELEMENTS(_Array)-1L)

  dif_lower = ABS(_ARRAY(subs_arr_lower) - _values)
  dif_upper = ABS(_ARRAY(subs_arr_upper) - _values)
  test_dif  = dif_lower LE dif_upper
  SUBS_nearest = LONARR(N_ELEMENTS(_values))
  OK = WHERE(test_dif EQ 1,COUNT)
  IF COUNT GE 1 THEN SUBS_nearest(OK) = subs_arr_lower(OK)
	OK = WHERE(test_dif EQ 0,COUNT)
  IF COUNT GE 1 THEN SUBS_nearest(OK) = subs_arr_upper(OK)

; =====> Now determine which elements in subs_arr are valid (within NEAR, or exact match)
 	valid = WHERE( ABS(_ARRAY(SUBS_nearest) - _values) LE _NEAR,COUNT_VALID, NCOMPLEMENT=ncomplement,COMPLEMENT=complement)


 ; =====> If none of _Values match _Array then return -1L ;
	IF COUNT_VALID EQ 0 THEN BEGIN
	  COUNT=0
  	ncomplement = sz_Array.n_elements
    complement 	= LINDGEN(ncomplement)
    SUBS= -1L
  ENDIF ELSE BEGIN
;		=====> Check if original Array had only 1 element
    IF  sz_array.n_elements EQ 1 THEN BEGIN
			subs = 0L
			count = 1
			ncomplement = 0L
      complement 	= -1L
		ENDIF ELSE BEGIN
  		subs_valid = SUBS_nearest(valid)
  		SUBS=INDEX(subs_valid)
  		c = LONARR(N_ELEMENTS(_ARRAY))
   		c(subs) = 1

 			S=SORT(SUBS) & SUBS=SUBS(S) & U=UNIQ(SUBS) & SUBS=SUBS(U)
    	count=N_ELEMENTS(SUBS)


   		COMPLEMENT=WHERE(c NE 1,ncomplement)
   	ENDELSE
  ENDELSE
  RETURN, SUBS



END; #####################  End of Routine ################################
