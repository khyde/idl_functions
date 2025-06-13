; $Id:	where_in.pro,	January 26 2011	$
;+
;	This Function works like IDL's WHERE but finds elements in the array matching multiple values
; WHERE_IN Uses IDL's VALUE_LOCATE to find the indices in Array which match the Values array.
; WHERE_IN finds all elements in Array which Exactly Match Any Elements in Value
;
;	ok = WHERE_IN(Array,Values,Count,NCOMPLEMENT=ncomplement,COMPLEMENT=complement)
; OUTPUT:		Subscripts of Array matching any value in Values array
; ARGUMENTS:
; 	Array:	Required Input: A scalar or array
; 	Values: Required Input: A scalar or array of Values to find in the Array
;   Count:  Output: The number of Array elements matching any element in Values


; KEYWORDS:
;   ncomplement:  Output: The number of Array elements NOT matching any element in Values
;    complement:  Output: The subscripts of Array NOT matching any value in Values array
;
; EXAMPLE:
;		ARRAY=['ZEBRA','CAT','BIRD','CAT','BIR','CAT','BIRD','CAT','BIRD','DOG','CAT']
;		VALUES = ['DOG','BIRD']
;		PRINT, ARRAY,VALUES
;		OK=WHERE_IN(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement)
;		PRINT,'FOUND '+NUM2STR(COUNT)
;		IF COUNT GE 1 THEN PRINT, Array(ok)
;		PRINT,'NOT FOUND '+NUM2STR(ncomplement)
;		IF ncomplement GE 1 THEN PRINT,array(complement)
;

; NOTES:
;  The original order of elements in Array and Values is not changed by this program
;	 The subscripts returned refer to the original input array order

;
; HISTORY:
;	 May 5, 2003	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION WHERE_IN, Array,Values,Count,NCOMPLEMENT=ncomplement,COMPLEMENT=complement
  ROUTINE_NAME='WHERE_IN'

; =====> Determine Size,and IDLtypes of Array and Values
  sz_Array = SIZE(Array,/struct)
  sz_values = SIZE(Values,/struct)

; =====> Ensure that both Array and Values are not empty
  IF sz_Array.n_elements  EQ 0 OR sz_values.n_elements  EQ 0 THEN BEGIN
    COUNT = 0
    RETURN, []     ; Removed RETURN, -1 to be compatible with IDL 8.1 - may not be compatible with ealier versions of IDL
  ENDIF  

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

;	=====> Get subscripts of Array elements nearest to each element in the Values array
  subs_arr 		= VALUE_LOCATE(_Array, _Values)

; =====> Now determine which elements in subs_arr are valid
  valid	 = WHERE(_Array(subs_arr) EQ	_Values 				, count)

; =====> If none of _Values match _Array then return -1L ;
	IF count EQ 0 THEN BEGIN
	  subs = -1L
  	ncomplement = sz_Array.n_elements
    complement 	= LINDGEN(ncomplement)
    RETURN,subs
  ENDIF ELSE BEGIN
   	subs_valid = subs_arr(valid)

;		=====> Determine subscripts of _array within _array
	 	subs_arr_arr = VALUE_LOCATE(_array,_array)

;		=====> If subs_valid has only 1 element then duplicate (to get through VALUE_LOCATE)
  	IF N_ELEMENTS(subs_valid) EQ 1 THEN _subs_valid = [subs_valid,subs_valid] ELSE _subs_valid = subs_valid


;		=====> Locate subscript in _subs_valid that match subscripts in subs_arr_arr
  	subs_subs = VALUE_LOCATE(_subs_valid,subs_arr_arr)

  	subs 			= WHERE(_subs_valid(subs_subs) EQ subs_arr_arr,count,ncomplement=ncomplement,COMPLEMENT=complement)

;		=====> Check if original Array had only 1 element
    IF N_ELEMENTS(subs) EQ 2 AND sz_array.n_elements EQ 1 THEN BEGIN
      subs=subs(0) & count = 1 & INDEX = 0L
    ENDIF

;		=====> Sort subscripts in ascending order (original order of input Array)
    IF ncomplement GE 1 THEN BEGIN
     	complement = INDEX(complement)
     	S=SORT(complement) & complement=complement(s)
    ENDIF
		IF COUNT GE 1 THEN BEGIN
    	SUBS=INDEX(subs)
    	S=SORT(SUBS) & SUBS=SUBS(S)
    ENDIF
  	RETURN, SUBS
  ENDELSE

END; #####################  End of Routine ################################
