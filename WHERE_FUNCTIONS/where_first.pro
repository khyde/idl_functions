; $Id: WHERE_FIRST.PRO.pro $   Oct 4, 2003
;+
;	This Function returns SUBSCRIPTS for the input array which have the FIRST instance of values after sortine
; ok = WHERE_FIRST(Array,Values,Count,NCOMPLEMENT=ncomplement,COMPLEMENT=complement)
;
; OUTPUT:		Subscripts of the Input Array having the FIRST of the Sorted Values
;
; ARGUMENTS:
; 	Array:	Required Input: A scalar or array
; 	Values: Required Input: A scalar or array of Values to find in the Array
;   Count:  Output: The number of Array elements having the FIRST Values
;		(count will be the number of unique (array+Values) elements)
;
;
; KEYWORDS:
;   ncomplement:  Output: The number of Array elements NOT matching any element in Values
;    complement:  Output: The subscripts of Array NOT matching any value in Values array
;
; EXAMPLE:
;		Array = ['EE',			'AA',				'BB',				'CC',				'BB',				'DD',				'AA']
;		Values  = ['20030401','20030502',	'20030501',	'20030504',	'20030503',	'20030505',	'20030504']
;		ok = WHERE_FIRST(Array,Values,Count,NCOMPLEMENT=ncomplement,COMPLEMENT=complement)
;
;		PRINT,count
;		PRINT,array(ok)
;
;		PRINT,'Older Duplicates= ',+NUM2STR(ncomplement)
;		IF ncomplement GE 1 THEN PRINT,array(complement)

;		EXAMPLE (where no duplicates):
;		Array = ['EE',			'AA',				 						'CC',				'BB',				'DD' 				     ]
;		Values  = ['20030401','20030502',							'20030504',	'20030503',	'20030505'       ]
;		ok = WHERE_FIRST(Array,Values,Count,NCOMPLEMENT=ncomplement,COMPLEMENT=complement)
;
;		PRINT,count
;		PRINT,array(ok);
;		PRINT,'Older Duplicates= ',+NUM2STR(ncomplement)
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

 FUNCTION WHERE_FIRST, Array, Values,Count, NCOMPLEMENT=ncomplement,COMPLEMENT=complement
  ROUTINE_NAME='WHERE_FIRST'


; =====> Determine Size,and IDLtypes of Array and Values
  sz_Array 	= SIZE(Array,/struct)
  sz_Values 	= SIZE(Values,/struct)

;	===> Make a subscript index for the array
  index 		= LINDGEN(N_ELEMENTS(Array))

; ===> Sort the Conconcatenated (_Array + Values)
  srt 			= SORT(STRTRIM(Array,2)+STRTRIM(Values,2))
;	===> Rearrange _array and index
  _Array 		= Array(srt)
  _index 		= index(srt)
;	===> Determine uniq of sorted _array (without Values appended)
  U    			=	UNIQ(_Array)

;	===> Sort so subs returned are in the order of the input Array
  S=SORT(_INDEX(U))
  SUBS = _INDEX(U(S))
  count = N_ELEMENTS(SUBS)


  test =REPLICATE(0,N_ELEMENTS(Array))
  test(subs) = 1
;	===> Now Determine the Complement (earliest of any duplicates)
  COMPLEMENT = WHERE(TEST EQ 0,NCOMPLEMENT)

  RETURN, SUBS



END; #####################  End of Routine ################################
