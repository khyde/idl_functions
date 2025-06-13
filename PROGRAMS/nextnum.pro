; $Id: NEXTNUM.pro, MARCH 15,1999J.E.O'Reilly Exp $

function NEXTNUM,num
;+
; NAME:
;       NEXTNUM
;
; PURPOSE:
;       Determine the next highest number (for plotting axis etc)
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       Result = NEXTNUM(a)
;
; INPUTS:
;       A NUMBER
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, March 15,1999
;-

   E = STRING(NUM,FORMAT='(E)')

   POS = STRPOS(E,'E')
   EE  = STRMID(E,POS,5)
   next = FIX(E) + 1
   CMD = 'NEXT = ' + NUM2STR(NEXT) + EE
   A = EXECUTE(CMD)

   RETURN,NEXT


   END