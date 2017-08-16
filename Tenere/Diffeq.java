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

class Diffeq {

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