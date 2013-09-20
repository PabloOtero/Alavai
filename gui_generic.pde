// generic_gui 2.1
// neil banas, dec 2010

class Stylesheet { // with the actual stylesheet for the app in the defaults.

  color dkGreenColor = color(10,40,0);
  color medGreenColor = color(66,90,33);
  color ltGreenColor = color(122,140,66);
  color ltltGreenColor = color(169,190,99);
  // ----
  color dkTealColor = color(6,34,44);
  color medTealColor = color(36,72,72);
  color ltTealColor = color(66,110,104);
  color ltltTealColor = color(96,148,136);
  // ----
  color dkBlueColor = color(14,30,60);
  color medBlueColor = color(34,65,105);
  color ltBlueColor = color(54,100,150);
  color ltltBlueColor = color(74,135,195);
  // ----
  color dkPurpleColor = color(57,24,51);
  color medPurpleColor = color(80,53,73);
  color ltPurpleColor = color(103,81,95);
  color ltltPurpleColor = color(126,108,117);
  // ----
  color dkRedColor = color(112,15,0);
  color medRedColor = color(146,54,38);
  color ltRedColor = color(180,90,76);
  color ltltRedColor = color(214,126,114);
  // ----
  color orangeColor = color(186,92,38);
  color yellowColor = color(191,146,54);
  // ----
  color offWhiteColor = color(255,255,243);
  color dkBrownColor = color(77,47,31);
  color medBrownColor = color(125,88,64);
  color ltBrownColor = color(185,142,92);
  color dkGrayColor = color(0);
  color medGrayColor = color(102);
  color ltGrayColor = color(204);

  String fontFamily = "BentonSans-Regular";
  int smallFontSize = 10;
  int normalFontSize = 12;
  int largeFontSize = 18;
  int[] fontSizes = {smallFontSize, normalFontSize, largeFontSize};
  PFont[] fonts;
  float guiHeight = 24;
  float guiMargin = 8;
  float textBtnTextSize = 13;
  float iconBtnTextSize = 10;
  float sliderHeight = 10;
  float sliderTextSize = 12;
  color bkgndColor = color(230);
  color labelColor = color(0);
  color[] btnPalette = {color(0), ltGreenColor, medGreenColor, dkGreenColor};
  color sliderLabelColor = color(0);
  color sliderBkgndColor = color(255);
    
  Stylesheet() {}
  
  void loadFonts() {    
    fonts = new PFont[fontSizes.length];
    for (int i=0; i<fontSizes.length; i++) {
      fonts[i] = loadFont(fontFamily + "-" + fontSizes[i] + ".vlw");
    }
    textFont(fonts[0]);
  }
  
  int smallFontSize() {return fontSizes[0];}
  int normalFontSize() {return fontSizes[1];}
  int largeFontSize() {return fontSizes[2];}
  int maxFontSize() {return fontSizes[3];}
    
  void setFont(float fs) {
    fs = constrain(fs, fontSizes[0],fontSizes[fontSizes.length-1]);
    int i=0;
    while (i<fontSizes.length && fs > fontSizes[i]) i++;
    i = constrain(i,0,fontSizes.length-1);
    textFont(fonts[i]);
    textSize(fs);
  }
  
}


// --------------------------------------------------------------------------------------


class GuiElement {
  String name = "";
  float x0, y0, width, height;
  boolean hidden = false;
  boolean alwaysAwake = false;
  Stylesheet styles = masterStylesheet;

  GuiElement() {}
  
  boolean update() {return false;}  

  boolean offerMousePress() {return false;}  

  float[] getPosition() {
    return new float[] {x0, y0, width, height};
  }
  
  void setPosition(float[] pos) {
    x0 = pos[0];
    y0 = pos[1];
    width = pos[2];
    height = pos[3];
  }
  
  void setPosition(float x, float y, float wd, float ht) {
    x0 = x;
    y0 = y;
    width = wd;
    height = ht;
  }
  
  float left() {return x0;}
  float right() {return x0+width;}
  float top() {return y0;}
  float bottom() {return y0+height;}
  
  boolean over() {
    return mouseX >= left()  &&  mouseX <= right()  &&  mouseY >= top()  &&  mouseY <= bottom();
  }
  
}


// -----------------------------------------------------------------------------------

 
class Button extends GuiElement { // a clickable region, no visible labeling
  boolean awake = false;
  boolean pressed = false;
  
  Button() {}

  Button(String name, float x, float y, float wd, float ht, Stylesheet styles) {
    this.name = name;
    setPosition(x,y,wd,ht);
  }
  
  color areaColor() {
    if (pressed) {
      return(styles.btnPalette[3]);
    } else if (over() || alwaysAwake) {
      return(styles.btnPalette[2]);
    } else {
      return(styles.btnPalette[1]);
    }
  }
  
  color textColor() {
    if (pressed) {
      return(styles.btnPalette[3]);
    } else if (over() || alwaysAwake) {
      return(styles.btnPalette[2]);
    } else {
      return(styles.btnPalette[0]);
    }
  }

  void draw() {
    pushStyle();
    noStroke();
    fill(areaColor());
    rectMode(CORNER);
    rect(x0,y0,width,height);
    popStyle();
  }
  
  boolean offerMousePress() {
    pressed = over() && (!hidden);
    return pressed;
  }
  
  boolean update() { // returns true when the button is released.
    boolean result = false;
    if (pressed) {
      awake = over();
      pressed = mousePressed;
    }
    if (awake && (!mousePressed)) {
      pressed = false;
      awake = false;
      result = true;
    } 
    if (!hidden) {
      draw();
    }
    return result;
  }
  
}


// -----------------------------------------------------------------------------------


class TextButton extends Button {
  
  boolean outline = false;
  float textSize;
  
  TextButton(String name, float x, float y, float wd, float ht, Stylesheet styles) {
    this.name = name;
    this.styles = styles;
    textSize = styles.textBtnTextSize;
    setPosition(x,y,wd,ht);
  }

  TextButton(String name, float x, float y, float ht, Stylesheet styles) {
    this.name = name;
    this.styles = styles;
    textSize = styles.textBtnTextSize;
    pushStyle();
    styles.setFont(textSize);
    setPosition(x,y,textWidth("  " + name + "  "),ht);
    popStyle();
  }

  void draw() {
    pushStyle();
    fill(textColor());
    noStroke();
    styles.setFont(textSize);
    textAlign(CENTER);
    text(name, x0 + width/2., y0 + height/2. + 0.5*textAscent());   
    if (outline) {
      strokeWeight(1);
      stroke(255);
      noFill();
      rectMode(CORNERS);
      rect(x0, y0, x0+width, y0+height);
    }
    popStyle(); 
  }
  
}


class TextLabel extends TextButton {
  
  TextLabel(String name, float x, float y, float wd, float ht, Stylesheet styles) {
    super(name, x, y, wd, ht, styles);
  }

  TextLabel(String name, float x, float y, float ht, Stylesheet styles) {
    super(name, x, y, ht, styles);
  }
  
  color textColor() {
    return styles.labelColor;
  }
  
  boolean update() {
    if (!hidden) draw();
    return false;
  }
    
}


// -----------------------------------------------------------------------------------


class IconButton extends Button {
  
  PImage[] imgs = new PImage[1];
  String[] names = new String[1];
  int current = 0;
  String lastSelected = "";
  
  boolean estado = false; 
  
  IconButton(String name, float x, float y, String filename, Stylesheet styles) {
    this.styles = styles;
    //names[current] = name;
    this.name = name;
    imgs[current] = loadImage(filename);
    setPosition(x,y,imgs[current].width,imgs[current].height);
  }
  
  void addState(String name, String filename) {
    imgs = (PImage[]) append(imgs, loadImage(filename));
    names = (String[]) append(names, name);    
  }

  void draw() {
    pushStyle();
    if (imgs[current] != null) {
      //tint(areaColor());
      //tint(255, 126);
      if (pressed || estado) {
        tint(255, 255);
      } else if (over() || alwaysAwake) {
        tint(255, 240);
      } else {
        tint(255, 100);
      }     
      image(imgs[current],x0,y0);
    } else {
      fill(areaColor());
      noStroke();
      rectMode(CORNERS);
      rect(x0,y0,x0+width,y0+height);
    }
    /* POT
    fill(textColor());
    noStroke();
    textAlign(CENTER);
    textLeading(1.1*styles.iconBtnTextSize);
    text(names[current], x0 + width/2., y0 + height + 1.5*textAscent());
    */
    popStyle();
  }
  
  boolean update() {
    boolean captured = super.update();
    if (captured) {
      lastSelected = names[current];
      current = (current+1) % names.length;
    }
    return captured;
  }

}


// -----------------------------------------------------------------------------------


class Slider extends GuiElement {
  boolean awake = false;
  boolean pressed = false;
  
  float markerWidth;
  boolean showNameOnLeft = true;
  boolean showValOnRight = true;
  float leading = 0.9;

  float dataMin, dataMax;
  boolean logScale = false;
  float pos = 0.0; // pos = normalized units
  int decimalPlaces = 2;
  boolean quantized = false;
  float quantizeUnit;
  
  Slider() {}
  
  Slider(String name, float x, float y, float wd, Stylesheet styles, float dataMin, float dataMax) {
    this.name = name;
    this.styles = styles;
    this.dataMin = dataMin;
    this.dataMax = dataMax;
    setPosition(x, y, wd, styles.sliderHeight);
    markerWidth = styles.sliderHeight;
  }
  
  void quantize(float unit) {
    quantized = true;
    quantizeUnit = unit;
    if (abs(unit-round(unit)) < 1e-6) decimalPlaces = 0;
    setVal(getVal());
  }

  color areaColor() {
    if (pressed) {
      return(styles.btnPalette[3]);
    } else if (over() || alwaysAwake) {
      return(styles.btnPalette[2]);
    } else {
      return(styles.btnPalette[1]);
    }
  }

  void drawMarker() {
    if (pressed) {
      drawMarker(getVal(), styles.btnPalette[3]);
    } else if (over() || alwaysAwake) {
      drawMarker(getVal(), styles.btnPalette[2]);
    } else {
      drawMarker(getVal(), styles.btnPalette[1]);
    }
  }
  
  void drawMarker(float val, color col) {
    pushStyle();
    rectMode(CORNER);
    noStroke();
    fill(col);
    float x1 = x0 + (width-markerWidth)*val2pos(val);
    rect(x1,y0,markerWidth,height);   
    popStyle(); 
  }
  
  void writeOnLeft(String S) {
    pushStyle();
    fill(styles.sliderLabelColor);
    textAlign(RIGHT);
    styles.setFont(styles.sliderTextSize);
    textLeading(leading*styles.sliderTextSize);
    text(S+" ",x0,y0+height);
    popStyle();
  }
  
  void writeOnRight(String S) {
    pushStyle();
    fill(styles.sliderLabelColor);
    textAlign(LEFT);
    styles.setFont(styles.sliderTextSize);
    textLeading(leading*styles.sliderTextSize);
    text(" "+S, x0+width, y0+height);
    popStyle();
  }
  
  void draw() {
    pushStyle();
    // background
    rectMode(CORNER);
    noStroke();
    fill(styles.sliderBkgndColor);
    rect(x0,y0,width,height);
    // marker
    drawMarker();
    // labeling
    if (showNameOnLeft) writeOnLeft(name);
    if (showValOnRight) writeOnRight(val2string(getVal()));
    popStyle();
  }
  
  boolean offerMousePress() {
    pressed = over() && (!hidden);
    return pressed;
  }
  
  boolean update() {
    // returns true if the user is changing the position of the slider.
    boolean result = false;
    if (!hidden) {
      pressed = pressed && mousePressed;
      awake = over() && pressed;
      if (awake) {
        float newpos = (mouseX - x0) / (width - markerWidth);
        if (newpos != getPos()) {
          setPos(newpos);
          result = true;
        }
      }
      draw();
    }
    return result;
  }
  
  // use these four routines for reading & changing the position of the slider.
  // pos = relative position, 0..1
  // val = value in data units  
  float getPos() {return pos;}
  float getVal() {return pos2val(getPos());}
  void setPos(float p) {pos = constrain(p, 0, 1);}
  void setVal(float v) {setPos(val2pos(v));}

  // these are general conversion functions, that can be used for values other than the current one
  // e.g., to find out the current min and max values allowed, use pos2val(0) and pos2val(1)
  String val2string(float v) {
    if (decimalPlaces==0) {
      return str(round(v));
    } else {
      float p = pow(10,decimalPlaces);
      return str(round(v*p)/(float)p);
    }
  }
  
  float val2pos(float v) {
    float p;
    if (quantized) v = round(v/quantizeUnit)*quantizeUnit;
    if (logScale) {
      p = (log(v)-log(dataMin))/(log(dataMax)-log(dataMin));
    } else {
      p = (v-dataMin)/(dataMax-dataMin);
    }
    if (isnan(p)) {
      return 0;
    } else {
      return p;
    }
  }
  
  float pos2val(float p) {
    float v;
    if (logScale) {
      v = dataMin * pow(dataMax/dataMin, p);
    } else {
      v = dataMin + (dataMax-dataMin) * p;
    }
    if (quantized) v = round(v/quantizeUnit)*quantizeUnit;
    return v;
  }  

}


// -----------------------------------------------------------------------------------


class ImageSlider extends Slider {

  PImage img;
  
  ImageSlider(String name, float x, float y, String filename, Stylesheet styles, float dataMin, float dataMax) {
    this.name = name;
    this.styles = styles;
    this.dataMin = dataMin;
    this.dataMax = dataMax;
    img = loadImage(filename);
    setPosition(x, y, img.width, img.height);
    markerWidth = styles.sliderHeight; // just a guess at something appropriate
    showNameOnLeft = false; // likewise
    showValOnRight = false;
  }
  
  void draw() {
    image(img, x0, y0);
    drawMarker();
  }

}


// -----------------------------------------------------------------------------------


class Toolbar extends GuiElement {
  
  GuiElement[] elements = new GuiElement[0];
  boolean addFromLeft = true;
  float unoccLeft, unoccRight, margin;
  String lastUpdated;
  
  Toolbar() {}
  
  Toolbar(float x, float y, float wd, Stylesheet styles) {
    this.styles = styles;
    setPosition(x, y, wd, styles.guiHeight);
    margin = styles.guiMargin;
    unoccLeft = x0 + margin;
    unoccRight = x0 + width - margin;
  }

  TextButton addTextButton(String name, float wd) {
    TextButton btn = new TextButton(name, unoccLeft, y0, wd, height, styles);
    if (addFromLeft) {
      unoccLeft += btn.width + margin;
    } else {
      btn.x0 = unoccRight - btn.width;
      unoccRight = btn.x0 - margin;
    }
    elements = (GuiElement[]) append(elements, btn);
    return btn;
  }

  TextButton addTextButton(String name) {
    TextButton btn = new TextButton(name, unoccLeft, y0, height, styles);
    if (addFromLeft) {
      unoccLeft += btn.width + margin;
    } else {
      btn.x0 = unoccRight - btn.width;
      unoccRight = btn.x0 - margin;
    }
    elements = (GuiElement[]) append(elements, btn);
    return btn;
  }
  
  TextLabel addTextLabel(String name, float wd) {
    TextLabel btn = new TextLabel(name, unoccLeft, y0, wd, height, styles);
    if (addFromLeft) {
      unoccLeft += btn.width + margin;
    } else {
      btn.x0 = unoccRight - btn.width;
      unoccRight = btn.x0 - margin;
    }
    elements = (GuiElement[]) append(elements, btn);
    return btn;
  }

  TextLabel addTextLabel(String name) {
    TextLabel btn = new TextLabel(name, unoccLeft, y0, height, styles);
    if (addFromLeft) {
      unoccLeft += btn.width + margin;
    } else {
      btn.x0 = unoccRight - btn.width;
      unoccRight = btn.x0 - margin;
    }
    elements = (GuiElement[]) append(elements, btn);
    return btn;
  }

  IconButton addIconButton(String name, String filename) {
    IconButton btn = new IconButton(name, unoccLeft, y0, filename, styles);
    if (addFromLeft) {
      unoccLeft += btn.width + margin;
    } else {
      btn.x0 = unoccRight - btn.width;
      unoccRight = btn.x0 - margin;
    }
    elements = (GuiElement[]) append(elements, btn);
    return btn;
  }
  
  Slider addSlider(String name, float wd, float dataMin, float dataMax) {
    Slider sl = new Slider(name, unoccLeft, y0 + (height-styles.sliderHeight)/2., wd, styles, dataMin, dataMax);
    pushStyle();
    styles.setFont(styles.sliderTextSize);
    float leftTextSpace = textWidth(sl.name+" ");
    float rightTextSpace = max(textWidth(" "+sl.val2string(dataMin)), textWidth(" "+sl.val2string(dataMax)));
    popStyle();
    if (addFromLeft) {
      unoccLeft += leftTextSpace + sl.width + rightTextSpace + margin;
    } else {
      sl.x0 = unoccRight - sl.width - rightTextSpace;
      unoccRight = sl.x0 - leftTextSpace - margin;
    }
    elements = (GuiElement[]) append(elements, sl);
    return sl;
  }
  
  void addSpacer() {
    addSpacer(height);
  }
  
  void addSpacer(float wd) {
    if (addFromLeft) {
      unoccLeft += wd + margin;
    } else {
      unoccRight -= wd + margin;
    }
  }
  
  void select(String key) {
    for (int i=0; i<elements.length; i++) {
      if (elements[i].name.equals(key)) {
        elements[i].alwaysAwake = true;
      }
    }
  }
  
  void deselect(String key) {
    for (int i=0; i<elements.length; i++) {
      if (elements[i].name.equals(key)) {
        elements[i].alwaysAwake = false;
      }
    }
  }

  void deselect() {
    for (int i=0; i<elements.length; i++) {
      elements[i].alwaysAwake = false;
    }
  }
  
  boolean update() {
    boolean captured = false, result = false;
    int i;
    for (i=0; i<elements.length; i++) {
      captured = elements[i].update();
      if (captured) {
        lastUpdated = elements[i].name;
        result = true;
      }
    }
    return result;
  }
  
  boolean offerMousePress() {
    boolean captured = false;
    for (int i=0; i<elements.length && !captured; i++) {
      captured = elements[i].offerMousePress();
    }
    return captured;
  }
  
}


// ---------------------------------------------------------------------------------


class SliderList extends Toolbar {

  SliderList(float x, float y, float wd, Stylesheet styles) {
    this.styles = styles;
    setPosition(x, y, wd, 0);
    margin = styles.guiMargin;
  }
  
  Slider addSlider(String name, float dataMin, float dataMax) {
    Slider sl = new Slider(name, x0, y0+height, width, styles, dataMin, dataMax);
    elements = (GuiElement[]) append(elements, sl);
    height += styles.sliderHeight + margin;
    return sl;
  }
  
  void addSpacer() {
    height += margin;
  }

}



