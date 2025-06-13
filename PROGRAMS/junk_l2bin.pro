pro junk_l2bin

bin = 'L3B2'
map = 'nec'
night='1'
qm = '3'
res='2'
aprod='sst4'
flags='LAND,~HISOLZEN'; 'ISMASKED,BTBAD,BTRANGE,BTDIFF,SSTRANGE,VHISENZ,SSTREFVDIFF,SST_CLOUD'
infile='/nadata/DATASETS/SST-MODIS-1KM/L3B2/PROCESS/A2002185-L2BIN-SST4.txt'
ofile='/nadata/DATASETS/SST-MODIS-1KM/TEST/A2002185.L3B2_DAY_SST4.nc'
gfile='/nadata/DATASETS/SST-MODIS-1KM/TEST/A2002185.L3B2_DAY_SST4.png'

CMD = 'l2bin infile='+infile + ' ofile='+ofile + ' resolve='+RES +  ' l3bprod='+APROD + ' suite=SST4' +' qual_max='+QM ; ; + ' night='+NIGHT + +' flaguse='+FLAGS; 
P, CMD
if file_test(ofile) eq 0 then SPAWN, CMD, L2LOG, L2ERR

d = read_nc(ofile,prod='sst4') & help, d.sd.sst4.data & pmm, d.sd.sst4.data
m = maps_remap(d.sd.sst4.data,bins=d.sd.sst4.bins,map_in=bin,map_out=map)
imgr, m, prod='sst', map=map, png=gfile

stop
end