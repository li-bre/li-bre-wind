void MPPT () {

  digitalWrite(Dumpload_FET,LOW);
  Dumpload=0;
  digitalWrite(Short_Break_FET,LOW);
  Short_Break=0;

//  Measure();
  MPPT_omega=float(Gen_RPM);
  MPPT_delta_P_2=P_2-P_2_A;
  MPPT_delta_Omega=MPPT_omega-MPPT_omega_A;

//  Print_data_Serial("8");
  
// ///////////////DELTA V1//////////////////
    
  if (abs(MPPT_delta_Omega)>= MPPT_wind_v1_epsilon){
      if (MPPT_omega_A==0){
        MPPT_delta_wind_v1=0;
      }
      else {
        MPPT_delta_wind_v1=1;
        MPPT_delta_wind_v1_Reason=1; //Deviation of omega bigger than reasonable 
      }
  }
  else if(isPositive(MPPT_delta_Omega)==isPositive(MPPT_DCDC_PWM-MPPT_DCDC_PWM_A)){
      if (abs(MPPT_delta_Omega)<0.9 && abs(MPPT_DCDC_PWM-MPPT_DCDC_PWM_A)<0.9) {
        MPPT_delta_wind_v1=0;
      }
      else if (MPPT_omega_A==0 || MPPT_delta_Omega==0 || (MPPT_DCDC_PWM-MPPT_DCDC_PWM_A)==0){
        MPPT_delta_wind_v1=0;        
      }
      else {
        MPPT_delta_wind_v1=1;
        MPPT_delta_wind_v1_Reason=2;             
      }
    }
  else if(MPPT_delta_P_2 < 0 && MPPT_delta_P_2_A < 0){
    MPPT_delta_wind_v1=1;
    MPPT_delta_wind_v1_Reason=3;        
  }
  else {
    MPPT_delta_wind_v1=0;
  }

  if (MPPT_delta_wind_v1==0) MPPT_delta_wind_v1_Reason=0;
  
//    Print_data_Serial("9");

// ///////////////MPPT_MODES///////////////////

  if (P_2<0) MPPT_MODE=3;
  else if (MPPT_MODE==3) {
    MPPT_MODE=0;
    MPPT_delta_DCDC_PWM=MPPT_delta_DCDC_PWM_0;
  }

  switch (MPPT_MODE) {
    // ///////////////MPPT_MODE 0///////////////////
    case 0:
    if (MPPT_delta_wind_v1==1 && (!(MPPT_kopt==0))){
      MPPT_omega_stern=pow(P_2/MPPT_kopt,0.333333333);
      MPPT_delta_DCDC_PWM=MPPT_beta*(MPPT_omega-MPPT_omega_stern);
      MPPT_MODE=2;
    }
    else {
      if (MPPT_delta_P_2 < 0 && MPPT_delta_wind_v1==0 && MPPT_delta_wind_v1_A==0) {
        MPPT_delta_DCDC_PWM=-MPPT_delta_DCDC_PWM;
//          Serial.print(P_2_A);
//          Serial.println(MPPT_omega_A);
        MPPT_kopt=P_2_A/(pow(MPPT_omega_A,3));
        MPPT_omega_opt=MPPT_omega_A;
        MPPT_P_2_opt=P_2_A;
        MPPT_MODE=1;
      }
      else if (MPPT_delta_P_2 < 0){
          MPPT_delta_DCDC_PWM=-MPPT_delta_DCDC_PWM;
      }
      else {
 
      }
    }
    break;
    
    // ///////////////MPPT_MODE 1///////////////////
    case 1:
    if (abs(MPPT_omega-MPPT_omega_opt)<MPPT_delta_omega_epsilon && abs(P_2-MPPT_P_2_opt)<MPPT_delta_P_2_epsilon ) { //EXPERIMENTELL!!
       MPPT_delta_DCDC_PWM=0;
    }
    else {
      MPPT_omega_stern=pow(P_2/MPPT_kopt,0.333333333);
      MPPT_delta_DCDC_PWM=MPPT_beta*(MPPT_omega-MPPT_omega_stern);
      MPPT_MODE=2;
    }
    break;
    
    // ///////////////MPPT_MODE 2///////////////////
    case 2:
    MPPT_omega_stern=pow(P_2/MPPT_kopt,0.333333333);
    if (abs(MPPT_omega-MPPT_omega_stern)<MPPT_delta_omega_stern_epsilon && MPPT_delta_wind_v1==0) { //<- Experimentell!!!!!
      if (isPositive(MPPT_delta_DCDC_PWM)==isPositive(MPPT_delta_P_2)) {
        MPPT_delta_DCDC_PWM=MPPT_delta_DCDC_PWM_0;
      }
      else {
        MPPT_delta_DCDC_PWM=-MPPT_delta_DCDC_PWM_0;
      }
      MPPT_MODE=0;
    }
    else {
      MPPT_delta_DCDC_PWM = MPPT_beta * ( MPPT_omega - MPPT_omega_stern );
    }
    break;
    
    // ///////////////MPPT_MODE 3///////////////////
    case 3:
    MPPT_delta_DCDC_PWM=5;
    break;
    
    // ///////////////DEFAULT//////////////////
    default:
    delay(10000);
  }

  MPPT_DCDC_PWM_A=MPPT_DCDC_PWM;
  MPPT_omega_A=MPPT_omega;
  V_2_A=V_2;
  I_2_A=I_2;
  P_2_A=P_2;
  MPPT_delta_P_2_A=MPPT_delta_P_2;
  MPPT_delta_wind_v1_A=MPPT_delta_wind_v1;

//  Print_data_Serial("10");
  LCD_print();

  MPPT_DCDC_PWM=MPPT_DCDC_PWM+MPPT_delta_DCDC_PWM;
  if (MPPT_DCDC_PWM>245) MPPT_DCDC_PWM=245;
  if (MPPT_DCDC_PWM<50) MPPT_DCDC_PWM=50;
  analogWrite(DCDC_PWM_PIN,MPPT_DCDC_PWM);
  delay(100);
  digitalWrite(DCDC_Treiber_SD_Quer,HIGH);

}

int isPositive(int x) //https://stackoverflow.com/questions/3912375/check-if-a-number-x-is-positive-x0-by-only-using-bitwise-operators-in-c
{
 return (!(x & 0x80000000) & !!x); 
}
