; $ID:	UPKWHERE.PRO,	2020-07-08-15,	USER-KJWH	$
;+NAME\ONE LINE DESCRIPTION OF ROUTINE:
;    UPKWHERE unpacks a 'where' vector into cube,level,col,row.
;
; DESCRIPTION:
;     Takes the result of any 'where' type operation and unpacks
;     it into the equivalent 'cube','level','col','row' format.
;
; CALLING SEQUENCE:
;     UPKWHERE,Inarray,Where_vector,vec1,vec2 [,vec3,vec4]
;
; ARGUMENTS (I = input, O = output, [] = optional):
;     Inarray        I   arr      Array which was operated on by the
;                                 where function to give the
;                                 'Where_vector'
;     Where_vector   I   arr      The result of the 'where' operation
;     Vec1,Vec2,..   O   arr      Depends on the dimensions of
;                                 'Inarray'. Two to four vectors will
;                                 be returned. If inarray is 2-D,then
;                                 vec1 gives the coloumn indices and
;                                 vec2 the rows, if 3-D, vec1 is the
;                                 level, vec2 the col and vec3 the
;                                 rows... etc.
;
; WARNINGS:
;     This procedure can only handle up to four dimensions.
;
; EXAMPLE:
;     x = intarr(10,10) & x(2:4,2)=1 & x(5,6:8)=1
;     select = where(x gt 0)
;     print,select
;          22          23          24          65          75          85
;     upkwhere,x,select,i,j
;     print,i
;           2           3           4           5           5           5
;     print,j
;           2           2           2           6           7           8
;
;#
; COMMON BLOCKS:
;     None.
;
; PROCEDURE (AND OTHER PROGRAMMING NOTES):
;     None.
;
; PERTINENT ALGORITHMS, LIBRARY CALLS, ETC.:
;     None.
;
; MODIFICATION HISTORY:
;     Written: 	William H. Daffer, ST Systems, Inc, June 1991
;     Mod:      Franz, February 1993, changed name from UPACK_WHERE
;
;.title
;Routine UPKWHERE
;-
pro upkwhere,inarray,where_vector,vec1,vec2,vec3,vec4
on_error,2	; on error, return to caller

s = size(inarray) ; Get the dimensions of inarray

case 1 of

  s[0] eq 2 : begin
    ncol = s[1]
    nrow = s(2)
    vec1 = where_vector mod ncol                      ; The Coloumns
    vec2 = where_vector / ncol                        ; The Rows
  end

  s[0] eq 3 : begin
    nlev = s[1]
    ncol = s(2)
    nrow = s(3)
    vec1 = where_vector mod nlev                      ; The Levels
    vec2 = ( where_vector / nlev ) mod ncol           ; The Coloumns
    vec3 = where_vector / ( nlev*ncol )               ; The Rows
  end

  s[0] eq 4 :  begin
    ncube = s[1]
    nlev  = s(2)
    ncol  = s(3)
    nrow  = s(4)
    vec1  = where_vector mod ncube                    ; The Cubes
    vec2 = ( where_vector / ncube ) mod nlev          ; The Levels
    vec3 = where_vector / ( nlev*ncube ) mod ncol     ; The Coloumns
    vec4 = where_vector / (ncube*nlev*ncol)	      ; The Rows
  end

  else: begin
    message,'Can only handle 2 to 4 dimensions.',/cont
  end
endcase

return
end
