const int m_time = 3;      //Meassuretime in Seconds
int wind_ct = 0;
float wind = 0.0;
float lambda = 0.0;
unsigned long time = 0;

unsigned long time_a = 0;
unsigned long time_b = 0;
float RPM = 0.0;
unsigned int RPM_a = 0;
unsigned int RPM_ct = 0;
unsigned int RPM_ct_2 = 0;
const int RPM_ct_fin = 1;
const float RPM_fac = float(RPM_ct_fin) * 60 * 1000;
bool  RPM0 = false;

void setup()
{
  Serial.begin(9600);
  time = millis();
  attachInterrupt(digitalPinToInterrupt(2), countRPM, FALLING );
  attachInterrupt(digitalPinToInterrupt(3), countWind, RISING);
  Serial.println  ("n_turb v1 lambda");
}

void loop()
{
  wind_ct = 0;
  delay(1000 * m_time);
  wind = (float)wind_ct / (float)m_time * 0.47;
  lambda = RPM * 2 * 3.141 * 0.75 / (60 * wind);

  if (RPM_ct_2 == RPM_a) {
    Serial.print("0");
    RPM0 = false;
  } else {
    Serial.print(RPM);
    RPM0 = true;
  }
  RPM_a = RPM_ct_2;
  Serial.print(" ");
  Serial.print(wind );       //Speed in m/s
  Serial.print(" ");
  if (RPM0 == false) {
    Serial.println("0");
  } else {
    Serial.println(lambda);
  }
}

void countWind() {
  wind_ct ++;
}

void countRPM() {
  RPM_ct_2 ++;
  time_a = time_b;
  time_b = millis();
  RPM = RPM_fac / float((time_b - time_a));
}
