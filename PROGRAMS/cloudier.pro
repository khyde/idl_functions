; $Id: cloudier.pro,v 1.3 1997/02/18 12:00:00 J.E.O'Reilly  Exp $

  PRO CLOUDIER, FILES=files, IMAGE=image, MASK=mask, BOX=BOX, X0=X0, Y0=Y0, CLOUDS=CLOUDS, IN_EXT=IN_EXT, OUT_EXT=OUT_EXT, QUIET=quiet

; =======================================>
;+
; NAME:
;               CLOUDIER
; PURPOSE:
;         Program uses IDL Dilate command to enlarge the areas
;         of the image covered by clouds, ensuring that cloud edges are masked.
;         Displays the original and dilated images side by side in a scroll window.
;         Writes dilated image to an output image file (use optional keyword out_ext).
;
; CATEGORY:
;       Image
;
; CALLING SEQUENCE:
;
;       cloudier                                           ; centers dilation box on cloud pixel
;       cloudier, clouds = 0                               ; dilates grey values of 0
;       cloudier, clouds = 255                             ; dilates grey values of 255
;       cloudier,files='testimg.dsp', box=3                ; centers dilation box on cloud pixel
;       cloudier,files='testimg.dsp', box=3, x0=1, y0=1    ; centers dilation box on cloud pixel
;       cloudier,files='testimg.dsp', box=5                ; centers dilation box on cloud pixel
;       cloudier,files='testimg.dsp', box=5, x0=2, y0=2    ; centers dilation box on cloud pixel
;       cloudier,files='i7*.dsp',     box=[11,1],x0=1,y0=0 ; Masks 1 pixel to left and 10 to right of cloud pixel
                                                           ; (making a total of 11 pixels wide)

;       cloudier,files='i7*.dsp',     box=[5,5], out_ext='msk' ; Makes an output file with 'msk' extension
;       cloudier,files='i7*.dsp',     box=7,x0=3, y0=3, clouds=255, out_ext='msk',/QUIET
;                                                           Quiet keyword suppresses print
;
;   cloudier,image=image            ; pass an image array directly to the program
;   cloudier, image=image,mask=mask ; pass an image array and return the cloud mask array
;
; INPUTS:
;       DSP image FILES or IMAGE array.
;       If no keywords supplied then program
;         prompts for a single file (PICKFILE.PRO)
;         and assumes the following default values:
;         BOX=3,CLOUDS=0, X0=1,Y0=1 ; center cloud mask on cloud pixel
;
;         PROGRAM calls IDL (J.O'R) programs:
;
;         PARSE_IT.PRO   ; Extracts full name, directory, name, and extension from file
;         READ_DSP.PRO   ; Reads a Miami DSP formatted file (see restrictions below).
;
;
; KEYWORDS:
;    FILES:   Path and Name(s) of DSP Image
;             files (inside paired single or
;             double quotes).
;             Can use wild cards (*) for input
;             of multiple file.
;             If no file name is supplied then
;             PICKFILE.PRO
;             prompts user for a single file.
;
;    BOX:     Width or [width,length] of box (in pixels) used to
;             dilate the cloud mask.
;             Note: for a symmetrical dilation use odd values for box (3,5,7,9,11).
;
;    CLOUDS:  Count (color: 0 to 255) representing cloud
;             pixels in the DSP image.
;
;    IN_EXT:  Extension name of input files
;           This allows user to filter files to a subset, after targeting an entire directory
;             when using the keyword: FILES= '     '
;
;    OUT_EXT: Output File Extension (inside single or double quotes).
;             This keyword must be provided to generate
;             output image files.
;             Output image files are created using
;             the image directory and image name plus the
;             output extension provided by user in OUT_EXT.
;
;     QUIET:  Suppresses program messages (print) and
;             graphics display during program execution (batch mode).
;
;     OUTPUTS:
;             Dilated Cloud mask is displayed.
;             New image files are generated if keyword OUT_EXT is provided.
;             A cloud mask of 0's and 1's (clouds) is passed from cloudier to IDL if keyword MASK is provided.
;
; SIDE EFFECTS:
;             None.
;
; RESTRICTIONS:
;             Input image files must be DSP  with 3(512bytes) header bytes,
;             followed by, any number of image bytes, followed by any number of  tail bytes.
;
;             Or, the input image file must be exactly 512x512 bytes with no header or tail
;             (i.e. a 512x512 image saved using savenohead in dsp).
;
; COMMON BLOCKS:
;             None.
;
; MODIFICATION HISTORY:
;  November 2,1994: Written By J.E.O'Reilly
;         NOAA, NMFS, Narragansett Laboratory,
;         28 Tarzwell Drive, Narragansett, RI 02882-1199
;         oreilly@fish1.gso.uri.edu
;
;                   NOAA, NMFS, Narragansett, RI
;  November 7,1994: Uses read_dsp.pro to input image files.
;  January  8,1995: Added additional program documentation.
;  January 31,1995: Uses SLIDE_IMAGE.PRO when only one
;                   image file is being examined and
;                   PICKFILE() is called.
;                   Image file name is displayed
;                   in graphics window.
;  October 2,1995:  Made input of keyword BOX 1,or 2 dimensions
;             Added keywords X0 and Y0 to allow user to specify
;           the row,column origin of the structuring element of the dilate operator.
;           Added keyword IMAGE, which permits an image array to be passed to program,
;           the name of an image file.
;  December 6,1995: If keyword X0 not supplied by user then assume X0 is dilation box width/2
;                   If keyword Y0 not supplied by user then assume Y0 is dilation box height/2
;                   (This centers the dilation box on the cloud pixel)
;
;  December 8,1995: Checks that dilation mask origin (x0 and y0) are inside the dilation mask.
;                   Prints out dilation mask dimensions and x0,y0
;                   Prints out graphical representation of cloud pixel and surrounding pixels
;                   which will be changed to clouds.
;  February 18,1997 Changed graphical representation of cloud pixel and surrounding pixels when
;                   box height is 1
;
;  IDL commands       are (usually) in UPPER CASE
;  Program variables  are (usually) in lower case
;  END OF PROGRAM DOCUMENTATION
;-

  ROUTINE_NAME = 'CLOUDIER'
  COMPILE_OPT IDL2

;  ====================>
; Get device window size for resetting device size after program completion
   x_size= !d.x_size & y_size=!d.y_size

;  ====================>
;  Evaluate Keyword BOX and generate default parameters for BOX
   IF KEYWORD_SET(box) THEN BEGIN
     IF N_ELEMENTS(BOX) EQ 1 THEN box = [box,box]
     IF N_ELEMENTS(BOX) GE 3 THEN   MESSAGE,"ERROR: box must have 1,or 2 dimensions"
   ENDIF ELSE BEGIN
     box = [3,3]
   ENDELSE

; ====================>
; Check values of KEYWORDS X0 and Y0
; If the user does not supply X0 then make X0 the middle of the dilation box width
  IF N_ELEMENTS(X0) EQ 0 THEN x0 = box[0]/2

; If the user does not supply Y0 then make Y0 the middle of the dilation box height
  IF N_ELEMENTS(Y0) EQ 0 THEN y0 = box[1]/2  ;

; =====================>
; Check whether the origin of the dilation box (x0,y0) is inside the dilation box
  IF X0 LT 0 OR X0 GE BOX[0] THEN MESSAGE,'ERROR: Parameter X0 is outside dilation box, Try again'
  IF Y0 LT 0 OR Y0 GE BOX[1] THEN MESSAGE,'ERROR: Parameter Y0 is outside dilation box, Try again'

  IF KEYWORD_SET(quiet) EQ 0 THEN BEGIN
    PRINT, ' '
    PRINT, 'Dilation Box width:      ',STRTRIM(box[0],2),' pixels '
    PRINT, 'Dilation Box height:     ',STRTRIM(box[1],2),' pixels '
    PRINT, 'Dilation Box X-offset is ',STRTRIM(x0,2),' pixels '
    PRINT, 'Dilation Box Y-offset is ',STRTRIM(y0,2),' pixels '


  IF box[1] GT 1 THEN BEGIN
    txt = strarr(box[0],box[1])
    txt[*] = 'x'
    txt[x0,y0]='C'
  ENDIF ELSE BEGIN
    txt = STRARR(box[0])
    txt[*] = 'x'
    txt[x0]='C'
  ENDELSE



  PRINT, ' '
  PRINT, 'Graphical Representation of the Cloud Dilation Mask:'
  PRINT, 'The Cloud Pixel is represented by C'
  PRINT, 'The ', STRTRIM((N_ELEMENTS(txt)-1),2),' Surrounding Pixels (x) will be Changed to Clouds'
  PRINT, ' '
  PRINT, ROTATE(txt,7)
  PRINT, ' '
  ENDIF

;  ====================>
;  Check if user supplied grey value for clouds
   IF KEYWORD_SET(clouds) THEN BEGIN
     IF (clouds LE 255 AND clouds GE 0) THEN cld=clouds ELSE cld = 0
   ENDIF ELSE BEGIN
     cld = 0
   ENDELSE

   IF KEYWORD_SET(IMAGE) EQ 0 THEN BEGIN
     IF KEYWORD_SET(files) EQ 0 THEN BEGIN
       files = PICKFILE(/READ)
     ENDIF ELSE BEGIN
       files = FINDFILE(files)
       IF N_ELEMENTS(files) EQ 1 AND STRMID(FILES[0],0,1) EQ '' THEN $
          MESSAGE,'ERROR: No files found, Try Again'
     ENDELSE

     IF KEYWORD_SET(in_ext) THEN BEGIN
       fname = parse_it(files)
     ok = WHERE(fname.ext EQ in_ext, count)
       IF count GE 1 THEN files = files[OK]
       IF count EQ 0  THEN $
          MESSAGE,'ERROR: No files found with the IN_EXT you provided, Try Again'
     ENDIF
   ENDIF ; IF KEYWORD_SET(IMAGE) EQ 0 THEN BEGIN


;  ====================>
;  Check if user wants output files
   IF KEYWORD_SET(out_ext) NE 0 THEN BEGIN
     output_extension = out_ext
   ENDIF

;  ====================>
;  Create a  matrix of dimension (box*box) and fill it with one's
   box_of_ones = REPLICATE(1,box[0],box[1])

;  ====================>
;  If the user passed an image array to program then change to current directory
;  and generate a dummy file name 'image.dsp' for the program to execute properly.
   IF KEYWORD_SET(IMAGE) THEN BEGIN
     CD, CURRENT=DIR
     files=DIR+'\'+'image.dsp'
     s=size(image) & px=s[1] & py=s[2]
   ENDIF

;  ====================>
;  ====================>
;  Loop for each of the files
   FOR _files = 0, (N_ELEMENTS(files)-1) DO BEGIN


;    =====================>
;    Run function PARSE_IT.PRO (J.O'Reilly) to extract
;    directory, name, extension,  from file into a structure (filename)
     file = files[_files]
     fname = parse_it(file)

;    =====================>
;    If an image array is  passed to program then do not run read_dsp
     IF KEYWORD_SET(IMAGE) THEN BEGIN
       image_original = image
       GOTO,SKIP_READ_DSP
     ENDIF
;     ====================>
;    Run IDLprogram READ_DSP.PRO (J.O'Reilly)
     READ_DSP,FILE=FILE,HEAD=HEAD,IMAGE=IMAGE_ORIGINAL, TAIL=TAIL,PX=PX,PY=PY,/QUIET
     IF KEYWORD_SET(quiet) EQ 0 THEN $
       PRINT,  '<DIR> ',fname.dir,'  <IMAGE> ',fname.name,' <EXT>  ',fname.ext,$
       px,'x',py,' Pixels', FORMAT='(6A,I5,A2,I5,A)'

     SKIP_READ_DSP:

;    ====================>
;    Make a copy of the image
     image_copy = image_original

;    ====================>
;    Make a binary (0's and 1's) mask with 1's where there are clouds
     mask = image_copy EQ cld

;    ====================>
;    Grow the Clouds using IDL Function DILATE
     cloudier = DILATE(mask,box_of_ones,X0,Y0)

;    ====================>
;    If keyword mask is present, then place new cloud mask into variable MASK
     IF KEYWORD_SET(MASK) THEN MASK = cloudier

;    ====================>
;    Check if any cloud pixels present in dilated cloud mask
     cloud_pixels = WHERE(cloudier eq 1,count)

     IF count GE 1 THEN BEGIN  ;  If there is at least 1 pixel identified as cloud then:
       image_copy[cloud_pixels] = cld
     ENDIF ELSE BEGIN
       PRINT, 'NO CLOUDS (values of ',cld,') IN FILE: ', file,$
       FORMAT = '(A,I4,A,A)'
     ENDELSE

;    ====================>
;    View 'before' and 'after' images (image and image_copy)
     IF KEYWORD_SET(quiet) EQ 0 THEN BEGIN

  ;   Open Graphics window and size it to px,py
  ;    slide_image ,[IMAGE_ORIGINAL,IMAGE_COPY], /ORDER,/REGISTER,$

    slide_image ,[IMAGE_ORIGINAL,IMAGE_COPY],           /REGISTER,$
      xsize=2*px, ysize=py, XVISIBLE=1024,yvisible=512, $
      show_full=0,full_window= full, slide_window=win,$
      TITLE=' Original       '+fname.name +'      Dilated'
     ENDIF

;    ====================>
;    Output an dilated image file ?
     IF KEYWORD_SET(out_ext) THEN BEGIN
;      Write output file
       cloudier_file =fname.dir+fname.name+'.'+ output_extension
       IF KEYWORD_SET(quiet) EQ 0 THEN PRINT,'Writing Image File:    ',cloudier_file
       OPENW,   lun, cloudier_file,/GET_LUN
       IF N_ELEMENTS(head) GE 2 THEN WRITEU,  lun, head
       WRITEU,  lun, image_copy
       IF N_ELEMENTS(tail)  GE 2 THEN WRITEU,  lun, tail
       CLOSE,   lun
       FREE_LUN,lun
     ENDIF

   ENDFOR ; (FOR _FILES = 0, (N_ELEMENTS(FILES)-1) DO BEGIN)
;  ====================>
;  ====================>
;  End of Loop for each of the files

   IF KEYWORD_SET(quiet) EQ 0 THEN BEGIN
     PRINT,'End of Program Cloudier.pro'
   ENDIF

  END ; End of Program
; ===================>

