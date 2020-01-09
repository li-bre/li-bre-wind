
// /////////////////////////////MEASURE DATA //////////////////////////////////////////////
void Measure() {
  // /////////////////////////RTC /////////////

  dt = clock.getDateTime();
  now_st = clock.dateFormat("U", dt);
  now = now_st.toInt();
  
// /////////////////////////ADC auslesen////////
  adc0_mean=0;
  adc1_mean=0;
  adc2_mean=0;
  adc3_mean=0;
  
  for (i=0; i<=samplelength-1; i++){
    adc0_mean      = adc0_mean+ads.readADC_SingleEnded(0);
    adc1_mean      = adc1_mean+ads.readADC_SingleEnded(1);
    adc2_mean      = adc2_mean+ads.readADC_SingleEnded(2);
    adc3_mean      = adc3_mean+ads.readADC_SingleEnded(3);
  }
  
  adc0_mean=adc0_mean/samplelength;  
  adc1_mean=adc1_mean/samplelength;
  adc2_mean=adc2_mean/samplelength;  
  adc3_mean=adc3_mean/samplelength;

// //////////////////Werte berechnen /////////////////////////////
  V_1=0.0025889*adc0_mean + 0.0116110; //excel fit Arduino: y= 0,0025889x + 0,0116110
  V_2=0.0005688*adc3_mean - 0.0928622; //excel fit Arduino: y = 0,0005688x - 0,0928622
  I_1=adc1_mean*0.001698 - 26.723722; //exel fit: y = y = 0.001698x - 26.723722
  I_2=adc2_mean*0.001726 - 27.067205; //exel fit: y = 0.001726x - 27.067205
//  P_1=V_1*I_1;
  P_2=V_2*I_2;
  P_1=P_2;  //Because I_1 Sensor broken
  MS_RPM=long(MS_tick_fin)*60/MS_RPM_m_time/MS_RPM_frac;
  Gen_RPM=long(Gen_tick_fin)*60/MS_RPM_m_time/Gen_RPM_frac;
}
