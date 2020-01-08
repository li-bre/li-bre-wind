//                       LiBre Wind: WECS Control   v 1.0                       //
//                                Decelerate                                    //
// This software is designed to be used with the Circuit Board B1v8 to controll //
//                a Stand Alone Wind Energy Conversion System                   //
//  Copyright (C) 2019  Julian Brendel julian.brendel@gmx.de under GNU GPLv3    //

void decelerate () {

  if (Short_Break==0) {                   // Only execute if Short Break is not already 1(on)
    for (i=0;i<255;i++) {                 // Turn on the Dumpload by increasing the PWM which controlls of the Dumploads MOSFET Gate from 0 (off) to 255 (on)
      analogWrite(Dumpload_FET,i);
      delay(50);
    }
    digitalWrite(Dumpload_FET,HIGH);      // Turn on the Dumpload
    Dumpload=1;                           // set Variable that shows dumpload state to 1 (on)

    Measure();                            // Measure Data
    Print_data_Serial("17");              // Print Data to SD Card and Serial Moitor, Datapoint 17

    delay(30000);                         // Wait 30 seconds
    
    for (i=0;i<255;i++) {                 // Turn on the short circuit brake by increasing the PWM which controlls of the Dumploads MOSFET Gate from 0 (off) to 255 (on)
      analogWrite(Short_Break_FET,i);
      delay(50);
    }
    digitalWrite(Short_Break_FET,HIGH);   // Turn on the short circuit brake
    Short_Break=1;                        // Variable that shows short circuit brake state

    Measure();                            // Measure Data
    Print_data_Serial("18");              // Print Data to SD Card and Serial Moitor, Datapoint 18
    
    for (i=0;i<255;i++) {                 // Turn off the Dumpload by decreasing the PWM which controlls of the Dumploads MOSFET Gate from 255 (on) to 0 (off)
      analogWrite(Dumpload_FET,255-i);
      delay(50);
    }
    digitalWrite(Dumpload_FET,LOW);       // Turn off the Dumpload 
    Dumpload=0;                           // set Variable that shows dumpload state to 0 (off)

    Measure();                            // Measure Data
    Print_data_Serial("19");              // Print Data to SD Card and Serial Moitor, Datapoint 19
    
  }
  
  digitalWrite(DCDC_Treiber_SD_Quer,LOW); // Prevent DC DC Controller from switching by disabling the MOSFET Driver
}
