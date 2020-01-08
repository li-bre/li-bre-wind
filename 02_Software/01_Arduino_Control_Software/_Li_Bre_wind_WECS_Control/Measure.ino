//                       LiBre Wind: WECS Control   v 1.0                       //
//                                   Measure                                    //
// This software is designed to be used with the Circuit Board B1v8 to controll //
//                a Stand Alone Wind Energy Conversion System                   //
//  Copyright (C) 2019  Julian Brendel julian.brendel@gmx.de under GNU GPLv3    //

void Measure() {
  
  ////RTC////

  dt = clock.getDateTime();                 //Measure current time
  now_st = clock.dateFormat("U", dt);       //Transform to string    
  now = now_st.toInt();                     //Transform to integer  
  
  ////read ADC Values////
  adc0_mean=0;                  //Initialise values for mean calculation
  adc1_mean=0;                  //Initialise values for mean calculation
  adc2_mean=0;                  //Initialise values for mean calculation
  adc3_mean=0;                  //Initialise values for mean calculation
  
  for (i=0; i<=samplelength-1; i++){                        // measure each channel samplelength times and add values
    adc0_mean      = adc0_mean+ads.readADC_SingleEnded(0);
    adc1_mean      = adc1_mean+ads.readADC_SingleEnded(1);
    adc2_mean      = adc2_mean+ads.readADC_SingleEnded(2);
    adc3_mean      = adc3_mean+ads.readADC_SingleEnded(3);
  }
  
  adc0_mean=adc0_mean/samplelength;  // Calcualte mean values
  adc1_mean=adc1_mean/samplelength;  // Calcualte mean values
  adc2_mean=adc2_mean/samplelength;  // Calcualte mean values
  adc3_mean=adc3_mean/samplelength;  // Calcualte mean values

  ////Calculate values in SI Units////
  V_1=0.0025889*adc0_mean + 0.0116110;  // V1 fit: y= 0.0025889x + 0.0116110 in Volts
  V_2=0.0005688*adc3_mean - 0.0928622;  // V2 fit: y = 0.0005688x - 0.0928622 in Volts
  I_1=adc1_mean*0.001698 - 26.723722;   // I1 fit: y = y = 0.001698x - 26.723722 in Ampere
  I_2=adc2_mean*0.001726 - 27.067205;   // I2 fit: y = 0.001726x - 27.067205 in Ampere
  //  P_1=V_1*I_1;                      // Normal calculation of P1 but sensor is broken in Watt
  P_1=P_2;                              // Estimation because I_1 Sensor broken in Watt
  P_2=V_2*I_2;                          // Calculation of P2 in Watt
  MS_RPM=long(MS_tick_fin)*60/MS_RPM_m_time/MS_RPM_frac;      //calculation of Motor RPM
  Gen_RPM=long(Gen_tick_fin)*60/MS_RPM_m_time/Gen_RPM_frac;   //calculation of Generator RPM
}
