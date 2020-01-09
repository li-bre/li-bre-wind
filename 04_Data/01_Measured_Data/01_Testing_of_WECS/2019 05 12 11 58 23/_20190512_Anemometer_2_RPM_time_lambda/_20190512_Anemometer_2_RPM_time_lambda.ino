//More information at: http://www.aeq-web.com/?ref=arduinoide

const unsigned int h_0=11;
const unsigned int m_0=28;
const unsigned int s_0=40;
const unsigned long mil_0=(s_0*1000+m_0*60000+h_0*3600000); //Nur Zahlen die durch 3 teilbar sind!

const int m_time = 3;      //Meassuretime in Seconds
int wind_ct = 0;
float wind = 0.0;
float lambda = 0.0;
unsigned long time = 0;

unsigned long time_a = 0;
unsigned long time_b = 0;
float RPM=0.0;
unsigned int RPM_a = 0;
unsigned int RPM_ct = 0;
unsigned int RPM_ct_2 = 0;
const int RPM_ct_fin=1;
const float RPM_fac=float(RPM_ct_fin)*60*1000;
bool  RPM0=false;

unsigned long nt_mil=0;
unsigned long s_r=0;
unsigned long mil=0;
unsigned long s=0;
unsigned long m=0;
unsigned long h=0;


void setup()
{
  Serial.begin(9600);
  time = millis();
//  pinMode(2, INPUT_PULLUP);
  
  attachInterrupt(digitalPinToInterrupt(2), countRPM, FALLING );
  attachInterrupt(digitalPinToInterrupt(3), countWind, RISING);
  Serial.println  ("Hour Minute Second RPM v1 lambda RPM_ct wind_ct");
}

void loop()
{
  nt_mil=millis();
  mil=nt_mil+mil_0;

  s_r=mil/1000;

  h=s_r/3600;
  m=(s_r-3600*h)/60;
  s=(s_r-3600*h-m*60);
  


  wind_ct = 0;
  delay(1000 * m_time);
  Serial.print(" ");
  Serial.println(wind_ct);
  wind = (float)wind_ct / (float)m_time * 0.47;

  lambda=RPM*2*3.141*0.75/(60*wind);

  Serial.print(h);
  Serial.print(" ");
  Serial.print(m);
  Serial.print(" ");
  Serial.print(s);
  Serial.print(" ");
  if (RPM_ct_2==RPM_a) {
      Serial.print("0");
      RPM0=false;
  } else {
      Serial.print(RPM);
      RPM0=true;
  }
  RPM_a=RPM_ct_2;
  Serial.print(" ");
  Serial.print(wind );       //Speed in m/s  
  Serial.print(" ");
  if (RPM0==false) {
      Serial.print("0");
  } else {
      Serial.print(lambda);
  }
  Serial.print(" ");
  Serial.print(RPM_ct_2);

}

void countWind() {
  wind_ct ++;
  
}

void countRPM(){
  RPM_ct_2 ++;
  time_a=time_b;
  time_b= millis();
  RPM=RPM_fac/float((time_b-time_a));
}
