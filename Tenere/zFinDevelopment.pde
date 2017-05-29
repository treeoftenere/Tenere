//public class PlasmaGenerator  {
  
//  private final float _size; 
//  private final float _rate;
//  private float result;
  
//  public PlasmaGenerator(int size, int rate)
//  {
//    _size = size;
//    _rate = rate;
//  }
  
//  //cx and cy are the locations of the moving circle
//  public float GetShade( LXPoint pixelPoint, float movement, LXPoint circle)
//  {
//     result =
//      + SinVertical( pixelPoint, _size) 
//      + SinRotating( pixelPoint, _size) 
//      + SinCircle(   pixelPoint,circle, _size) / 3;
      
//      return result;
//  }
  
//  private float SinVertical(LXPoint p, float size)
//  {
//    return sin(   ( p.x / model.xMax / size) + (movement / 100 ));
//  }
  
//  private float SinRotating(LXPoint p, float size)
//  {
//    return sin( ( ( p.y / model.yMax / size) * sin( movement /134 )) + (p.z / model.zMax / size) * (cos(movement / 200))  ) ;
//  }
   
//  private float SinCircle(LXPoint p, LXPoint c, float size)
//  {
//    //float cx =  (float)CircleMoveX.getValue();
//    //float cy = (float)CircleMoveY.getValue();
//    return sin( (sqrt(sq(c.y-p.y) + sq(c.x-p.x) )+ movement + (p.z/model.zMax)) / model.xMax / size );
//  }
//}