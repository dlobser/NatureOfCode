
class NoisePoints{

	float tx,ty;
	int goX,goY;
	float q;
	float speed;

	NoisePoints(float tx, float ty,int q,float speed){
		this.q = q;
		this.tx = tx;
		this.ty = ty;
		goX = 1;
		goY = 1;
		this.speed = speed;
	}

	void mover(){
	  
	  tx += map(noise(q),0,.95,-speed,speed)*goX;
	  ty += map(noise(q+100),0,.95,-speed,speed)*goY;
	  q+=.01;
	  
	 if(tx<0)
		goX*=-1;
	 if(tx>width)
		goX*=-1;
	 if(ty<0)
		goY*=-1;
	 if(ty>height)
		goY*=-1;
		
	}
}

class LineList{

int maxLines;
int numLines;
int q;

ArrayList<Line> lines;

LineList(int maxLines){
	this.maxLines = maxLines;
	lines = new ArrayList();
}

void add(Line line){
	lines.add(line);
	numLines++;
}

void add(int type, int anchor, int amount, int spacing, float speed){
	lines.add(new Line(type,anchor,amount,spacing,speed));
	numLines ++;
}

void add(int type, int anchor, int amount, int spacing, float speed,float wheel,color thisColor){
	lines.add(new LineDad(q,type,anchor,amount,spacing,speed,wheel,thisColor,.001));
	q++;
	numLines ++;
}

void initThings(float tx, float ty){
	
	for(int i = 0; i<lines.size() ; i++)
	{
		//if(i>0)
		//	i=numLines-2;
		
		float rtx = random(width);
		float rty = random(height);
		Line thisLine = lines.get(i);
		thisLine.initThing();
		thisLine.initPosArray(tx,ty);
		lines.set(i,thisLine);
	}
}

void initThings(){
	
	for(int i = 0; i<numLines ; i++)
	{
		float rtx = random(width);
		float rty = random(height);
		initThings(rtx,rty);
	}
}

void remove(){
//println(numLines);
//println(lines.size());
//println("remove");
if(numLines>0){
	lines.remove(lines.size()-1);
		numLines--;
		}
}

void counter(){
	
		Line thisLine = lines.get(lines.size()-1);
		thisLine.counter(mouseX,mouseY);
		thisLine.normalizeThings();
		lines.set(lines.size()-1,thisLine);
		
	
}

void clipLength(){
	
		if(lines.size() > 0){
			Line thisLine = lines.get(lines.size()-1);
			thisLine.clipPosArray();
			thisLine.normalizeThings();
			lines.set(lines.size()-1,thisLine);
		}
}

void display(){
	for(int i = 0; i<lines.size() ; i++){
		Line thisLine = lines.get(i);
		thisLine.counter(mouseX,mouseY);
	}
}

void display(float[] position){
	int u = 0 ;
		for(int i = 0; i<lines.size() ; i++){
			Line thisLine = lines.get(i);
			thisLine.counter(position[u],position[u+1]);
			u+=2;
	}
}

void display(float tx, float ty){
	int u = 0 ;
		for(int i = 0; i<lines.size() ; i++){
			Line thisLine = lines.get(i);
			thisLine.counter(tx,ty);
			lines.set(i,thisLine);
			u+=2;
	}
}


}

class Dot{

	float tx,ty,ntx,nty;
	int id;
	
	Dot(float tx, float ty,int id){
		this.tx = tx;
		this.ty = ty;
		this.id = id;
		ntx = 0;
		nty = 0;
	}
}

class Line{

float tx,ty,angle,speed,cWheel,pOffsetSpeed;
color myColor,initColor;

//things contain the items to instance and their attributes
ArrayList<Thing> things;

//spots are the control points
ArrayList<Dot> spots;
Dot prevDot;

//max number of dots
int numDot, spacing, spaceOffset, numThing, type;

//actual amount of dots
int amountDot;

//q is always counter
int q;
int id;

float[] TX;
float[] TY;

Line(int numDot)
{
	things = new ArrayList();
	speed = .001;
	spots = new ArrayList();
	this.numDot = numDot;
	type = 1;
	cWheel = .001;
	id = (int)random(10000);
	pOffsetSpeed = .0001;
	

	
	for (int i = 0; i<numDot ; i++){
	//	addDot();
	}
}

Line(int numDot, int numThing, int spacing, float speed)
{
	this(numDot);
	//int iSpeed = (int)speed;
	//if(speed>0)
	//this.speed = numDot/(float)(iSpeed*10000);
	//else
	this.speed = speed;
	this.numThing = numThing;
	this.spacing = spacing;
	//TX = new float[numDot*spacing];
	//TY = new float[numDot*spacing];
	TX = new float[0];
	TY = new float[0];
	
	//initPosArray(mouseX,mouseY);
}

Line(int type, int numDot, int numThing, int spacing, float speed)
{
	this(numDot,numThing,spacing,speed);
	this.type = type;
	cWheel = 0;
	myColor = color(255);
}

Line(int type, int numDot, int numThing, int spacing, float speed,float wheel,color thisColor)
{
	this(type,numDot,numThing,spacing,speed);
	cWheel = wheel;
	this.myColor = thisColor;
	initColor = thisColor;
}

Line(int id,int type, int numDot, int numThing, int spacing, float speed,float wheel,color thisColor)
{
	this(type,numDot,numThing,spacing,speed,wheel,thisColor);
	this.id = id;
}

Line(int id,int type, int numDot, int numThing, int spacing, float speed,float wheel,color thisColor, float pOffsetSpeed)
{
	this(id,type,numDot,numThing,spacing,speed,wheel,thisColor);
	this.pOffsetSpeed = pOffsetSpeed;
}

void counter(float tx, float ty, boolean toAdd, boolean showAnchor, boolean Noise, float nAmount, float nSpeed, float nTail, float nDetail)
{
	counter(tx,ty,toAdd);
	
	if (showAnchor)
	{
		displayAnchor();
		displayArray();
	}
	
	if(Noise)
		messDot(nAmount,nSpeed,nTail,nDetail);
	
}

void counter(float tx, float ty, boolean toAdd)
{
	this.tx = tx;
	this.ty = ty;
	
	q++;
	
	//update pos array adds items to the end of the array then offset based on the number of 
	//anchor points (numdot) and the desired spacing between them (spacing)
	boolean posBool = updatePosArray();
	
	moveDot();
	displayThing();
	
	//updatePosArray will become true when it updates
	if(toAdd && posBool){	
		enlargePosArray();
		if(TX.length%spacing == 0)
		{
			addDot(tx,ty);
			for(int i = 0; i<spacing ; i++)
				addThing(myColor);
		}
		
	}
	
	updateColor(cWheel);
	
	//adds noise(amount,speed(bigger is slower),tail fade(0 is fade, 1 is not), detail(bigger is less detail))
	//messDot(5,100,1, 5);
	//noiseDot(1,100,1, 50);
	//noiseDot(.1,30,1, 1);
	
	//drawLine();
	
	//show the anchor points
	//displayAnchor();
	//displayArray();
}

void counter(float tx, float ty)
{
	this.tx = tx;
	this.ty = ty;
	
	q++;
	
	//update pos array adds items to the end of the array then offset based on the number of 
	//anchor points (numdot) and the desired spacing between them (spacing)
	boolean posBool = updatePosArray();


	//normalizeThings();
	updateColor(cWheel);
	//println(posBool);
	//alternately you can just add dots directly)
	//if(spots.size() < numDot && posBool){
	//
	//if(posBool){
	if(posBool && spots.size()<numDot){
		if(TX.length%spacing ==0){
		addDot(tx,ty);
		}
		//for(int i = 0 ; i<spacing ; i++)
			enlargePosArray();
	}
	
	//println(spots.size());

	moveDot();
	if(spots.size()>1)
		displayThing();
	
	//println(" spots " + spots.size());
	//println(" things " + things.size());
	//color n = color(255);
	//if(q%spacing == 0)
	//println(cWheel + "   " + id + "    " + q + "   " + cWheel*q);

	//updateColor(cWheel );
	//if(posBool)
	if(things.size()<numThing && posBool)
		addThing(myColor);
		
	//messDot(20,100000,1,1);
	
	//adds noise(amount,speed(bigger is slower),tail fade(0 is fade, 1 is not), detail(bigger is less detail))
	messDot(10,50,1, 50);
	//noiseThing(150,10000,1,1);
	//noiseDot(150,100,1, 50);
	//noiseDot(.1,30,1, 1);
	
	//show the anchor points
	//displayAnchor();
	//displayArray();
}

//sets the array to zero
void initPosArray(){

TX = new float[numDot*spacing];
TY = new float[numDot*spacing];

for(int i = 0; i<numDot*spacing ; i++){
	TX[i] = 0;
	TY[i] = 0;
	}
}

//sets all the points in the array to whatever you tell them to be
void initPosArray(float tx, float ty)
{
TX = new float[numDot*spacing];
TY = new float[numDot*spacing];
for(int i = 0; i<numDot*spacing ; i++){
	TX[i] = tx;
	TY[i] = ty;
}
}

//sets all the points in the array to whatever you tell them to be
void initPosArray(float[] pArray)
{
TX = new float[pArray.length/2];
TY = new float[pArray.length/2];

int u = 0;

for(int i = 0; i < pArray.length/2 ; i++){
	TX[i] = pArray[u];
	TY[i] = pArray[u+1];
	u+=2;
}
}

//adds things while spaceOffset<numThing and the interval is correct
void addThingWhileDrawing(){
	if(things.size()<numThing)
	{
		spaceOffset+=1;
		for(int i = 0; i<spacing; i++)
		{
			updateColor();
			addThing(myColor);
		}
	 }
}

//adds an item to the beginning of the position array and offsets the rest
//it also adds things for each update if there aren't enough things yet
//it also enlarges the array if it's at 0
boolean updatePosArray(){


try{
	if ( TX.length == 0 )
	{
		TX = enlarge(TX,1);
		TY = enlarge(TY,1);
		return true;
	}
	
	else if(dist(tx,ty,TX[0],TY[0])>0 && tx!=0 && ty!= 0 && TX.length>0)
	{
		TX[TX.length-1] = tx;
		TY[TY.length-1] = ty;
		
		TX = arrayOffsetR(TX);
		TY = arrayOffsetR(TY);
		
		spaceOffset++;
		
		return true;
	}

	else
		{
		return false;
		}
	}
	catch(ArrayIndexOutOfBoundsException e)
	{
		e = new ArrayIndexOutOfBoundsException(TX.length);
		return false;
	}
}

void enlargePosArray(){
	TX = enlarge(TX,1);
	TY = enlarge(TY,1);
}

float[] enlarge(float[] array, int amount){

	float[] nArray = new float[array.length + amount];
	
	//for( int i = 0; i<nArray.length; i++){
	//	nArray[i] = array[0];
	//	}
	
	for (int i = 0; i<array.length ; i++){
		nArray[i] = array[i];
	}
	//for( int i = array.length-1; i<nArray.length; i++){
	//	nArray[i] = nArray[i-1];
	//	}
	return nArray;

}

//offsets the hue by the value specified in 'wheel'
void updateColor(float cWheel){

	 colorMode(HSB,1,1,1,1);
	float h = hue(myColor);
	float s = saturation(myColor);
	float b = brightness(myColor);
	
	h+=cWheel;
	if(h>1)
	h=0;
	 
	myColor = color(h,s,b);
	colorMode(RGB,255,255,255,255);
}

void updateColor(){
	updateColor(cWheel);
}

//chops the array based on 'spaceOffset'
void clipPosArray(){

	if(spaceOffset<numDot){
		
		//println(spaceOffset);
		float[] nTX = new float[spaceOffset*spacing];
		float[] nTY = new float[spaceOffset*spacing];
		//println(nTX.length);
		//println(TX.length);
		for (int i = 0 ; i<nTX.length ; i++){
			nTX[i] = TX[i];
			nTY[i] = TY[i];
		}

		TX = nTX;
		TY = nTY;
		
		for(int i = spots.size()-1; i >= spaceOffset; i--){
			spots.remove(i);
		}
		
		numDot = spaceOffset;
		
		/*
		println(numDot);
		println(spots.size());
		println(TX.length);
		println(numDot*spacing);
		*/
	}
	
	
}

//adds one dot and increments q
void addDot(){
q++;
	spots.add(new Dot(tx,ty,q));
	amountDot ++;
}

void addDot(float mytx, float myty){
q++;
	spots.add(new Dot(mytx,myty,q));
	amountDot ++;
}

//adds dots based on a variety of rules
void addDots() {

	//add spots for the first 5 frames
	if (q<=5) spots.add(new Dot(tx, ty, q));
	
	//prev dot is the last one added
	prevDot = (Dot) spots.get(spots.size()-1);
 
	//then add one more every fifth frame if the distance is great enough
	if (q%5 == 0 && q>5 && dist(tx, ty, prevDot.tx, prevDot.ty) > 10)
	{
		spots.add(new Dot(mouseX, mouseY,q));
		amountDot++;		
	}
	
	
}

//shows the positions of all the points in the TX, TY arrays
void displayArray(){

int j = 0;

for (int i = 0; i<TX.length; i++){
	fill(255,255);
	ellipse(TX[i],TY[i],5,5);
	j+=spacing;
}

}

//this simply draws small elipses at every anchor point - for testing
void displayAnchor(){

	for (int i = 0; i< spots.size() ; i++)
	{
		fill(255);
		Dot thisSpot = spots.get(i);
		//ellipse(thisSpot.tx,thisSpot.ty,15,15);
		text(thisSpot.id,thisSpot.tx + thisSpot.ntx,thisSpot.ty + thisSpot.nty);
	}
}

//places the dots incrementally along the TX, TY arrays
void moveDot(){

int j = 0;
for (int i = spots.size()-1; i>=0 ; i--)
{
	Dot thisDot = (Dot) spots.get(i);
	thisDot.tx = TX[j] + thisDot.ntx;
	thisDot.ty = TY[j] + thisDot.nty;
	spots.set(i,thisDot);
	
	//if(j+spacing<TX.length)
	j+=spacing;
}

	
}

//draws a line along all the anchor points;
void drawLine(color myColor,float weight){
if(spots.size()>1){
	pushStyle();
	fill(0,0);
	stroke(myColor);
	strokeWeight(weight);
	beginShape();
	for (int i = 0; i< spots.size() ; i++)
	{
		
		Dot thisSpot = spots.get(i);
		curveVertex(thisSpot.tx+thisSpot.ntx,thisSpot.ty+thisSpot.nty);
		
	}
	endShape();
	popStyle();
}
}

void drawLine(){
	color c = color(255,255,255,255);
	drawLine(c,3);
}

//returns the array in a format which alternates between x and y so {tx,ty,tx,ty,tx,ty}
float[] getDotPos(){

int j = 0;
int u = 0;

float[] returnXY = new float[spots.size()*2];

for (int i = spots.size()-1; i>=0 ; i--)
{
	returnXY[u] = TX[j];
	returnXY[u+1] = TY[j];
	
	u+=2;
	j+=spacing;
}

return returnXY;
	
}

float[] getArray(){

int u = 0;
float[] returnXY = new float[TX.length * 2];

for (int i = 0 ; i < TX.length ; i++){

	returnXY[u] = TX[i];
	returnXY[u+1] = TY[i];

	u+=2;
}

return returnXY;
}

void setDotPos(float[] dotPos){
int u = 0;

for (int i = spots.size()-1; i>=0 ; i--)
{
	
	if(i*2 < dotPos.length)
	{
		Dot thisDot = spots.get(i);
		
		thisDot.tx = dotPos[u];
		thisDot.ty = dotPos[u+1];
		
		u+=2;
	}
}
	
	
}

//functions that offset an array forward or backward
float[] arrayOffsetR(float[] array){

	float[]tempArray = new float[array.length];
	
	float tmp = array[array.length-1];
	
	for (int i = 1; i<array.length; i++)
	{
		tempArray[i] = array[i-1];

	}
	tempArray[0]=tmp;
	return tempArray;
}

float[] arrayOffset(float[] array){
	float[]tempArray = new float[array.length];
	float tmp = array[array.length-1];
	
	for (int i = 0; i<array.length-1; i++)
	{
		tempArray[i] = array[i+1];

	}
	tempArray[0]=tmp;
	
	return tempArray;
}

//adds random noise for each dot position
void messDot(float amount, float speed, float tailor, float detail){
	
float q2 = (float)q/speed;

noiseDetail(1);
for (int i = 0 ; i<spots.size() ; i++)
	{
		Dot thisDot = spots.get(i);

		float b = (float)thisDot.id/detail;
		
		
		float tail = map((float)thisDot.id,0,spots.size(),1,tailor);
	
		thisDot.ntx = map(noise((b+q2+id)),0,.45,amount*-1,amount)*tail;
		thisDot.nty = map(noise(((b+q2)+b+1000+id)),0,.45,amount*-1,amount)*tail;

		spots.set(i,thisDot);
	}
	noiseDetail(4);
}


//adds random noise for each dot position
void noiseDot(float amount, float speed, float tailor, float detail){
	
float q2 = (float)q/speed;

noiseDetail(1);
for (int i = 0 ; i<spots.size() ; i++)
	{
		Dot thisDot = spots.get(i);

		float b = (float)thisDot.id/detail;
		
		
		float tail = map((float)thisDot.id,0,spots.size(),1,tailor);
	
		thisDot.ntx += map(noise((b+q2+id)),0,.5,-amount,amount)*tail;
		thisDot.nty += map(noise(((b+q2)+b+1000+id)),0,.5,-amount,amount)*tail;

		spots.set(i,thisDot);
	}
	noiseDetail(4);
}

void noiseThing(float amount, float speed, float tailor, float detail){

float q2 = (float)q/speed;

noiseDetail(1);

for (int i = 0 ; i<things.size() ; i++)
	{
		Thing thisThing = things.get(i);

		float b = (float)thisThing.id/detail;
		
		
		float tail = map((float)thisThing.id,0,spots.size(),1,tailor);
	
		thisThing.ntx = map(noise((b+q2+id)),0,.45,amount*-1,amount)*tail;
		thisThing.nty = map(noise(((b+q2)+b+1000+id)),0,.45,amount*-1,amount)*tail;

		things.set(i,thisThing);
	}
	
noiseDetail(4);

}
//removes the last spot when there are too many
void cleanUp(){
	if(spots.size()>numDot)
		spots.remove(0);
}

//returns an array that has the x and y values of a point along a curve
float[] CurveLerper(float amt){

//returns x,y and angle in an array

//if spots.size > 1 then add two spots, one at the beginning and one at the end
ArrayList<Dot> spotsW = new ArrayList(spots);
if (spots.size() > 0){
			
	Dot zeroDot = spotsW.get(0);
	Dot endDot = spotsW.get(spotsW.size()-1);
	Dot oneDot = spotsW.get(1);
	Dot penDot = spotsW.get(spotsW.size()-2);
	
	float ztx = zeroDot.tx + zeroDot.ntx;
	float zty = zeroDot.ty + zeroDot.nty;
	
	float etx = endDot.tx + endDot.ntx;
	float ety = endDot.ty + endDot.nty;
	
	float otx = oneDot.tx + oneDot.ntx;
	float oty = oneDot.ty + oneDot.nty;
	
	float ptx = penDot.tx + penDot.ntx;
	float pty = penDot.ty + penDot.nty;
	
	float dx = ztx - otx;
	float dy = zty - oty;
	
	float ex = etx - ptx;
	float ey = ety - pty;
	
	float angle1 = atan2 (dy,dx);
	float angle2 = atan2 (ey,ex);
	
	float distance1 = dist(ztx,zty,otx,oty);
	float distance2 = dist(etx,ety,ptx,pty);
	
	float nztx = distance1*cos(angle1);
	float nzty = distance1*sin(angle1);
	
	float netx = distance2*cos(angle2);
	float nety = distance2*sin(angle2);
	
	Dot spotZero = new Dot(nztx + ztx,nzty + zty,0);
	Dot spotEnd = new Dot(netx + etx,nety+ety,spots.size());
	
	//this will display the additional anchor points
	//ellipse(spotEnd.tx,spotEnd.ty,30,30);
	//ellipse(spotZero.tx,spotZero.ty,30,30);
	
	spotsW.add(0,spotZero);
	spotsW.add(spotEnd);
}

float firstOffset = map(amt,0,1,3,spotsW.size());
int segment = (int) floor(firstOffset);
float offset = (firstOffset-segment);

//if(segment<4)
//segment = 4;

//this stores the values that are returned by the curveLerper
float[] coord = new float[11];

float lerpX,lerpY;

Dot one =null;
Dot two = null;
Dot three = null;
Dot four = null;

//println(spots.size());
//println(spotsW.size());

if(segment < spotsW.size() && spotsW.size() > 1)
	{

	int j = segment;
		
		if(j>3)
		{
				one = (Dot) spotsW.get(j);
				two = (Dot) spotsW.get(j-1);
				three = (Dot) spotsW.get(j-2);
				four = (Dot) spotsW.get(j-3);  
			
		}
		
		else if(j>2)
		{	
				one = (Dot) spotsW.get(j);
				two = (Dot) spotsW.get(j-1);
				three = (Dot) spotsW.get(j-2);
				four = (Dot) spotsW.get(j-2);  
			
		}
		else if (j>1)
		{	
				one = (Dot) spotsW.get(j);
				two = (Dot) spotsW.get(j);
				three = (Dot) spotsW.get(j-1);
				four = (Dot) spotsW.get(j-1);  
			
		}
		
		else
		{
				one = (Dot) spotsW.get(j);
				two = (Dot) spotsW.get(j);
				three = (Dot) spotsW.get(j);
				four = (Dot) spotsW.get(j);  
			
		}
		
		
		lerpX = curvePoint(four.tx+four.ntx,three.tx+three.ntx,two.tx+two.ntx,one.tx+one.ntx,offset);
		lerpY = curvePoint(four.ty+four.nty,three.ty+three.nty,two.ty+two.nty,one.ty+one.nty,offset);
		
		
		float[] temp = {lerpX,lerpY,0,four.tx,four.ty,three.tx,three.ty,two.tx,two.ty,one.tx,one.ty};
		coord = temp;
	
	} //segment
return coord;
}

//returns an array that has the x and y values of a point along a curve
float[] CurveLoopLerper(float amt){

//returns x,y and angle in an array

float firstOffset = map(amt,0,1,0,amountDot);
int segment = (int) floor(firstOffset);
float offset = (firstOffset-segment);


//this stores the values that are returned by the curveLerper
float[] coord = new float[11];

float lerpX,lerpY;

Dot one =null;
Dot two = null;
Dot three = null;
Dot four = null;

if(spots.size()>4){
if(segment < spots.size() && spots.size() > 1)
	{

	int j = segment;
		
		if(j>3)
		{
				one = (Dot) spots.get(j);
				two = (Dot) spots.get(j-1);
				three = (Dot) spots.get(j-2);
				four = (Dot) spots.get(j-3);  
			
		}
		
		else if(j>2)
		{	
				one = (Dot) spots.get(j);
				two = (Dot) spots.get(j-1);
				three = (Dot) spots.get(j-2);
				four = (Dot) spots.get(spots.size()-1);  
			
		}
		else if (j>1)
		{	
				one = (Dot) spots.get(j);
				two = (Dot) spots.get(j-1);
				three = (Dot) spots.get(spots.size()-1);
				four = (Dot) spots.get(spots.size()-2);  
			
		}
		
		else
		{
				one = (Dot) spots.get(j);
				two = (Dot) spots.get(spots.size()-1);
				three = (Dot) spots.get(spots.size()-2);
				four = (Dot) spots.get(spots.size()-3);  
			
		}
		lerpX = curvePoint(four.tx+four.ntx,three.tx+three.ntx,two.tx+two.ntx,one.tx+one.ntx,offset);
		lerpY = curvePoint(four.ty+four.nty,three.ty+three.nty,two.ty+two.nty,one.ty+one.nty,offset);
		
		
		float[] temp = {lerpX,lerpY,0,four.tx,four.ty,three.tx,three.ty,two.tx,two.ty,one.tx,one.ty};
		coord = temp;
	
	} //segment
}
else{ 
lerpX =0; 
lerpY = 0;
}
return coord;
}

//adds things all at once at regular intervals along the curve
void initThing(){

//float c=0;
float h = hue(myColor);
float s = saturation(myColor);
float b = brightness(myColor);
for (int i = 0 ; i<numThing ; i++)
{
	
	colorMode(HSB,1,1,1);
	
	color tColor = color(h,s,b);
		things.add(new Thing(type,tColor,speed, map(i,0,numThing,0,1)));
	h+=cWheel;
	if(h>1)
	h=0;
	spaceOffset++;
}

}

void initDot(){
while(spots.size() < numDot){
	addDot();
}
}

//adds things
void addThing(color thisColor){
	things.add(new Thing(type,thisColor,speed,things.size(),pOffsetSpeed));
	//spaceOffset++;
}	

//adds things with no color info
void addThing(){
	color thisColor = color(255);
	things.add(new Thing(type,thisColor,speed,q));
	//spaceOffset++;
}	

//takes all the things and sets their qOffset to a value between 0 and 1 based on the # of dots
void normalizeThings(){


//println(things.size());
for (int i = 0 ; i<things.size() ; i++){
		
		//println("amountDot: " + amountDot + " things.size: " + things.size());
		float b = map(i,0,things.size(),0,1);
		Thing thisFly = things.get(i);
		//print(i + ": ");
		//println(b);
		//thisFly.speed = (speed*10)/spots.size();
		thisFly.qOffset = b;
		thisFly.pOffset = b;
		thisFly.qOffsetB= b+.001;
		//thisFly.bulb =10;
		//println(thisFly.qOffset);
		things.set(i,thisFly);
		}
		
}

void setThingSpeed(float speed)
{
	for (int i = 0 ; i<things.size() ; i++){
		Thing thisFly = things.get(i);
		thisFly.speed = speed;
		things.set(i,thisFly);
	}
}

void blur(PImage img, float amt){
	img.filter(BLUR,amt);
}

void blur(float amt){
}

float getThingSpeed(){
float speed = 0;
	for (int i = 0 ; i<things.size() ; i++){
		Thing thisFly = things.get(i);
		speed += thisFly.speed;
	}
return speed /= things.size();
}

void incrementThingSpeed(float speed)
{
	for (int i = 0 ; i<things.size() ; i++){
		Thing thisFly = things.get(i);
		thisFly.speed += speed;
		things.set(i,thisFly);
	}
}

void setThingPOffsetSpeed(float speed)
{
	for (int i = 0 ; i<things.size() ; i++){
		Thing thisFly = things.get(i);
		thisFly.pOffsetSpeed = speed;
		things.set(i,thisFly);
	}
}

void incrementThingPOffsetSpeed(float speed)
{
	for (int i = 0 ; i<things.size() ; i++){
		Thing thisFly = things.get(i);
		thisFly.pOffsetSpeed += speed;
		things.set(i,thisFly);
	}
}

void setThingBulb(float bulb)
{
	for (int i = 0 ; i<things.size() ; i++){
		Thing thisFly = things.get(i);
		thisFly.bulb = bulb;
		things.set(i,thisFly);
	}
}

void setThingRad(float rad)
{
	for (int i = 0 ; i<things.size() ; i++){
		Thing thisFly = things.get(i);
		thisFly.rad = rad;
		things.set(i,thisFly);
	}
}

void incrementThingRad(float rad)
{
	for (int i = 0 ; i<things.size() ; i++){
		Thing thisFly = things.get(i);
		thisFly.rad += rad;
		things.set(i,thisFly);
	}
}

//this calls the CurveLerper to get the position, and it calculates the angle and displays the Thing
void displayThing(){

	for (int i = 0 ; i<things.size() ; i++){
		
		Thing thisPrev = things.get(i);
		
		if(i>0){
			thisPrev = things.get(i-1);
		}

		Thing thisFly = things.get(i);
		
		float[] pos = CurveLerper(thisFly.qOffset);
		float[] posB = CurveLerper(thisFly.qOffsetB);
		
		tx = pos[0] + thisFly.ntx;
		ty = pos[1] + thisFly.nty;
		
		float txb = posB[0];
		float tyb = posB[1];
		
		
		float dx = tx - txb;
		float dy = ty - tyb;
		
		float angle = atan2 (dy,dx);
		
		
		float lx = pos[3];
		float ly = pos[4];
		
		float kx = pos[9];
		float ky = pos[10];
		
		stroke(0,255);

		pushMatrix();
		translate(tx,ty);
		rotate(angle);
		thisFly.tx = tx;
		thisFly.ty = ty;
		
		//println(thisFly.qOffset);
		
		//if (thisFly.qOffset > 0 && tx != 0)
		//thisFly.display();
		
	
		//ellipse(0,0,100,100);
		
		//ellipse(0,0,40,40);
		
		
			float scaled   = map(dist(thisFly.tx,thisFly.ty,thisPrev.tx,thisPrev.ty),0,width,0,1);
			thisFly.scaler = scaled;
	
		
		
		thisFly.pOffset += thisFly.pOffsetSpeed;
		thisFly.offset();
		
		if(pos[0]!=0)
		display(thisFly.qOffset,thisFly.pOffset,thisFly.myColor,thisFly.scaler,thisFly.rad,thisFly.bulb);
		
		things.set(i,thisFly);
		popMatrix();
	}
	
	for (int i = 0 ; i<things.size() ; i++){
		Thing thisFly = things.get(i);
		things.set(i,thisFly);
	}
}

//override this one
void display(){
ellipse(0,0,10,10);
}

//also consider overriding this one
void display(float q, float p, color myColor,float scaler,float rad,float bulb){
	float fat = constrain(map(q,0,1,0,PI),0,PI);
	//float fatness = constrain(sin(fat)*10,0,50);
	float fatness = sin(fat)*rad;
	float bulbs = abs(sin(p*(PI*bulb)));
	//println(id);
	pushStyle();
	noStroke();
	fill(myColor,255);
	tint(myColor);
	pushMatrix();
		rotate(fat);
		//scale(fatness*bulb*(scaler*8));
		//scale(scaler*10);
		scale(fatness*sin((q*bulbs)));
		//scale(fatness);
		//scale(fatness*.2);
		display();
		
	popMatrix();
	popStyle();
		pushMatrix();
		pushStyle();
			//translate(2.5,2.5);
			noStroke();
			scale(.3);
			//display();
		popStyle();
		popMatrix();
}
}

class LineCube extends Line{

LineCube(int id,int type, int numDot, int numThing, int spacing, float speed,float wheel,color thisColor, float pOffsetSpeed)
{
	super(id,type,numDot,numThing,spacing,speed,wheel,thisColor,pOffsetSpeed);
}

	void display(){
		rect(-5,-5,10,10);
	}
}

class LineDad extends Line{

PImage img;
int imx,imy;

LineDad(int id,int type, int numDot, int numThing, int spacing, float speed,float wheel,color thisColor, float pOffsetSpeed)
{
	super(id,type,numDot,numThing,spacing,speed,wheel,thisColor,pOffsetSpeed);
	img = loadImage("flower.png");
	//blur(img,10);
	imx = img.width;
	imy = img.height;
}

void blur(float amt){
	if(amt == 0)
		img = loadImage("flower.png");
	else
	blur(img,amt);
}
	void display(){
		
		//ellipse(0,0,10,10);
		dad();
	}
	void dad(){
		//rect(0,0,10,10);
		pushMatrix();
		rotate(PI/-2);
		translate(-imx/12,-imy/12);

		beginShape();
		texture(img);
		//tint(myColor);
		vertex(0,0,0,0);
		vertex(imx/6,0,imx,0);
		vertex(imx/6,imy/6,imx,imy);
		vertex(0,imy/6,0,imy);
		endShape();
		popMatrix();
}
}

class LineLight extends Line{

PImage img;
int imx,imy;

LineLight(int id,int type, int numDot, int numThing, int spacing, float speed,float wheel,color thisColor, float pOffsetSpeed)
{
	super(id,type,numDot,numThing,spacing,speed,wheel,thisColor,pOffsetSpeed);
	img = loadImage("light.png");
	imx = img.width;
	imy = img.height;
}

	void display(){
		//ellipse(0,0,10,10);
		dad();
	}
	void dad(){
		//rect(0,0,10,10);
		pushMatrix();
		rotate(PI/-2);
		translate(-imx/2,-imy/2);

		beginShape();
		texture(img);
		//tint(myColor);
		vertex(0,0,0,0);
		vertex(imx,0,imx,0);
		vertex(imx,imy,imx,imy);
		vertex(0,imy,0,imy);
		endShape();
		popMatrix();
}
}

class LineTree extends Line{

PImage img;
int imx,imy;

LineTree(int id,int type, int numDot, int numThing, int spacing, float speed,float wheel,color thisColor, float pOffsetSpeed)
{
	super(id,type,numDot,numThing,spacing,speed,wheel,thisColor,pOffsetSpeed);
	img = loadImage("tree.png");
	imx = img.width;
	imy = img.height;
}

	void display(){
		dad();
	}
	void dad(){
		//rect(0,0,10,10);
		pushMatrix();
		rotate(PI/-2);
		translate(-imx/6,-imy/6);

		beginShape();
		texture(img);
		//tint(myColor);
		vertex(0,0,0,0);
		vertex(imx/3,0,imx,0);
		vertex(imx/3,imy/3,imx,imy);
		vertex(0,imy/3,0,imy);
		endShape();
		popMatrix();
}

void display(float q, float p, color myColor,float scaler){
	float fat = constrain(map(q,0,1,-.5,PI),0,PI);
	float fatness = constrain(sin(fat)*10,0,100);
	float bulb = abs(sin(p*30));
	//println(id);
	pushStyle();
	stroke(myColor);
	noStroke();
	fill(myColor,255);
	tint(myColor);
	pushMatrix();
		//rotate(fat);
		scale(fatness*bulb*(scaler*5)+.2);
		//scale(scaler*10);
		//scale(fatness*sin((qOffset*bulb)));
		//scale(fatness);
		
		display();
		
	popMatrix();
	popStyle();
	}
}

class Thing{

int imx,imy;

float tx,ty,ntx,nty,rad,pOffsetSpeed;
int id;
color myColor;

float qOffset = 0;
float qOffsetB = .01;

float speed,pOffset,bulb,scaler;

int type;


Thing(int type, color myColor){
	this.type = type;
	this.id = 0;
	this.myColor = myColor;
	qOffsetB=1;
	scaler = 1;
	bulb = 10;
	rad = 5;
}

Thing(int type, color myColor,float speed){
	this(type, myColor);
	this.speed = speed;
}

Thing(int type, color myColor,float speed,float offset){
	this(type, myColor,speed);
	this.pOffset = offset;
	this.qOffset = offset;
	this.qOffsetB = offset + .001;
	this.type = type;
	id = (int)offset;
}

Thing(int type, color myColor,float speed,float offset,float pOffsetSpeed){
	this(type, myColor,speed,offset);
	this.pOffsetSpeed = pOffsetSpeed;
}

Thing(){
	this.id = 1;
	this.myColor = color(128);
}

void offset(){
	qOffset += speed;
	if(qOffset>1) qOffset = 0;
	if(qOffset<0) qOffset = 1;
	qOffsetB += speed;
	if(qOffsetB>1) qOffsetB = 0;
	if(qOffsetB<0) qOffsetB = 1;
}

void offset(float offset){
	qOffsetB += offset;
	if(qOffsetB>1) qOffsetB = 0;
	if(qOffsetB<0) qOffsetB = 1;
	qOffset += offset;
	if(qOffset>1) qOffset = 0;
	if(qOffset<0) qOffset = 1;
	
}

}
