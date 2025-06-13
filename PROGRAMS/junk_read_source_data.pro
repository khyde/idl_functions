

pro junk_read_source_data

filename='/nadata/DATASETS/OC/MODISA/L3B2/NC/POC/ADD_IFILES/A2005232.L3B2_DAY_POC.nc'
grpname='processing_control'
varname='source'
attname='source'

ncid = ncdf_open(filename, /NOWRITE)
grpid = ncdf_ncidinq(ncid, grpname)
;varid = ncdf_varid(grpid, varname)
ncdf_attget, grpid, attname, attr, /global
ncdf_close, ncid



help, attr
print, string(attr)
stop
end