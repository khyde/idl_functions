; $ID:	JUNK_PRINT.PRO,	2020-07-08-15,	USER-KJWH	$
pro junk_print

ALGS = ['VGPM','VGPM2','OPAL','HIRATA','UITZ','POC','PIC','PAR','GSM','LEE','IOP','MUR','AVHRR','N_4UM','N_11UM','BOA']
FOR A=0, N_ELEMENTS(ALGS)-1 DO BEGIN
  AA = ALGS(A)
  CASE AA OF 


  

  'VGPM': ALG  = 'Behrenfeld, M. J. and P. G. Falkowski (1997). "Photosynthetic rates derived from satellite-based chlorophyll concentration." Limnology and Oceanography 42[1]: 1-20.'

  'VGPM2': ALG  = 'Behrenfeld, M. J. and P. G. Falkowski (1997). "Photosynthetic rates derived from satellite-based chlorophyll concentration." Limnology and Oceanography 42[1]: 1-20;  ' + $
  'Eppley, R. W. (1972). "Temperature and phytoplankton growth in the sea." Fishery Bulletin 70(4): 1063-1085.'

  'OPAL':  ALG  = 'TBD'

  'HIRATA': ALG  = 'Hirata, T., J. Aiken, N. Hardman-Mountford, T. J. Smyth and R. G. Barlow (2008). "An absorption model to determine phytoplankton size classes from satellite ocean colour." ' + $
    'Remote Sensing of Environment 112(6): 3153-3159;  ' + $
  'Hirata, T., N. J. Hardman-Mountford, R. J. W. Brewin, J. Aiken, R. Barlow, K. Suzuki, T. Isada, E. Howell, T. Hashioka, M. Noguchi-Aita and Y. Yamanaka (2011). ' + $
    '"Synoptic relationships between surface Chlorophyll-a and diagnostic pigments specific to phytoplankton functional types." Biogeosciences 8(2): 311-327.'

  'UITZ': ALG  = 'Uitz, J., Y. Huot, F. Bruyant, M. Babin, H. Claustre and H. Claustre (2008). "Relating Phytoplankton Photophysiological Properties to Community Structure on Large Scales." Limnology and Oceanography 53(2): 614-630.'

  'POC': ALG = 'Stramski, D., Reynolds, R. A., Babin, M., Kaczmarek, S., Lewis, M. R., Röttgers, R., ? Claustre, H. (2008). Relationships between the surface concentration of particulate organic carbon and ' + $
    'optical properties in the eastern South Pacific and eastern Atlantic Oceans. Biogeosciences, 5[1], 171-201. doi:10.5194/bg-5-171-2008

  'PIC': ALG  = 'Balch, W. M., Gordon, H. R., Bowler, B. C., et al. (2005). Calcium carbonate measurements in the surface global ocean based on Moderate-Resolution Imaging Spectroradiometer data. ' + $
    'Journal of Geophysical Research 110, C07001. http://dx.doi.org/10.1029/2004jc002560;  ' + $
  'Gordon, H. R., Boynton, G. C., Balch, W. M., et al. (2001). Retrieval of coccolithophore calcite concentration from SeaWiFS imagery. Geophysical Research Letters 28(8), 1587-1590. http://dx.doi.org/10.1029/2000gl012025'

  'PAR': ALG  = 'Frouin, R., McPherson, J., Ueyoshi, K., & Franz, B. A. (2012). A time series of photosynthetically available radiation at the ocean surface from SeaWiFS and MODIS data. ' + $
    'Remote Sensing of the Marine Environment II. http://dx.doi.org/10.1117/12.981264;  ' + $
  'Frouin, R., Franz, B. A., & Werdell, P. J. (2002). The SeaWiFS PAR product. ,In: S.B. Hooker and E.R. Firestone, Algorithm Updates for the Fourth SeaWiFS Data Reprocessing, ' + $
    'NASA Tech. Memo. 2003-206892, Volume 22, NASA Goddard Space Flight Center, Greenbelt, Maryland, 46-50.The SeaWiFS PAR product;  ' + $
  "Frouin, R. & Pinker, R. T. (1995). Estimating Photosynthetically Active Radiation (PAR) at the earth's surface from satellite observations. Remote Sensing of Environment, " + $
    'Volume 51, Issue 1, January 1995, Pages 98-107, ISSN 0034-4257. http://dx.doi.org/10.1016/0034-4257(94)00068-X'

  'GSM': ALG  = 'Maritorena, S., Siegel, D. A., & Peterson, A. R. (2002). Optimization of a semianalytical ocean color model for global-scale applications. Appl. Opt., 41(15), 2705.http://dx.doi.org/10.1364/ao.41.002705'

  'IOP': ALG  = 'Lee, Z., Carder, K. L., & Arnone, R. A. (2002). Deriving Inherent Optical Properties from Water Color: a Multiband Quasi-Analytical Algorithm for Optically Deep Waters. Appl. Opt., 41(27), 5755. http://dx.doi.org/10.1364/ao.41.005755'

  'LEE': ALG  = 'Lee, Z.-P. (2005). A model for the diffuse attenuation coefficient of downwelling irradiance. Journal of Geophysical Research, 110(C2). http://dx.doi.org/10.1029/2004jc002275;  ' + $
  'Lee, Z., Weidemann, A., Kindle, J., Arnone, R., Carder, K. L., &Davis, C. (2007). Euphotic zone depth: Its derivation and implication to ocean-color remote sensing. Journal of Geophysical Research, 112(C3). http://dx.doi.org/10.1029/2006jc003802'

  'MUR': ALG  = 'Chin, T. M., J. Vazquez-Cuervo and E. M. Armstrong (2017). "A multi-scale high-resolution analysis of global sea surface temperature." Remote Sensing of Environment 200: 154-169.'

  'AVHRR': ALG  = 'Casey, K.S., T.B. Brandon, P. Cornillon, and R. Evans (2010). "The Past, Present and Future of the AVHRR Pathfinder SST Program", in Oceanography from Space: Revisited, eds. V. Barale, J.F.R. Gower, and L. Alberotanza, Springer. doi:10.1007/978-90-481-8681-5_16'

  'N_11UM': ALG  = 'Walton, C. C., Pichel, W. G., Sapper, J. F., and May, D. A.(1998). The development and operational application of nonlinear algorithms for the measurement of sea surface temperatures with the NOAA polar-orbiting environmental satellites, Journal of Geophysical Research, 103(C12), 27999?28012, doi:10.1029/98JC02370.'

  'N_4UM': ALG  = 'Kilpatrick, K. A. (2001). Overview of the NOAA/NASA advanced very high resolution radiometer Pathfinder algorithm for sea surface temperature and associated matchup database. Journal of Geophysical Research. 106(C5):9179-9197. http://dx.doi.org/10.1029/1999JC000065;  ' + $
  'Brown, O. B. & Minnett, P. J. (1999). MODIS Infrared Sea Surface Temperature Algorithm - Algorithm Theoretical Basis Document. University of Miami.'

  'BOA': ALG  = "Belkin, I. M. and J. E. O'Reilly (2009). " + '"An algorithm for oceanic front detection in chlorophyll and SST satellite imagery." Journal of Marine Systems 78(3): 319-326.'

  ENDCASE
  g = str_break(alg,';')
  PRINT, 'ALG = ' + AA
  PRINT, G
  PRINT
  PRINT
  ENDFOR



end
