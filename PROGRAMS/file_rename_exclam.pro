; $ID:	FILE_RENAME_EXCLAM.PRO,	2014-02-08 20	$
PRO FILE_RENAME_EXCLAM
HDD = GET_HDD(4)
DIR = HDD  + 'SMI' + PATH_SEP()
FILES = FILE_SEARCH(DIR,'*!*.*') & PN,FILES
OK = WHERE_STRING(FILES,'BAD') & FILES = REMOVE(FILES,OK)
      FILE_RENAME,FILES,NAME_CHANGE = ['!',''],/VERBOSE
  
  
      DIR = GET_HDD(4)  + 'SMI\PP' + PATH_SEP()   & P,DIR
      FILES = FILE_SEARCH(DIR,'*!*.*') & PN,FILES
      FILE_RENAME,FILES,NAME_CHANGE = ['!',''],/VERBOSE
      
      DIR = GET_HDD(3)  + 'SMI\PP' + PATH_SEP()   & P,DIR
      FILES = FILE_SEARCH(DIR,'*!*.*') & PN,FILES
      FILE_RENAME,FILES,NAME_CHANGE = ['!',''],/VERBOSE
  
      DIR = 'F:\'  + 'SMI' + PATH_SEP()
      FILES = FILE_SEARCH(DIR,'*!*.*') & PN,FILES     
      FILE_RENAME,FILES,NAME_CHANGE = ['!',''],/VERBOSE
      
      
      DIR = 'E:\'  + 'SMI' + PATH_SEP()
      FILES = FILE_SEARCH(DIR,'*!*.*') & PN,FILES     
      FILE_RENAME,FILES,NAME_CHANGE = ['!',''],/VERBOSE      
STOP
END; #####################  END OF ROUTINE ################################
