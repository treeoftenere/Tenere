final int NumApcRows=4, NumApcCols=8;


static public float angleBetween(PVector v1, PVector v2) {

  // We get NaN if we pass in a zero vector which can cause problems
  // Zero seems like a reasonable angle between a (0,0,0) vector and something else
  if (v1.x == 0 && v1.y == 0 && v1.z == 0 ) return 0.0f;
  if (v2.x == 0 && v2.y == 0 && v2.z == 0 ) return 0.0f;

  double dot = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
  double v1mag = FastMath.sqrt(v1.x * v1.x + v1.y * v1.y + v1.z * v1.z);
  double v2mag = FastMath.sqrt(v2.x * v2.x + v2.y * v2.y + v2.z * v2.z);
  // This should be a number between -1 and 1, since it's "normalized"
  double amt = dot / (v1mag * v2mag);
  // But if it's not due to rounding error, then we need to fix it
  // http://code.google.com/p/processing/issues/detail?id=340
  // Otherwise if outside the range, acos() will return NaN
  // http://www.cppreference.com/wiki/c/math/acos
  if (amt <= -1) {
    return PConstants.PI;
  } else if (amt >= 1) {
    // http://code.google.com/p/processing/issues/detail?id=435
    return 0;
  }
  return (float) FastMath.acos(amt);
}
boolean btwn  	(int 		a,int 	 b,int 		c)		{ return a >= b && a <= c; 	}
boolean btwn  	(double 	a,double b,double 	c)		{ return a >= b && a <= c; 	}
float	interp 	(float a, float b, float c) { return (1-a)*b + a*c; }
float	randctr	(float a) { return random(a) - a*.5; }
float	min		(float a, float b, float c, float d) { return min(min(a,b),min(c,d)); 	}
float   pointDist(LXPoint p1, LXPoint p2) { return dist(p1.x,p1.y,p1.z,p2.x,p2.y,p2.z); 	}
float   xyDist   (LXPoint p1, LXPoint p2) { return dist(p1.x,p1.y,p2.x,p2.y); 				}
float 	distToSeg(float x, float y, float x1, float y1, float x2, float y2) {
	float A 			= x - x1, B = y - y1, C = x2 - x1, D = y2 - y1;
	float dot 			= A * C + B * D, len_sq	= C * C + D * D;
	float xx, yy,param 	= dot / len_sq;
	
	if (param < 0 || (x1 == x2 && y1 == y2)) { 	xx = x1; yy = y1; }
	else if (param > 1) {						xx = x2; yy = y2; }
	else {										xx = x1 + param * C;
												yy = y1 + param * D; }
	float dx = x - xx, dy = y - yy;
	return sqrt(dx * dx + dy * dy);
}

public class Pick {
	public int 	NumPicks, Default	,	
			CurRow	, CurCol	,
			StartRow, EndRow	;
	String  tag		, Desc[]	;

	public Pick	(String label, int _Def, int _Num, 	int nStart, String d[])	{
		NumPicks 	= _Num; 	Default = _Def; 
		StartRow 	= nStart;	EndRow	= StartRow + floor((NumPicks-1) / NumApcCols);
		tag			= label; 	Desc 	= d;
		reset();
	}

	int		Cur() 	 		{ return (CurRow-StartRow)*NumApcCols + CurCol;					}
	String	CurDesc() 		{ return Desc[Cur()]; }
	void	reset() 		{ CurCol = Default % NumApcCols; CurRow	= StartRow + Default / NumApcCols; }

	boolean set(int r, int c)	{
		if (!btwn(r,StartRow,EndRow) || !btwn(c,0,NumApcCols-1) ||
			!btwn((r-StartRow)*NumApcCols + c,0,NumPicks-1)) 	return false;
		CurRow=r; CurCol=c; 									return true;
	}
}

public class Bool {
	boolean def, b;
	String	tag;
	int		row, col;
	void 	reset() { b = def; }
	boolean set	(int r, int c, boolean val) { if (r != row || c != col) return false; b = val; return true; }
	boolean toggle(int r, int c) { if (r != row || c != col) return false; b = !b; return true; }
	Bool(String _tag, boolean _def, int _row, int _col) {
		def = _def; b = _def; tag = _tag; row = _row; col = _col;
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
public class APat extends LXPattern
{
	ArrayList<Pick>   picks  = new ArrayList<Pick>  ();
	ArrayList<Bool>  bools  = new ArrayList<Bool> ();
    PVector pTrans= new PVector(); 
	PVector		mMax, mCtr, mHalf;

	LXMidiOutput  APCOut;
	LXMidiOutput MidiFighterTwisterOut; 
	int			nMaxRow  	= 53;
	float		LastJog = -1;
	float[]		xWaveNz, yWaveNz;
	int 		nPoint	, nPoints;
	PVector		xyzJog = new PVector(), modmin;

	float			NoiseMove	= random(10000);
	BoundedParameter	pSpark, pWave, pRotX, pRotY, pRotZ, pSpin, pTransX, pTransY;
	BooleanParameter			pXsym, pYsym, pRsym, pXdup, pXtrip, pJog, pGrey;

	float		lxh		() 									{ return lx.hsb(250,100,100); 											}
	int			c1c		 (float a) 							{ return round(100*constrain(a,0,1));								}
	float 		interpWv(float i, float[] vals) 			{ return interp(i-floor(i), vals[floor(i)], vals[ceil(i)]); 		}
	void 		setNorm (PVector vec)						{ vec.set(vec.x/mMax.x, vec.y/mMax.y, vec.z/mMax.z); 				}
	void		setRand	(PVector vec)						{ vec.set(random(mMax.x), random(mMax.y), random(mMax.z)); 			}
	void		setVec 	(PVector vec, LXPoint p)				{ vec.set(p.x, p.y, p.z);  											}
	void		interpolate(float i, PVector a, PVector b)	{ a.set(interp(i,a.x,b.x), interp(i,a.y,b.y), interp(i,a.z,b.z)); 	}
	void  		StartRun(double deltaMs) 					{ }
	float 		val		(BoundedParameter p) 					{ return p.getValuef();												}
	color		CalculateColor(PVector p) 						{ return lx.hsb(0,0,0); 											}
	color		blend3(color c1, color c2, color c3)		{ return PImage.blendColor(c1,PImage.blendColor(c2,c3,ADD),ADD); 					}

	void	rotateZ (PVector p, PVector o, float nSin, float nCos) { p.set(    nCos*(p.x-o.x) - nSin*(p.y-o.y) + o.x    , nSin*(p.x-o.x) + nCos*(p.y-o.y) + o.y,p.z); }
	void	rotateX (PVector p, PVector o, float nSin, float nCos) { p.set(p.x,nCos*(p.y-o.y) - nSin*(p.z-o.z) + o.y    , nSin*(p.y-o.y) + nCos*(p.z-o.z) + o.z    ); }
	void	rotateY (PVector p, PVector o, float nSin, float nCos) { p.set(    nSin*(p.z-o.z) + nCos*(p.x-o.x) + o.x,p.y, nCos*(p.z-o.z) - nSin*(p.x-o.x) + o.z    ); }

	BoundedParameter	addParam(String label, double value) 	{ BoundedParameter p = new BoundedParameter(label, value); addParameter(p); return p; }
    BoundedParameter  addParam(String label, double value, double min, double max)  { BoundedParameter p2 = new BoundedParameter(label, value, min, max); addParameter(p2); return p2; }
	PVector 	vT1 = new PVector(), vT2 = new PVector();
	float 		calcCone (PVector v1, PVector v2, PVector c) 	{	vT1.set(v1); vT2.set(v2); vT1.sub(c); vT2.sub(c);
																	return degrees(angleBetween(vT1,vT2)); }

	Pick 		addPick(String name, int def, int _max, String[] desc) {
		Pick P 		= new Pick(name, def, _max+1, nMaxRow, desc); 
		nMaxRow		= P.EndRow + 1;
		picks.add(P);
		return P;
	}


  boolean noteOn(MidiNote note) {return false;}

  boolean handleNote(MidiNote note) {return false;}

  void    onInactive()      {}

	void 		onReset() 				{
		for (int i=0; i<bools .size(); i++) bools.get(i).reset();
		for (int i=0; i<picks .size(); i++) picks.get(i).reset();
		// presetManager.dirty(this); 
	//	updateLights(); now handled by patternControl UI
	}

	public APat(LX lx) {
		super(lx);

		pSpark		=	addParam("Sprk",  0);
		pWave		=	addParam("Wave",  0);
		pTransX		=	addParam("TrnX", .5);
		pTransY		=	addParam("TrnY", .5);
		pRotX 		= 	addParam("RotX", .5);
		pRotY 		= 	addParam("RotY", .5);
		pRotZ 		= 	addParam("RotZ", .5);
		pSpin		= 	addParam("Spin", .5);


    	pXsym = new BooleanParameter("X-SYM");
    	pYsym = new BooleanParameter("Y-SYM");
    	pRsym = new BooleanParameter("R-SYM");
    	pXdup = new BooleanParameter("X-DUP");
    	pJog = new BooleanParameter("JOG");
    	pGrey = new BooleanParameter("GREY");

    	addParameter(pXsym);
    	addParameter(pYsym);
    	addParameter(pRsym);
    	addParameter(pXdup);
    	addParameter(pJog);
    	addParameter(pGrey);

		nPoints 	=	model.points.length;
		
		//addMultipleParameterUIRow("Bools",pXsym,pYsym,pRsym,pXdup,pJog,pGrey);

		modmin		=	new PVector(model.xMin, model.yMin, model.zMin);
		mMax		= 	new PVector(model.xMax, model.yMax, model.zMax); mMax.sub(modmin);
		mCtr		= 	new PVector(); mCtr.set(mMax); mCtr.mult(.5);
		mHalf		= 	new PVector(.5,.5,.5);
		xWaveNz		=	new float[ceil(mMax.y)+1];
		yWaveNz		=	new float[ceil(mMax.x)+1];

		//println (model.xMin + " " + model.yMin + " " +  model.zMin);
		//println (model.xMax + " " + model.yMax + " " +  model.zMax);
	  //for (MidiOutputDevice o: RWMidi.getOutputDevices()) { if (o.toString().contains("APC")) { APCOut = o.createOutput(); break;}}
	}

	float spin() {
	  float raw = val(pSpin);
	  if (raw <= 0.45) {
	    return raw + 0.05;
	  } else if (raw >= 0.55) {
	    return raw - 0.05;
    }
    return 0.5;
	}
	
	void updateLights() {}

	void run(double deltaMs)
	{
		if (deltaMs > 100) return;

		NoiseMove   	+= deltaMs; NoiseMove = NoiseMove % 1e7;
		StartRun		(deltaMs);
		PVector P 		= new PVector(), tP = new PVector(), pSave = new PVector();
		pTrans.set(val(pTransX)*200-100, val(pTransY)*100-50,0);
		nPoint 	= 0;

		if (pJog.getValueb()) {
			float tRamp	= (lx.tempo.rampf() % .25);
			if (tRamp < LastJog) xyzJog.set(randctr(mMax.x*.2), randctr(mMax.y*.2), randctr(mMax.z*.2));
			LastJog = tRamp; 
		}

		// precalculate this stuff
		float wvAmp = val(pWave), sprk = val(pSpark);
		if (wvAmp > 0) {
			for (int i=0; i<ceil(mMax.x)+1; i++)
				yWaveNz[i] = wvAmp * (noise(i/(mMax.x*.3)-(2e3+NoiseMove)/1500.) - .5) * (mMax.y/2.);

			for (int i=0; i<ceil(mMax.y)+1; i++)
				xWaveNz[i] = wvAmp * (noise(i/(mMax.y*.3)-(1e3+NoiseMove)/1500.) - .5) * (mMax.x/2.);
		}

		for (LXPoint p : model.points) { nPoint++;
			setVec(P,p);
			P.sub(modmin);
			P.sub(pTrans);
			if (sprk  > 0) {P.y += sprk*randctr(50); P.x += sprk*randctr(50); P.z += sprk*randctr(50); }
			if (wvAmp > 0) 	P.y += interpWv(p.x-modmin.x, yWaveNz);
			if (wvAmp > 0) 	P.x += interpWv(p.y-modmin.y, xWaveNz);
			if (pJog.getValueb())		P.add(xyzJog);


			color cNew, cOld = colors[p.index];
							{ tP.set(P); 				  					cNew = CalculateColor(tP);							}
 			if (pXsym.getValueb())	{ tP.set(mMax.x-P.x,P.y,P.z); 					cNew = PImage.blendColor(cNew, CalculateColor(tP), ADD);	}
			if (pYsym.getValueb()) 	{ tP.set(P.x,mMax.y-P.y,P.z); 					cNew = PImage.blendColor(cNew, CalculateColor(tP), ADD);	}
			if (pRsym.getValueb()) 	{ tP.set(mMax.x-P.x,mMax.y-P.y,mMax.z-P.z);		cNew = PImage.blendColor(cNew, CalculateColor(tP), ADD);	}
			if (pXdup.getValueb()) 	{ tP.set((P.x+mMax.x*.5)%mMax.x,P.y,P.z);		cNew = PImage.blendColor(cNew, CalculateColor(tP), ADD);	}
			if (pGrey.getValueb())	{ cNew = lx.hsb(0, 0, LXColor.b(cNew)); }
			colors[p.index] = cNew;
		}
	}
}