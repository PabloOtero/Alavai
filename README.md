Alavai
======

Visualization tool for a surface ocean drift forecast

Please, cite: Otero et al., 2013. Visualization tool for a surface ocean drift forecast. Environmental Modelling & Software. Submitted

Here you can find *.pde files to run this application in Processing. Start reading Alavai.pde.

// WHAT THIS APPLET DOES:
// This program plots trajectories of lagrangian particles at both 1-m depth and 1-m depth + 3%
// of the wind speed. The current fields are obtained from operational results of the ROMS model
// operated and mantained by the Modelling Group of the Instituto Español de Oceanografía, Spain. Data
// are stored in the Thredds of this group at http://centolo.co.ieo:8080/thredds
// with 1 h of temporal resolution and ~1.3 km of horizontal resolution. Meterological data are
// obtained from the WRF model operated and mantained by MeteoGalicia (http://www.meteogalicia.es)
// This program is a strong modification of "flowWeaver_ecohab5" by Neil Banas. Please, visit:
// http://staff.washington.edu/banasn/flowWeaver/index.html
// This Applet uses local time based on the client machine.
//
// WHAT YOU CAN DO (STEPS TO ADAPT ALAVAI TO OTHER REGION):
// If you are an ocean modeller, you can adapt Alavai to run it with your ROMS outputs. To help in this
// scope, we can provide you with some Matlab scripts to create the CF compliant files from ROMS_AGRIF
// history files and also one script that creates the file with the information that Alavai will use to plot trajectories.
// First, download Processing (http://www.processing.org/) and learn a little bit about it.
// Second, download all the *pde files that we provide and place them in a new folder named "Alavai".
// Third, create a map of your entire domain and save it as "png" image with 320x480 pixels. Place it in the
// "data" folder of your Alavai sketch. If you need to change the size of the image because the domain is highly distorted,
// then you have to modify the "size()" property in the "setup" (read the code below). Last action will unplace buttons
// and other stuff of the applet, which means that you will have to do an extra effort.
// Fourth, select your specific options for your setup (see below).
//
// WARNING:
// To properly run the applet, we need to put into the "Code" folder the following libraries:
// - netcdf-2.2.14.jar
// - slf4j-simple.jar
// To export as an applet, yo need version 1.5. Otherwise, we recommend you to run it with version 2+.

