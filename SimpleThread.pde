class SimpleThread extends Thread {
 
  boolean running;           // Is the thread running?  Yes or no?
  int wait;                  // How many milliseconds should we wait in between executions?
  String id;                 // Thread name
  int count;                 // counter
  
 
  // Constructor, create the thread
  // It is not running by default
  SimpleThread (int w, String s) {
    wait = w;
    running = false;
    id = s;
    count = 0;
  }
 
  int getCount() {
    return count;
  }
 
  // Overriding "start()"
  void start () {
    // Set running equal to true
    running = true;
    // Print messages
    println("Starting thread (will execute every " + wait + " milliseconds.)"); 
    // Do whatever start does in Thread, don't forget this!
    super.start();
  }
 
 
  // We must implement run, this gets triggered by start()
  void run () {
    /*
    while (running && count < 10) {
      println(id + ": " + count);
      count++;
      // Ok, let's wait for however long we should wait
      try {
        sleep((long)(wait));
       } catch (Exception e) {
      }
    }
    System.out.println(id + " thread is done!");  // The thread is done when we get to the end of run()
    */
    while(running) {
     if(cargado == false) {
       F = new Flow(id, true);
       F.cyclic = false;
     } else {  
       F2 = new Flow(id, true);
       F2.cyclic = false;
     }  
     quit();
    } 
  }
 
 
  // Our method that quits the thread
  void quit() {
    System.out.println("Quitting."); 
    running = false;  // Setting running to false ends the loop in run()
    // IUn case the thread is waiting. . .
    interrupt();
  }
}
