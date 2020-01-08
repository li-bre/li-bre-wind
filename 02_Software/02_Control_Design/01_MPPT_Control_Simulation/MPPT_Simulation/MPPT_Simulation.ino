const int MPPT_wind_v1_epsilon = 10;
const int MPPT_delta_DCDC_PWM_0 = 4;
const int MPPT_delta_omega_epsilon = 4;
const int MPPT_delta_P_2_epsilon = 2;
const int MPPT_delta_omega_stern_epsilon = 8;
int MPPT_DCDC_PWM = 40;
int MPPT_DCDC_PWM_A = 0;
int MPPT_delta_DCDC_PWM = MPPT_delta_DCDC_PWM_0;
float MPPT_omega;
float MPPT_omega_stern;
float MPPT_omega_A = 0;
float MPPT_omega_opt;
float MPPT_delta_Omega;
float MPPT_kopt = 0;
float Voltage;
float Voltage_A = 0;
float Current;
float Current_A = 0;
char inByte = 'H';
float P_2;
float P_2_A = 0;
float MPPT_P_2_opt;
float MPPT_delta_P_2;
float MPPT_delta_P_2_A;
byte MPPT_delta_wind_v1 = 0;
byte MPPT_delta_wind_v1_A = 0;
byte MPPT_MODE = 0;
float MPPT_beta = 0.35;

void setup() {
  Serial.begin(9600);
}

void loop() {
  ///// Serial Communication //////////
  while (Serial.available() <= 0 )
  {
    Serial.write('D');
    Serial.print(MPPT_DCDC_PWM);
    Serial.write('X');

    Serial.write('E');
    Serial.print(MPPT_kopt * 1000000);
    Serial.write("XXXXX");

    Serial.write('G');
    Serial.print(MPPT_omega_stern);
    Serial.write('X');

    Serial.write('S');
    Serial.print(MPPT_MODE);
    Serial.write('X');

    Serial.write('V');
    Serial.print(MPPT_delta_wind_v1);
    Serial.write('X');

    delay(100);
  }

  inByte = Serial.read();
  if (inByte == 'w')
  {
    MPPT_omega = Serial.parseInt(); //In Omega
    MPPT_omega = MPPT_omega / 1000;
    //   analogWrite(ActuatorPin1,MPPT_omega/2000);
  }
  inByte = Serial.read();
  if (inByte == 'V')
  {
    Voltage = Serial.parseInt(); //In Volt
    Voltage = Voltage / 1000;
    //    analogWrite(ActuatorPin2,Voltage/100);
  }
  inByte = Serial.read();
  if (inByte == 'I')
  {
    Current = Serial.parseInt(); //In Ampere
    Current = Current / 1000;
    //    analogWrite(ActuatorPin3,Current);
  }

  P_2 = Current * Voltage;
  MPPT_delta_P_2 = P_2 - P_2_A;

  // ///////////////DELTA V1///////////////////

  MPPT_delta_Omega = MPPT_omega - MPPT_omega_A;

  if (abs(MPPT_delta_Omega) >= MPPT_wind_v1_epsilon) {
    if (MPPT_omega_A == 0) {
      MPPT_delta_wind_v1 = 0;
    }
    else {
      MPPT_delta_wind_v1 = 1;
    }
  }
  else if (isPositive(MPPT_delta_Omega) == isPositive(MPPT_DCDC_PWM - MPPT_DCDC_PWM_A)) {
    if (abs(MPPT_delta_Omega) < 0.9 && abs(MPPT_DCDC_PWM - MPPT_DCDC_PWM_A) < 0.9) {
      MPPT_delta_wind_v1 = 0;
    }
    else if (MPPT_omega_A == 0) {
      MPPT_delta_wind_v1 = 0;
    }
    else {
      MPPT_delta_wind_v1 = 1;
    }
  }
  else if (MPPT_delta_P_2 < 0 && MPPT_delta_P_2_A < 0) {
    MPPT_delta_wind_v1 = 1;
  }
  else {
    MPPT_delta_wind_v1 = 0;
  }
  // ///////////////MODES///////////////////
  switch (MPPT_MODE) {
    // ///////////////MODE 0///////////////////
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
    // ///////////////MODE 1///////////////////
    case 1:
      if (abs(MPPT_omega - MPPT_omega_opt) < MPPT_delta_omega_epsilon && abs(P_2 - MPPT_P_2_opt) < MPPT_delta_P_2_epsilon ) {
        MPPT_delta_DCDC_PWM = 0;
      }
      else {
        MPPT_omega_stern = pow(P_2 / MPPT_kopt, 0.333333333);
        MPPT_delta_DCDC_PWM = MPPT_beta * (MPPT_omega - MPPT_omega_stern);
        MPPT_MODE = 2;
      }
      break;
    // ///////////////MODE 2///////////////////
    case 2:
      MPPT_omega_stern = pow(P_2 / MPPT_kopt, 0.333333333);
      if (abs(MPPT_omega - MPPT_omega_stern) < MPPT_delta_omega_stern_epsilon && MPPT_delta_wind_v1 == 0) {
        if (isPositive(MPPT_delta_DCDC_PWM) == isPositive(MPPT_delta_P_2)) {
          MPPT_delta_DCDC_PWM = MPPT_delta_DCDC_PWM_0;
        }
        else {
          MPPT_delta_DCDC_PWM = -MPPT_delta_DCDC_PWM_0;
        }
        MPPT_MODE = 0;
      }
      else {
        MPPT_delta_DCDC_PWM = MPPT_beta * (MPPT_omega - MPPT_omega_stern);
      }
      break;
    // ///////////////DEFAULT//////////////////
    default:
      delay(10000);
  }
  MPPT_DCDC_PWM_A = MPPT_DCDC_PWM;
  MPPT_omega_A = MPPT_omega;
  Voltage_A = Voltage;
  Current_A = Current;
  P_2_A = P_2;
  MPPT_delta_P_2_A = MPPT_delta_P_2;
  MPPT_delta_wind_v1_A = MPPT_delta_wind_v1;

  MPPT_DCDC_PWM = MPPT_DCDC_PWM + MPPT_delta_DCDC_PWM;
}
int isPositive(int x) //https://stackoverflow.com/questions/3912375/check-if-a-number-x-is-positive-x0-by-only-using-bitwise-operators-in-c
{
  return (!(x & 0x80000000) & !!x);
}
