// /////////////////////////Start Up ///////////////////////////////////////////////////////////////
void Start_Up()
{
  digitalWrite(Dumpload_FET,LOW);
  Dumpload=0;
  digitalWrite(Short_Break_FET,LOW);
  Short_Break=0;
  
  MS_DCDC_PWM=MS_DCDC_PWM_0;
  SU_MS=0;
  SU_P_1_target=0;
  analogWrite(DCDC_PWM_PIN,MS_DCDC_PWM);
  delay(100);
  digitalWrite(DCDC_Treiber_SD_Quer,HIGH);
  delay(100);
  digitalWrite(Relais_FET_PIN,HIGH);
  Relais_state=1;
  delay(100);

  SU_finished=0;
  SU_start_time=now;
  Measure();
  Print_data_Serial("3");
  
  while (SU_finished==0){

  
  
/////Control Voltage V1 via P-Controllerregeln
  
    j=0;
    while (abs(V_1-float(MS_V1_target))> 0.5 && j<=5){
      j++;
      
      Measure();
        if (abs(P_1)>SU_P_1_max) {  // Wenn er in die falsche Richtung dreht geht die Leistung mega hoch. Dann nochmal von vorne
          SU_MS=0;
          analogWrite(MS_outputPin,SU_MS);
          Measure();
          Print_data_Serial("4.1");
          LCD_print();
        }
        
      MS_DCDC_Delta_PWM = MS_DCDC_PWM_P * (V_1-MS_V1_target);
      if (abs(MS_DCDC_Delta_PWM)>8){
        if (MS_DCDC_Delta_PWM>0) {
          MS_DCDC_Delta_PWM=8;
        } else if (MS_DCDC_Delta_PWM<0) {
          MS_DCDC_Delta_PWM=-8;
        }
      }
      
      MS_DCDC_PWM = MS_DCDC_PWM + MS_DCDC_Delta_PWM;      
      if (MS_DCDC_PWM>255) MS_DCDC_PWM=255;
      if (MS_DCDC_PWM<50) MS_DCDC_PWM=50;
      analogWrite(DCDC_PWM_PIN,MS_DCDC_PWM);

      Print_data_Serial("4");
      LCD_print();
    }
    Measure();
    Print_data_Serial("5");
    LCD_print();
  
    
//////////// Stabilitätsbestimmung(SU_stable) /////////////
    SU_stable=0;
    
    if (MS_tick_fin>0) { //Kommen Signale aus dem Motor Controller?
      
      for (SU_i=0; SU_i<SU_stable_tryouts ; SU_i++) { //Führe (tryouts) Male die Bestimmung durch
          for (i=0; i<SU_Signal_tests ; i++) {  //Führe die Bestimmung  mit (tests) Proben pro Durchlauf aus
            SU_Signal_length[i]=pulseIn(MS_Sensor_pulsewidth_PIN, HIGH,200000); //Messung der Signaldauer
            delay(25);
          }
          
          SU_Signal_length_min=32000; //initialisierung
          SU_Signal_length_max=0; //initialisierung
          
          for (i=0 ; i<SU_Signal_tests ; i++) {
            SU_Signal_length_min=min(SU_Signal_length[i],SU_Signal_length_min);
            SU_Signal_length_max=max(SU_Signal_length[i],SU_Signal_length_max);      
          }
          
          if (SU_Signal_length_max-SU_Signal_length_min < 1000){ //Ist die Signaldauer unter den Proben maximal 1000us unterschiedlich
            SU_stable=SU_stable+1; //Stabilitätszahl wird um 1 eröht
          }
      }
      if (SU_stable>=SU_stable_tryouts-1) { //Das ist das eigentliche Stabilitätskriterium
        digitalWrite(SU_LED_Pin,HIGH);
      }
    }
    
//////////// Hochfahren  /////////////
    if (now-SU_step_time >=1 && abs(V_1-float(MS_V1_target))< 1) { //Die SU_MS soll maximal jede sekunde erhöht werden
      if (SU_stable>=SU_stable_tryouts-1){ //Stable: P-Regler um RPM einzustellen
        
        SU_MS_stepsize=SU_MS_P*(MS_RPM_target-MS_RPM); //P-Regler um RPM zu regeln min -10 max 10
        if (SU_MS_stepsize>10){SU_MS_stepsize=10;}
        else if (SU_MS_stepsize<-10) {SU_MS_stepsize=-10;}
        
        SU_step_time=now;
        SU_MS=SU_MS+SU_MS_stepsize;
        
        if (MS_RPM-MS_RPM_target>-5){  //Wenn bei Zieldrehzahl oder darüber
          if (SU_P_1_target==0 || P_1<SU_P_1_target) { //Its always negative, so abs(SU_P_1_target) becomes bigger
            SU_P_1_target=P_1;
          }
          if (P_1/SU_P_1_target >= 0.8) {   // Kein Leistungsabfall
            SU_Gen_Start_Counter=0;

          } else if (abs(P_1/SU_P_1_target) < 0.8) {   // Leistungsabfall
              if (SU_Gen_Start_Counter<2) {
                SU_Gen_Start_Counter++;
              } else if (SU_Gen_Start_Counter>=2){
                digitalWrite(SU_Gen_Start_PIN,HIGH);    //Leistungsabfall konstant genug -> Start Generator
                digitalWrite(Relais_FET_PIN,LOW);
                Relais_state=0;
                SU_finished=1;
                delay(500);
                wind_ct=5*wind_m_time/wind_v1_factor;
                wind_v1=5; // So that the program goes into MPPT subsequently
                MPPT_DCDC_PWM = MS_DCDC_PWM; //Als Übergabe für die MPPT
              }
          }
        }
        
      } else if (SU_stable<SU_stable_tryouts-1){ // Not Stable: Erhöhung um 10 bis Stable erreicht ist
        SU_MS=SU_MS+10;
        SU_step_time=now;
        SU_P_1_target=0;
      }
    }

  if (now-SU_start_time>SU_start_time_max) { // Zu lange kein Leistunggsabfall -> Abbruch des Start Up  
    MPPT_DCDC_PWM = MS_DCDC_PWM; //Als Übergabe für die MPPT die nach Abbruch kurz angeht bis Rotor steht
//    while (MS_DCDC_PWM<(MS_DCDC_PWM_0-10)) {
//      MS_DCDC_PWM=MS_DCDC_PWM+10;
//      analogWrite(DCDC_PWM_PIN,MS_DCDC_PWM);
//      delay(500);
//    }
//    MS_DCDC_PWM=MS_DCDC_PWM_0;
    
    digitalWrite(Relais_FET_PIN,LOW);
    Relais_state=0;
    SU_finished=1;
    delay(500);
    wind_ct=2*wind_m_time/wind_v1_factor;
    wind_v1=2; // So that the program goes into windcheck
  }

  if (SU_MS>255) SU_MS=255;
  analogWrite(MS_outputPin,SU_MS);
  delay(250);
  Measure();
  
  Print_data_Serial("6");
  
  if (abs(P_1)>SU_P_1_max) {  // Wenn er in die falsche Richtung dreht geht die Leistung mega hoch. Dann nochmal von vorne
    SU_MS=0;
    analogWrite(MS_outputPin,SU_MS);
    Measure();
    Print_data_Serial("7");
    LCD_print();
  }

  }
  SU_MS=0;
  analogWrite(MS_outputPin,SU_MS);
}
