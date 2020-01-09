// ////////////////////////Serielle ausgabe//////////////////////////////////////////////////////////
void Print_data_Serial (String Point) {

  dt = clock.getDateTime();

  dataString="";
  dataString += String(clock.dateFormat("Y m d H i s", dt)); dataString += " ";
  dataString += String(V_1,3); dataString += " ";
  dataString += String(V_2,3); dataString += " ";
//  dataString += String(I_1,3); dataString += " ";
  dataString += "Nan"; dataString += " ";
  dataString += String(I_2,3); dataString += " ";
//  dataString += String(P_1); dataString += " ";
  dataString += "Nan"; dataString += " ";
  dataString += String(P_2); dataString += " ";
  dataString += String(SU_MS); dataString += " ";
  dataString += String(SU_stable); dataString += " ";
  dataString += String(MS_sensorValue/4); dataString += " ";
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
  dataString += String((MPPT_kopt*1000000)); dataString += " ";
  dataString += String(MPPT_P_2_opt); dataString += " ";
  dataString += String(MPPT_delta_P_2); dataString += " ";
  dataString += String(MPPT_delta_Omega); dataString += " ";
  dataString += Point; dataString += " ";
  
  Serial.println(dataString);

// ////////////////// Schreibe auf SD Karte //////////////
//  if (dataFile) {
//    dataFile.println(dataString);
//    dataFile.flush();
//  } else { // if the file isn't open, pop up an error:
//    Serial.print("error writing in ");
//    Serial.println(filename);
//  }
  delay(50);
}

