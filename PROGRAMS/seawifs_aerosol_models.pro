; $Id: seawifs_aerosol_models.pro  November 1999 J.E.O'Reilly Exp $

function seawifs_aerosol_models,models,FULL=full, RANK=rank
;+
; NAME:
;       seawifs_aerosol_models
;
; PURPOSE:
;       Return Standard SeaWiFS Aerosol Model Names
;
; CATEGORY:
;       SeaWiFS SEADAS
;
; CALLING SEQUENCE:
;       Result = seawifs_aerosol_models()
;       Result = seawifs_aerosol_models(/full)
;       Result = seawifs_aerosol_models([1,2,3])
;       Result = seawifs_aerosol_models(/rank) ; orders model numbers by increasing slope
;
; INPUTS:
;       models
;
; KEYWORD PARAMETERS:
;       FULL:  Full names
;       RANK:  Ordinates the 12 models from lowest slope (Log(epsilon 7/8) vs wavelength) (Gordon)
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
;       Written by:  J.E.O'Reilly, November, 1999
;-

;  Model Number     Aerosol model
;      1-2	   Oceanic      RH=90% and 99%
;      3-6	   Maritime     RH=50%, 70%, 90%, and 99%
;      7-9	   Coastal      RH=50%, 90%, and 99%
;     10-12	   Tropospheric RH=50%, 90%, and 99%

;
; Ordinating the models according to slope of epsilon vs nm
;  (and resulting decrease in Lwn when using a single fixed aerosol model during
;   atmospheric processing)
; 2       1       6       9       5       8       4       3       7      12      11      10

  IF N_ELEMENTS(MODELS) EQ 0 THEN MODELS = INDGEN(13)

  IF KEYWORD_SET(FULL) THEN BEGIN
   m=[' ','Oceanic 90',    'Oceanic 99',$
         'Maritime 50',   'Maritime 70', 'Maritime 90','Maritime 99',$
         'Coastal 50',    'Coastal 90', 'Coastal 99',$
         'Tropospheric 50','Tropospheric 90','Tropospheric 99']
   ENDIF ELSE BEGIN
   m=[' ','O90',    'O99',$
         'M50',   'M70', 'M90','M99',$
         'C50',    'C90', 'C99',$
         'T50','T90','T99']
   ENDELSE

   IF KEYWORD_SET(RANK) THEN  RETURN, [2,1,6,9,5,8,4,3,7,12,11,10]
   RETURN, M(MODELS)

  END ; OF PROGRAM