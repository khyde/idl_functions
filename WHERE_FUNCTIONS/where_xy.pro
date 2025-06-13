; $Id: WHERE_XY.pro $
;+
;	This Program Generates a formatted request list for daac of the hrpt target files
; SYNTAX:
;	WHERE_XY, Param1, Param2 [,/KEY1] [,/KEY2] [KEY3=KEY3] )
;	Result = WHERE_XY(Param1, Param2 [,/KEY1] [,/KEY2] [KEY3=KEY3] )
; OUTPUT:
; ARGUMENTS:
; 	Parm1:
; 	Parm2:
; KEYWORDS:
;	KEY1:
;	KEY2:
;	KEY3:
; EXAMPLE:
; CATEGORY:
;	DT
; NOTES:
; VERSION:
;	Jan 01,2001
; HISTORY:
;		Obtained from RSI web site April 26, 2001 	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

 PRO WHERE_XY, array, index, x_location, y_location
  ROUTINE_NAME='WHERE_XY'


                     ;++++++++BEGIN:  Example Procedure++++++++

                     ; Inputs -> array:  array used in previous call to
                     ;                   WHERE.
                     ;           index:  results returned from previous
                     ;                   call to WHERE.
                     ; Outputs -> x_location: column positions of "index".
                     ;            y_location: row positions of "index".

                     ; Determining the parameters of the inputed array.
                     array_size = SIZE(array)
                     x_size = array_size[1]
                     y_size = array_size[2]

                     ; Creating "x" and "y" to map the positions within the
                     ; inputed array.
                     x_array = FINDGEN(x_size) # REPLICATE(1.0, y_size)
                     y_array = REPLICATE(1.0, x_size) # FINDGEN(y_size)

                     ; Using "index" resulting from an earlier call to WHERE
                     ; to determine row and column locations of the inputed
                     ; array.
                     x_location = FIX(x_array[index])
                     y_location = FIX(y_array[index])


END; #####################  End of Routine ################################
