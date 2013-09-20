class Axes {

  // private
  float x0,y0,wd,ht; // screen location
  float xdmin=0, xdmax=1, ydmin=0, ydmax=1; // data ranges
  String topLabel, bottomLabel, leftLabel, rightLabel;
  boolean largeTopLabel = false;
  String[] topTickLabels, bottomTickLabels, leftTickLabels, rightTickLabels;
  float[] topTicks, bottomTicks, leftTicks, rightTicks;
  float leftLabelOffset=0, rightLabelOffset=0, topLabelOffset=0, bottomLabelOffset=0;
  color col = color(0);
  float fontSize = 12;
  Stylesheet styles = masterStylesheet;
  
  // public
  float[] horizGrid, vertGrid;
  boolean gridOn = true, gridOnTop = true; // on top = after the contents of the plot are drawn rather than before
  boolean axesOn = true;
  boolean labelsOn = true, labelsOnTop = true;
  color bkgndColor = color(255,0);
  color gridColor = color(255);
  
  Axes() {}
  
  Axes(float[] rect) {
    setPosition(rect[0], rect[1], rect[2], rect[3]);
  }
  
  Axes(float x0, float y0, float wd, float ht) {
    setPosition(x0,y0,wd,ht);
  }
  
  void setPosition(float x0, float y0, float wd, float ht) {
    this.x0 = x0;
    this.y0 = y0;
    this.wd = wd;
    this.ht = ht;
  }
  
  void setAppearance(color col, float fontSize) {
    this.col = col;
    this.fontSize = fontSize;
  }

  void setXRange(float xdmin, float xdmax) {
    this.xdmin = xdmin;
    this.xdmax = xdmax;
  }
  
  void setYRange(float ydmin, float ydmax) {
    this.ydmin = ydmin;
    this.ydmax = ydmax;
  }
  
  float dataAspectRatio() {
    return ((ydmax-ydmin) / ht) / ((xdmax-xdmin) / wd);
  }

  void setLabels(String where, String label) {
    if (where.equals("left") || where.equals("left of origin") || where.equals("right") || where.equals("right of origin")) {
      setLabels(where, label, horizGrid);
    } else {
      setLabels(where, label, vertGrid);
    }
  }

  void setLabels(String where, String label, float[] ticks) {
    String[] tickLabels = null;
    if (ticks != null) {
      tickLabels = new String[ticks.length];
      for (int i=0; i<ticks.length; i++) tickLabels[i] = nicenum(ticks[i]);
    }
    setLabels(where, label, ticks, tickLabels);
  }
  
  void setLabels(String where, String label, float[] ticks, String[] tickLabels) {
    if (where.equals("left")) {
      leftLabel = label;
      leftTicks = ticks;
      leftTickLabels = tickLabels;
    } else if (where.equals("right")) {
      rightLabel = label;
      rightTicks = ticks;
      rightTickLabels = tickLabels;
    } else if (where.equals("top")) {
      topLabel = label;
      topTicks = ticks;
      topTickLabels = tickLabels;
    } else if (where.equals("bottom")) {
      bottomLabel = label;
      bottomTicks = ticks;
      bottomTickLabels = tickLabels;
    } else if (where.equals("left of origin")) {
      setLabels("left", label, ticks, tickLabels);
      leftLabelOffset = x2scr(0) - left();
    } else if (where.equals("right of origin")) {
      setLabels("right", label, ticks, tickLabels);
      rightLabelOffset = x2scr(0) - right();
    } else if (where.equals("top of origin")) {
      setLabels("top", label, ticks, tickLabels);
      topLabelOffset = y2scr(0) - top();
    } else if (where.equals("bottom of origin")) {
      setLabels("bottom", label, ticks, tickLabels);
      bottomLabelOffset = y2scr(0) - bottom();
    }
  }
  
  float left() {return x0;}
  float right() {return x0+wd;}
  float top() {return y0;}
  float bottom() {return y0+ht;}
  
  float xmin() {return xdmin;}
  float xmax() {return xdmax;}
  float ymin() {return ydmin;}
  float ymax() {return ydmax;}
  
  float scr2x(float s) {return map(s, left(), right(), xmin(), xmax());}
  float scr2y(float s) {return map(s, bottom(), top(), ymin(), ymax());}
  float x2scr(float x) {return map(x, xmin(), xmax(), left(), right());}
  float y2scr(float y) {return map(y, ymin(), ymax(), bottom(), top());}
  
  boolean over(float x, float y) {
    return (x >= left() && x <= right() && y >= top() && y <= bottom());
  }
  boolean over() {
    return over(mouseX,mouseY);
  }

  void drawAxes() {drawAxes(col,1);}
  void drawAxes(color col, float wt) {
    pushStyle();
    stroke(col);
    strokeWeight(wt);
    fill(bkgndColor);
    rectMode(CORNERS);
    rect(left(), top(), right(), bottom());
    popStyle();
  }
  
  void drawLabels() {drawLabels(col,fontSize);}
  
  void drawLabels(color col, float fontSize) {
    float sp = fontSize/4;
    pushStyle();
    fill(col);
    styles.setFont(fontSize);    
    if (leftLabel != null || leftTickLabels != null) {
      textAlign(RIGHT);
      float x = left() + leftLabelOffset - sp;
      float maxWd = 0;
      if (leftTickLabels != null) {
        for (int i=0; i<leftTickLabels.length; i++) {
          textVAlign(leftTickLabels[i], x, y2scr(leftTicks[i]), "middle");
          maxWd = max(maxWd, textWidth(leftTickLabels[i]));
        }
        x -= maxWd - sp;
      }
      if (leftLabel != null) {
        
        pushMatrix();
        if(procession2plus) {         
            rotate(HALF_PI);
            textAlign(CENTER);
            text(rightLabel,x, 0.5*(top()+bottom()));      
        } else {
            translate(x, 0.5*(top()+bottom()));
            rotate(HALF_PI);
            textAlign(CENTER);
            text(leftLabel,0,0);     
        }
        popMatrix(); 
        
      }
    }
    if (rightLabel != null || rightTickLabels != null) {
      textAlign(LEFT);
      float x = right() + rightLabelOffset + sp;
      float maxWd = 0;
      if (rightTickLabels != null) {
        for (int i=0; i<rightTickLabels.length; i++) {
          textVAlign(rightTickLabels[i], x, y2scr(rightTicks[i]), "middle");
          maxWd = max(maxWd, textWidth(rightTickLabels[i]));
        }
        x += maxWd + sp;
      }
      if (rightLabel != null) {
        
 
         pushMatrix();
        if(procession2plus) {         
            rotate(-HALF_PI);
            textAlign(CENTER);
            text(rightLabel,x, 0.5*(top()+bottom()));  
        } else {
            translate(x, 0.5*(top()+bottom()));
            rotate(-HALF_PI);
            textAlign(CENTER);
            text(rightLabel,0,0); 
        }
        popMatrix(); 
                  
      }
    }
    if (topLabel != null || topTickLabels != null) {
      textAlign(CENTER);
      float y = top() + topLabelOffset - sp;
      if (topTickLabels != null) {
        for (int i=0; i<topTickLabels.length; i++) {
          text(topTickLabels[i], x2scr(topTicks[i]), y);
        }
        y -= (textAscent() + sp);
      }
      if (topLabel != null) {
        titleText(topLabel, 0.5*(left()+right()), y); // mechanism for extending classes to write exciting titles
      }
    }
    if (bottomLabel != null || bottomTickLabels != null) {
      textAlign(CENTER);
      float y = bottom() + bottomLabelOffset + sp;
      if (bottomTickLabels != null) {
        for (int i=0; i<bottomTickLabels.length; i++) {
          textVAlign(bottomTickLabels[i], x2scr(bottomTicks[i]), y, "top");
        }
        y += (textAscent() + sp);
      }
      if (bottomLabel != null) {
        text(bottomLabel, 0.5*(left()+right()), y);
      }
    }
    popStyle();
  } // drawLabels
  
  void titleText(String S, float x, float y) {
    textAlign(CENTER);
    if (largeTopLabel) styles.setFont(styles.largeFontSize); // this breaks the independence of the Axes class from the font handling in this applet
    text(S,x,y);
    styles.setFont(styles.normalFontSize);
  }
  
  void drawGrid() {drawGrid(gridColor,0.5);}
  void drawGrid(color col, float wt) {
    pushStyle();
    stroke(col);
    strokeWeight(wt);
    if (horizGrid != null) {
      for (int i=0; i<horizGrid.length; i++) line(left(), y2scr(horizGrid[i]), right(), y2scr(horizGrid[i]));
    }
    if (vertGrid != null) {
      for (int i=0; i<vertGrid.length; i++) line(x2scr(vertGrid[i]), top(), x2scr(vertGrid[i]), bottom());
    }
    popStyle();
  }

  // -------------- call these as brackets around drawing the content of the plot
  void drawBase() {
    if (gridOn && !gridOnTop) drawGrid();
    if (labelsOn && !labelsOnTop) drawLabels();
  }
  
  void drawOnTop() {
    if (gridOn && gridOnTop) drawGrid();
    if (axesOn) drawAxes();
    if (labelsOn && labelsOnTop) drawLabels();
  }
  // ---------------
  
  
  void plot(float X, float Y, color col, String lineSpec, float sz) {
    plot(new float[] {X}, new float[] {Y}, col, lineSpec, sz);
  }

  void plot(float[] X, float[] Y, color col, String lineSpec, float sz) {
    if (lineSpec.equals("o-") || lineSpec.equals("-o")) {
      plot(X,Y,col,"-",sz/4);
      plot(X,Y,col,"o",sz);
    } else {
      stroke(col);
      strokeWeight(sz);
      noFill();
      if (lineSpec.equals("o")) {
        beginShape(POINTS);
      } else {
        beginShape();
      }
      for (int i=0; i<X.length; i++) {
        if (over(x2scr(X[i]), y2scr(Y[i]))) { // only plot points within the axes. Won't work for line segments, just points!
          vertex(x2scr(X[i]), y2scr(Y[i]));
        }
      }
      endShape();
    }
  }

  
}


// -----------------------------------------------------------------------------------------------------------
 
 
 
class MapAxes extends Axes {
  
  String tag;
  PImage bkgndImage;
  String bkgndFilename;
  MapAxes[] insets = new MapAxes[0];
  
  MapAxes(String tag, String filename, float[] scrRect, float[] dataRect) { // give both rects as x0, y0, width, height
    this.tag = tag;
    String suffix = fileSuffix(filename);
    if (suffix==null) {
      println("don't know how to load " + filename + ".");
    } else if (suffix.equals("jpg") || suffix.equals("png")) {
      bkgndFilename = filename;
      bkgndImage = loadImage(bkgndFilename);
    } else {
      println("don't know how to load " + filename + ".");      
    }
    setPosition(scrRect[0], scrRect[1], scrRect[2], scrRect[3]);
    setXRange(dataRect[0], dataRect[0]+dataRect[2]);
    setYRange(dataRect[1], dataRect[1]+dataRect[3]);
    // could do more here regarding labels
    axesOn = false;
    gridOn = false;
  }
  
  void drawBase() {
    image(bkgndImage, left(), top(), right()-left(), bottom()-top());
    for (int i=0; i<insets.length; i++) {
      noFill();
      stroke(60,80);
      strokeWeight(2);
      rectMode(CORNERS);
      rect(x2scr(insets[i].xdmin), y2scr(insets[i].ydmin), x2scr(insets[i].xdmax), y2scr(insets[i].ydmax));
    }
    super.drawBase();
  }
  
  void addInset(MapAxes ax) {
    insets = (MapAxes[]) append(insets, ax);
  }
  
}
 






