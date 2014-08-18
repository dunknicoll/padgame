class Note {
   boolean ison;
   boolean canchange;
  Note(boolean toggle){
   ison = toggle;
   canchange = true;
  }
  
  void resetChange(){
    canchange = true;
  } 
  
  void switchit(MidiBus myBus, int channel, int pitch, int velocity)
  {
    if(canchange){
      if(ison){
        println("turning off " + pitch + " " + ison);
        myBus.sendNoteOff(channel, pitch, 12);
        ison = false;
      } else {
        println("turning on " + pitch + " " + ison);
        ison = true;
        myBus.sendNoteOn(channel, pitch, 60);
      }
      canchange = false;
    }
  }
}
