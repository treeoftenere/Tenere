//a simple buffer to hold a history of data
public class hist {
  float[] history;
  int index;
   
  public hist(int w) {
     history = new float[w];
  }
  
 public void addValue(float newValue) {
  history[index] = newValue;
  index = (index+1) % history.length;    
  }
 
 public int prevValue(int index) {
  int i = index - 1;
  if (i < 0) i = history.length - 1;
  return i;  
  }
 
 public int lookupInd(int ind){
  if (ind > history.length){
    return -1;
  }
  int i = index - ind;
  if (i < 0) i = history.length + i;
  return i;  
  }
 public float getValue(int ind) {
  return history[ind];
 }
}