
///////////////////// INTERRUPTS ////////////////////////////////////////////////////////////////////////

void MS_RPM_count() {
  MS_tick ++;
}

void Gen_RPM_count() {
  Gen_tick ++;
}

void wind_count() {
  wind_ct ++;
}

void Sec_count() {
  MS_tick_fin=MS_tick;
  Gen_tick_fin=Gen_tick;
  MS_tick = 0;
  Gen_tick = 0;
  
  Sec ++;

  if (Sec==wind_m_time){
    wind_ct_fin=wind_ct;
    wind_ct=0;
    //wind_v1=float(wind_ct_fin)/float(wind_m_time) * wind_v1_factor;
    wind_v1=2;
    Sec=0; // Muss beim größten Sec==xxx_m_time zu = 0 gesetzt werden (nachdenken wenn zB wo 10 sec aber anders wo alle 2, dann verändern)
  }

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

void clearLED() {
  LED_yellow=0;
  LED_blue=0;
  LED_green=0;
  LED_red=0;
}


