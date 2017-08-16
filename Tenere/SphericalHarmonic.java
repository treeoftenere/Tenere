

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

class SphericalHarmonic {
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