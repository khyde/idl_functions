; $ID:	GET_TAGS.PRO,	2015-11-15	$
;VIEWING CONTENTS OF FILE '../IDLLIB/CONTRIB/FANNING/GET_TAGS.PRO'
FUNCTION ALL_TAGS, STRUCTURE, ROOTNAME

  ; THIS IS A FUNCTION THAT RECURSIVELY SEARCHES THROUGH
  ; A STRUCTURE TREE, FINDING ALL OF THE STRUCTURE'S FIELD NAMES.
  ; IT RETURNS A POINTER TO AN ARRAY OF POINTERS, EACH POINTING
  ; TO THE NAMES OF STRUCTURE FIELDS.

  IF N_ELEMENTS(ROOTNAME) EQ 0 THEN ROOTNAME = '.' ELSE $
    ROOTNAME = STRUPCASE(ROOTNAME) + '.'
  NAMES = TAG_NAMES(STRUCTURE)
  RETVALUE = PTR_NEW(ROOTNAME + NAMES)

  ; IF ANY OF THE FIELDS ARE STRUCTURES, REPORT THEM TOO.

  FOR J=0,N_ELEMENTS(NAMES)-1 DO BEGIN
    OK = EXECUTE('S = SIZE(STRUCTURE.' + NAMES[J] + ')')
    IF S[S[0]+1] EQ 8 THEN BEGIN
      NEWROOTNAME = ROOTNAME + NAMES[J]
      THESENAMES = CALL_FUNCTION('ALL_TAGS', $
        STRUCTURE.(J), NEWROOTNAME)
      RETVALUE = [[RETVALUE],[THESENAMES]]
    ENDIF
  ENDFOR

  RETURN, RETVALUE
END
;-------------------------------------------------------------------



FUNCTION GET_TAGS, STRUCTURE, ROOTNAME

  ; THIS FUNCTION RETURNS THE NAMES OF ALL STRUCTURE FIELDS
  ; IN THE STRUCTURE AS A STRING ARRAY. THE NAMES ARE GIVEN
  ; AS VALID STRUCTURE NAMES FROM THE ROOT STRUCTURE NAME,
  ; WHICH CAN BE PASSED IN ALONG WITH THE STRUCTURE ITSELF.

  ON_ERROR, 1

  ; CHECK PARAMETERS.

  CASE N_PARAMS() OF

    0: BEGIN
      MESSAGE, 'STRUCTURE ARGUMENT IS REQUIRED.'
    ENDCASE

    1: BEGIN
      ROOTNAME = ''
      S = SIZE(STRUCTURE)
      IF S[S[0]+1] NE 8 THEN $
        MESSAGE, 'STRUCTURE ARGUMENT IS REQUIRED.'
    ENDCASE

    2: BEGIN
      S = SIZE(STRUCTURE)
      IF S[S[0]+1] NE 8 THEN $
        MESSAGE, 'STRUCTURE ARGUMENT IS REQUIRED.'
      S = SIZE(ROOTNAME)
      IF S[S[0]+1] NE 7 THEN $
        MESSAGE, 'ROOT NAME PARAMETER MUST BE A STRING'
    ENDCASE

  ENDCASE

  TAGS = ALL_TAGS(STRUCTURE, ROOTNAME)

  ; EXTRACT AND FREE THE FIRST POINTER.

  RETVAL = [*TAGS[0,0]]
  PTR_FREE, TAGS[0,0]

  ; EXTRACT AND FREE THE THE REST OF THE POINTERS.

  S = SIZE(TAGS)
  FOR J=1,S[2]-1 DO BEGIN
    RETVAL = [RETVAL, *TAGS[0,J]]
    PTR_FREE, TAGS[0,J]
  ENDFOR
  PTR_FREE, TAGS

  ; RETURN THE STRUCTURE NAMES.

  RETURN, RETVAL
END


; MAIN-LEVEL PROGRAM TO EXERCISE GET_TAGS.

D = {DOG:'SPOT', CAT:'FUZZY'}
C = {SPOTS:4, ANIMALS:D}
B = {FAST:C, SLOW:-1}
A = {CARS:B, PIPEDS:C, OTHERS:'MAN'}
TAGS = GET_TAGS(A)
S = SIZE(TAGS)
FOR J=0,S[1]-1 DO PRINT, TAGS[J]
END
