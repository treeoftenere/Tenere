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


/*

Copyright 2002 David Joiner and the Shodor Education Foundation, Inc.

Shodor general use license

This code is provided as is, and is offered with no guarantee.

This code may be used freely in any non commercial product. Any works
using this code must publicly give credit for this work to the Shodor
Education Foundation, and should provide in that credit a link to the
location of the code on the Computational Science Education Reference
Desk (http://www.shodor.org/cserd) as well as to the Shodor Education
Foundation (http://www.shodor.org) and to any other authors listed in
the copyright statement found within the code.

Copyright statements within the code may not be modified.

This license does not grant permission for use in any commercial product.

*/

static class AssocLegendre {
    private int l;
    private int m;

    public AssocLegendre(int l, int m){
        this.l=l;
        this.m=m;
    }
    public AssocLegendre(){
  l=0;
  m=0;
    }
    public void setL(int l){
        this.l=l;
    }
    public void setM(int m){
        this.m=m;
    }
    public void setLM(int l, int m){
        this.l=l;
        this.m=m;
    }
    public int getL(){
        return l;
    }
    public int getM(){
        return m;
    }
    public double eval(double u){
        if(l<0||m<0||m>l) {
            System.err.println("WARNING: improper values l,m = "+l+","+m+".");
        }
  double last, current, next;
  if (l<m) {
            current = 0.0;
  } else if (l==m && m==0) {
      current = 1.0;
  } else {
      last=0.0;
      if (m==0) {
          current=1.0;
      } else {
          current=(double)MathLib.doubleFactorial(2*m-1)*
              Math.pow((1-u*u),0.5*(double)(m));
      }
      if (l!=m) {
          for (int k=m;k<l;k++) {
              next = ((double)(2*k+1)*u*current -
                    (double)(k+m)*last)/(k+1-m);
                last=current;
                current=next;
          }
      }
  }
  return current;
    }

}

/*

Copyright 1999-2002 David Joiner and the Shodor Education Foundation, Inc.

Shodor general use license

This code is provided as is, and is offered with no guarantee.

This code may be used freely in any non commercial product. Any works
using this code must publicly give credit for this work to the Shodor
Education Foundation, and should provide in that credit a link to the
location of the code on the Computational Science Education Reference
Desk (http://www.shodor.org/cserd) as well as to the Shodor Education
Foundation (http://www.shodor.org) and to any other authors listed in
the copyright statement found within the code.

Copyright statements within the code may not be modified.

This license does not grant permission for use in any commercial product.

*/

public static class Complex {
    private double r;
    private double i;

    public Complex(){
        r=0;
        i=0;
    }
    public Complex(double r, double i){
        this.r=r;
        this.i=i;
    }
    public Complex(Complex z){
        this.r=z.getReal();
        this.i=z.getImag();
    }
    public void set(double r,double i){
        this.r=r;
        this.i=i;
    }
    public void setReal(double r){
        this.r=r;
    }
    public void setImag(double i){
        this.i=i;
    }
    public Complex exp(){
        Complex result = new Complex(this);
        result.set(Math.exp(r)*Math.cos(i),Math.exp(r)*Math.sin(i));
        return result;
    }
    public Complex conjugate(){
        Complex result = new Complex(this);
        result.setImag(-i);
        return result;
    }
    public double getReal(){
        return r;
    }
    public double getImag(){
        return i;
    }
    public Complex times(Complex z){
        Complex result = new Complex(this);
        result.setReal(r*z.getReal()-i*z.getImag());
        result.setImag(i*z.getReal()+r*z.getImag());
        return result;
    }
    public Complex times(double x){
        Complex result = new Complex(this);
        result.setReal(r*x);
        result.setImag(i*x);
        return result;
    }
    public Complex plus(Complex z){
        Complex result = new Complex(this);
        result.setReal(r+z.getReal());
        result.setImag(i+z.getImag());
        return result;
    }
    public Complex plus(double x){
        Complex result = new Complex(this);
        result.setReal(r+x);
        return result;
    }
    public Complex minus(Complex z){
        Complex result = new Complex(this);
        result.setReal(r-z.getReal());
        result.setImag(i-z.getImag());
        return result;
    }
    public Complex minus(double x){
        Complex result = new Complex(this);
        result.setReal(r-x);
        return result;
    }
}


/*

Copyright 1999-2002 David Joiner and the Shodor Education Foundation, Inc.

Shodor general use license

This code is provided as is, and is offered with no guarantee.

This code may be used freely in any non commercial product. Any works
using this code must publicly give credit for this work to the Shodor
Education Foundation, and should provide in that credit a link to the
location of the code on the Computational Science Education Reference
Desk (http://www.shodor.org/cserd) as well as to the Shodor Education
Foundation (http://www.shodor.org) and to any other authors listed in
the copyright statement found within the code.

Copyright statements within the code may not be modified.

This license does not grant permission for use in any commercial product.

*/

import java.awt.*;
import java.applet.Applet;

static class Diffeq {

   int neq=0;
   double [] x;
   double time;
   double [] der;
   double [] x_old;
   double [] der_old;
   double [] k1;
   double [] k2;
   double [] k3;
   double [] k4;

   public Diffeq(int j){
      neq=j;
      x=new double[neq];
      der=new double[neq];
      x_old=new double[neq];
      der_old=new double[neq];
      k1=new double[neq];
      k2=new double[neq];
      k3=new double[neq];
      k4=new double[neq];
      for (int i=0;i<neq;i++) {
         x[i]=0.0;
         der[i]=0.0;
         x_old[i]=0.0;
         der_old[i]=0.0;
         k1[i]=0.0;
         k2[i]=0.0;
         k3[i]=0.0;
         k4[i]=0.0;
      }
      time=0.0;
   }

   public void updateEuler(double step){
      for(int i=0;i<neq;i++){
         x_old[i]=x[i];
      }
      deriv(neq,time,x,der);
      for(int i=0;i<neq;i++){
         x[i]=x[i]+step*der[i];
      }
      time=time+step;
   }
   
   public void updateIEuler(double step){
      for(int i=0;i<neq;i++){
         x_old[i]=x[i];
      }
      deriv(neq,time,x,der);
      for(int i=0;i<neq;i++){
         der_old[i]=der[i];
         x[i]=x[i]+step*der[i];
      }
      deriv(neq,time,x,der);
      for(int i=0;i<neq;i++){
         x[i]=x_old[i]+step*0.5*(der[i]+
            der_old[i]);
      }
      time=time+step;
   }

   void updateRKutta4(double step){
      for(int i=0;i<neq;i++){
         x_old[i]=x[i];
      }
      double time_old=time;
      deriv(neq,time,x,der);
      for(int i=0;i<neq;i++){
         k1[i]=step*der[i];
         x[i]=x_old[i]+0.5*k1[i];
      }
      time=time_old+step/2.0;
      deriv(neq,time,x,der);
      for(int i=0;i<neq;i++){
         k2[i]=step*der[i];
         x[i]=x_old[i]+0.5*k2[i];
      }
      deriv(neq,time,x,der);
      time=time_old+step;
      for(int i=0;i<neq;i++){
         k3[i]=step*der[i];
         x[i]=x_old[i]+k3[i];
      }
      deriv(neq,time,x,der);
      double con6=1.0/6.0;
      for(int i=0;i<neq;i++){
         k4[i]=step*der[i];
         x[i]=x_old[i]+(k1[i]+2.0*k2[i]+2.0*k3[i]+k4[i])*con6;
      }
   }

   public void deriv(int n, double t, double [] xd, double [] xdp) {
   }

}

/*
MathLib.java

Copyright 2001 David Joiner and the Shodor Education Foundation, Inc.

Shodor general use license

This code is provided as is, and is offered with no guarantee.

This code may be used freely in any non commercial product. Any works
using this code must publicly give credit for this work to the Shodor
Education Foundation, and should provide in that credit a link to the
location of the code on the Computational Science Education Reference
Desk (http://www.shodor.org/cserd) as well as to the Shodor Education
Foundation (http://www.shodor.org) and to any other authors listed in
the copyright statement found within the code.

Copyright statements within the code may not be modified.

This license does not grant permission for use in any commercial product.

*/

public static class MathLib {

    public static double niceNumber ( double x, boolean round) {
        int exp;
        double frac;
        double niceFrac;
        
        exp = (int)Math.floor(log10(x));
        frac = x/Math.pow(10.0,exp);
        if (round) {
            if (frac < 1.5) {
                niceFrac=1.0;
            } else if (frac<3.0) {
                niceFrac=2.0;
            } else if (frac<7.0) {
                niceFrac=5.0;
            } else {
                niceFrac=10.0;
            }
        } else {
            if (frac <= 1.0001) {
                niceFrac=1.0;
            } else if (frac<=2.0001) {
                niceFrac=2.0;
            } else if (frac<=5.0001) {
                niceFrac=5.0;
            } else {
                niceFrac=10.0;
            }
        }
        return niceFrac * Math.pow(10.0,exp);
    }
    
    public static final double log10Constant = Math.log(10.0);
    
    public static double log10(double x) {
        return Math.log(x)/log10Constant;
    }
    
    public static double [] niceLabels (int nLabel, double minLabel, double maxLabel) {
        double [] label = new double[nLabel];
        int nfrac;
        double d;
        double graphmin, graphmax;
        double range, x;
        
        range = niceNumber(maxLabel-minLabel, true);
        d = niceNumber(range/(nLabel-1),true);
        graphmin = Math.floor(minLabel/d)*d;
        graphmax = Math.ceil(maxLabel/d)*d;
        nfrac = Math.max((int)log10(d),0);
        
        for (int i=0; i<nLabel; i++) {
            x = graphmin + (double)i*d;
            label[i] = x;
        }
        
        return label;
    }

    public static double [] niceLogLabels(int nLabel, double minLabel, double maxLabel) {
        double minLogLabel = log10(minLabel);
        double maxLogLabel = log10(maxLabel);
        double [] niceLogLabel = MathLib.niceLabels(nLabel,minLogLabel,maxLogLabel);
        for (int i=0;i<nLabel;i++) {
            niceLogLabel[i] = MathLib.niceNumber(
                Math.pow(10.0,niceLogLabel[i]),false);
        }
        return niceLogLabel;
    }

    public static double cartesianToR(double x, double y, double z) {
        return Math.sqrt(x*x+y*y+z*z);
    }
    public static double cartesianToPhi(double r, double z) {
        if (z>=0.0) {
            return Math.acos(z/r);
        } else {
            return -Math.acos(z/r);
        }
    }
    public static double cartesianToPhi(double x, double y, double z) {
        if (z>=0.0) {
            return Math.acos(z/cartesianToR(x,y,z));
        } else {
            return -Math.acos(z/cartesianToR(x,y,z));
        }
    }
    public static double cartesianToTheta(double x, double y) {
        double pi = 4.0*Math.atan(1.0);
        if (x == 0.0) {
            if (y>=0.0) return pi/2.0;
            else return -pi/2.0;
        } else if (y==0.0) {
            if (x>=0.0) return 0.0;
            else return pi;
        } else {
            if (x>=0.0) return Math.atan(y/x);
            else return Math.atan(y/x)+pi;
        }
    }

    public static double [] linearGrid(int n, double min, double max) {
        
        double diff = (max-min)/(double)(n-1);
        double [] retval = new double[n];
        
        retval[0] = min;
        retval[n-1]=max;
        for(int i=1;i<n-1;i++) {
            retval[i]=retval[0]+diff*i;
        }
        
        return retval;
    }
    
    public static int factorial (int n) {
        int retval=1;
        for (int i=2;i<=n;i++) {
            retval*=i;
        }
        return retval;
    }
    public static int doubleFactorial(int l) {
        int i;
        int retval=1;
        for (i=l;i>=2;i-=2) retval*=i;
        return retval;
    }

}



/*

Copyright 2002 David Joiner and the Shodor Education Foundation, Inc.

Shodor general use license

This code is provided as is, and is offered with no guarantee.

This code may be used freely in any non commercial product. Any works
using this code must publicly give credit for this work to the Shodor
Education Foundation, and should provide in that credit a link to the
location of the code on the Computational Science Education Reference
Desk (http://www.shodor.org/cserd) as well as to the Shodor Education
Foundation (http://www.shodor.org) and to any other authors listed in
the copyright statement found within the code.

Copyright statements within the code may not be modified.

This license does not grant permission for use in any commercial product.

*/

static class SphericalHarmonic {
    private int l;
    private int m;
    
    public SphericalHarmonic(){
        l=0;
        m=0;
    }
    public SphericalHarmonic(int l,int m){
        this.l=l;
        this.m=m;
    }
    public void setL(int l){
        this.l=l;
    }
    public void setM(int m){
        this.m=m;
    }
    public void setLM(int l,int m){
        this.l=l;
        this.m=m;
    }
    public int getL(){
        return l;
    }
    public int getM(){
        return m;
    }
    public Complex eval(double theta, double phi){
        int absm=Math.abs(m);
        double sign;
        if (absm%2==1) sign=-1.0;
        else sign=1.0;
        AssocLegendre P = new AssocLegendre(l,absm);
        Complex retval = new Complex(0.0,(double)absm*phi);
        retval=retval.exp();
        double factor=sign*
            Math.sqrt((double)(2*l+1)/(4.0*Math.PI)*
            MathLib.factorial(l-m)/MathLib.factorial(l+m))*
            P.eval(Math.cos(theta));
        retval=retval.times(factor);
        
        if (m<0) {
            retval=retval.conjugate();
            retval=retval.times(sign);
        }
        return retval;
    }
}