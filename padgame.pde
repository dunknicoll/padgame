import themidibus.*; //Import the library
import java.util.Map;

MidiBus myBus; // The MidiBus
HashMap<Integer,Note> ns;
int offset;
int posX,posY;
int oldX,oldY;
int fadeX, fadeY;
int xSpeed,ySpeed;

void setup() {
  size(400, 400);
  background(0);
  offset = 0;
  posX = 3;
  posY = 0;
  xSpeed = 1;
  ySpeed = 1;
  ns = new HashMap<Integer,Note>();
//  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  myBus = new MidiBus(this, 0, 3); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
  reset();
   byte data[] = new byte[3];
  //B0h, 00h, 00h 
  
  data[0] = (byte)0x90;
  data[1] = (byte)0x27; // x and y - row 3 col 8
  data[2] = (byte)0x0F;
  myBus.sendMessage(data); 
}

void reset(){
 byte data[] = new byte[3];
  //B0h, 00h, 00h
  data[0] = (byte)0xB0;
  data[1] = (byte)0x00;
  data[2] = (byte)0x00;
  myBus.sendMessage(data); 
}

void draw() {
  
  oldX = fadeX;
  oldY = fadeY;
  fadeX = posX;
  fadeY = posY;
  posX+=xSpeed;
  posY+=ySpeed;
  if(posX>=7 || posX<1)
  {
   xSpeed *= -1; 
  }
  if(posY>=7 || posY<1){
   ySpeed *= -1;
  }
  
//  int oldPitch  = (ceil(map(oldY, 0, 100, 0, 7))*16)+ceil(map(oldX, 0, 100, 0, 7));
//  int fadePitch  = (ceil(map(fadeY, 0, 100, 0, 7))*16)+ceil(map(fadeX, 0, 100, 0, 7));
//  int newPitch = (ceil(map(posY, 0, 100, 0, 7))*16)+ceil(map(posX, 0, 100, 0, 7));
  int oldPitch  = (oldY*16)+oldX;
  int fadePitch  = (fadeY*16)+fadeX;
  int newPitch = (posY*16)+posX;
//  println(posX+" new "+posY);
  myBus.sendNoteOff(0, oldPitch, 0);
  myBus.sendNoteOn(0, fadePitch, 1);
  myBus.sendNoteOn(0, newPitch, 15);
  //myBus.sendNoteOff(channel, pitch, velocity); // Send a Midi nodeOff

  //int number = 0;
  //int value = 90;

  //myBus.sendControllerChange(channel, number, value); // Send a controllerChange
  delay(100);
}

void noteOn(int channel, int pitch, int velocity) {
  // Receive a noteOn  
  try {
      Note notey = ns.get( pitch );
      notey.switchit(myBus,channel,pitch,velocity); 
  } catch ( NullPointerException e ) {
      Note notey = new Note(false);
      notey.switchit(myBus,channel,pitch,velocity); 
      ns.put(pitch,notey);
  }
  
}

void noteOff(int channel, int pitch, int velocity) {
  // Receive a noteOff
 try {
      Note notey = ns.get( pitch );
      notey.resetChange(); 
  } catch ( NullPointerException e ) {
      //damn
  }
}

void controllerChange(int channel, int number, int value) {
  // Receive a controllerChange
  println();
  println("Controller Change:");
  println("--------");
  println("Channel:"+channel);
  println("Number:"+number);
  println("Value:"+value);
}

void delay(int time) {
  int current = millis();
  while (millis () < current+time) Thread.yield();
}


