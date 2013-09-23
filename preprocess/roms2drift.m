function roms2drift(tini,tend,xres,dt,numsteps,borde,wind_factor)
% function roms2drift(tini,tend,xres,dt,numsteps,borde,wind_factor)
%
% Creates a new NetCDF file to use in the "Alavai" application.
%
% The new NetCDF stores, for each time step, the final position that a
% lagrangian particle would get departing from the center of each cell.
% This final position is recorded as a relative position of the width 
% and height of horizontal grid (the whole domain), with values ranging 
% from -32768 to 32767. By so doing, the final size of the file is smaller.
%
% --------------------------------------------------------------------
% Usage: roms2drift(tini,tend,xres,dt,numsteps,borde,wind_factor)
%   where,
%   	tini = date of the fist file to use in the way 'yyyymmdd'
%       tend = date of the last file to use in the way 'yyyymmdd'
% 	xres = reduce the horizontal resolution to improve the connection 
%		to the Thredds by the App. For example, 2 means that reduces
%		the final resolution by this factor
%	dt   = seconds between time steps of the ROMS file
%       numsteps = total of number steps to build the drift file. If we are
%               going to concatenate 5 days of the operational model, each one
%               with 24 hourly data, then numsteps = 5*24
%       borde =  Numer of cells to skip around the grid. Useful to reduce the grid size.
%		Use 1 if no cells are skipped
%	wind_factor = Fraction of the wind speed directly affecting the oil spill
%		Typical values range from 0.01 to 0.05
%		
% Example: roms2drift('20130101','20130105',2,3600,120,1,0.03)
% ---------------------------------------------------------------------
%
%
% DEPENDENCIES:
% Roms_tools are needed http://www.romsagrif.org/ and also julian.m from
% recoded by Rich Signell http://woodshole.er.usgs.gov/operations/sea-mat/timeplt-html/
%
% THIS SCRIPT REQUIRES STRONG CHANGES TO BE ADAPTED TO OTHER OPERATIONAL
% CONFIGURATION. Here there are some notes to help in this task:
% 
% - In the original "Alavai" application, the drift file is computed from 
% "yesterday" to the 3-days prediction (5 days in total) and using winds
% from the WRF model. Hence, we use the ROMS CF-Complaint files stored in
% our Thredds and the WRF predictions. We have one file per day in both cases. 
% Thus, we need to match both datasets in the temporal scale.
% - Our ROMS files are named: Raia_CF_his_20130101.nc.1
% - Our WRF files are named: wrf_arw_det_20120101_12km_00Z_0d.nc for the 
% current day, and finished in *1d.nc, *2d.nc, *2d.nc for the prediction
% during the following days.
%  
%
% Pablo Otero, October 2012.


%------------------   USER SPECIFIC OPTIONS ------------------------------

wrf_data_dir='/data/data_camaron2/wrf_forecast/';
cffile_prefix='/data/thredds_centolo/ROMS-IEO/ROMS1km/Horario/Raia_CF_his_';
cffile_subfix='.nc.1';   
driftfile_passive='Raia_drift_passive.nc';                 
driftfile_oil='Raia_drift_oil.nc';
deflect=0; %Deflect oil spill in fucntion of wind speed

%-------------------  END OF USER CONFIGURATION --------------------------

cffile=strcat(cffile_prefix,tini,cffile_subfix);

%
% Read coordinates to use in velocity interpolations
%
  ncgrd=netcdf(cffile);
  lat_rho=ncgrd{'latitude'}(borde:xres:end-borde+1,borde:xres:end-borde+1);
  lon_rho=ncgrd{'longitude'}(borde:xres:end-borde+1,borde:xres:end-borde+1);
  lat=lat_rho(:,1);
  lon=lon_rho(1,:)';
  u=ncgrd{'u'}(1,1,borde:xres:end-borde+1,borde:xres:end-borde+1);  
  v=ncgrd{'v'}(1,1,borde:xres:end-borde+1,borde:xres:end-borde+1);
  close(ncgrd)

% Only cells with valid data
isee=find(~isnan(u) & ~isnan(v));

%
%  Create dimensions
%
nw = netcdf(driftfile_passive, 'clobber');
result = redef(nw);
disp(['Creating the drift file structure']);
nw('J') = length(lat);
nw('I') = length(lon);
nw('Nreps') = numsteps;
nw('one') = 1;
nw('cell') = length(isee);

nw2 = netcdf(driftfile_oil, 'clobber');
result = redef(nw2);
disp(['Creating the drift file structure']);
nw2('J') = length(lat);
nw2('I') = length(lon);
nw2('Nreps') = numsteps;
nw2('one') = 1;
nw2('cell') = length(isee);


%
%  Create variables and attributes
%
nw{'x'} = ncfloat('I');
nw{'y'} = ncfloat('J');
nw{'ind'}= ncint('cell');
nw{'xnext'} = ncshort('Nreps','cell');
nw{'ynext'} = ncshort('Nreps','cell');
nw{'timemodel'} = ncfloat('Nreps');
nw{'numAlternates'} = ncfloat('one');
nw{'numCells'} = ncfloat('one');
result = endef(nw);


nw2{'x'} = ncfloat('I');
nw2{'y'} = ncfloat('J');
nw2{'ind'}= ncint('cell');
nw2{'xnext'} = ncshort('Nreps','cell');
nw2{'ynext'} = ncshort('Nreps','cell');
nw2{'timemodel'} = ncfloat('Nreps');
nw2{'numAlternates'} = ncfloat('one');
nw2{'numCells'} = ncfloat('one');
result = endef(nw2);


%
% Create global attributes
%
nw.title = 'Alavai - Currents at 1-m depth'; 
nw.long_title = 'This a ROMS_AGRIF ouput file transformed to be used in Alavai Drift application';
nw.institution = 'Write here the name of your institution';
nw.CreationDate = datestr(now,'yyyy-mm-dd HH:MM:SS');
nw.CreatedBy = getenv('LOGNAME');
nw.MatlabSource = version; 

nw2.title = 'Alavai - Currents at 1-m depth + 3% of wind speed at 10-m height'; 
nw2.long_title = 'This a ROMS_AGRIF ouput file transformed to be used in Alavai Drift application';
nw2.institution = 'Write here the name of your institution';
nw2.CreationDate = datestr(now,'yyyy-mm-dd HH:MM:SS');
nw2.CreatedBy = getenv('LOGNAME');
nw2.MatlabSource = version; 


%
% Write variables
%
nw{'x'}(:)=lon;
nw{'y'}(:)=lat;
nw{'ind'}(:)=isee;
nw{'numAlternates'}(:) = 1;
nw{'numCells'}(:) = length(isee);

nw2{'x'}(:)=lon;
nw2{'y'}(:)=lat;
nw2{'ind'}(:)=isee;
nw2{'numAlternates'}(:) = 1;
nw2{'numCells'}(:) = length(isee);

disp(['Writing variables']);
arco_y=2*pi*6370000/360;

contador=1;

ini_date=julian(str2num(tini(1:4)),str2num(tini(5:6)),str2num(tini(7:8)));
end_date=julian(str2num(tend(1:4)),str2num(tend(5:6)),str2num(tend(7:8)));


%%% Ocean outputs start at 0h and ends at 23h
%%% Meteo outputs start at 1h and ends at 24h
%%% To deal with last problem, we read both groups of data and we concatenate them in separate matrix
%%% Meteo data requires to read one day before, to take the last hour of the day
for days=ini_date-1:end_date

  kk=gregorian(days);
  year=num2str(kk(1));
  if(kk(2)<10)
    month=strcat('0',num2str(kk(2)));
  else
    month=num2str(kk(2));
  end
  if(kk(3)<10)
    day=strcat('0',num2str(kk(3)));
  else
    day=num2str(kk(3));
  end
  daystr=strcat(year,month,day);

  if(days==(ini_date-1))
    currentday=days;
  end

  nd=days-currentday;

  wrf_file =[wrf_data_dir 'wrf_arw_det_' daystr '_12km_00Z_0d.nc'];
  if(exist(wrf_file))
    currentday=days;
    currentstr=daystr;
  else
    wrf_file =[wrf_data_dir 'wrf_arw_det_' currentstr '_12km_00Z_' num2str(nd) 'd.nc'];
  end
  disp(['WRF file : ',wrf_file]);  

  ncf=netcdf(wrf_file);
  
  if(days==ini_date-1)
   la_1_mm5 = ncf{'lat'}(:);
   lo_1_mm5 = ncf{'lon'}(:);
   ma_mm5 = squeeze(ncf{'lwm'}(1,:,:)); %The WRF mask has 3 dimensions!
   isee_mm5 = find(ma_mm5==1);
   
   uwrf=ones(1,size(lo_1_mm5,1),size(lo_1_mm5,2));
   vwrf=ones(1,size(lo_1_mm5,1),size(lo_1_mm5,2));

   uwrf(1,:,:) = ncf{'u'}(end,:,:);
   vwrf(1,:,:) = ncf{'v'}(end,:,:);
  else
    disp(['...+1'])
   uwnd = ncf{'u'}(:,:,:);
   vwnd = ncf{'v'}(:,:,:);

   %Deflection angle
   if(deflect)
	   defangle=25*exp(  -10^-8 .* (sqrt(uwnd.^2+vwnd.^2).^3) ./ (1.05*10.^-6) ./ 9.82 );
	   R=[cos(deg2rad(defangle)) sin(deg2rad(defangle)); -sin(deg2rad(defangle)) cos(deg2rad(defangle))];

	   u3prima = uwnd.*cos(deg2rad(defangle)) + vwnd.*sin(deg2rad(defangle));
	   v3prima = -uwnd.*sin(deg2rad(defangle)) + vwnd.*cos(deg2rad(defangle));

	   uwnd = u3prima;
	   vwnd = v3prima;
   end

   uwrf = [uwrf;uwnd];
   vwrf = [vwrf;vwnd];
  end

  close(ncf);

end
% We do not want the last hour in order to match with ROMS-CF outputs
uwrf=uwrf(1:end-1,:,:);
vwrf=vwrf(1:end-1,:,:);


% Read ROMS-CF currents
count=0;
for days=ini_date:end_date

  kk=gregorian(days);
  year=num2str(kk(1));
  if(kk(2)<10)
    month=strcat('0',num2str(kk(2)));
  else
    month=num2str(kk(2));
  end
  if(kk(3)<10)
    day=strcat('0',num2str(kk(3)));
  else
    day=num2str(kk(3));
  end
  daystr=strcat(year,month,day);

  cffile=strcat(cffile_prefix,daystr,cffile_subfix)

  ncgrd=netcdf(cffile);
  time=ncgrd{'time'}(:);
  if( length(time) == 25 )
    time = time(1:end-1);
  end 

  nw{'timemodel'}([1:24]+24*(days-ini_date))=time;  
  nw2{'timemodel'}([1:24]+24*(days-ini_date))=time;  

  for hours=1:length(time)
    count=count+1;

    disp(['Hour: ', num2str(hours)]);    

    u=ncgrd{'u'}(hours,1,borde:xres:end-borde+1,borde:xres:end-borde+1); 
    v=ncgrd{'v'}(hours,1,borde:xres:end-borde+1,borde:xres:end-borde+1);
 
    arco_x=2*pi*6370000*cos(deg2rad(lat_rho))/360;
    delta_x=lon_rho+u.*dt./arco_x;
    delta_y=lat_rho+v.*dt./arco_y;
    posx=round(   -32768+((delta_x-min(lon))*length([-32768:32767])/abs((max(lon)-min(lon))))   ); 
    posx(posx<-32768)=-32768;
    posx(posx>32767)=32767;
    posy=round(   -32768+((delta_y-min(lat))*length([-32768:32767])/abs((max(lat)-min(lat))))   );
    posy(posy<-32768)=-32768;
    posy(posy>32767)=32767;

    posx=int16(posx); 
    posy=int16(posy); 

    nw{'xnext'}(contador,:) = posx(isee);
    nw{'ynext'}(contador,:) = posy(isee);

    clear posx posy;

    u3=griddata(lo_1_mm5,la_1_mm5,squeeze(uwrf(count,:,:)),lon_rho,lat_rho,'cubic').*wind_factor;
    v3=griddata(lo_1_mm5,la_1_mm5,squeeze(vwrf(count,:,:)),lon_rho,lat_rho,'cubic').*wind_factor;
    
    u=u+u3;
    v=v+v3;

    arco_x=2*pi*6370000*cos(deg2rad(lat_rho))/360;
    delta_x=lon_rho+u.*dt./arco_x;
    delta_y=lat_rho+v.*dt./arco_y;
    posx=round(   -32768+((delta_x-min(lon))*length([-32768:32767])/abs((max(lon)-min(lon))))   ); 
    posx(posx<-32768)=-32768;
    posx(posx>32767)=32767;
    posy=round(   -32768+((delta_y-min(lat))*length([-32768:32767])/abs((max(lat)-min(lat))))   );
    posy(posy<-32768)=-32768;
    posy(posy>32767)=32767;

    posx=int16(posx); 
    posy=int16(posy); 

    nw2{'xnext'}(contador,:) = posx(isee);
    nw2{'ynext'}(contador,:) = posy(isee);
    
    clear u v u3 v3;
    contador=contador+1;

   end
  close(ncgrd)
end

nw{'ind'}(:)=uint16(isee);
nw2{'ind'}(:)=uint16(isee);

close(nw);
close(nw2);   




