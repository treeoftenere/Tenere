public  class MyNewAnimation extends LXPattern {
  
  //Variables go here
  //See Tutorial for use of Modulators and Parameters
  //Extra classes must be static
  
  //Constructor
  public MyNewAnimation(LX lx) {
    super(lx);
  }
  
  //run(), works like draw(). 
  public void run(double deltaMs) {
    
     
    //ittreate colors[] array, populating colrs
    for (LXPoint p : model.points) {
      colors[p.index]  = LX.rgb(255,0,0); //make it all red
    }
    
  } //end of run()
  
} //end of class()