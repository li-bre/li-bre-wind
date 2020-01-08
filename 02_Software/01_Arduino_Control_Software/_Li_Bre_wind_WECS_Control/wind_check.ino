//                       LiBre Wind: WECS Control   v 1.0                       //
//                                Wind Check                                    //
// This software is designed to be used with the Circuit Board B1v8 to controll //
//                a Stand Alone Wind Energy Conversion System                   //
//  Copyright (C) 2019  Julian Brendel julian.brendel@gmx.de under GNU GPLv3    //

void wind_check() {
  const int wind_mean_m_time=1;                     //How many Minutes to calculate wind_v1_mean
  int wind_mean_m_amount;                           //How many measurements to calculate wind_v1_mean 
  int k;                                            //Counter
     
   wind_mean_m_amount=wind_mean_m_time*60/wind_m_time; //wind_mean_m_time in seconds divided by time per measurement

   wind_v1_mean=0;                                  // Initiaization
   for (k=0; k<wind_mean_m_amount; k++) {
      wind_v1_mean=wind_v1_mean+wind_v1;            // Add wind v1 (calculated in interrupt) to wind_v1_mean
      delay (wind_m_time*1000);                     // Wait for next wind v1 from interrupt
   }
   wind_v1_mean=wind_v1_mean/wind_mean_m_amount;    // Calculate mean
   
   // Determine wind status
   if (wind_v1_mean < wind_v1_cut_in) {         
    wind_status=1;          
   } else if (wind_v1_mean > wind_v1_cut_in && wind_v1_mean < wind_v1_cut_out) {
    wind_status=2;
   } else if (wind_v1_mean > wind_v1_cut_out) {
    wind_status=3;
   }

}
