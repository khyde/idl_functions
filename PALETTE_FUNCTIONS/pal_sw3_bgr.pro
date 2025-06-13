; $Id:	pal_sw3.pro,	December 12 2006	$

	PRO PAL_SW3_BGR ,R,G,B

;+
; NAME:
;		PAL_SW3
;
; PURPOSE:;
;		This Program provides the Red,Green,and Blue Intensities for the O'Reilly SeaWiFS Rainbow Palette
;
;
; CATEGORY:
;		PALETTE
;
; CALLING SEQUENCE:
;		PAL_SW3       ; will load the R G B using TVLCT
;
;		PAL_SW3, r,g,b  ; will also provide the red,green,blue intensities for the palette
;
; INPUTS:
;		NONE
;
; OUTPUTS:
;		R: The Red Intensities (0-255)
;		G: The Green Intensities (0-255)
;		B: The Blue Intensities  (0-255)
;
; EXAMPLE:
;		Image = BYTSCL(DIST(512)) & PAL_SW3,R,G,B & WRITE_PNG,'test.png',Image,r,g,b
;	NOTES:
;
;
; MODIFICATION HISTORY:
;		Written Sept, 2002 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'PAL_SW3_BGR'


	R=BYTARR(256) & G=BYTARR(256) & B=BYTARR(256)

	R(  0)=  0 & G(  0)=  0 & B(  0)=  0 &
	R(  1:82)  = 0   & G(  1:82)  = 7   & B(  1:82)  = 254
	R( 83:166) = 11  & G( 83:166) = 255 & B( 83:166) = 0
	R(167:249) = 255 & G(167:249) = 22  & B(167:249) = 0
	R(    250) = 255 & G(    250) =  0  & B(    250)=255
	R(    251) = 128 & G(    251) = 128 & B    (251)=128
	R(    252) = 160 & G(    252) = 160 & B(    252)=160
	R(    253) = 192 & G(    253) = 192 & B(    253)=192
	R(    254) = 224 & G(    254) = 224 & B(    254)=224
	R(    255) = 255 & G(    255) = 255 & B(    255)=255

	TVLCT,R,G,B

END; #####################  End of Routine ################################

