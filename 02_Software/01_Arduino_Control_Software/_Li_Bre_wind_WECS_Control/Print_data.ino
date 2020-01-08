//                       LiBre Wind: WECS Control   v 1.0                       //
//                                Print Data                                    //
// This software is designed to be used with the Circuit Board B1v8 to controll //
//                a Stand Alone Wind Energy Conversion System                   //
//  Copyright (C) 2019  Julian Brendel julian.brendel@gmx.de under GNU GPLv3    //

void Print_data_Serial (String Point) {

  dt = clock.getDateTime();

  dataString = "";
  dataString += String(clock.dateFormat("Y m d H i s", dt)); dataString += " ";
  dataString += String(V_1, 3); dataString += " ";
  dataString += String(V_2, 3); dataString += " ";
  //  dataString += String(I_1,3); dataString += " ";         // As I1 Sensor is broken
  dataString += "Nan"; dataString += " ";
  dataString += String(I_2, 3); dataString += " ";
  //  dataString += String(P_1); dataString += " ";
  dataString += "Nan"; dataString += " ";                   // As P1 cant be calculated because I1 Sensor is broken
  dataString += String(P_2); dataString += " ";
  dataString += String(SU_MS); dataString += " ";
  dataString += String(SU_stable); dataString += " ";
  dataString += String(MS_RPM); dataString += " ";
  dataString += String(Gen_RPM); dataString += " ";
  dataString += String(SU_P_1_target); dataString += " ";
  dataString += String(SU_Gen_Start_Counter); dataString += " ";
  dataString += String(Relais_state); dataString += " ";
  dataString += String(wind_v1); dataString += " ";
  dataString += String(wind_v1_mean); dataString += " ";
  dataString += String(wind_v1_cut_out); dataString += " ";
  dataString += String(wind_status); dataString += " ";
  dataString += String(Battery_full); dataString += " ";
  dataString += String(MS_DCDC_PWM); dataString += " ";
  dataString += String(Dumpload); dataString += " ";
  dataString += String(Short_Break); dataString += " ";
  dataString += String(MPPT_MODE); dataString += " ";
  dataString += String(MPPT_delta_wind_v1); dataString += " ";
  dataString += String(MPPT_delta_wind_v1_Reason); dataString += " ";
  dataString += String(MPPT_DCDC_PWM); dataString += " ";
  dataString += String(MPPT_omega_stern); dataString += " ";
  dataString += String(MPPT_omega_opt); dataString += " ";
  dataString += String((MPPT_kopt * 1000000)); dataString += " ";
  dataString += String(MPPT_P_2_opt); dataString += " ";
  dataString += String(MPPT_delta_P_2); dataString += " ";
  dataString += String(MPPT_delta_Omega); dataString += " ";
  dataString += Point; dataString += " ";

  Serial.println(dataString);

 ////////////////// Write to SD card //////////////
  if (dataFile) {                     // if the file is open:
    dataFile.println(dataString);     // Write data
    dataFile.flush();                 // Write now
  } else {                            // if the file isn't open:
    Serial.print("error writing in ");// pop up an error
    Serial.println(filename);
  }
  
  delay(50);
}


// ////////////////////////LCD Screen//////////////////////

//// Print values to LCD Screen ////

void LCD_print() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("DCDC ");  
  lcd.print(MS_DCDC_PWM);
  
  lcd.setCursor(10, 0);
  lcd.print("SU_MS ");
  lcd.print(SU_MS);

  lcd.setCursor(0, 1);
  lcd.print("V1 ");
  lcd.print(V_1,3);
  
  lcd.setCursor(10, 1);
  lcd.print("V2 ");
  lcd.print(V_2,3);

//  lcd.setCursor(0, 2);
//  lcd.print("I1 ");
////  lcd.print(I_1,3);
//  lcd.print("NaN");

  lcd.setCursor(0, 2);
  lcd.print("RPM ");
  lcd.print(Gen_RPM);
  
  lcd.setCursor(10, 2);
  lcd.print("I2 ");
  lcd.print(I_2,3);

//  lcd.setCursor(0, 3);
//  lcd.print("P1 ");
////  lcd.print(P_1,3);
//  lcd.print("NaN");

  lcd.setCursor(0, 3);
  lcd.print("MPPT ");
  lcd.print(MPPT_DCDC_PWM);
  
  lcd.setCursor(10, 3);
  lcd.print("P2 ");
  lcd.print(P_2,3);
  
}
