class Gui {
  
  Stylesheet styles = masterStylesheet;
  Display display;
  
  Gui() {}
  
  void update() {
    
    println(display);
    if (display==null) return;
    
  }
  
  boolean offerMousePress() {
    return false;
  }
  
  boolean offerMouseDrag() {
    return false;
  }
  
  boolean offerMouseRelease() {
    return false;
  }

  
}


