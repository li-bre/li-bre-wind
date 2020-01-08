//                       LiBre Wind: WECS Control   v 1.0                       //
//                             Overall controll                                 //
// This software is designed to be used with the Circuit Board B1v8 to controll //
//                a Stand Alone Wind Energy Conversion System                   //

//  Copyright (C) 2019  Julian Brendel julian.brendel@gmx.de under GNU GPLv3    //
//
//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License version 3 as
//published by the Free Software Foundation
//
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <https://www.gnu.org/licenses/>.


////Include Libraries
#include <LiquidCrystal_I2C.h>
#include <Wire.h>
#include <Adafruit_ADS1015.h>
#include <DS3231.h>
#include <SPI.h>
#include <SD.h>

//// PINS ////
const int MS_RPM_interrupt_PIN=2;
const int Gen_PWM_interrupt_PIN = 3;
const int MS_outputPin = 4;
const int Relais_FET_PIN=5;
const int MS_Sensor_pulsewidth_PIN=7;
const int Dumpload_FET=8;
const int Short_Break_FET=9;
const int DCDC_Treiber_SD_Quer=10;
const int DCDC_PWM_PIN = 11;
const int wind_interrupt_PIN = 18;
const int Sec_interrupt_PIN=19;
const int Status_LED_red=22;
const int Status_LED_yellow=23;
const int Status_LED_blue=24;
const int Status_LED_green=25;
const int SU_LED_Pin=6;
const int SD_Card_CS = 53;

////Initialise RTC////
#define DS3231_ADDRESSE 0x68
DS3231 clock;
RTCDateTime dt;
int Sec=0;

////Initialise LCD////
LiquidCrystal_I2C lcd(0x27, 2, 1, 0, 4, 5, 6, 7, 3, POSITIVE);  // Set the LCD I2C address// PINS /////////////

//////Variable Declaraion//////
////Batterie check////
int Battery_full=0;                   // Batterie status
const float Battery_V2_High=14;       // Set Voltage when Batterie is full
const float Battery_V2_Low=12.5;      // Set Voltage when Batterie is not full

////LED status////
byte  LED_yellow = 0;                 // 0=Off, 1=blink, 2=on;
byte  LED_blue = 0;
byte  LED_red = 0;
byte  LED_green = 0;
bool  LED_blink_yellow_stat = false;  // Variable to facilitate blining
bool  LED_blink_blue_stat = false;
bool  LED_blink_red_stat = false;
bool  LED_blink_green_stat = false;

////Break and Dumpload status////
int Dumpload=0;                       // 0=OFF, 1=ON;
int Short_Break=0;                    // 0=OFF, 1=ON;

////Motor Control (Motor Steuerung) Variables////
int MS_V1_target=36;                  // Voltage for Motor Start Up
const int MS_DCDC_PWM_0=240;          // starting point for DCDC PWM in start up mode
int MS_DCDC_PWM=240;                  // DCDC PWM in start up mode
int MS_DCDC_PWM_P=2;                  // P-Value for Voltage V1 Control
int MS_DCDC_Delta_PWM;                // Difference to next DCDC PWM Value in start up mode
int MS_RPM=0;                         // RPM Measurement
int MS_RPM_target=150;                // Target Motor RPM in start up mode
int MS_tick = 0;                      // Counter for Motor RPM Measurement
int MS_tick_fin=0;                    // Counter limit for Motor RPM
const int MS_RPM_m_time=1;            // Time of Motor RMP Measurement in seconds
int MS_RPM_frac=75;                   // Amount of signals of 'Signal' PIN of motorcontroller per full motor revolution

////Relay Stauts////
byte Relais_state=0;                  // Relais_state=0 for Generator operation, Relais_state=1 for Motor operation

////wind measurement////
const int wind_m_time = 3;            // Meassuretime in Seconds
int wind_ct = 0;                      // Wind counter
int wind_ct_fin = 0;                  // Wind counter limit
float wind_v1 = 0.0;                  // V1 in m/s
const float wind_v1_factor = 0.66;    // Factor for conversion of V1 into m/s
int wind_status=0;                    // 1: Low, 2:Intermediate, 3: Too high
const int wind_v1_cut_in=3.5;         // Cut in velocity in m/s
float wind_v1_mean=0;                 // mean v1 for windcheck

////Start Up Variables////
String now_st;                        // To store current time as string
unsigned long now;                    // To store current time as numerical value
unsigned long SU_start_time=0;        // To store starting time of Start Up Process
unsigned long SU_step_time=0;         // To store current time of Start Up Process
unsigned long SU_start_time_max=1500; // Maximum time to try to start up the Rotor
int SU_MS=0;                          // Control factor of the Motorcontroller
int SU_MS_stepsize=0;                 // Difference to next Control factor of the Motorcontroller
int SU_MS_P=1;                        // P-Value for MS P_controller
const int SU_stable_tryouts = 6;      // Maximum possible stabily criteria for Motorcontroller
const int SU_Signal_tests=5;          // Test cycles for determing the stabily criteria for Motorcontroller
unsigned int SU_Signal_length[SU_Signal_tests]; // Measuring the length of signals from Motorcontroller
unsigned int SU_Signal_length_min;    // Minimum length of signals from Motorcontroller
unsigned int SU_Signal_length_max;    // Maximum length of signals from Motorcontroller
int SU_stable = 0;                    // Stabily criteria for Motorcontroller (if close to SU_stable_tryouts RPM are measured correctly)
int SU_i=0;                           // Counting variable
float SU_P_1_target= 0;               // Needed power to rotate the Motor at MS_RPM_target
const int SU_P_1_max= 75;             // Maximum tolerated power to rotate the Motor at MS_RPM_target
int SU_Gen_Start_Counter=0;           // Counting when the power to rotate the Motor becomes less: indicator if Turbine has reached motor speed
int SU_finished=0;                    // Indicates if Start Up porcess has finished

////Generator RPM measuring Variables////
int Gen_RPM_frac=26;                  // Multiplier to calculate RPM
int Gen_RPM=0;                        // Indicating Generators RPM
int Gen_RPM_A=0;                      // Indicating Generators previous RPM, needed for MPPT
int Gen_tick = 0;                     // Counter for Interrupt routine
int Gen_tick_fin=0;                   // Maximum Counter for Interrupt routine

////Volatage and Current measuring Variables////
float V_1=0;                          // Voltage V1
float V_2=0;                          // Voltage V2
float V_2_A=0;                        // previous Voltage V2
float I_1=0;                          // Current I1
float I_2=0;                          // Current I2
float I_2_A=0;                        // previous Current I2
float P_1 = 0;                        // Power P1
float P_2 = 0;                        // Power P2
float P_2_A = 0;                      // previous Power P2

////Initialise Analog Digital Converter////
Adafruit_ADS1115 ads;                 // Use this for the 16-bit ADC ADS1115
const int samplelength=20;            // Samplelength for calculating mean value of meaurements
int32_t adc0_mean;                    // mean value of meaurements
int32_t adc1_mean;                    // mean value of meaurements
int32_t adc2_mean;                    // mean value of meaurements
int32_t adc3_mean;                    // mean value of meaurements
int i;                                // Counting variable
int j;                                // Counting variable

////Initialise SD Card////
File dataFile;                        // File on the SD Card
String filename;                      // Filename on the SD Card
String dataString = "";               // Data to store on the SD Card and print on serial monitor

////MPPT Variables////
const int MPPT_wind_v1_epsilon=10;    // if difference in omega is bigger than this, change in v1 is triggered
const int MPPT_delta_DCDC_PWM_0=2;    // Standard difference to next PWM value in MPPT Mode 0
const int MPPT_delta_omega_epsilon=4; // In Mode 1 (waiting) smaller changes are regarded as constant omega
const int MPPT_delta_P_2_epsilon=2;   // In Mode 1 (waiting) smaller changes are regarded as constant P2
const int MPPT_delta_omega_stern_epsilon=8;     // When omega is closer to omega_stern than this value, MPPT switches from fast mode (2) to more precise mode (0)
int MPPT_delta_DCDC_PWM=MPPT_delta_DCDC_PWM_0;  // difference to next PWM value in MPPT
int MPPT_DCDC_PWM=200;                // Current PWM value in MPPT
int MPPT_DCDC_PWM_A=0;                // Previous PWM value in MPPT
float MPPT_omega=0;                   // Current omega in MPPT
float MPPT_omega_stern=0;             // Calculated control variable for MPPT
float MPPT_omega_A=0;                 // Previous omega in MPPT
float MPPT_omega_opt=0;               // Optimum omega in MPPT Mode 2
float MPPT_delta_Omega=0;             // Difference between last and current omega in MPPT
float MPPT_kopt=0;                    // k-factor for MPPT
float MPPT_P_2_opt=0;                 // Optimum power P2 in MPPT Mode 2
float MPPT_delta_P_2=0;               // Difference between last and current P2 in MPPT
float MPPT_delta_P_2_A=0;             // Previous power P2 in MPPT
byte MPPT_delta_wind_v1=0;            // Indicating if velocity v1 has changed due to estimator
byte MPPT_delta_wind_v1_A=0;          // Previous Indicator for wind change
int MPPT_delta_wind_v1_Reason=0;      // Reason wind change has been detected by estimator
byte MPPT_MODE=0;                     // ModeMPPT is in: 0-HCS 1-waiting 2-fast 3- P2 < 0 ->increase load
float MPPT_beta=0.35;                 // P value vor MPPT Mode 2

////CUT OUT VALUES////
const int V_1_cut_out=80;             // Cut out voltage V1
float wind_v1_cut_out=8;              // Cut out wind speed v1
const int Gen_RPM_cut_out=500;        // Cut out generator RPM
const int P_1_cut_out=100;            // Cut out power P2


void setup() {
//// Begin Serial Communication ////
Serial.begin(9600);

//// Initialize DS3231 ////
Serial.println("Initialize DS3231");;
Wire.begin();
Wire.beginTransmission(DS3231_ADDRESSE);
Wire.write(0x0e);                                   // DS3231 Register
Wire.write(B01100011);
Wire.endTransmission();
clock.begin();
//clock.setDateTime(__DATE__, __TIME__);            // Set clock to sketch compiling time: only to set time at first start then remove and compile again
delay(20);

//// SD Card ////
Serial.print("Initializing SD card...");
if (!SD.begin(SD_Card_CS)) {                        // see if the card is present and can be initialized:
Serial.println("Card failed, or not present");    // don't do anything more:
  return;
}
Serial.println("card initialized.");

//// Initialize DS3231 ////
dt = clock.getDateTime();
filename += String(clock.dateFormat("mdHi", dt));
filename += ".txt";

//// SD Card ////
dataFile = SD.open(filename, FILE_WRITE);
if (dataFile) {    // if the file is available, write to it
  dataFile.println(" ");
  Serial.print(filename);
  Serial.println(" open");
} else { // if the file isn't open, pop up an error:
  Serial.print("error opening ");
  Serial.println(filename);
}

//// set up the LCD's number of columns and rows: ////
lcd.begin(20, 4);
lcd.setCursor(0, 0);
lcd.print("Good wind to you!");

//// Define PIN modes ////
pinMode(MS_outputPin, OUTPUT);
pinMode(Relais_FET_PIN, OUTPUT);
pinMode(MS_Sensor_pulsewidth_PIN, INPUT);
pinMode(DCDC_Treiber_SD_Quer, OUTPUT); //SD_Q Sicherheit des MOSFET-Treibers
pinMode(DCDC_PWM_PIN, OUTPUT);
pinMode(Status_LED_yellow, OUTPUT);
pinMode(Status_LED_blue, OUTPUT);
pinMode(Status_LED_red, OUTPUT);
pinMode(Status_LED_green, OUTPUT);
pinMode(Dumpload_FET, OUTPUT);
pinMode(Short_Break_FET, OUTPUT);
pinMode(SU_LED_Pin, OUTPUT);
pinMode(SD_Card_CS, OUTPUT);

//// Set built in clocks ////
TCCR0B = (TCCR0B & 0b11111000) | 0x03;  // Standard
TCCR1B = (TCCR1B & 0b11111000) | 0x01;  // Necessary for PWM @ 32kHz
TCCR2B = (TCCR2B & 0b11111000) | 0x03;  // Standard

//// Set ADC resolution ////  !!!! ADC will be damaged if voltage is out of bounds !!!!
ads.setGain(GAIN_ONE);       const float ADC_faktor = 0.125;  // 1x gain   +/- 4.096V  1 bit = 2mV      0.125mV              6 MOhm
ads.begin();

//// Interrupts ////
attachInterrupt(digitalPinToInterrupt(Gen_PWM_interrupt_PIN), Gen_RPM_count, RISING);   // To measure Generator RPM
attachInterrupt(digitalPinToInterrupt(Sec_interrupt_PIN), Sec_count, RISING);           // Exact Seconds from RTC
attachInterrupt(digitalPinToInterrupt(wind_interrupt_PIN), wind_count, RISING);         // To measure wind speed
attachInterrupt(digitalPinToInterrupt(MS_RPM_interrupt_PIN), MS_RPM_count, RISING);     // To measure Motor RPM

//// Write Data Header on Serial Monitor and SD File ////
Serial.println  ("Year Month Day Hour Minute Second V1 V2 I1 I2 P1 P2 SU_MS SU_Stability MS_RPM Gen_RPM SU_P_1_target SU_Gen_Start_Counter Relais_state wind_v1 wind_v1_mean wind_v1_cut_out wind_status Battery_full MS_DCDC_PWM Dumpload Short_Break MPPT_MODE MPPT_delta_wind_v1 MPPT_delta_wind_v1_Reason MPPT_DCDC_PWM MPPT_omega_stern MPPT_omega_opt MPPT_kopt*10^6 MPPT_P_2_opt MPPT_delta_P_2 MPPT_delta_Omega Codepoint");
dataFile.println("Year Month Day Hour Minute Second V1 V2 I1 I2 P1 P2 SU_MS SU_Stability MS_RPM Gen_RPM SU_P_1_target SU_Gen_Start_Counter Relais_state wind_v1 wind_v1_mean wind_v1_cut_out wind_status Battery_full MS_DCDC_PWM Dumpload Short_Break MPPT_MODE MPPT_delta_wind_v1 MPPT_delta_wind_v1_Reason MPPT_DCDC_PWM MPPT_omega_stern MPPT_omega_opt MPPT_kopt*10^6 MPPT_P_2_opt MPPT_delta_P_2 MPPT_delta_Omega Codepoint");
dataFile.flush();
delay(2000);
}

void loop() {

  Measure();                                          // Measure Data

  Print_data_Serial("1");                             // Print Data to SD Card and Serial Moitor, Datapoint 1

  //  LCD_print();                                      // Print Data LCD Screen

  if (V_2 >= Battery_V2_High) Battery_full = 1;       // Batterie check
  else if (V_2 <= Battery_V2_Low) Battery_full = 0;

  if (Battery_full == 0) {                            // If Batterie is not full

    if (Gen_RPM == 0) {                               // If turbine is not spinning

      while (MS_DCDC_PWM < (MS_DCDC_PWM_0 - 10)) {    // When RPM = 0 set V1 to 12 V by regulating the DCDC PWM to MS_DCDC_PWM_0
        MS_DCDC_PWM = MS_DCDC_PWM + 10;
        analogWrite(DCDC_PWM_PIN, MS_DCDC_PWM);
        delay(500);
      }
      MS_DCDC_PWM = MS_DCDC_PWM_0;
      analogWrite(DCDC_PWM_PIN, MS_DCDC_PWM);

      MPPT_reset();                                   // Reset MPPT values
      clearLED();                                     // Reset LED Status (see interrups tab)
      LED_yellow = 1;                                 // Yellow LED blinking while waiting
      wind_check();                                   // Ceck for windspeed windstatus==1: low wind, 2: intermediate wind, 3: high wind
      Measure();                                      // Measure Data
      Print_data_Serial("2");                         // Print Data to SD Card and Serial Moitor, Datapoint 2
      LCD_print();                                    // Print Data LCD Screen
      switch (wind_status) {
        case 1:                                       // If windstatus==1: low wind
          clearLED();                                   // Reset LED Status (see interrups tab)
          LED_yellow = 1;                               // Yellow LED blinking while waiting
          delay (900000);                               // wait 15 minutes until next windcheck
          break;

        case 2:                                       // If windstatus==2: intermediate wind
          clearLED();                                   // Reset LED Status (see interrups tab)
          LED_green = 1;                                // Green LED blinking while Start Up
          Start_Up();                                   // Start up the rotor
          break;

        case 3:                                       // If windstatus==3: high wind
          clearLED();                                   // Reset LED Status (see interrups tab)
          LED_red = 1;                                  // Red LED blinking while in high winds
          decelerate();                                 // Break down and Block the rotor electrically
          delay (900000);                               // wait 15 minutes until next windcheck
          break;
      }
    }
    else if (Gen_RPM > 0) {                           // If turbine is spinning
      if (wind_v1 >= wind_v1_cut_out ) {            // if windspeed exceeds cut out velocity
        MPPT_reset();                               // Reset MPPT values
        clearLED();                                 // Reset LED Status (see interrups tab)
        LED_red = 1;                                // Red LED blinking while in high winds
        decelerate();                               // Break down and Block the rotor electrically
      } else {
        if (P_1 > P_1_cut_out || V_1 > V_1_cut_out || Gen_RPM > Gen_RPM_cut_out)  {   // check if P1, V1 or Generator RPM exceed limits

          MPPT_reset();                             // Reset MPPT values
          clearLED();                               // Reset LED Status (see interrups tab)
          LED_red = 1;                              // Red LED blinking while in high winds
          wind_v1_cut_out = wind_v1;                // Decrease cut out velocity to current wind speed
          decelerate();                             // Break down and Block the rotor electrically
        } else {                                    // if no limits are exceeded
          clearLED();                               // Reset LED Status (see interrups tab)
          LED_green = 2;                            // Green LED tunred on while in MPPT
          MPPT();                                   // Go one step in MPPT
        }
      }
    }
  } else if (Battery_full == 1) {                     // If the Battery is full
    clearLED();                                       // Reset LED Status (see interrups tab)
    LED_red = 2;                                      // Red LED tunred on while Battery is full -> change Battery
    decelerate();                                     // Break down and Block the rotor electrically
    delay (900000);                                   // Wait 15 minutes to check Battery again
  }
  Print_data_Serial("20");                            // Print Data to SD Card and Serial Moitor, Datapoint 20
}
///////////////////// END OF LOOP ///////////////////////////////////////////////////
