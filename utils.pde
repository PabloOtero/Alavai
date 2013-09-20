// color -----------------------------------------------------------------------------------------

color shift(color col, float r) {
  if (r>0) {
    return lerpColor(col,color(255,255,255,alpha(col)),r);
  } 
  else {
    return lerpColor(col,color(0,0,0,alpha(col)),-r);
  }
}

color lighten(color col) {
  return shift(col,0.25);
}

color darken(color col) {
  return shift(col,-0.25);
}

color transparency(color col, float f) {
  return color(red(col),green(col),blue(col),f*alpha(col));
}

color desaturate(color col, float f) {
  return lerpColor(col, desaturate(col), f);
}
color desaturate(color col) {
  return color(brightness(col),brightness(col),brightness(col),alpha(col));
}


// math -----------------------------------------------------------------------------------------


float[] firstRow(float[][] A) {
  return A[0];
}

float[] firstCol(float[][] A) {
  float[] x = new float[A[0].length];
  for (int i=0; i<x.length; i++) x[i] = A[i][0];
  return x;
}


float[] zeros(int I) {
  float[] a = new float[I];
  for (int i=0; i<I; i++) a[i] = 0;
  return a;
}
float[][] zeros(int J, int I) {
  float[][] a = new float[J][I];
  for (int j=0; j<J; j++) for (int i=0; i<I; i++) a[j][i] = 0;
  return a;
}
float[][][] zeros(int K, int J, int I) {
  float[][][] a = new float[K][J][I];
  for (int k=0; k<K; k++) for (int j=0; j<J; j++) for (int i=0; i<I; i++) a[k][j][i] = 0;
  return a;
}


float Inf = 1./0.;
float almostInf = 1e20;
boolean isfinite(float a) {
  return (a<almostInf) && (a>-almostInf);
}
boolean isnan(float a) {
  return !((a>0) || (a<=0));
}


void finitize(float[] a) {
  for (int i=0; i<a.length; i++) {
    if (!isfinite(a[i])) a[i] = 0;
  }
}
void finitize(float[][] a) {
  for (int j=0; j<a.length; j++) {
    for (int i=0; i<a[0].length; i++) {
      if (!isfinite(a[j][i])) a[j][i] = 0;
    }
  }
}
void finitize(float[][][] a) {
  for (int k=0; k<a.length; k++) {
    for (int j=0; j<a[0].length; j++) {
      for (int i=0; i<a[0][0].length; i++) {
        if (!isfinite(a[k][j][i])) a[k][j][i] = 0;
      }
    }
  }
}


int findIndexBefore(float[] x, float xi) {
  // assumes x is monotonic and increasing
  // return -1 if xi is out of range
  if (xi < x[0]) return -1;
  if (xi > x[x.length-1]) return -1;
  int nbefore = 0;
  int nafter = x.length-1;
  while (nafter-nbefore > 1) {
    int nmid = (nbefore+nafter)/2;
    if (xi > x[nmid]) {
      nbefore = nmid;
    } 
    else {
      nafter = nmid;
    }
  }
  return nbefore;
}


int findNearest(float[] x, float xi) {
  // assumes x is monotonic and increasing
  // always returns a valid index
  if (xi <= x[0]) return 0;
  if (xi >= x[x.length-1]) return x.length-1;
  int nbefore = 0;
  int nafter = x.length-1;
  while (nafter-nbefore > 1) {
    int nmid = (nbefore+nafter)/2;
    if (xi > x[nmid]) {
      nbefore = nmid;
    } 
    else {
      nafter = nmid;
    }
  }
  if (xi < 0.5*(x[nbefore]+x[nafter])) {
    return nbefore;
  } 
  else {
    return nafter;
  }
}


float interp2(float[] y, float[] x, float[][] z, float yi, float xi) {
  int j0 = findIndexBefore(y,yi);
  int i0 = findIndexBefore(x,xi);
  if (i0==-1 || j0==-1) return z[findNearest(y,yi)][findNearest(x,xi)];
  float b = (yi-y[j0]) / (y[j0+1]-y[j0]);
  float a = (xi-x[i0]) / (x[i0+1]-x[i0]);
  float result = (1-b)*(1-a)*z[j0][i0] + b*(1-a)*z[j0+1][i0] + (1-b)*a*z[j0][i0+1] + b*a*z[j0+1][i0+1];
  return result;
}


float randn() { // normally distributed random number with std dev 1
  return sqrt(-2*log(random(1)))*cos(TWO_PI*random(1));
}


float[] centerdiff(float[] x) {
  float[] dx = new float[x.length];
  for (int i=1; i<x.length-1; i++) {
    dx[i] = 0.5*(x[i+1]-x[i-1]);
  }
  dx[0] = dx[1];
  dx[x.length-1] = dx[x.length-2];
  return dx;
}



// strings -----------------------------------------------------------------------------------------



String fileSuffix(String filename) {
  String[] tok = split(filename,'.');
  if (tok.length<2) {
    return null;
  } 
  else {
    return tok[tok.length-1];
  }
}


String nicenum(float a) {
  if (a==round(a)) {
    return "" + round(a);
  } else {
    return "" + a;
  }
}


void textVAlign(String S, float x, float y) {textVAlign(S,x,y,"baseline");}
void textVAlign(String S, float x, float y, String align) {
  if (align.equals("baseline")) {
    text(S,x,y);
  } else if (align.equals("middle")) {
    text(S,x,y+0.5*(textAscent()));
  } else if (align.equals("bottom")) {
    text(S,x,y-textDescent());
  } else if (align.equals("top")) {
    text(S,x,y+textAscent());
  }
}


