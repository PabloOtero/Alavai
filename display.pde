class Display {
  MapAxes[] axes = new MapAxes[0];
  Flow[] flows = new Flow[0];
  color[] flowColors = new color[0];
  float timestep = 0;
  Gui gui;
  Stylesheet styles = masterStylesheet;
  String modelCredits = null;

  float currTime = 0;
  float virtualTime = 0;

  boolean showPathOnHover = true;
  //float hoverPathDuration = 5*86400;
  //int hoverPathReplicates = 10;
  Trajectory[][] hoverPaths;
  float hoverStartMouseX = -1, hoverStartMouseY = -1;

  float selectX0, selectY0, selectR;
  boolean selecting = false;
  MapAxes selectionAxes;
  color selectColor = color(220,150);
  boolean animating = false;
  //int animMaxRadius = 50;
  Particle[] animParticleStart;
  Particle[][] animParticles; // animParticles[j][i] is the ith point within the set of current particle positions for flow j
  int animParticleReps = 1;
  float animLastFrameTime;
  float animEndTime = Inf;
  
  float animStartByUser = 0;
  
 

  Display() {}

  MapAxes addAxes(MapAxes A) {
    axes = (MapAxes[]) append(axes, A);
    return A;
  }

  Flow addFlow(Flow F) {
    return addFlow(F,color(0));
  }
  Flow addFlow(Flow F, color col) {
    flows = (Flow[]) append(flows, F);
    flowColors = (color[]) append(flowColors, col);
    if (timestep == 0) timestep = F.timestep; // set the display timestep from (probably) the first flow added. This can be overridden. 
    return F;
  }
  
  MapAxes overWhich() {
    return overWhich(mouseX, mouseY);
  }
  MapAxes overWhich(float x, float y) {
    for (int i=axes.length-1; i>=0; i--) {
      if (axes[i].over(x,y)) return axes[i];
    }
    return null;
  }

  boolean over(float x, float y) {
    return overWhich(x,y) != null;
  }
  boolean over() {
    return overWhich() != null;
  }

  float[] scr2xy(float sx, float sy) {
    MapAxes ax = overWhich(sx,sy);
    if (ax == null) {
      return null;
    } 
    else {
      return new float[] {
        ax.scr2x(sx), ax.scr2y(sy)
      };
    }
  }


  void update() {
   
        
    // construct a faint trajectory leading forward in time from the point the mouse is hovering over--one path per flowfield    
    if (showPathOnHover && over() && !selecting && !animating) {
      
      //Plots the trajectory from the selected start time step
      virtualTime = display.animStartByUser; 
 
      if (mouseX != hoverStartMouseX || mouseY != hoverStartMouseY) { // new start position: re-initialize the hover paths
        hoverStartMouseX = mouseX;
        hoverStartMouseY = mouseY;
        float[] xyStart = scr2xy(mouseX, mouseY);
        hoverPaths = new Trajectory[1][hoverPathReplicates];
        //for (int i=0; i<1; i++) {
          if (flows[flowindex].visible && flows[flowindex].hoverable) {
            for (int k=0; k<hoverPathReplicates; k++) {            
              hoverPaths[0][k] = new Trajectory(xyStart[0], xyStart[1], display.animStartByUser, flows[flowindex]);                                                                                                              
            }
          }
        //}
      }
      float calcTime = max(20, animFrameInterval) / 2 / hoverPathReplicates; // all flows together get animFrameInterval (or at least 20 ms) to update their hover paths per frame
      //for (int i=0; i<1; i++) { // update the hover paths 
        for (int k=0; k<hoverPathReplicates; k++) {
          if (hoverPaths[0][k] != null) {
            hoverPaths[0][k].brieflyCalcTowardTime(animEndTime, calcTime);
          }
        }
      //} 
    }

    if (animating) {
      // update particle positions  
      if (millis() >= animLastFrameTime + animFrameInterval) {
        animLastFrameTime = millis();
        //for (int j=0; j<1; j++) {
          if (flows[flowindex].visible && flows[flowindex].animatable) {
            for (int i=0; i<animParticles[flowindex].length; i++) {
              animParticles[flowindex][i].calcToTime(currTime + timestep); // assuming that while animating, the advancing particles control currTime; if the user tries to intervene, the animation stops (or something)
            }
          }
        //}
        currTime += timestep;
        virtualTime += timestep;
        if (currTime > animEndTime) startAnimation();
      }
    }

    // in each axes, draw the base background image followed by the hover path for each flowfield, followed by the top layer.
    // all plotting within each axes should be done before the background of the next axes is drawn.
    background(255);
    for (int i=0; i<axes.length; i++) {
      axes[i].drawBase();
     
     // Oil flow (j=0) draws a red cicle if reachs the coastline
      if (!animating && !selecting && userStartedDoingStuff) {
        //for (int j=0; j<1; j++) {
          for (int k=0; k<hoverPathReplicates; k++) {
            if (hoverPaths[0][k] != null) {
              float[] x = hoverPaths[0][k].x();
              float[] y = hoverPaths[0][k].y();
              for (int m=0; m<x.length-1; m++) {
                color colscreen = get(round(axes[i].x2scr(x[m])),round(axes[i].y2scr(y[m]))); //POT
                color colscreenstart = get(round(axes[i].x2scr(x[0])),round(axes[i].y2scr(y[0]))); //POT
                //Draw text indicating how many days gone, e.g. +1d, +2d, +3d
                float resto = m % 24; 
                if(k==0 && m>=1 && resto==0) {
                  String horallegada = "+" + str(m/24) + " d";
                  fill(styles.offWhiteColor);
                  stroke(255);
                  textAlign(LEFT);
                  styles.setFont(styles.smallFontSize);
                  text(horallegada,round(axes[i].x2scr(x[m]))-30,round(axes[i].y2scr(y[m])));
                } 
                //Draw text an red circles indicating how many hours left to reach the coastline, e.g. +17h, +26h...
                if(flowindex==0 && k==0 && m>=1 && colscreen == -1 && colscreenstart!=-1) {
                  String horallegada = "+" + str(m) + " h";
                  fill(styles.dkRedColor);
                  stroke(255);
                  textAlign(LEFT);
                  styles.setFont(styles.normalFontSize);
                  text(horallegada,round(axes[i].x2scr(x[m]))+10,round(axes[i].y2scr(y[m])));
 
                  axes[i].plot(new float[] {x[m],x[m]}, new float[] {y[m],y[m]}, color(180,90,76), "*", 10.0); 
                }            
                  color col = flowColors[flowindex];
                  axes[i].plot(new float[] {x[m],x[m+1]}, new float[] {y[m],y[m+1]}, col, "-", 0.75);             
              }
            }
          //}
        }    
      }
        
      if (animating) {
        // draw particle start locations for the first flow only
        for (int k=0; k<animParticleStart.length; k++) {
          axes[i].plot(animParticleStart[k].x, animParticleStart[k].y, transparency(selectColor, 1./animParticleReps), "o", 4);
        } 
        // draw current particle positions
        //for (int j=0; j<1; j++) {
          if (flows[flowindex].visible && flows[flowindex].animatable) {
            for (int k=0; k<animParticleStart.length; k++) {          
              if (!animParticles[flowindex][k].stuck()) {
               color colscreen = get(round(axes[i].x2scr(animParticles[flowindex][k].x)),round(axes[i].y2scr(animParticles[flowindex][k].y))); //POT
               //Detect if particle is over land (white region in the map => colour of the screen = -1)
               if (flowindex==0 && colscreen==-1){       
                  axes[i].plot(animParticles[flowindex][k].x,animParticles[flowindex][k].y, transparency(masterStylesheet.ltRedColor, 1./sqrt(animParticleReps)), "o", 10.0); //POT
               }     
               axes[i].plot(animParticles[flowindex][k].x, animParticles[flowindex][k].y, transparency(flowColors[flowindex], 1./sqrt(animParticleReps)) , "o", 4);
              }          
           }
          }
        //}
      }
      
     //Plot the coordinates at the right bottom corner of the screen 
     float p = pow(10,2);
     float[] xyStart = scr2xy(mouseX, mouseY);
     fill(styles.dkRedColor);
     stroke(255);
     textAlign(RIGHT);
     styles.setFont(styles.normalFontSize);
     if(mouseX>=1 && mouseX<=width && mouseY>=1 && mouseY<=height) {
      String lonpos = str(round(xyStart[0]*p)/p);
      String latpos = str(round(xyStart[1]*p)/p);
      text(latpos + " N   " + lonpos + " E",width-12,height-12); 
     }   
     axes[i].drawOnTop();
    }

    if (selecting) {
      fill(selectColor);
      noStroke();
      ellipseMode(CENTER);
      ellipse(selectX0, selectY0, 2*selectR, 2*selectR);
    }  
       
  }  //End update()

  void startSelection() {
    selecting = true; // true even if the initial click is in a bad location; that's how we know this drag event has already started
    stopAnimation();  // any click that might start a selection ends the animation
    selectionAxes = overWhich();
    if (selectionAxes != null) {
      selectX0 = mouseX;
      selectY0 = mouseY;
      selectR = 0;
    }
  }

  void offerMouseDrag() {
    if (!selecting) {
      startSelection();
    }
    if (selecting && selectionAxes != null) {
      float x1 = constrain(mouseX, selectionAxes.left(), selectionAxes.right());
      float y1 = constrain(mouseY, selectionAxes.top(), selectionAxes.bottom());
      selectR = dist(x1, y1, selectX0, selectY0);
      selectR = min(selectR, animMaxRadius);
    }
  }

  void offerMouseRelease() {
    if (!selecting) { // just a click
      if (animating) {
        stopAnimation();
        return;
      } 
      else {
        startSelection(); // if it's good conditions for a selection, treat a click as a zero-radius selection
      }
    }
    selecting = false;
    if (selectionAxes != null) {
      setAnimStartPositions(selectX0, selectY0, selectR);
      startAnimation();
    }
  }

  void setAnimStartPositions(float sx0, float sy0, float sr) {
    // convert the selection coordinates to data units
    float[] xy0 = scr2xy(sx0,sy0);
    float x1 = overWhich(sx0,sy0).scr2x(sx0+sr);
    float y1 = overWhich(sx0,sy0).scr2y(sy0+sr);
    float x0 = xy0[0];
    float y0 = xy0[1];
    float rx = x1 - xy0[0];
    float ry = y1 - xy0[1];
    // initialize
    float[] xgrid = flows[0].X;
    float[] ygrid = flows[0].Y;
    animParticleStart = new Particle[0];
    // find all grid points within radius r of (x0,y0)
    for (int i=0; i<xgrid.length; i++) {
      if (xgrid[i] >= x0-rx && xgrid[i] <= x0+rx) {
        for (int j=0; j<ygrid.length; j++) {
          if (ygrid[j] >= y0-rx && ygrid[j] <= y0+rx) {
            float d2 = (xgrid[i] - x0) * (xgrid[i] - x0) / rx / rx + (ygrid[j] - y0) * (ygrid[j] - y0) / ry / ry;
            if (d2 < 1) {
              for (int r=0; r<animParticleReps; r++) {
                animParticleStart = (Particle[]) append(animParticleStart, new Particle(xgrid[i], ygrid[j], currTime, flows[flowindex]));
              }
            }
          }
        }
      }
    }
    if (animParticleStart.length == 0) {
      // make sure at least one point is included
      float xn = xgrid[findNearest(xgrid,x0)];
      float yn = ygrid[findNearest(ygrid,y0)];
      for (int r=0; r<animParticleReps; r++) {
        animParticleStart = (Particle[]) append(animParticleStart, new Particle(xn, yn, currTime, flows[flowindex]));
      }
    }
  }


  void startAnimation() { // same for a cold start and a rewind
    animating = true;
    animLastFrameTime = millis() - animFrameInterval;
    animParticles = new Particle[flows.length][animParticleStart.length];
    for (int i=0; i<animParticleStart.length; i++) {
      //for (int j=0; j<1; j++) {
        animParticles[flowindex][i] = new Particle(animParticleStart[i].x, animParticleStart[i].y, animParticleStart[i].t, flows[flowindex]);
      //}
    }
    currTime = display.animStartByUser;
    virtualTime = display.animStartByUser;
  }

  void stopAnimation() {
    animating = false;
    currTime = display.animStartByUser;
    virtualTime = display.animStartByUser;
  }

  void resumeAnimation() {
    animating = true;
  }
}


