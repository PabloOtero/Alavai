Alavai
======

Citation: Otero et al., 2015. A surface ocean trajectories visualization tool and its initial application to the Galician coast. Environmental Modelling & Software, 66:12-16, DOI: 10.1016/j.envsoft.2014.12.006

https://www.researchgate.net/publication/270487483_A_surface_ocean_trajectories_visualization_tool_and_its_initial_application_to_the_Galician_coast

### What is Alavai?
Alavai is a interactive visualization tool for surface ocean drift forecasts

- [Watch a video](http://www.youtube.com/watch?v=MZJFnWjX1yc) demonstrating the use of Alavai
- [Try using Alavai](http://centolo.co.ieo.es:8080/alavai_en/index.html), visualizing the latest ROMS ocean forecast for the Galician coast of Spain.

### Details
This program plots trajectories of Lagrangian particles at both 1-m depth and 1-m depth + 3%
of the wind speed. The current fields are obtained from operational results of the ROMS model
operated and mantained by the Modelling Group of the Instituto Español de Oceanografía, Spain. Data
are stored in the Thredds of this group at http://centolo.co.ieo:8080/thredds
with 1 h of temporal resolution and ~1.3 km of horizontal resolution. Meterological data are
obtained from the WRF model operated and mantained by MeteoGalicia (http://www.meteogalicia.es).
In the code folder you can find the *.pde files written in the [Processing](http://processing.org/) programming language. Start reading Alavai.pde.
This program is a strong modification of "flowWeaver_ecohab5" by Neil Banas. Please, visit:
http://staff.washington.edu/banasn/flowWeaver/index.html
This Applet uses local time based on the client machine.



### How to set-up ALAVAI for another region
If you are an ocean modeller, you can adapt Alavai to run it with your ROMS outputs. To help in this
scope, we can provide you with some Matlab scripts to create the CF compliant files from ROMS_AGRIF
history files and also one script that creates the file with the information that Alavai will use to plot trajectories.
First, download Processing (http://www.processing.org/) and learn a little bit about it.
Second, download all the *pde files that we provide and place them in a new folder named "Alavai".
Third, create a map of your entire domain and save it as "png" image with 320x480 pixels. Place it in the
"data" folder of your Alavai sketch. If you need to change the size of the image because the domain is highly distorted,
then you have to modify the "size()" property in the "setup" (read the code below). Last action will unplace buttons
and other stuff of the applet, which means that you will have to do an extra effort.
Fourth, select your specific options for your setup (see below).

**WARNING**: To properly run the applet, you will need to put the following libraries in the "code" folder:
- netcdf-2.2.14.jar
- slf4j-simple.jar
To export as an applet, you need version 1.5. Otherwise, we recommend you to run it with version 2+.

