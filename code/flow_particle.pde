// Flow and Particle are the two classes that house the actual technique for representing the flow and tracking particles in it.
// it should be possible to change the internals of the return-map method substantially and not change anything except this file.

class Flow {
  
  boolean visible = true;
  float timestep;
  float[] timemodel;
  float[] X, Y;
  float[] T;
  float[] T2;
  float[][][] Xnext, Ynext; // time x n_alternates x J x I
  float[][] mask;
  int[] ind;
  int I, J, NF;
  boolean cyclic = false;
  float cyclePeriod;
  String filenames;
  boolean indicesInFirstFileOnly = false;
  boolean preloading = true;
  int nextToPreload = 0;
  boolean animatable = true;
  boolean hoverable = true;

  Stylesheet styles = masterStylesheet;

  Flow() {}
    
  Flow(String filenames) {this(filenames, false);}
  
  Flow(String filenames, boolean iiffo) {
    /* the flow data is stored as follows:
    each netcdf file stores one timestep: one displacement map showing where a cartesian grid of points will be after some time interval.
    this map can be multiply valued, since particles might be tracked including random diffusion, such that one start location on the grid
    has multiple end locations. That's what "numAlternates" and "nAlt" are about.
    within each file:
    x, y are 1-d arrays that specify a cartesian grid
    ind is a linear index into points in that grid (mapping the 2 spatial dimensions onto one index the same way matlab does)
    xnext and ynext are arrays the same length (in the first dimension) as ind, giving end locations
    */
    this.filenames = filenames;
    indicesInFirstFileOnly = iiffo;
 
    
//    NetcdfFile nc = nc_open(filenames); // Open a local file. POT
    //Open a remote NetCDF file
    NetcdfFile nc = null;
    try { 
      nc = NetcdfDataset.openFile(filenames, null);
    } catch (IOException ioe) {
      textAlign(CENTER);
      if(language_Spanish) {   
         text("ERROR AL CONECTARSE. INTENTELO MAS TARDE.",width/2, height*3/5+40);
      } else {
         text("CONNECTING ERROR! PLEASE, TRY IT LATER.",width/2, height*3/5+40);
      }   
      noLoop();
     } 
     /*
     finally { 
      if (null != nc) try {
        nc.close();
     } catch (IOException ioe) {
        println("trying to close " + filenames + ioe);
     }
    } 
    */   
    //End of connecting process
    
    X = nc_read1D(nc,"x");
    Y = nc_read1D(nc,"y");  
    //nAlt = round(nc_readOne(nc,"numAlternates"));
    T = nc_read1D(nc,"timemodel");    
    timestep = round(T[2]-T[1]);
    
    I = X.length;
    J = Y.length; 
    
    NF = T.length;
    Xnext = new float[NF][J][I];
    Ynext = new float[NF][J][I];
    mask  = new float[J][I];
       
      //read frames of flow information
      int nCells = (int) nc_readOne(nc,"numCells");      
      float[][] xn = new float[NF][nCells];
      float[][] yn = new float[NF][nCells];

      ind = nc_read1D_int(nc,"ind"); // ind can theoretically change between files (if there's wetting and drying, for example), but load the first frame's version now in case it doesn't and the other files omit it  
      
      xn = nc_read2D(nc,"xnext");   
      yn = nc_read2D(nc,"ynext");
      //ind =  (int) nc_readOne(nc,"ind");
      
      //Indices in Matlab start to count at 1, here start at 0 
      for (int i=0; i<ind.length; i++) {
         ind[i]=ind[i]-1;
      }
      
     if (nCells != ind.length) println("warning: wrong number of points in file (ind.length = " + ind.length + ", nCells = " + nCells +")");
      nc_close(nc);
      // blank out Xnext, Ynext (setting everything to what a land cells would have)
     for (int t=0; t<NF; t++) {
        for (int j=0; j<J; j++) {
          for (int i=0; i<I; i++) {
            Xnext[t][j][i] = X[i];
            Ynext[t][j][i] = Y[j];
            if(t==0) {
              mask[j][i] = 0;
            }  
          }
        }
      }
      
    styles.setFont(styles.smallFontSize);
    fill(styles.orangeColor);
    stroke(255);
    textAlign(CENTER);
    
      // now fill in the valid values from xn,yn, rescaling to lat-lon units
     for (int t=0; t<NF; t++) {
      if(cargado == false) {     
        if(t==0) { loadinginfocount = true; }
      }  
      for (int m=0; m<nCells; m++) {
        int i = ind2i((int) ind[m]);
        int j = ind2j((int) ind[m]);

        Xnext[t][j][i] = map(xn[t][m], -32768, 32767, X[0], X[I-1]);
        Ynext[t][j][i] = map(yn[t][m], -32768, 32767, Y[0], Y[J-1]); 
        if(t==0) {
         mask[j][i] = 1;  
        }
       } 
      }     
  }
  
  
  float firstTime() {return T[0];}
  float lastTime() {return T[T.length-1];}
  float lastLoadedTime() {return T[max(nextToPreload-1,0)];}
  
  // 1D - 2D index conversions
  int ij2ind(int i, int j) {return i*Y.length + j;}
  int ind2i(int ind) {return ind / Y.length;}
  int ind2j(int ind) {return ind % Y.length;}
  int[] ind2ij(int ind) {return new int[] {ind % Y.length, ind / Y.length};}
  //int[] ind2ij(int ind) {return new int[] {ind / Y.length, ind % Y.length};}
  
  
  // index - coordinate conversions
  float i2x(int i0) {return X[round(i0)];}
  float j2y(int j0) {return Y[round(j0)];}
  float n2t(int n0) {return T[round(n0)];}
  int x2i(float x0) {return findNearest(X,x0);}
  int y2j(float y0) {return findNearest(Y,y0);}  
  int t2n(float t0) {
    if (cyclic) {
      return findNearest(T,t0 % cyclePeriod);
    } else {
      return findNearest(T,t0);
    }
  }
  int xy2ind(float x0, float y0) {return ij2ind(x2i(x0), y2j(y0));}
  float[] ind2xy(int ind) {
    int[] ij = ind2ij(ind);
    return new float[] {i2x(ij[0]), j2y(ij[1])};
  }

  // flow information
  float[] interpXYnext(float x0, float y0, float t0) {
    float xn = interp2(Y, X, Xnext[t2n(t0)], y0, x0);
    float yn = interp2(Y, X, Ynext[t2n(t0)], y0, x0);
    return new float[] {xn,yn};
  }
  
  //float interpMask(float x0, float y0, float t0) {
  //  return interp2(Y, X, mask[t2n(t0)], y0, x0);
  //}
  
  float interpMask(float x0, float y0) {
    return interp2(Y, X, mask, y0, x0);
  }

}



// -------------------------------------------------------------------------------------



class Particle {
  // a single location/time, updateable but with no memory

  Flow flow;
  float t, age;
  float x, y; // position
  float mask = 1;
  //float Kjitter = 10;

  Particle() {}
  
  Particle(float x, float y, float t, Flow flow) {
    this.flow = flow;
    this.x = x;
    this.y = y;
    this.t = t;
    mask = flow.interpMask(x,y);
    //this.mask = mask;
    age = 0;
  }
  
  boolean stuck() { // there are loose and strict ways of defining stuckness
    return (mask < stuckness); 
  }
  
  void takeStep() {
    t += flow.timestep; // no matter what, time advances
    age += flow.timestep;
    if (!stuck()) {
      // the actual step
      float[] xy1 = flow.interpXYnext(x,y,t);
      x = xy1[0];
      y = xy1[1];
      //mask = flow.interpMask(x,y,t);
      // jitter
      
      // Here, we use a random walk model normalized with a distribution of mean = 0 and standard deviation = 1
      // This is the reason why the standard deviation (is 1) does not appear inside the square expression
      float dx = sqrt(2*Kjitter*abs(flow.timestep)) * constrain(randn(),-2,2) / 111325 / cos(y/180.*PI);
      float dy = sqrt(2*Kjitter*abs(flow.timestep)) * constrain(randn(),-2,2) / 111325;
      
      //Or... should we split the unidimensional random walk model in both directions?
      //float mial1=constrain(randn(),-2,2);
      //float mial2=random(1);
      //float dx = sqrt(2*Kjitter*abs(flow.timestep)) * mial1 * cos(2*PI*mial2) / 111325 / cos(y/180.*PI);
      //float dy = sqrt(2*Kjitter*abs(flow.timestep)) * mial1 * sin(2*PI*mial2) / 111325;
      
      float mask1 = flow.interpMask(x+dx,y+dy);
      
      if (mask1 > mask) { // apply the jitter only if it moves particles away from the coastline (or in open water)
        x += dx;
        y += dy;
        mask = mask1;
      }   
    }
  }
  
  void calcToTime(float tend) {
    if (flow.timestep > 0) {
      while (t < tend) takeStep();
    } else {
      while (t > tend) takeStep();
    }
  }
  
  Particle clone() {
    return new Particle(x,y,t,flow);
  }
  
}


// --------------------------------------------------------------------------------------------------


class Trajectory {// like a particle, but saves its history
  
  Particle[] pos = new Particle[0];
  int length = 0;
  
  Trajectory() {}
  
  Trajectory(float x, float y, float t, Flow flow) {
    addPos(new Particle(x,y,t,flow));
  }
  
  void addPos(Particle pos1) {
    pos = (Particle[]) append(pos, pos1);
    length++;
  }
  
  void takeStep() {
    Particle pos1 = pos[length-1].clone();
    pos1.takeStep();
    addPos(pos1);
  }
  
  void calcToTime(float tend) {
    if (pos[0].flow.timestep > 0) {
      while (pos[length-1].t < tend) takeStep();
    } else {
      while (pos[length-1].t > tend) takeStep();
    }
  }
  
  void brieflyCalcTowardTime(float tend, float maxCalcTime) {
    float tic = millis();
   
    if (pos[0].flow.timestep > 0) {   
      while (pos[length-1].t < tend && (millis()-tic < maxCalcTime)) takeStep();
    } else {
      while (pos[length-1].t > tend && (millis()-tic < maxCalcTime)) takeStep();
    }
  }
  
  float[] x() {
    float[] result = new float[length];
    for (int i=0; i<result.length; i++) result[i] = pos[i].x;
    return result;
  }
  
  float[] y() {
    float[] result = new float[length];
    for (int i=0; i<result.length; i++) result[i] = pos[i].y;
    return result;
  }
  
  float[] t() {
    float[] result = new float[length];
    for (int i=0; i<result.length; i++) result[i] = pos[i].t;
    return result;
  }
  
  float[] age() {
    float[] result = new float[length];
    for (int i=0; i<result.length; i++) result[i] = pos[i].age;
    return result;
  }
  
  Particle atTime(float t0) {
    float[] T = t();
    if (t0 < T[0] || t0 > T[T.length-1]) return null;
    int n = findNearest(T, t0);
    return pos[n];
  }
 
}
