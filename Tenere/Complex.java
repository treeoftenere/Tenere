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

public class Complex {
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

