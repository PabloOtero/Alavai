class RaiaCOGui extends Gui {
  
  Toolbar controller;
  Slider timeSlider;
  TextLabel dateLabel;
  
  IconButton buttonoil, buttonpassive;

  PImage logoRaia, logoIEO, iconOil, iconPassive, logoinfo;
  int columns, rows;
  float count=0.0;
  int newpos2;
  
  boolean infopressed = false;
  float comienzoinfo;  
  boolean displaywarning = false; 

  
  RaiaCOGui() {
    
    controller = new Toolbar(0, styles.guiMargin, width, styles);
    dateLabel = controller.addTextLabel("", 110);
    dateLabel.textSize = styles.normalFontSize;
    timeSlider = controller.addSlider("", 4*styles.guiHeight, -300, 0); 
    timeSlider.showValOnRight = false;
    
    if(raia_project) {
     logoIEO  = loadImage("logoIEO.png");
     logoRaia = loadImage("logoRaia.png");
     logoinfo = loadImage("inforaia.png");
     columns  = logoRaia.width;   
     rows     = logoRaia.height;    
    }
    
    buttonoil = controller.addIconButton("Oil","icon_oilspill.png");
    float[] posoil = {width-42,2,40,40};
    buttonoil.setPosition(posoil);
 
    buttonpassive = controller.addIconButton("Passive","icon_passive.png");
    float[] pospassive = {width-84,2,40,40};
    buttonpassive.setPosition(pospassive);
      
    buttonoil.awake = true;
    buttonpassive.awake = false;
    
  }
  
  boolean over() {
    return mouseY <= styles.guiHeight + 2*styles.guiMargin;
  }
  
  void update() {
    
     
     // When the app starts, two logos appear rotating over their central axis.
     if(inicia) {
      loadPixels();
      count++;   
      if(raia_project) {
       float angular=cos((count/15)%(2*PI)); //15 means that we recompute location each 1/15s (take into account that the refreshing time is 60fps)
       if(angular>-0.95) {
       for ( int i = 0; i < columns;i++) {
        for ( int j = 0; j < rows;j++) {
         int loc = i + columns*j;              // Pixel array location
         color c = logoRaia.pixels[loc];       // Grab the color
         color c2 = logoIEO.pixels[loc];       // Grab the color
         pushMatrix();   
         if(millis()<2000) {       
          fill(c);
          newpos2=floor( (i-columns/2) );
         } else if( millis()>=2000 && angular>=0) {
          fill(c);
          newpos2=floor( (i-columns/2)*angular ); 
         } else if( millis()>=2000 && angular<0){     
          fill(c2);
          newpos2=floor( (i-columns/2)*angular*-1 ); 
         }    
         translate(width/2+newpos2,height/2-rows/2+j);
         noStroke();
         rect(0,0,2,2);
         popMatrix();
        }  
       }        
      } else {   
       inicia=false;
      }
     }
    } 
    
     
    if (display==null) return;
    
    fill(200,180);
    stroke(150);
    strokeWeight(1);
    rect(0, 0, width, styles.guiHeight + 2.5*styles.guiMargin);
  
    Calendar cal = Calendar.getInstance();                  //Create a "Calendar" instance
    Calendar calnow = Calendar.getInstance();   
    cal.set(year_reference_roms,0,1,0,0,0);                                //Adjust the calendar to the start date of the ROMS configuration 
    cal.add(Calendar.SECOND,floor(display.virtualTime));    //Add the current time step in seconds   
    TimeZone tz = cal.getTimeZone();                        //TimeZone represents a time zone offset, and also figures out daylight savings.
    int offset = tz.getRawOffset();                         //And see which is the corresponding offset (e.g., +1 in Madrid)  
    Date date = cal.getTime();                              //Create a Calendar object based on the current time. Is there Day light time savings? (e.g, +1h in summer) 
    //if(tz.inDaylightTime(date)){
    //    offset = offset + tz.getDSTSavings();
    //    print("offset 2 = " + offset);
    //}
    int offsetHrs = offset / 1000 / 60 / 60;
    cal.add(Calendar.HOUR,offsetHrs);                       //Add the daylight saving and GMT offset to the model time.   
    
    if(cargado && count==2.0) {  
     float difTime = floor((calnow.getTimeInMillis()-cal.getTimeInMillis()+offset)/1000/3600); //From milliseconds to hours   
      timeSlider.setPos(difTime/120);
    }
 
    int aa = cal.get(Calendar.YEAR); 
    int mm = cal.get(Calendar.MONTH); 
    int dd = cal.get(Calendar.DATE);
    int hh = cal.get(Calendar.HOUR_OF_DAY);
    
    if(language_Spanish) {
        String mestexto[] = {"Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic"}; 
        dateLabel.name = dd + " " + mestexto[mm] + " " + aa + ", " + hh + ":00";
    } else {
        String mestexto[] = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};
        dateLabel.name = dd + " " + mestexto[mm] + " " + aa + ", " + hh + ":00";
    }    
             
    if (!display.animating) {
      fill(255);    
      textAlign(CENTER);
      if(language_Spanish) {
        text("Pincha y arrastra en el mapa para animar",width/2,60);
      } else {
        text("Click and drag to animate",width/2,60);
      }          
    } else {
      fill(255);
      textAlign(CENTER);
      if(language_Spanish) {
        text("Pincha para parar la animación",width/2,60);
      } else {
        text("Click to stop animation",width/2,60);
      } 
    }

   
    boolean hit = controller.update();
    if (hit) {      
      display.stopAnimation();  //If the slider change, stop the animation
        
        if (controller.lastUpdated.equals("Oil")) {
          if(alldone == true) {
            flowindex=0;
            display.flows[1].visible = false;
          }  
          display.flows[0].visible = true; 
          buttonoil.estado = true;
          buttonpassive.estado = false;
        }  else if (controller.lastUpdated.equals("Passive")) {
          if(alldone == true) {
             flowindex=1;
             display.flows[1].visible = true;
             display.flows[0].visible = false;
             buttonoil.estado = false;
             buttonpassive.estado = true;     
          } else {
             flowindex=0;    
             displaywarning = true;
             comienzoinfo = millis();
             display.flows[0].visible = true; 
             buttonoil.estado = true;
             buttonpassive.estado = false;
          }
        }          
    }
    
    if (buttonoil.over() || buttonpassive.over()) {
       fill(masterStylesheet.ltBlueColor,150);
       rect(width-145, styles.guiHeight+25, 140, 40); 
       fill(255);
       if(buttonoil.over()) {
         if(language_Spanish) {
          text("Vertido hidrocarburo",width-70,styles.guiHeight+50); 
         } else {
          text("Oil spill",width-70,styles.guiHeight+50); 
         }
       } else {
          if(language_Spanish) {
          text("Corrientes a 1 m",width-70,styles.guiHeight+50); 
          } else {
          text("Surface currents",width-70,styles.guiHeight+50); 
         }
       } 
    }  
    
     
    //If the thread is still opened, a warning message appear on screen 
    if(displaywarning) {
     int durainfo = round( (millis()-comienzoinfo) );
     if(durainfo < 2000) {
       fill(masterStylesheet.ltBlueColor,150);
       rect(width-145, styles.guiHeight+25, 140, 40); 
       fill(255);
       textSize(styles.smallFontSize);
       if(language_Spanish) {
          text("Descargando datos...",width-70,styles.guiHeight+50); 
       } else {
          text("Loading data...",width-70,styles.guiHeight+50); 
       }  
     } else {
       displaywarning = false;
     }    
    }
    
    
    timeSlider.dataMin=display.flows[0].firstTime();
    timeSlider.dataMax=display.flows[0].lastTime();    
    display.animStartByUser = timeSlider.getVal();  
  
    
    fill(0);
    if(language_Spanish) {
          text("Hora inicio",172,38);
       } else {
          text("Start time",172,38);
       }  
   
    if(raia_project) { 
        fill(255);
        ellipse(20,height-20,25,25);
        fill(masterStylesheet.dkBlueColor);
        textSize(18);
        text("?",20+2,height-20+7);
        
        if(infopressed == false && mousePressed && mouseX>20-10 && mouseX<20+10 && mouseY>height-20-10 && mouseY<height-20+10){
          infopressed = true;
          comienzoinfo = millis();
        }  
        if(infopressed) {
          int durainfo = round( (millis()-comienzoinfo)*255/1000);
          if(durainfo<255) { 
            tint(255, durainfo);
          } else {
            tint(255, 255);
          }  
          image(logoinfo,0,0);
        }    
    }
  
    if(cargado ==true && doonce2 == true && thread2.running == false && alldone == false) {  
       noLoop();   
       display.addFlow(F2, masterStylesheet.ltGreenColor);
       alldone = true;
       loop(); 
    }
    
  }

  boolean offerMousePress() {
    if(infopressed) {
      infopressed=false;
      noTint();
    }  
    controller.offerMousePress();
    return over();
  }
  
  boolean offerMouseDrag() {
    return over();
  }
  
  boolean offerMouseRelease() {
    return over();
  }
}



class RaiaCODisplay extends Display {

  RaiaCODisplay() {
    MapAxes A1 = new MapAxes("fulldomain",filename_map, new float[] {0, 0, width, height}, new float[] {minlon, minlat, lonlength, latlength});
    addAxes(A1);
   }
}


