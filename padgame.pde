import themidibus.*; //Import the library
import controlP5.*;
import java.util.Map;
import java.util.List;

MidiBus myBus; // The MidiBus
HashMap<Integer, Note> ns;
int offset;
int posX, posY;
int oldX, oldY;
int fadeX, fadeY;
int xSpeed, ySpeed;
ControlP5 controlP5;
CheckBox checkbox;
Textfield myTextfield;
int myBitFontIndex;
boolean doDraw = false;
List<Toggle> citems;
boolean[] canToggle = new boolean[64];

void setup() {
  size(600, 600);
  smooth();
  background(0);
  offset = 0;
  posX = 3;
  posY = 0;
  xSpeed = 1;
  ySpeed = 1;
  ns = new HashMap<Integer, Note>();
  //MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  myBus = new MidiBus(this, 0, 0); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
  reset();
  controlP5 = new ControlP5(this);
  myTextfield = controlP5.addTextfield("textinput", 10, 500, 100, 20);//this is where you type the words
  //Textfield(ControlP5 theControlP5, ControllerGroup theParent, java.lang.String theName,
  //java.lang.String theDefaultValue, int theX, int theY, int theWidth, int theHeight)
  myTextfield.setFocus(true);
  checkbox = controlP5.addCheckBox("checkBox")
    .setPosition(10, 10)
      .setColorForeground(color(120))
        .setColorActive(color(255,0,0))
          .setColorLabel(color(255))
            .setSize(30, 30)
              .setItemsPerRow(8)
                .setSpacingColumn(22)
                  .setSpacingRow(22);
 int cCount = 0;
  for (int i=0;i<(8*16);i+=16) {
    for(int j=0;j<8;j++){
      checkbox.addItem(Integer.toString(i+j), i+j);
      canToggle[cCount] = true;
      cCount++;
    }
  }
  
  citems = checkbox.getItems();

  //   byte data[] = new byte[3];
  //  //B0h, 00h, 00h 
  //  
  //  data[0] = (byte)0x90;
  //  data[1] = (byte)0x27; // x and y - row 3 col 8
  //  data[2] = (byte)0x0F;
  //  myBus.sendMessage(data);
  //  scrollString("HELLO DAWNY", -1, 3, 0);
}

void reset() {
  byte data[] = new byte[3];
  //B0h, 00h, 00h
  data[0] = (byte)0xB0;
  data[1] = (byte)0x00;
  data[2] = (byte)0x00;
  myBus.sendMessage(data);
}

void draw() {
  background(0);
  //  doPong();
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(checkbox)) {
    for (int h=0;h<citems.size();h++) {
        Toggle element = citems.get(h);
        int keyValue = Integer.parseInt(element.getName());
        if(checkbox.getState(h)){
          displayRaw(keyValue, 3,0);
          canToggle[h] = false;
        } else {
          displayRaw(keyValue, 0,0);
          canToggle[h] = true;
        }
    }
  }
}

void checkBox(float[] pads) {
}

public void textinput(String theValue) {
  reset();
  String values[] = split(theValue, ',');
  for (int i=0;i<(8*16);i+=16) {
    for (int j=0;j<8;j++) {
      int sum = i + j;
      if (sum >= i && sum < (i + 8)) {
        if ((Integer.decode(values[j]) & 0x80 >> j)>0) {
          println("on");
          displayRaw(sum, 3, 0);
        } 
        else {
          println("off");
          displayRaw(sum, 0, 0);
        }
      }
    }
  }
}

void doPong() {
  LedSetXY(posX, posY, 0, 0);

  oldX = fadeX;
  oldY = fadeY;
  fadeX = posX;
  fadeY = posY;
  posX+=xSpeed;
  posY+=ySpeed;
  if (posX>=7 || posX<1)
  {
    xSpeed *= -1;
  }
  if (posY>=8 || posY<1) {
    ySpeed *= -1;
  }

  //  LedSetXY(oldX,oldY,1,1);
  //  LedSetXY(fadeX,fadeY,2,1);
  LedSetXY(posX, posY, 3, 0);

  delay(100);
}

void noteOn(int channel, int pitch, int velocity) {
  // Receive a noteOn  
  int checkRow = floor(pitch / 16);
  int checkCol = pitch - (checkRow * 16);
  int checkNumber = checkCol + (checkRow * 8);
  
  if(checkCol < 8 && canToggle[checkNumber]){
    Toggle checkItem = citems.get(checkNumber);
    checkItem.setValue(1.0);
    canToggle[checkNumber] = false;
  } else if(checkCol < 8 && !canToggle[checkNumber]){
    Toggle checkItem = citems.get(checkNumber);
    checkItem.setValue(0.0);
    canToggle[checkNumber] = true;
  }
  
//  try {
//    Note notey = ns.get( pitch );
//    notey.switchit(myBus, channel, pitch, velocity);
//  } 
//  catch ( NullPointerException e ) {
//    Note notey = new Note(false);
//    notey.switchit(myBus, channel, pitch, velocity); 
//    ns.put(pitch, notey);
//  }
}

void noteOff(int channel, int pitch, int velocity) {
  // Receive a noteOff
//  int checkRow = floor(pitch / 16);
//  int checkCol = pitch - (checkRow * 16);
//  int checkNumber = checkCol + (checkRow * 8);
//  
//  if(checkCol < 8 && canToggle[checkNumber]){
//    Toggle checkItem = citems.get(checkNumber);
//    checkItem.setValue(0.0);
//  }
//  try {
//    Note notey = ns.get( pitch );
//    notey.resetChange();
//  } 
//  catch ( NullPointerException e ) {
//    //damn
//  }
}

void delay(int time) {
  int current = millis();
  while (millis () < current+time) Thread.yield();
}

void scrollString(String s, int dir, int r, int g) {
  char[] str = s.toCharArray();
  if (dir==-1) {
    for (char i : str) {
      for (int j = 5; j > -8; j--) {
        displayCharacter(i, j, r, g);
        delay(45);
      }
    }
  } 
  else if (dir == 0) {
    for (char i : str) {
      for (int j = 0; j < 4; j++) {
        displayCharacter(i, j, r, g);
        delay(50);
      }
    }
  } 
  else if (dir == 1) {
    for (char i : str) {
      for (int j = -5; j < 8; j++) {
        displayCharacter(i, j, r, g);
        delay(50);
      }
    }
  }
}


void displayCharacter(char c, int x, int r, int g) {
  int code = (int) c;
  code = (code > 255 ? 255 : code);
  code = (code < 0 ? 0 : code) * 8;

  for (int i=0;i<(8*16);i+=16) {
    for (int j=0;j<8;j++) {
      int sum = i + j + x;
      if (sum >= i && sum < (i + 8)) {
        if ((CHARTAB[code] & 0x80 >> j)>0) {
          displayRaw(sum, r, g);
        } 
        else {
          displayRaw(sum, 0, 0);
        }
      }
    }
    code += 1;
  }
}

void displayRaw(int number, int r, int g) {
  number = (number >  120 ? 120 : number);
  number = (number <  0 ? 0 : number);
  myBus.sendNoteOn(0, number, getLedColor(r, g));
}

public int getLedColor(int red, int green) {
  int led = 0;

  red = ( red > 3 ? 3 : red );
  red = ( red < 0 ? 0 : red );

  green = ( green > 3 ? 3 : green );
  green = ( green < 0 ? 0 : green );

  led |= red;
  led |= green << 4;

  return led;
}

void LedSetXY(int x, int y, int r, int g) {
  if (x < 0 || y > 8 || y < 0 || y > 8) {
    return;
  }

  if (y==0) {
    displayOnAutomap( x, r, g );
  } 
  else {
    displayRaw( ( (y-1) << 4) | x, r, g );
  }
}

void displayOnAutomap(int number, int r, int g) {
  number = (number > 7 ? 7 : number);
  number = (number < 0 ? 0 : number);
  myBus.sendNoteOn(0, number, getLedColor(r, g));
}

