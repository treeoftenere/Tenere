
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

class AssocLegendre {
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

