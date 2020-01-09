void MPPT_reset() {

  MPPT_MODE=0;
  MPPT_delta_wind_v1=0;
  MPPT_delta_wind_v1_Reason=0;
  MPPT_DCDC_PWM=240;
  MPPT_omega_stern=0;
  MPPT_omega_opt=0;
  MPPT_kopt=0;
  MPPT_P_2_opt=0;
  MPPT_delta_P_2=0;
  MPPT_delta_Omega=0;
  
}

