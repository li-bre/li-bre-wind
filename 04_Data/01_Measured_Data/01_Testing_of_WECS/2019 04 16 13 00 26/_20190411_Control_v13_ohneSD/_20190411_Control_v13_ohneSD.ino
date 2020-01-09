// High Speed (32kHz) PWM MOSFET-Ansteuerung mit Poti Regelung der PWM Anzeioge über LCD
// MS (Motorsteuerung als PWM ebenfalls über Poti
// Analog Digital Wandler zur Spannungsmessung mit ADS1115 _v8 = Mit Dumpload

#include <LiquidCrystal_I2C.h>
#include <Wire.h>
#include <Adafruit_ADS1015.h>
#include <DS3231.h>
#include <SPI.h>
#include <SD.h>

// PINS /////////////

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
  const int SU_Gen_Start_PIN=35;
  const int SD_Card_CS = 53;
    
  #define DS3231_ADDRESSE 0x68
  DS3231 clock;
  RTCDateTime dt;
  int Sec=0;
  
  LiquidCrystal_I2C lcd(0x27, 2, 1, 0, 4, 5, 6, 7, 3, POSITIVE);  // Set the LCD I2C address// PINS /////////////

  
  int Battery_full=0;
  const float Battery_V2_High=14;
  const float Battery_V2_Low=12.5;

  byte  LED_yellow = 0; //0=Off, 1=blink, 2=on;
  byte  LED_blue = 0;
  byte  LED_red = 0;
  byte  LED_green = 0;

  bool  LED_blink_yellow_stat = false;
  bool  LED_blink_blue_stat = false;
  bool  LED_blink_red_stat = false;
  bool  LED_blink_green_stat = false;

  int Dumpload=0; //0=OFF, 1=ON;
  int Short_Break=0; //0=OFF, 1=ON;
  
  int MS_V1_target=28; //Voltage for Motor Start Up
  const int MS_DCDC_PWM_0=240; //starting DCDC PWM to reach MS_V1_target
  int MS_DCDC_PWM=240; //DCDC PWM during Start_Up
  int MS_DCDC_PWM_P=2; //P-Value for Voltage V1 Control
  int MS_DCDC_Delta_PWM;
  int MS_RPM=0;
  int MS_RPM_target=80;
  int MS_tick = 0; //Counter for Motor RPM
  int MS_tick_fin=0; //Counter for Motor RPM
  const int MS_RPM_m_time=1; // Zeit der RMP-Messung in Sekunden
  int MS_RPM_frac=75; // Anzahl der Signale des "Signal" PIN der Motorsteuerung pro Umdrehung (experimentell ermittelt)
  int MS_sensorValue = 0;  // variable to store the value coming from the sensor
  byte Relais_state=0;

  const int wind_m_time = 3;      //Meassuretime in Seconds
  int wind_ct = 0;                // Wind counter
  int wind_ct_fin = 0;                // Wind counter
  float wind_v1 = 0.0;            // V1 in m/s
  const float wind_v1_factor = 0.66;            // V1 in m/s
  int wind_status=0; //1: Low, 2:Intermediate, 3: Too high
  const int wind_v1_cut_in=1;
  float wind_v1_mean=0;


  String now_st;
  unsigned long now;
//  int SU=0;
  unsigned long SU_start_time=0;
  unsigned long SU_step_time=0;
  unsigned long SU_start_time_max=900;
  int SU_MS=0;
  int SU_MS_stepsize=0;
  int SU_MS_P=1; //P-Value for MS P_controller
  const int SU_stable_tryouts = 6; //Wie viele Durchläufe = gleichzeitig max. Stabilitätszahl
  const int SU_Signal_tests=5; //Wie viele Proben pro Durchlauf die verglichen werden
  unsigned int SU_Signal_length[SU_Signal_tests]; //Länge der Signal HIGHs aus dem Controller
  unsigned int SU_Signal_length_min;
  unsigned int SU_Signal_length_max;
  int SU_stable = 0; //Stabilitätszahl
  int SU_i=0; //Durchlaufvariable
  float SU_P_1_target= 0; 
  const int SU_P_1_max= 40; //Maximale Leistung
  int SU_Gen_Start_Counter=0;
  int SU_finished=0;

  int Gen_RPM_frac=26;
  int Gen_RPM=0;
  int Gen_RPM_A=0; // _A -> for MPPT Step -1
  int Gen_tick = 0;
  int Gen_tick_fin=0;

  float V_1=0;
  float V_2=0;
  float V_2_A=0;
  
  float I_1=0;
  float I_2=0;
  float I_2_A=0;
  
  float P_1 = 0; 
  float P_2 = 0; 
  float P_2_A = 0; 

  Adafruit_ADS1115 ads;  /* Use this for the 16-bit version */
  // Adafruit_ADS1015 ads;     // Use this for the 12-bit version

  const int samplelength=20;
  int32_t adc0_mean;
  int32_t adc1_mean;
  int32_t adc2_mean;
  int32_t adc3_mean;

  int i;
  int j;

  File dataFile;
  String filename;
  String dataString = "";

  const int MPPT_wind_v1_epsilon=10; // <- experimentally derived, if bigger than this, change in v1 is detected
  const int MPPT_delta_DCDC_PWM_0=2;
  const int MPPT_delta_omega_epsilon=4;
  const int MPPT_delta_P_2_epsilon=2;
  const int MPPT_delta_omega_stern_epsilon=8;
  int MPPT_delta_DCDC_PWM=MPPT_delta_DCDC_PWM_0;
  int MPPT_DCDC_PWM=200;
  int MPPT_DCDC_PWM_A=0;
  float MPPT_omega=0;
  float MPPT_omega_stern=0;
  float MPPT_omega_A=0;
  float MPPT_omega_opt=0;
  float MPPT_delta_Omega=0;
  float MPPT_kopt=0;
  float MPPT_P_2_opt=0;
  float MPPT_delta_P_2=0;
  float MPPT_delta_P_2_A=0;
  byte MPPT_delta_wind_v1=0;
  byte MPPT_delta_wind_v1_A=0;
  int MPPT_delta_wind_v1_Reason=0;
  byte MPPT_MODE=0;
  float MPPT_beta=0.35;

  const int V_1_cut_out=80;
  float wind_v1_cut_out=8;
  const int Gen_RPM_cut_out=500;
  const int P_1_cut_out=100;
  
  

void setup() {
  Serial.begin(9600);
  
  // Initialize DS3231
  Serial.println("Initialize DS3231");;
  Wire.begin();
  Wire.beginTransmission(DS3231_ADDRESSE);
  Wire.write(0x0e); // DS3231 Register zu 0Eh
  Wire.write(B01100011); // Register schreiben
  Wire.endTransmission();
  clock.begin();
  //clock.setDateTime(__DATE__, __TIME__); // Set clock to sketch compiling time: only for first start then remove and compile again
  delay(20);

//  Serial.print("Initializing SD card...");
//  if (!SD.begin(SD_Card_CS)) {    // see if the card is present and can be initialized:
//    Serial.println("Card failed, or not present");    // don't do anything more:
//    return;
//  }
//  Serial.println("card initialized.");
  
  dt = clock.getDateTime();
  filename += String(clock.dateFormat("mdHi", dt));
  filename += ".txt";

  dataFile = SD.open(filename, FILE_WRITE);
  if (dataFile) {    // if the file is available, write to it
    dataFile.println(" ");
    Serial.print(filename);
    Serial.println(" open");
  } else { // if the file isn't open, pop up an error:
    Serial.print("error opening ");
    Serial.println(filename);
  }
  
  // set up the LCD's number of columns and rows:
  lcd.begin(20, 4);
  lcd.setCursor(0,0);
  lcd.print("Buenas Dias Julian");

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
  pinMode(SU_Gen_Start_PIN, OUTPUT);
  pinMode(SD_Card_CS, OUTPUT);

  TCCR0B = (TCCR0B & 0b11111000) | 0x03;
  TCCR1B = (TCCR1B & 0b11111000) | 0x01;
  TCCR2B = (TCCR2B & 0b11111000) | 0x03;

  // Auflösung des ADC einstellen
  ads.setGain(GAIN_ONE);       const float ADC_faktor=0.125;    // 1x gain   +/- 4.096V  1 bit = 2mV      0.125mV              6 MOhm
  ads.begin();

// //////////////// Interrupts /////////////////////////////////////////
  attachInterrupt(digitalPinToInterrupt(Gen_PWM_interrupt_PIN), Gen_RPM_count, RISING);
  attachInterrupt(digitalPinToInterrupt(Sec_interrupt_PIN), Sec_count, RISING);
  attachInterrupt(digitalPinToInterrupt(wind_interrupt_PIN), wind_count, RISING);
  attachInterrupt(digitalPinToInterrupt(MS_RPM_interrupt_PIN), MS_RPM_count, RISING);
  
  Serial.println  ("Year Month Day Hour Minute Second V1 V2 I1 I2 P1 P2 SU_MS SU_Stability MS MS_RPM Gen_RPM SU_P_1_target SU_Gen_Start_Counter Relais_state wind_v1 wind_v1_mean wind_v1_cut_out wind_status Battery_full MS_DCDC_PWM Dumpload Short_Break MPPT_MODE MPPT_delta_wind_v1 MPPT_delta_wind_v1_Reason MPPT_DCDC_PWM MPPT_omega_stern MPPT_omega_opt MPPT_kopt*10^6 MPPT_P_2_opt MPPT_delta_P_2 MPPT_delta_Omega Codepoint");
  dataFile.println("Year Month Day Hour Minute Second V1 V2 I1 I2 P1 P2 SU_MS SU_Stability MS MS_RPM Gen_RPM SU_P_1_target SU_Gen_Start_Counter Relais_state wind_v1 wind_v1_mean wind_v1_cut_out wind_status Battery_full MS_DCDC_PWM Dumpload Short_Break MPPT_MODE MPPT_delta_wind_v1 MPPT_delta_wind_v1_Reason MPPT_DCDC_PWM MPPT_omega_stern MPPT_omega_opt MPPT_kopt*10^6 MPPT_P_2_opt MPPT_delta_P_2 MPPT_delta_Omega Codepoint");
  dataFile.flush();
  delay(2000);
}

void loop() {

  Measure();

  Print_data_Serial("1");
  LCD_print();

  if (V_2 >= Battery_V2_High) Battery_full=1; 
  else if (V_2 <= Battery_V2_Low) Battery_full=0;
  
  if (Battery_full==0) {
    
    if (Gen_RPM == 0) {

    while (MS_DCDC_PWM<(MS_DCDC_PWM_0-10)) {
      MS_DCDC_PWM=MS_DCDC_PWM+10;
      analogWrite(DCDC_PWM_PIN,MS_DCDC_PWM);
      delay(500);
    }
    MS_DCDC_PWM=MS_DCDC_PWM_0;
    analogWrite(DCDC_PWM_PIN,MS_DCDC_PWM);

      MPPT_reset();
      clearLED();
      LED_yellow=1;
      wind_check();
      Measure();
      Print_data_Serial("2");
      LCD_print();
      switch (wind_status) {
        case 1:
        clearLED();
        LED_yellow=1;
        delay (10000); //Lange warten + Energie sparen
        break;
        
        case 2:
        clearLED();
        LED_green=1;
        Start_Up();
        break;
        
        case 3:
        clearLED();
        LED_red=1;
        decelerate();
        delay (10000); //Lange warten + Energie sparen
        break;
      }
    }
    
    else if (Gen_RPM > 0) {
        if (wind_v1 >= wind_v1_cut_out ) {
          MPPT_reset();
          clearLED();
          LED_red=1;
          decelerate();
        } else {
          if (P_1 > P_1_cut_out || V_1 > V_1_cut_out || Gen_RPM > Gen_RPM_cut_out)  {

            //Maybe include an average calculation here to avoid false decrease of wind_v1_cut_out
            MPPT_reset();
            clearLED();
            LED_red=1;
            wind_v1_cut_out=wind_v1;
            decelerate();
          } else {
            clearLED();
            LED_green=2;
            MPPT();
          }
        }
    }
    
  } else if (Battery_full==1) {
    clearLED();
    LED_red=2;
    decelerate();
    delay (10000); //Lange warten + Energie sparen
  }
  
//  Print_data_Serial("20");
  
}
///////////////////// END OF LOOP ///////////////////////////////////////////////////
