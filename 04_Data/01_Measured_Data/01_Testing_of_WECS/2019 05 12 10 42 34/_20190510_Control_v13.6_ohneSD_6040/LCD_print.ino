// ////////////////////////LCD Ausgabe//////////////////////

void LCD_print() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("DCDC ");  
  lcd.print(MS_DCDC_PWM);
  
  lcd.setCursor(10, 0);
  lcd.print("SU_MS ");
  lcd.print(SU_MS);
//  lcd.print("MS ");
//  lcd.print(MS_sensorValue/4);

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
