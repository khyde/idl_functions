; $ID:	COORD_2PLOT.PRO,	JULY 18 2005, 10:36	$
;+
;	This Program Converts Relative Position within the Plot Window [(0 to 1.0),(0 to 1.0)] to coordinates within Plot Window
;
;	EXAMPLES:
;		Result = COORD_2PLOT(0.8,0.8)
;		Result = COORD_2PLOT(0.8,0.8,/TO_DATA)
;		Result = COORD_2PLOT(0.8,0.8,/TO_NORMAL)
;
; OUTPUT:
;	 Coordinates within the Plot Window
; ARGUMENTS:
; 	X:	X coordinate in Relative Units (0 to 1.0)
;		Y:	Y coordinate in Relative Units (0 to 1.0)
; KEYWORDS:
;		SEE IDL CONVERT_COORD
; HISTORY:
;	Feb 10,2001	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

	FUNCTION COORD_2PLOT, X, Y,Z,  TO_DATA=to_data,TO_NORMAL=to_normal,TO_DEVICE=to_device, ERROR=error

  ROUTINE_NAME='COORD_2PLOT'
  ERROR = 0

; ================> Get plot window (normal)
  plot_window_x = !X.WINDOW
  plot_window_y = !Y.WINDOW

  IF N_ELEMENTS(X) EQ 0 OR N_ELEMENTS(Y) EQ 0 OR N_ELEMENTS(X) NE N_ELEMENTS(Y) THEN BEGIN
    PRINT,'ERROR: Must provide X,Y  OR X,Y,Z Normal coordinates'
  ENDIF

	N = TOTAL( [N_ELEMENTS(TO_DATA),N_ELEMENTS(TO_NORMAL),N_ELEMENTS(TO_DEVICE)])
	IF N GE 2 THEN BEGIN
		PRINT,'ERROR: Provide only one output unit: TO_DATA,TO_NORMAL,TO_DEVICE'
		ERROR=1
		RETURN,-1
	ENDIF

	IF N EQ 0 THEN 	DATA=1 ; Because default for XYOUTS is DATA units

; ===> Adjust Input Relative coordinates to PLOT WINDOW
	XX=(!X.WINDOW(1)-!X.WINDOW(0))*X + !X.WINDOW(0)
  YY=(!Y.WINDOW(1)-!Y.WINDOW(0))*Y + !Y.WINDOW(0)

  IF N_ELEMENTS(Z) EQ N_ELEMENTS(X) THEN BEGIN
  	ZZ=(!Z.WINDOW(1)-!Z.WINDOW(0))*Z + !Z.WINDOW(0)
 		xyz=CONVERT_COORD(XX,YY,ZZ,/NORMAL ,TO_DATA=to_data,TO_NORMAL=to_normal,TO_DEVICE=to_device)
		XX = REFORM(xyz(0,*))
  	YY = REFORM(xyz(1,*))
  	ZZ = REFORM(xyz(2,*))
  	RETURN, CREATE_STRUCT('X',XX,'Y',YY,'Z',ZZ)
	ENDIF ELSE BEGIN
;		===> Convert Plot Window Coordinates to selected output units
  	xyz=CONVERT_COORD(XX,YY,/NORMAL ,TO_DATA=to_data,TO_NORMAL=to_normal,TO_DEVICE=to_device)
  	XX = REFORM(xyz(0,*))
  	YY = REFORM(xyz(1,*))
  	RETURN, CREATE_STRUCT('X',XX,'Y',YY )
	ENDELSE
; ===> Return a structure with x,y in selected output units for the plot window


 DONE:

END; #####################  End of Routine ################################
