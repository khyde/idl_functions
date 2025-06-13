PRO PLOT_DIM,FILE=FILE,THICK=THICK,LINESTYLE=LINESTYLE,COLOR=COLOR,LIST=LIST   
;  October 25,1994         
;  Revised Nov 2,1994         
               
;  J.E.O'Reilly, NOAA, NMFS, Narragansett, RI                 
;  Program reads and plots   
;  DSP '*.DIM' Files   
          
;  ________________________________________________              
;  NOTES          
;  IDL commands       are usually in UPPER CASE        
;  Program variables  are usually in lower case        
        
;  Program assumes DSP Dim Files are comprised of:          
;  Description Line (first line)        
;  Longitude   space   Latitude  (decimal degrees)   
;  etc to last longitude,latitude record in file   
          
;  _________________________________________________________________        
;  Get a single file using the mouse if      
;  the user does not supply a file=' file name '      
   IF KEYWORD_SET(file) EQ 0 THEN file = PICKFILE(/READ)        
       
   IF KEYWORD_SET(THICK) EQ 0 THEN THICK = 1 
   IF KEYWORD_SET(LINESTYLE) EQ 0 THEN LINESTYLE = 0   
   IF KEYWORD_SET(COLOR) EQ 0 THEN COLOR = 128           
   PRINT, 'Processing DSP DIM File: ' + file                                                                      
;  Create array lonlat(2,9999) to hold long,lat pairs  
   lonlat = fltarr(2,9999)  
  
      
                  
                       
;  ___________________________________________________________          
;  Open and Read the  DSP DIM file          
        
   ATEXT = ' '     
   OPENR,lun,file,/GET_LUN                         
   READF,lun, atext   
   IF KEYWORD_SET(LIST) THEN  PRINT, atext   
   npts = -1  
                                                        
   WHILE NOT EOF(lun) DO BEGIN  
      npts = npts + 1  
      READF,lun,lon,lat  
      IF KEYWORD_SET(LIST) THEN  PRINT, lon,lat         
      lonlat(0,npts)=lon  
      lonlat(1,npts)=lat  
;     PRINT, lonlat(0,npts)  
;     PRINT, lonlat(1,npts) 
   ENDWHILE  
     
if (!x.type NE 2) THEN message,'Map transform not established.'     
   PLOTS,lonlat(0,0:npts),lonlat(1,0:npts),thick=thick,linestyle=linestyle, color = color            
   
   CLOSE, lun                            
   FREE_LUN,lun        
        
   PRINT, "Program PLOT_DIM FINISHED"                                                              
   END  ; END of program                                                             
                                                               
                                                              
                                                                                                                                                                         
                                                           
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
                                                                                                                                                                                                                                                                               
