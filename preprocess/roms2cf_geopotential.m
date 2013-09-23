function roms2cf_geopotential(grdname,romsfile,cffile)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function roms2cf_geopotential(grdname,romsfile,cffile)
%
%  Example: roms2cf_geopotential('roms_grd.nc','roms_his.nc','roms_cf_his.nc')
%
% 	Create a netcdf his or avg file CF-complaint
%       grdname: name of the grid file
%       romsfile: name of the ROMS_AGRIF his or avg file
%       cffile: name of the new file to create
%
%       Interpolate from "s" to "z levels". By default, the standard
%       depths are [1 5 10 20 50 100 150 200 250 500 1000 1500 2000 3000 4000]
%
%       DEPENDENCIES:
%       Roms_tools are needed http://www.romsagrif.org/ 
%
%       NOTE:  
%       Maybe, you are using your ROMS_AGRIF configuration
%       in an operational way. In this case, it is possible
%       that you build one file per day. If the operational history 
%       file has 25 hourly time steps (from 0Z to 24Z, both included), 
%       then we recommend to remove the last time step (which corresponds 
%       to the 0Z of the following day).
%       This makes easier the interpretation if the file is finally
%       uploaded to a Thredds server.
%
%       Pablo Otero, April-2012
%       pablo.otero@co.ieo.es
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%-------------- USER'S OPTIONS --------------%%%

% Did you simulate a fixed time of year (climate experiment)?
climate_experiment=0;

% Select depths to interpolate ROMS s-levels
zdepths=[1 5 10 20 50 100 150 200 250 500 1000 1500 2000 3000 4000];

%%%%--------------END OF USER CONFIGURATION------------%%%


ncgrd=netcdf(grdname);
ncold=netcdf(romsfile);
nw = netcdf(cffile, 'clobber');
result = redef(nw);

theNewFillValue=1.e+37;

%
% Read coordinates to use in velocity interpolations
%
lat_rho=ncgrd{'lat_rho'}(:);
lon_rho=ncgrd{'lon_rho'}(:);
lat_u=ncgrd{'lat_u'}(:);
lat_v=ncgrd{'lat_v'}(:);
lon_u=ncgrd{'lon_u'}(:);
lon_v=ncgrd{'lon_v'}(:);
mask_rho=ncgrd{'mask_rho'}(:);
mask_rho(mask_rho==0)=nan;

%
%  Create dimensions
%
disp(['Creating the CF-compliant file structure']);
nw('scalar') = 1;
nw('latitude') = length(ncgrd('eta_rho'));
nw('longitude') = length(ncgrd('xi_rho'));
time_model = ncold{'scrum_time'}(:);

%% Uncomment following lines if you are working in hourly operational basis.
%if( length(time_model) == 25 )
%  time_model = time_model(1:end-1);
%end

nw('time') = length(time_model);
nw('depth') = length(zdepths);

%
%  Create variables and attributes
%
nw{'h'} = ncdouble('latitude', 'longitude');
nw{'h'}.long_name = ncchar('bathymetry at RHO-points');
nw{'h'}.long_name = 'bathymetry at RHO-points';
nw{'h'}.units = ncchar('meter');
nw{'h'}.units = 'meter';
nw{'h'}.coordinates = ncchar('longitude latitude');
nw{'h'}.coordinates = 'longitude latitude';
nw{'h'}.field = ncchar('bath, scalar');
nw{'h'}.field = 'bath, scalar';

nw{'longitude'} = ncdouble('latitude', 'longitude');
nw{'longitude'}.long_name = ncchar('longitude of RHO-points');
nw{'longitude'}.long_name = 'longitude of RHO-points';
nw{'longitude'}.standard_name = ncchar('longitude');
nw{'longitude'}.standard_name = 'longitude'
nw{'longitude'}.units = ncchar('degree_east');
nw{'longitude'}.units = 'degree_east';


nw{'latitude'} = ncdouble('latitude', 'longitude');
nw{'latitude'}.long_name = ncchar('latitude of RHO-points');
nw{'latitude'}.long_name = 'latitude of RHO-points';
nw{'latitude'}.standard_name = ncchar('latitude');
nw{'latitude'}.standard_name = 'latitude';
nw{'latitude'}.units = ncchar('degree_north');
nw{'latitude'}.units = 'degree_north';

nw{'depth'} = ncdouble('depth');
nw{'depth'}.long_name = ncchar('Vertical distance below the surface');
nw{'depth'}.long_name = 'Vertical distance below the surface';
nw{'depth'}.units = ncchar('m');
nw{'depth'}.units = 'm';
nw{'depth'}.positive = ncchar('down');
nw{'depth'}.positive = 'down';

nw{'time'} = ncdouble('time');
nw{'time'}.long_name = ncchar('time since initialization');
nw{'time'}.long_name = 'time since initialization';
if(climate_experiment)
  nw{'time'}.calendar = ncchar('none');
  nw{'time'}.calendar = 'none';
  nw{'time'}.units = ncchar('seconds');
  nw{'time'}.units = 'seconds';
else
  nw{'time'}.calendar = ncchar('gregorian');
  nw{'time'}.calendar = 'gregorian';
  nw{'time'}.units = ncchar('seconds since 2009-1-1 00:00:00');
  nw{'time'}.units = 'seconds since 2009-1-1 00:00:00';
end
nw{'time'}.field = ncchar('time, scalar, series');
nw{'time'}.field = 'time, scalar, series';


for count=1:length(var(ncold))
 namevar=name(var(ncold,count));
 if(strcmp(namevar,'zeta'))
  nw{'zeta'} = ncdouble('time', 'latitude', 'longitude');
  nw{'zeta'}.long_name = ncchar('free-surface elevation ');
  nw{'zeta'}.long_name = 'free-surface elevation';
  nw{'zeta'}.standard_name = ncchar('sea_surface_height_above_sea_level');
  nw{'zeta'}.standard_name = 'sea_surface_height_above_sea_level';
  nw{'zeta'}.units = ncchar('m');
  nw{'zeta'}.units = 'm';
  nw{'zeta'}.time = ncchar('time');
  nw{'zeta'}.time = 'time';
  nw{'zeta'}.coordinates = ncchar('longitude latitude time');
  nw{'zeta'}.coordinates = 'longitude latitude time';
  nw{'zeta'}.field = ncchar('zeta, scalar, series');
  nw{'zeta'}.field = 'zeta, scalar, series';
 elseif(strcmp(namevar,'temp'))
  nw{'temp'} = ncdouble('time', 'depth', 'latitude', 'longitude');
  nw{'temp'}.long_name = ncchar('potential temperature');
  nw{'temp'}.long_name = 'potential temperature';
  nw{'temp'}.standard_name = ncchar('sea_water_potential_temperature');
  nw{'temp'}.standard_name = 'sea_water_potential_temperature';
  nw{'temp'}.units = ncchar('Celsius');
  nw{'temp'}.units = 'Celsius';
  nw{'temp'}.time = ncchar('time');
  nw{'temp'}.time = 'time';
  nw{'temp'}.coordinates = ncchar('longitude latitude depth time');
  nw{'temp'}.coordinates = 'longitude latitude depth time';
  nw{'temp'}.field = ncchar('temperature, scalar, series');
  nw{'temp'}.field = 'temperature, scalar, series';
 elseif(strcmp(namevar,'salt'))
  nw{'salt'} = ncdouble('time', 'depth', 'latitude', 'longitude');
  nw{'salt'}.long_name = ncchar('salinity');
  nw{'salt'}.long_name = 'salinity';
  nw{'salt'}.standard_name = ncchar('sea_water_salinity');
  nw{'salt'}.standard_name = 'sea_water_salinity';
  nw{'salt'}.units = ncchar('1e-3');
  nw{'salt'}.units = '1e-3';
  nw{'salt'}.comment = ncchar('The unit of salinity is PSU, which is dimensionless.');
  nw{'salt'}.comment = 'The unit of salinity is PSU, which is dimensionless.';
  nw{'salt'}.time = ncchar('time');
  nw{'salt'}.time = 'time';
  nw{'salt'}.coordinates = ncchar('longitude latitude depth time');
  nw{'salt'}.coordinates = 'longitude latitude depth time';
  nw{'salt'}.field = ncchar('salinity, scalar, series');
  nw{'salt'}.field = 'salinity, scalar, series';
 elseif(strcmp(namevar,'u'))
  nw{'u'} = ncdouble('time', 'depth', 'latitude', 'longitude');
  nw{'u'}.long_name = ncchar('u-momentum component');
  nw{'u'}.long_name = 'u-momentum component';
  nw{'u'}.standard_name = ncchar('baroclinic_eastward_sea_water_velocity');
  nw{'u'}.standard_name = 'baroclinic_eastward_sea_water_velocity';
  nw{'u'}.units = ncchar('m s-1');
  nw{'u'}.units = 'm s-1';
  nw{'u'}.comment = ncchar('Positive when directed eastward (negative westward)');
  nw{'u'}.comment = 'Positive when directed eastward (negative westward)';
  nw{'u'}.time = ncchar('time');
  nw{'u'}.time = 'time';
  nw{'u'}.coordinates = ncchar('longitude latitude depth time');
  nw{'u'}.coordinates = 'longitude latitude depth time';
  nw{'u'}.field = ncchar('u-velocity, scalar, series');
  nw{'u'}.field = 'u-velocity, scalar, series';
 elseif(strcmp(namevar,'v'))
  nw{'v'} = ncdouble('time', 'depth', 'latitude', 'longitude');
  nw{'v'}.long_name = ncchar('v-momentum component');
  nw{'v'}.long_name = 'v-momentum component';
  nw{'v'}.standard_name = ncchar('baroclinic_northward_sea_water_velocity');
  nw{'v'}.standard_name = 'baroclinic_northward_sea_water_velocity';
  nw{'v'}.units = ncchar('m s-1');
  nw{'v'}.units = 'm s-1';
  nw{'v'}.comment = ncchar('Positive when directed northward (negative southward)');
  nw{'v'}.comment = 'Positive when directed northward (negative southward)';
  nw{'v'}.time = ncchar('time');
  nw{'v'}.time = 'time';
  nw{'v'}.coordinates = ncchar('longitude latitude depth time');
  nw{'v'}.coordinates = 'longitude latitude depth time';
  nw{'v'}.field = ncchar('v-velocity, scalar, series');
  nw{'v'}.field = 'v-velocity, scalar, series';
 elseif(strcmp(namevar,'w'))
  nw{'w'} = ncdouble('time', 'depth', 'latitude', 'longitude');
  nw{'w'}.long_name = ncchar('True vertical velocity');
  nw{'w'}.long_name = 'True vertical velocity';
  nw{'w'}.standard_name = ncchar('upward_sea_water_velocity');
  nw{'w'}.standard_name = 'upward_sea_water_velocity';
  nw{'w'}.units = ncchar('m s-1');
  nw{'w'}.units = 'm s-1';
  nw{'w'}.comment = ncchar('Positive when directed upward (negative downward)');
  nw{'w'}.comment = 'Positive when directed upward (negative downward)';
  nw{'w'}.time = ncchar('time');
  nw{'w'}.time = 'time';
  nw{'w'}.coordinates = ncchar('longitude latitude depth time');
  nw{'w'}.coordinates = 'longitude latitude depth time';
  nw{'w'}.field = ncchar('w-velocity, scalar, series');
  nw{'w'}.field = 'w-velocity, scalar, series';
% elseif(strcmp(namevar,'ubar'))
%  nw{'ubar'} = ncdouble('time', 'latitude', 'longitude');
%  nw{'ubar'}.long_name = ncchar('u-barotropic velocity');
%  nw{'ubar'}.long_name = 'u-barotropic velocity';
%  nw{'ubar'}.standard_name = ncchar('barotropic_eastward_sea_water_velocity');
%  nw{'ubar'}.standard_name = 'barotropic_eastward_sea_water_velocity';
%  nw{'ubar'}.units = ncchar('m s-1');
%  nw{'ubar'}.units = 'm s-1';
%  nw{'ubar'}.comment = ncchar('Positive when directed eastward (negative westward)');
%  nw{'ubar'}.comment = 'Positive when directed eastward (negative westward)';
%  nw{'ubar'}.time = ncchar('time');
%  nw{'ubar'}.time = 'time';
%  nw{'ubar'}.coordinates = ncchar('longitude latitude time');
%  nw{'ubar'}.coordinates = 'longitude latitude time';
%  nw{'ubar'}.field = ncchar('ubar, scalar, series');
%  nw{'ubar'}.field = 'ubar, scalar, series';
% elseif(strcmp(namevar,'vbar'))
%  nw{'vbar'} = ncdouble('time', 'latitude', 'longitude');
%  nw{'vbar'}.long_name = ncchar('v-barotropic velocity');
%  nw{'vbar'}.long_name = 'v-barotropic velocity';
%  nw{'vbar'}.standard_name = ncchar('barotropic_northward_sea_water_velocity');
%  nw{'vbar'}.standard_name = 'barotropic_northward_sea_water_velocity';
%  nw{'vbar'}.units = ncchar('m s-1');
%  nw{'vbar'}.units = 'm s-1';
%  nw{'vbar'}.comment = ncchar('Positive when directed northward (negative southward)');
%  nw{'vbar'}.comment = 'Positive when directed northward (negative southward)';
%  nw{'vbar'}.time = ncchar('time');
%  nw{'vbar'}.time = 'time';
%  nw{'vbar'}.coordinates = ncchar('longitude latitude time');
%  nw{'vbar'}.coordinates = 'longitude latitude time';
%  nw{'vbar'}.field = ncchar('vbar, scalar, series');
%  nw{'vbar'}.field = 'vbar, scalar, series';
 elseif(strcmp(namevar,'rho'))
  nw{'rho'} = ncdouble('time', 'depth', 'latitude', 'longitude');
  nw{'rho'}.long_name = ncchar('density anomaly');
  nw{'rho'}.long_name = 'density anomaly';
  nw{'rho'}.standard_name = ncchar('sea_water_sigma_theta');
  nw{'rho'}.standard_name = 'sea_water_sigma_theta';
  nw{'rho'}.units = ncchar('kg m-3');
  nw{'rho'}.units = 'kg m-3';
  nw{'rho'}.comment = ncchar('Usually referred to 1025 Kg m-3 in the ROMS code');
  nw{'rho'}.comment = 'Usually referred to 1025 Kg m-3 in the ROMS code';
  nw{'rho'}.time = ncchar('time');
  nw{'rho'}.time = 'time';
  nw{'rho'}.coordinates = ncchar('longitude latitude depth time');
  nw{'rho'}.coordinates = 'longitude latitude depth time';
  nw{'rho'}.field = ncchar('rho, scalar, series');
  nw{'rho'}.field = 'rho, scalar, series';
 end
end 
result = endef(nw);

%
% Create global attributes
%
nw.type = ncold.type(:);
nw.title = 'Write here the name of your configuration'; %nw.title = ncold.title(:);
nw.long_title = 'This a ROMS_AGRIF ouput file transformed to be CF-Compliant';
nw.comments = 'Variables have been interpolated from rho-points to some selected depths. Original outputs are available on request.';
nw.institution = 'Write here the name of your institution';
nw.source = 'ROMS_AGRIF';
nw.Conventions = 'CF-1.4';
nw.Conventions_help = 'http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html'; % This way I can always get back to fundamentals
nw.CreationDate = datestr(now,'yyyy-mm-dd HH:MM:SS');
nw.CreatedBy = getenv('LOGNAME');
nw.MatlabSource = version; % I like this one for tracking

%
% Write variables
%
disp(['Writing variables concerning grid structure']);
kk=ncold{'h'}(:).*mask_rho; 
isee=find(kk==0 | kk==nan); kk(isee)=theNewFillValue; 
nw{'h'}(:) = kk;
fillval(nw{'h'}, theNewFillValue);
nw{'longitude'}(:) = ncgrd{'lon_rho'}(:);
nw{'latitude'}(:) = ncgrd{'lat_rho'}(:);
nw{'time'}(:) = time_model;
nw{'depth'}(:) = zdepths(:);

disp(['Writing variables concerning model results']);

% zeta is a 2D vraiable that does not need to be interpolated to rho points
for count=1:length(var(ncold))
 namevar=name(var(ncold,count));
 if(strcmp(namevar,'zeta'))
  for countt=1:length(time_model)
    kk=squeeze(ncold{'zeta'}(countt,:,:)); 
    kk=kk.*mask_rho; isee=find(kk==0); kk(isee)=theNewFillValue;
    nw{'zeta'}(countt,:,:) = kk;
    fillval(nw{'zeta'}, theNewFillValue);
  end
 end
end


%% ubar and vbar are 2D vraiables that have to be interpolated to rho points
%for count=1:length(var(ncold))
% namevar=name(var(ncold,count));
% for countt=1:length(time_model)
%  if(strcmp(namevar,'ubar'))
%    kk=squeeze(ncold{'ubar'}(countt,:,:)); isee=find(kk~=0 | ~isnan(kk));
%    kk2=griddata(lon_u(isee),lat_u(isee),kk(isee),lon_rho,lat_rho); kk2=kk2.*mask_rho;
%    kk2(find(isnan(kk2)))=theNewFillValue;
%    nw{'ubar'}(countt,:,:) = squeeze(kk2);
%    fillval(nw{'ubar'}, theNewFillValue);
%  elseif(strcmp(namevar,'vbar'))
%    kk=squeeze(ncold{'vbar'}(countt,:,:)); isee=find(kk~=0 | ~isnan(kk));
%    kk2=griddata(lon_v(isee),lat_v(isee),kk(isee),lon_rho,lat_rho); kk2=kk2.*mask_rho;
%    kk2(find(isnan(kk2)))=theNewFillValue;
%    nw{'vbar'}(countt,:,:) = squeeze(kk2);
%    fillval(nw{'vbar'}, theNewFillValue);
%  end
% end
%end


for count=1:length(var(ncold))
 namevar=name(var(ncold,count));
 for countt=1:length(time_model)
  for countz=1:length(zdepths)
   if(strcmp(namevar,'temp'))
    kk=get_hslice(romsfile,grdname,'temp',countt,-zdepths(countz),'r');
    kk=kk.*mask_rho; isee=find(kk==0 | kk==nan); kk(isee)=theNewFillValue;
    nw{'temp'}(countt,countz,:,:) = squeeze(kk);
    fillval(nw{'temp'}, theNewFillValue);
   elseif(strcmp(namevar,'salt'))
    kk=get_hslice(romsfile,grdname,'salt',countt,-zdepths(countz),'r');
    kk=kk.*mask_rho; isee=find(kk==0 | kk==nan); kk(isee)=theNewFillValue;
    nw{'salt'}(countt,countz,:,:) = squeeze(kk);
    fillval(nw{'salt'}, theNewFillValue);
   elseif(strcmp(namevar,'u'))
    kk=get_hslice(romsfile,grdname,'u',countt,-zdepths(countz),'u');
    isee=find(kk~=0 | ~isnan(kk));  
    kk2=griddata(lon_u(isee),lat_u(isee),kk(isee),lon_rho,lat_rho);  kk2=kk2.*mask_rho;
    isee=find(kk2==0 | kk2==nan); kk2(isee)=theNewFillValue;
    nw{'u'}(countt,countz,:,:) = squeeze(kk2);
    fillval(nw{'u'}, theNewFillValue);
   elseif(strcmp(namevar,'v'))
    kk=get_hslice(romsfile,grdname,'v',countt,-zdepths(countz),'v');
    isee=find(kk~=0 | ~isnan(kk));  
    kk2=griddata(lon_v(isee),lat_v(isee),kk(isee),lon_rho,lat_rho); kk2=kk2.*mask_rho;
    isee=find(kk2==0 | kk2==nan); kk2(isee)=theNewFillValue;
    nw{'v'}(countt,countz,:,:) = squeeze(kk2);
    fillval(nw{'v'}, theNewFillValue);
   elseif(strcmp(namevar,'w'))
    kk=get_hslice(romsfile,grdname,'w',countt,-zdepths(countz),'r');
    isee=find(kk==0 | kk==nan); kk(isee)=theNewFillValue;
    nw{'w'}(countt,countz,:,:) = squeeze(kk);
    fillval(nw{'w'}, theNewFillValue);
   end
  end
 end
end

close(nw);





