//                       LiBre Wind: WECS Control   v 1.0                       //
//                                MPPT controll                                 //
// This software is designed to be used with the Circuit Board B1v8 to controll //
//                a Stand Alone Wind Energy Conversion System                   //
//  Copyright (C) 2019  Julian Brendel julian.brendel@gmx.de under GNU GPLv3    //

void MPPT () {

  digitalWrite(Dumpload_FET, LOW);                      // Turn off the Dumpload
  Dumpload = 0;
  digitalWrite(Short_Break_FET, LOW);                   // Turn off the short circuit brake
  Short_Break = 0;
  MPPT_omega = float(Gen_RPM);                          // Adapt datatype
  MPPT_delta_P_2 = P_2 - P_2_A;                         // Calculate difference in P2
  MPPT_delta_Omega = MPPT_omega - MPPT_omega_A;         // Calculate difference in omega

  //  Print_data_Serial("8");                           // Print Data to SD Card and Serial Moitor, Datapoint 8 if needed

  ///////////////DELTA V1//////////////////
  // Estimator for changes in wind speed //

  //// Detect Wind speed change if change is omega is bigger than MPPT_wind_v1_epsilon
  if (abs(MPPT_delta_Omega) >= MPPT_wind_v1_epsilon) { 
    if (MPPT_omega_A == 0) {
      MPPT_delta_wind_v1 = 0;
    }
    else {
      MPPT_delta_wind_v1 = 1;
      MPPT_delta_wind_v1_Reason = 1;
    }
  }

  //// Detect wind speed change if change in omega and change in Duty cycle of DC/DC have the same sign
  else if (isPositive(MPPT_delta_Omega) == isPositive(MPPT_DCDC_PWM - MPPT_DCDC_PWM_A)) {
    if (abs(MPPT_delta_Omega) < 0.9 && abs(MPPT_DCDC_PWM - MPPT_DCDC_PWM_A) < 0.9) {
      MPPT_delta_wind_v1 = 0;
    }
    else if (MPPT_omega_A == 0 || MPPT_delta_Omega == 0 || (MPPT_DCDC_PWM - MPPT_DCDC_PWM_A) == 0) {
      MPPT_delta_wind_v1 = 0;
    }
    else {
      MPPT_delta_wind_v1 = 1;
      MPPT_delta_wind_v1_Reason = 2;
    }
  }

  //// Detect Wind speed change if power gets smaller for two consecutive steps
  else if (MPPT_delta_P_2 < 0 && MPPT_delta_P_2_A < 0) {
    MPPT_delta_wind_v1 = 1;
    MPPT_delta_wind_v1_Reason = 3;
  }
  else {
    MPPT_delta_wind_v1 = 0;
  }

  if (MPPT_delta_wind_v1 == 0) MPPT_delta_wind_v1_Reason = 0;

  //    Print_data_Serial("9");

  /////////////////MPPT_MODES///////////////////

  if (P_2 < 0) MPPT_MODE = 3;
  else if (MPPT_MODE == 3) {
    MPPT_MODE = 0;
    MPPT_delta_DCDC_PWM = MPPT_delta_DCDC_PWM_0;
  }

  
  switch (MPPT_MODE) {
    // ///////////////MPPT_MODE 0///////////////////
    case 0:
      if (MPPT_delta_wind_v1 == 1 && (!(MPPT_kopt == 0))) {
        MPPT_omega_stern = pow(P_2 / MPPT_kopt, 0.333333333);
        MPPT_delta_DCDC_PWM = MPPT_beta * (MPPT_omega - MPPT_omega_stern);
        MPPT_MODE = 2;
      }
      else {
        if (MPPT_delta_P_2 < 0 && MPPT_delta_wind_v1 == 0 && MPPT_delta_wind_v1_A == 0) {
          MPPT_delta_DCDC_PWM = -MPPT_delta_DCDC_PWM;
          MPPT_kopt = P_2_A / (pow(MPPT_omega_A, 3));
          MPPT_omega_opt = MPPT_omega_A;
          MPPT_P_2_opt = P_2_A;
          MPPT_MODE = 1;
        }
        else if (MPPT_delta_P_2 < 0) {
          MPPT_delta_DCDC_PWM = -MPPT_delta_DCDC_PWM;
        }
        else {

        }
      }
      break;

    // ///////////////MPPT_MODE 1///////////////////
    case 1:
      if (abs(MPPT_omega - MPPT_omega_opt) < MPPT_delta_omega_epsilon && abs(P_2 - MPPT_P_2_opt) < MPPT_delta_P_2_epsilon ) { //EXPERIMENTELL!!
        MPPT_delta_DCDC_PWM = 0;
      }
      else {
        MPPT_omega_stern = pow(P_2 / MPPT_kopt, 0.333333333);
        MPPT_delta_DCDC_PWM = MPPT_beta * (MPPT_omega - MPPT_omega_stern);
        MPPT_MODE = 2;
      }
      break;

    // ///////////////MPPT_MODE 2///////////////////
    case 2:
      MPPT_omega_stern = pow(P_2 / MPPT_kopt, 0.333333333);
      if (abs(MPPT_omega - MPPT_omega_stern) < MPPT_delta_omega_stern_epsilon && MPPT_delta_wind_v1 == 0) { //<- Experimentell!!!!!
        if (isPositive(MPPT_delta_DCDC_PWM) == isPositive(MPPT_delta_P_2)) {
          MPPT_delta_DCDC_PWM = MPPT_delta_DCDC_PWM_0;
        }
        else {
          MPPT_delta_DCDC_PWM = -MPPT_delta_DCDC_PWM_0;
        }
        MPPT_MODE = 0;
      }
      else {
        MPPT_delta_DCDC_PWM = MPPT_beta * ( MPPT_omega - MPPT_omega_stern );
      }
      break;

    // ///////////////MPPT_MODE 3///////////////////
    case 3:
      MPPT_delta_DCDC_PWM = 3 * MPPT_delta_DCDC_PWM_0;
      break;

    // ///////////////DEFAULT//////////////////
    default:
      delay(10000);
  }

  MPPT_DCDC_PWM_A = MPPT_DCDC_PWM;
  MPPT_omega_A = MPPT_omega;
  V_2_A = V_2;
  I_2_A = I_2;
  P_2_A = P_2;
  MPPT_delta_P_2_A = MPPT_delta_P_2;
  MPPT_delta_wind_v1_A = MPPT_delta_wind_v1;

  //  Print_data_Serial("10");
  LCD_print();

  MPPT_DCDC_PWM = MPPT_DCDC_PWM + MPPT_delta_DCDC_PWM;
  if (MPPT_DCDC_PWM > 245) MPPT_DCDC_PWM = 245;
  if (MPPT_DCDC_PWM < 50) MPPT_DCDC_PWM = 50;

  MPPT_DCDC_PWM = 102;
  analogWrite(DCDC_PWM_PIN, MPPT_DCDC_PWM);
  delay(100);
  digitalWrite(DCDC_Treiber_SD_Quer, HIGH);

  MS_DCDC_PWM = MPPT_DCDC_PWM;

  delay(5000);
}

// Checks if the number is positive
int isPositive(int x) //https://stackoverflow.com/questions/3912375/check-if-a-number-x-is-positive-x0-by-only-using-bitwise-operators-in-c
{
  return (!(x & 0x80000000) & !!x);
}

/////////// Reset MPPT values ////////////////
void MPPT_reset() {

  MPPT_MODE = 0;
  MPPT_delta_wind_v1 = 0;
  MPPT_delta_wind_v1_Reason = 0;
  MPPT_DCDC_PWM = 240;
  MPPT_omega_stern = 0;
  MPPT_omega_opt = 0;
  MPPT_kopt = 0;
  MPPT_P_2_opt = 0;
  MPPT_delta_P_2 = 0;
  MPPT_delta_Omega = 0;

}
