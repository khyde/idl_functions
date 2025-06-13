PRO TRIGRID_DEMO

; Make 50 normal x, y points:
x = RANDOMN(seed, 50)
y = RANDOMN(seed, 50)

; Make the Gaussian:
z = EXP(-(x^2 + y^2))

; Show points:
PLOT, x, y, psym=1
in=' '
READ,"Press enter",in

; Obtain triangulation:
TRIANGULATE, x, y, tr, b

; Show the triangles:
FOR i=0, N_ELEMENTS(tr)/3-1 DO BEGIN & $
   ; Subscripts of vertices [0,1,2,0]:
   t = [tr[*,i], tr[0,i]] & $
   ; Connect triangles:
   PLOTS, x[t], y[t] & $
ENDFOR

; Show linear surface:
SURFACE, TRIGRID(x, y, z, tr)
in=' '
READ,"Press enter",in

; Show smooth quintic surface:
SURFACE, TRIGRID(x, y, z, tr, /QUINTIC)
in=' '
READ,"Press enter",in

; Show smooth extrapolated surface:
SURFACE, TRIGRID(x, y, z, tr, EXTRA = b)
in=' '
READ,"Press enter",in

; Output grid size is 12 x 24:
SURFACE, TRIGRID(X, Y, Z, Tr, NX=12, NY=24)
in=' '
READ,"Press enter",in

; Output grid size is 20 x 11. The X grid is
; [0, .1, .2, ..., 19 * .1 = 1.9].  The Y grid goes from 0 to 1:
SURFACE, TRIGRID(X, Y, Z, Tr, [.1, .1], NX=20)
in=' '
READ,"Press enter",in

; Output size is 20 x 40.  The range of the grid in X and Y is
; specified by the Limits parameter.  Grid spacing in X is
; [5-0]/(20-1) = 0.263.  Grid spacing in Y is (4-0)/(40-1) = 0.128:
SURFACE, TRIGRID(X, Y, Z, Tr, [0,0], [0,0,5,4],NX=20, NY=40)
in=' '
READ,"Press enter",in

WDELETE

END