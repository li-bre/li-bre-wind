// ///////////////////WIND CHECK ////////////////////////////////////////////////////////////////
void wind_check() {
  const int wind_mean_m_time=1; //How many Minutes to calculate wind_v1_mean
  int wind_mean_m_amount; //How many measurements to calculate wind_v1_mean 
  int k; //Counter
     
   wind_mean_m_amount=wind_mean_m_time*60/wind_m_time; //wind_mean_m_time in seconds divided by time per measurement

   wind_v1_mean=0;
   for (k=0; k<wind_mean_m_amount; k++) {
      wind_v1_mean=wind_v1_mean+wind_v1;
      delay (wind_m_time*1000);
   }
   wind_v1_mean=wind_v1_mean/wind_mean_m_amount;
   
   if (wind_v1_mean < wind_v1_cut_in) {
    wind_status=1;          
   } else if (wind_v1_mean > wind_v1_cut_in && wind_v1_mean < wind_v1_cut_out) {
    wind_status=2;
   } else if (wind_v1_mean > wind_v1_cut_out) {
    wind_status=3;
   }

}
