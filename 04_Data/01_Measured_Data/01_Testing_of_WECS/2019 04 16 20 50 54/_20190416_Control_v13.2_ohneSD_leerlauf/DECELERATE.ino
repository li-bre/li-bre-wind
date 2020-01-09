//////////////////////// DECELERATE ///////////////////////////////////////////////////////////

void decelerate () {

  if (Short_Break==0) { // Only execute if Short Break is not already 1(on)
    for (i=0;i<255;i++) {
      analogWrite(Dumpload_FET,i);
      delay(50);
    }
    digitalWrite(Dumpload_FET,HIGH);
    Dumpload=1;

    Measure();
    Print_data_Serial("17");
    
    for (i=0;i<255;i++) {
      analogWrite(Short_Break_FET,i);
      delay(50);
    }
    digitalWrite(Short_Break_FET,HIGH);
    Short_Break=1;

    Measure();
    Print_data_Serial("18");
    
    for (i=0;i<255;i++) {
      analogWrite(Dumpload_FET,255-i);
      delay(50);
    }
    digitalWrite(Dumpload_FET,LOW);
    Dumpload=0;

    Measure();
    Print_data_Serial("19");
    
  }
  
  digitalWrite(DCDC_Treiber_SD_Quer,LOW);
}
