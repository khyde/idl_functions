pro maskit, CHECK = check, DBF = dbf, FILES = files, MASKFILE = maskfile, DIR_OUT = dir_out

 IF N_ELEMENTS(DIR_IN) LT 1 THEN DIR_IN = '/oc5/czcs/credible_lows_cloudring/'
 IF N_ELEMENTS(MASKFILE) LT 1 THEN MASKFILE = '/oc5/czcs/maskit/maskit.txt'
 IF N_ELEMENTS(DIR_OUT) LT 1 THEN DIR_OUT = '/oc5/czcs/maskit/'

  maskimage,DIR_IN = dir_in, $
         overlay = '/usr/users/oreilly/idl/images/nec_coast.gif', $
         maskfile = maskfile, $
         dir_out = dir_out, $
         check = check, $
	 dbf = dbf, $
         xsize = 780, ysize = 850


end
