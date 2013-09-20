// Alavai
// Coded by Pablo Otero and Neil Banas
// October 2012
//
// CONTACT:
// pablo.otero@co.ieo.es
//
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
//
// OUR OWN NOTES ;-)
// Originally (in display):
// hoverPaths = new Trajectory[flow.length][hoverPathReplicates]
// hoverPaths[j][k], where j=index of the flow...
// and now,
// hoverPaths = new Trajectory[1][hoverPathReplicates]
// hoverPaths[0][k], which means that we can plot only one flow each time 
//  to do:
//    plot wind and tides in little axes
//    play/pause  


//------ SELECT HERE YOUR SPECIFIC OPTIONS IF YOU'RE GOING TO ADAPT IT TO OTHER REGION ----------
boolean procession2plus = false;         // The Procession version. To export as an applet yo need version 1.5 (false). If you use
                                         // newer versions (2+), then change it to true.
boolean raia_project = true;             // Plots the logos of our project. Change it to "false".
String filepath_oil = "dods://centolo.co.ieo.es:8080/thredds/dodsC/ROMS-IEO/ROMS1km/Horario/Raia_drift_oil.nc";
                                         // File path that contains displacements due to surface currents + 3% of wind speed
String filepath_passive = "dods://centolo.co.ieo.es:8080/thredds/dodsC/ROMS-IEO/ROMS1km/Horario/Raia_drift_passive.nc";
                                         // File path that contains ONLY displacements due to surface currents
String filename_map = "BaseMapDrift_320_480_cities.png"; // Place it in the "data" folder of your Processing sketch
int year_reference_roms = 2009;          // If your reference is not Jan 1 of a specific year, modify Calendar options in RaiaCO.pde 
boolean language_Spanish = true;         // Otherwise, the information will be plotted in English.
float animFrameInterval = 150;           // In milliseconds. Controls the behaviour of the plotting
float minlon = -10.48;                   // Minimum longitude of the domain
float minlat = 40.72;                    // Minimum latitude of the domain
float lonlength = 2.73;                  // West-East length of the domain in degrees
float latlength = 3.68;                  // South-North length of the domain in degrees
float hoverPathDuration = 5*86400;       // Time length of the trajectories (in seconds)
int hoverPathReplicates = 10;            // Number of trajectories departing from the same location
int animMaxRadius = 50;                  // Maximum radius in pixels of the draggable circle in animation 
float stuckness = 0.01;                  // Controls the approach to coast in the closest cell to land; 0 = land 1 = water.
float Kjitter = 65;                      // Turbulent horizontal diffusion. Controls the diffusive (naive) random walk model.
                                         // ...an estimation is given by (10^(-7))^(1/3) * L^(4/3), where L is the width of the cell
                                         // in meters, which is the unresolved horizontal spatial scale of the hydrodinamic model.
//-------------------------------     END OF USER SPECIFIC OPTIONS   ----------------------------      


Gui gui;
Display display;
Stylesheet masterStylesheet;

PImage imagenfondo;

SimpleThread thread1;
SimpleThread thread2;
Flow F, F2;

boolean userStartedDoingStuff = false;  // The user started to doing some stuff
boolean inicia = true;                  // The visualization has started
boolean cargado = false;                // The first file (oil) has been completely loaded
boolean doonce1 = false;                // Has the first file (oil) started to be downloaded? 
boolean doonce2 = false;                // Has the second file (passive) started to be downloaded? 
boolean alldone = false;                // All files have been downloaded
boolean loadinginfocount = false;       // The program did not reach the loading netcdf data section

int flowindex=0;                        //This is the index of the flow

void setup() {
  
  size(320,480); 
  
  smooth();
  
  masterStylesheet = new Stylesheet();
  masterStylesheet.loadFonts();
  display = new RaiaCODisplay();
  gui = new RaiaCOGui();
  gui.display = display;
  display.gui = gui; 
  
  //Data from "oil" file are downloaded during setup. After finishing, a new thread (running behind drawing) downloads data from the "passive" file 
  thread1 = new SimpleThread(0,filepath_oil);
  thread2 = new SimpleThread(0,filepath_passive);
}

void draw() {
      
  if(cargado == false && doonce1 == false) {
       thread1.start();
       doonce1 = true;
  }
  
  if(thread1.running == true) {
       background(51);
       if(loadinginfocount==false) {
          masterStylesheet.setFont(masterStylesheet.smallFontSize);
          //fill(masterStylesheet.orangeColor);
          fill(masterStylesheet.orangeColor);
          stroke(255);
          textAlign(CENTER);
          if(language_Spanish) {
            text("Conectando...", width/2, height*3/5);  
          } else {
            text("Connecting...", width/2, height*3/5);
          }   
       }  else {
          if(language_Spanish) {
            text("Cargando...", width/2, height*3/5);  
          } else {
            text("Loading...", width/2, height*3/5);
          }   
       }  
  }
 
  if(thread1.running == false && cargado ==false && doonce1 == true && doonce2 == false) {    
       thread2.start();
       cargado = true;    
  }
       
  if(cargado == true) { 
    if(doonce2 == false) {
      doonce2 = true;
      display.addFlow(F, masterStylesheet.dkGrayColor);
      display.animEndTime = display.flows[0].lastTime()-2*display.timestep; 
    }  
    display.update();
    gui.update();
  } 
   
}

void mousePressed() {
  gui.offerMousePress();
}

void mouseDragged() {
  if (!gui.offerMouseDrag()) display.offerMouseDrag();
}

void mouseReleased() {
  if (!gui.offerMouseRelease()) display.offerMouseRelease();
}

void mouseMoved() {
  userStartedDoingStuff = true;
}
