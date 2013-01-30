boolean export = false;
boolean finish = false;

import gifAnimation.*;
import processing.opengl.*;

GifMaker gifExport;

//////////////////////////////

Line things;
LineList lines;
LineList lines2;
NoisePoints[] points;
float[] point;

int q;
int numLines = 6;
int which = 1;

boolean writeFile = false;
int writeNum = 4;
boolean makeNew = false;

boolean pressed;
boolean released;
boolean addOne;
boolean alreadyAdded;

int type = 1;
int newNum = 2;

int disp = -1;

//dot holds the position of each anchor point
//line makes the arraylist of Dots, it adds Dots, it cleans up Dots, and it provides interpolation info
//Thing makes an arrayList of butterflies and calls up the Line object and runs line.counter() which lets the line do its business

void setup(){

//GIFvvv////////////////////////////////////////////////
gifExport = new GifMaker(this, "export.gif");
gifExport.setRepeat(0);
gifExport.setQuality(50);
//GIF^^^///////////////////////////////////////////////


size(1920,1080,P3D);

lines = new LineList(0);
lines2 = new LineList(0);
points = new NoisePoints[numLines];
point = new float[numLines*2];

color n = color(random(100,255),random(100,255),random(100,255));
//things = new Line(0,5,50,50,1,0,.01,n);

for(int i = 0; i<numLines ; i++){
	//(initial position x, y, offset for noise, speed)
	points[i] = new NoisePoints(random(width),random(height),i*100,5);

}


//Line(type 1-3,amount of anchor points, int numThing, int spacing, float speed,colorwheel offset, color)


/*
int i = 0;
	while(lines.numLines<numLines){
                int whichOne;
                if(random(10)<5)
                whichOne = 2;
                else
                whichOne = 4;
		colorMode(HSB,1,1,1);
		color ctemp = color(random(.0,.5),random(.6,1),random(.8,1));
		//color ctemp = color(1,1,1);
		lines.add(whichOne,50,40,30,0.000,random(.0005,.1),ctemp);	
		lines.initThings(points[i].tx,points[i].ty);
		i++;
	}
*/
}

void draw(){
  
buttons();
background(0);

if(addOne){
	//Line(int id,int type, int numDot, int numThing, int spacing, float speed,float wheel,color thisColor)
	//lines.add(new Line(type,anchor,amount,spacing,speed,wheel,thisColor));
	colorMode(HSB,1,1,1);
		color n = color(random(.2,.4),random(.6,1),random(.7,1));
		//color n = color(-1000000);
	//color n = color(random(100,255),random(100,255),random(100,255));
	color w = color(1);
	if(type == 1){
	//LineDad(int id,int type, int numDot, int numThing, int spacing, float speed,float wheel,color thisColor, float pOffsetSpeed)

	Line dad = new LineDad(q,type, 100,100,2,.0002,.001,n,.002);
	lines2.add(dad);
	//lines2.add(type, 0,100,2,.002,.005,n);
	}
	
	if(type == 2)// || type==4)
	{
	n = color(random(.2,.4),random(.6,1),random(.8,1));
	//color n = color(random(100,255),random(100,255),random(100,255));
	Line dad = new LineLight(q,type, 100,100,1,.007,.01,n,.003);
	lines2.add(dad);
	}
	
	if(type == 3)
	{
	n = color(random(.2,.25),random(.6,1),random(.1,.2));
	Line dad = new LineDad(q,type, 100,100,5,.005,.01,n,.011);
	lines2.add(dad);
	}
	if(type == 4){
	//LineDad(int id,int type, int numDot, int numThing, int spacing, float speed,float wheel,color thisColor, float pOffsetSpeed)

	Line dad = new LineDad(q,type, 0,1000,15,.002,.001,n,.002);
	lines2.add(dad);
	//lines2.add(type, 0,100,2,.002,.005,n);
	}
	alreadyAdded = true;
}

//println(disp);
//println(lines2.lines.size());





if(pressed){
	lines2.counter();
	pressed = false;
}

if(released){
	//lines2.clipLength();
	released = false;
}
/*
if(makeNew){	
	color ctemp = color(random(1),random(1),random(1));
	lines.add(1,100,50,1,0.000,random(.05),ctemp);	
	lines.initThings(points[newNum].tx,points[newNum].ty);
	makeNew = false;
}
*/
//float[] point = setPoints();

//things.counter(mouseX,mouseY);
//lines.display(0,0);
/*
int u = 0;
for(int i = 0; i<numLines ; i++){
	points[i].mover();
	point[u] = points[i].tx;
	point[u+1] = points[i].ty;
	//ellipse(point[u],point[u+1],20,20);
	u+=2;
}
*/
//	lines.display(point);
	if (lines2.lines.size()>0){
	//lines2.display(0,0);

for(int i = 0; i<lines2.lines.size() ; i++){
	Line thisLine = lines2.lines.get(i);
	if(keyPressed && key == 'e' && disp == i){
		thisLine.counter(mouseX,mouseY);
	}
	else
	thisLine.counter(0,0);
	lines2.lines.set(i,thisLine);
}
}

writeFile();

  if(export){
  gifExport.setDelay(1);
  gifExport.addFrame();
  writeCount++;
  }
  if( writeCount > 14){
     gifExport.finish();
     finish = false;
	 writeCount = 0;
  }

  if (disp>=0 && disp<lines2.lines.size()){
//if(lines2.lines.size()>0){
	Line thisLine = lines2.lines.get(disp);
	//thisLine.displayAnchor();
	text(disp,mouseX,mouseY-10);
	thisLine.drawLine();
}

}

float[] setPoints(){
float[] point = new float[numLines*2];
int u = 0;

for(int i = 0; i<numLines ; i++){
	points[i].mover();
	point[u] = points[i].tx;
	point[u+1] = points[i].ty;
	u+=2;
}

return point;
}

void buttons(){
if(keyPressed && key == '1')
	type = 1;
	if(keyPressed && key == '2')
	type = 2;
	if(keyPressed && key == '3')
	type = 3;
		if(keyPressed && key == '4')
	type = 4;



	if(keyPressed && key == 'w')
	writeFile = true;
	
    if(keyPressed && key == 'q'){
  export = true;
  //println(export);
  finish = true;
  writeCount = 0;
  }
  if(keyPressed &&  key == 'f'){
    //println("finished");
  finished = true;
  writeFile = false;
  
  }
		


}

void keyReleased(){

	if(key == '-')
		lines2.remove();	
	if(key == 'j' )
		disp += 1;
	if(key == 'k')
		disp -= 1;
		
	if(key == 'g'){
	
	int u = 0;
	
	String[] output = new String[lines2.lines.size()*2];
	//println(lines2.lines.size());
		for (int i = 0 ; i < lines2.lines.size() ; i++){
			Line thisLine = lines2.lines.get(i);
			int numDot = thisLine.TX.length/thisLine.spacing;
			output[u] = thisLine.id + "," + thisLine.type + "," + numDot + "," + thisLine.spaceOffset + "," + 
			thisLine.spacing + "," + thisLine.speed + "," + thisLine.cWheel + "," + thisLine.initColor + "," + thisLine.pOffsetSpeed;
			String thisArray = "";
			float[] gotArray = thisLine.getArray();
			//println(gotArray);
			for( int j = 0; j< thisLine.TX.length*2 ; j++){
				thisArray += Float.toString(gotArray[j]) + ",";
			}
			output[u+1] = thisArray;
			u+=2;
			//println(output[i]);
		}
		
	saveStrings("output.trb", output);
	}
	
	if(key == 'h'){
	
	String[] input = loadStrings("output.trb");
	int u = 0;
	
	for ( int i = 0; i<input.length/2 ; i++){
		String[] v = split(input[u],',');
		String[] arrayV = split(input[u+1],',');
		//println(arrayV);
		float[] av = new float[arrayV.length];
		
		//println(v);
		
		for ( int j = 0 ; j<arrayV.length-1 ; j++){
			av[j] = Float.parseFloat(arrayV[j]);
		}
	
	//Line(int id,int type, int numDot, int numThing, int spacing, float speed,float wheel,color thisColor, float pOffsetSpeed)
		color thisColor = Integer.parseInt(v[7]);
		
		Line dad;
		
		if(Integer.parseInt(v[1]) == 1){
		dad = new LineDad (Integer.parseInt(v[0]),Integer.parseInt(v[1]),Integer.parseInt(v[2]),Integer.parseInt(v[3]),
		Integer.parseInt(v[4]),Float.parseFloat(v[5]),Float.parseFloat(v[6]),thisColor,Float.parseFloat(v[8]));//(q,type, 100,100,2,.0002,.001,n,.002);
		}
		else if(Integer.parseInt(v[1]) == 2){
		dad = new LineLight (Integer.parseInt(v[0]),Integer.parseInt(v[1]),Integer.parseInt(v[2]),Integer.parseInt(v[3]),
		Integer.parseInt(v[4]),Float.parseFloat(v[5]),Float.parseFloat(v[6]),thisColor,Float.parseFloat(v[8]));//(q,type, 100,100,2,.0002,.001,n,.002);
		}
		else{
		dad = new LineDad (Integer.parseInt(v[0]),Integer.parseInt(v[1]),Integer.parseInt(v[2]),Integer.parseInt(v[3]),
		Integer.parseInt(v[4]),Float.parseFloat(v[5]),Float.parseFloat(v[6]),thisColor,Float.parseFloat(v[8]));//(q,type, 100,100,2,.0002,.001,n,.002);
		}
		
		dad.initPosArray(av);
		//println(av.length);
		//println(dad.TX.length);
		dad.initDot();
		dad.initThing();
		dad.normalizeThings();
		dad.setThingPOffsetSpeed(Float.parseFloat(v[8]));
		//println(dad.pOffsetSpeed);
		//println(dad.spots.size());
		//println(dad.numDot);
		//println(dad.TX.length);
		lines2.add(dad);
	
	
		u+=2;
	}
	
	
	}

if(disp>=0 && disp<lines2.lines.size()){
	if(key == 'l')
		lines2.lines.remove(disp);

	if(key == 'z'){
		Line thisLine = lines2.lines.get(disp);
		thisLine.incrementThingRad(-.5);
	}
	if(key == 'x'){
		Line thisLine = lines2.lines.get(disp);
		thisLine.incrementThingRad(.5);
	}
	if(key == 'c'){
		Line thisLine = lines2.lines.get(disp);
		thisLine.incrementThingSpeed(-.0001);
	}
	if(key == 'v'){
		Line thisLine = lines2.lines.get(disp);
		thisLine.incrementThingSpeed(.0001);
	}
	if(key == 'b'){
		Line thisLine = lines2.lines.get(disp);
		thisLine.setThingSpeed(0);
	}
	if(key == 'a'){
		Line thisLine = lines2.lines.get(disp);
		thisLine.incrementThingPOffsetSpeed(-.0002);
	}
	if(key == 's'){
		Line thisLine = lines2.lines.get(disp);
		thisLine.incrementThingPOffsetSpeed(.0002);
	}
	if(key == 'd'){
		Line thisLine = lines2.lines.get(disp);
		thisLine.setThingPOffsetSpeed(0);
	}
	if(key == 'n'){
		Line thisLine = lines2.lines.get(disp);
		thisLine.normalizeThings();
	}
	if(key == 'i'){
		Line thisLine = lines2.lines.get(disp);
		thisLine.blur(0);
	}
	if(key == 'o'){
		Line thisLine = lines2.lines.get(disp);
		thisLine.blur(3);
	}

}

}

int writeCount = 0;
void mouseClicked(){
makeNew = true;
newNum+=1;
which +=1;
if(which>3)
which=1;
//writeFile = !writeFile;
writeCount = 0;
}

void writeFile(){

if (writeCount>240){
	writeFile = false;
	writeCount=0;
	writeNum++;
	}
if (writeFile){
	writeCount++;
	saveFrame("sequence_" + writeNum + "/line-######.png");
	//println(writeCount);
	}
}

void mouseDragged(){
	pressed = true;
	if(!alreadyAdded)
		addOne = true;
	else
		addOne = false;
}

void mouseReleased(){
	alreadyAdded = false;
	released = true;
}
