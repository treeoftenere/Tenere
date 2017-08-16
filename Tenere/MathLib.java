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

public class MathLib {

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

