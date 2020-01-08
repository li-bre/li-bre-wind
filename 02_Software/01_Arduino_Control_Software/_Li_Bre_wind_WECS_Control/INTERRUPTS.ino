//                       LiBre Wind: WECS Control   v 1.0                       //
//                                Interrupts                                    //
// This software is designed to be used with the Circuit Board B1v8 to controll //
//                a Stand Alone Wind Energy Conversion System                   //
//  Copyright (C) 2019  Julian Brendel julian.brendel@gmx.de under GNU GPLv3    //

void MS_RPM_count() {                 // set counter for motor RPM +1 when high input on interrupt pin
  MS_tick ++;
}

void Gen_RPM_count() {                // set counter for generator RPM +1 when high input on interrupt pin
  Gen_tick ++;
}

void wind_count() {                   // set counter for generator RPM +1 when high input on interrupt pin
  wind_ct ++;
}

void Sec_count() {                    // When one Second has passed
  MS_tick_fin=MS_tick;                // Store the amount of high inputs on motor interrupt pin
  Gen_tick_fin=Gen_tick;              // Store the amount of high inputs on generator interrupt pin
  MS_tick = 0;                        // Set back the counter
  Gen_tick = 0;                       // Set back the counter
  Sec ++;                             // Increase the Second counter by one

  if (Sec==wind_m_time){              // When the wind measuring time (3s) has passed
    wind_ct_fin=wind_ct;              // Store the amount of high inputs on wind interrupt pin
    wind_ct=0;                        // Set back the counter
    wind_v1=float(wind_ct_fin)/float(wind_m_time) * wind_v1_factor;   //Calculate the wind speed in m/s
    Sec=0;                            // Set back Second counter
  }

  //// Enable the LEDs to blink by changing their state every second when in state 1////
  switch (LED_yellow) {
    case 0: digitalWrite(Status_LED_yellow,LOW); break;
    case 1:
    LED_blink_yellow_stat= !LED_blink_yellow_stat;
    digitalWrite(Status_LED_yellow,LED_blink_yellow_stat);
    break;
    case 2: digitalWrite(Status_LED_yellow,HIGH); break;
  }
  switch (LED_blue) {
    case 0: digitalWrite(Status_LED_blue,LOW); break;
    case 1:
    LED_blink_blue_stat= !LED_blink_blue_stat;
    digitalWrite(Status_LED_blue,LED_blink_blue_stat);
    break;
    case 2: digitalWrite(Status_LED_blue,HIGH); break;
  }
  switch (LED_red) {
    case 0: digitalWrite(Status_LED_red,LOW); break;
    case 1:
    LED_blink_red_stat= !LED_blink_red_stat;
    digitalWrite(Status_LED_red,LED_blink_red_stat);
    break;
    case 2: digitalWrite(Status_LED_red,HIGH); break;
  }
  switch (LED_green) {
    case 0: digitalWrite(Status_LED_green,LOW); break;
    case 1:
    LED_blink_green_stat= !LED_blink_green_stat;
    digitalWrite(Status_LED_green,LED_blink_green_stat);
    break;
    case 2: digitalWrite(Status_LED_green,HIGH); break;
  }
}

//// Reset LED Status ////
void clearLED() {
  LED_yellow=0;
  LED_blue=0;
  LED_green=0;
  LED_red=0;
}
