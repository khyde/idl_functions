; $Id: mk_help.pro,v 1.0 1995/1/31 10:00:00 J.O'Reilly Exp $        
     
pro mk_help       
;+        
; NAME:        
;       mk_help        
;        
; PURPOSE:        
;       This program runs mk_library_help.pro       
;       to make a help file (*.hel) for idl       
;       on-line help.       
;       The help file contains a listing of       
;       program documentation (everything       
;       between ';+'  and ';-  ).       
;       The help file is placed in the        
;       directory 'dir'        
;        
; CATEGORY:        
;       Misc.        
;        
; CALLING SEQUENCE:        
;       mk_help       
;        
; INPUTS:        
;       DIR   The full name of the       
;             directory to search       
;             for *.pro files and       
;             their documentation.       
; OUTPUTS:        
;       A *.hel file is written to       
;       the directory which is       
;       supplied by the user.       
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
;       Written by:     J.E. O'Reilly , January, 1995.        
;-       
  
;  ===========================>  
  a = PICKFILE(filter='*.pro',$      
               title='Pick Any File ... in this or any other directory')    
  fname = parse_it(a)    
  hel = fname.dir + fname.sub +  '.hel'    
  mk_library_help,fname.dir,hel      
  PRINT,' Making help file: ',hel           
  print, 'Program mk_help finished'  
        
  End  ; end of program       
