; $Id: WHERE_XYZ.pro $
;+
;	This Program Generates a formatted request list for daac of the hrpt target files
; SYNTAX:
;	WHERE_XYZ, Param1, Param2 [,/KEY1] [,/KEY2] [KEY3=KEY3] )
;	Result = WHERE_XYZ(Param1, Param2 [,/KEY1] [,/KEY2] [KEY3=KEY3] )
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

 PRO WHERE_XYZZ, array, index, $
                        x_location, y_location, z_location
  ROUTINE_NAME='WHERE_XYZ'
;++++++++BEGIN:  Example Procedure++++++++

                     ; Inputs -> array:  array used in previous call to
                     ;                   WHERE.
                     ;           index:  results returned from previous
                     ;                   call to WHERE.
                     ; Outputs -> x_location: column positions of "index".
                     ;            y_location: row positions of "index".
                     ;            z_location: layer positions of "index".

                     ; Determining the parameters of the inputed array.
                     array_size = SIZE(array)
                     x_size = array_size[1]
                     y_size = array_size[2]
                     z_size = array_size[3]

                     ; Creating "x" and "y" to map the positions within the
                     ; inputed array.
                     x_array = FLTARR(x_size, y_size, z_size)
                     x_matrix = FINDGEN(x_size) # REPLICATE(1.0, y_size)
                     FOR iz = 0, (z_size - 1) DO x_array[*, *, iz] = x_matrix
                     y_array = FLTARR(x_size, y_size, z_size)
                     y_matrix = REPLICATE(1.0, x_size) # FINDGEN(y_size)
                     FOR iz = 0, (z_size - 1) DO y_array[*, *, iz] = y_matrix
                     z_array = FLTARR(x_size, y_size, z_size)
                     FOR iz = 0, (z_size - 1) DO z_array[*, *, iz] = REPLICATE(iz, x_size, y_size)

                     ; Using "index" resulting from an earlier call to WHERE
                     ; to determine row and column locations of the inputed
                     ; array.
                     x_location = FIX(x_array[index])
                     y_location = FIX(y_array[index])
                     z_location = FIX(z_array[index])


                     ;+++++++++END:  Example Procedure+++++++
END; #####################  End of Routine ################################
