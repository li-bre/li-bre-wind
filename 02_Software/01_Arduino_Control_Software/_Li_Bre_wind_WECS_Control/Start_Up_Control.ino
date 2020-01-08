//                       LiBre Wind: WECS Control   v 1.0                       //
//                                 Start-up                                     //
// This software is designed to be used with the Circuit Board B1v8 to controll //
//                a Stand Alone Wind Energy Conversion System                   //
//  Copyright (C) 2019  Julian Brendel julian.brendel@gmx.de under GNU GPLv3    //

void Start_Up()
{
  digitalWrite(Dumpload_FET,LOW);                       // Set the Dumpload MOSFETs gate low, so it is turned of
  Dumpload=0;                                           // Set the Dumpload FET variable to 0 
  digitalWrite(Short_Break_FET,LOW);                    // Set the Short break MOSFETs gate low, so it is turned of
  Short_Break=0;                                        // Set the Short break MOSFETs variable to 0 
  
  MS_DCDC_PWM=MS_DCDC_PWM_0;                            // Initialize the DCDC PWM
  SU_MS=0;                                              // Initialize the Start Up Motor Stage Variable (SU_MS)
  SU_P_1_target=0;                                      // Initialize the Start Up Power variable
  analogWrite(DCDC_PWM_PIN,MS_DCDC_PWM);                // Start sending the PWM to the MOSFET DRIVER of the DC DC 
  delay(100);
  digitalWrite(DCDC_Treiber_SD_Quer,HIGH);              // Allow the MOSFET driver to start the operation of the DC DC 
  delay(100);
  digitalWrite(Relais_FET_PIN,HIGH);                    // Switch relais to motor mode
  Relais_state=1;                                       // Set the Relay variable to 0 
  delay(100);

  SU_finished=0;                                        // Initialize Variable
  SU_start_time=now;                                    // Record time when start up process starts
  Measure();                                            // Measure Data
  Print_data_Serial("3");                               // Print Data at Datapoint "3"
  
  while (SU_finished==0){                               // Start working loop of Start up process

    /////Control Voltage V1 to MS_V1_target via P-Controller by adjusting the DC/DC PWM ////////
    j=0;
    while (abs(V_1-float(MS_V1_target))> 0.5 && j<=5){  // loop until MS_V1_target is reached
      j++;
      Measure();                                        // Measure Data

      //// If rotor acceleration has problems, the Power rises significantly, if this happens (P_1>P_1,max) restart the start up process
      if (abs(P_1)>SU_P_1_max) {                        
        SU_MS=0;                                        // Set the Starut Up Motor Stage Variable to 0
        analogWrite(MS_outputPin,SU_MS);                // Run the motor controller at the Starut Up Motor Stage 0
        Measure();                                      // Measure Data
        Print_data_Serial("4.1");                       // Print Data at Datapoint "4.1"
        LCD_print();                                    // Print Data LCD Screen
      }

      //// The actual P_controller to adjust voltage V1
      MS_DCDC_Delta_PWM = MS_DCDC_PWM_P * (V_1-MS_V1_target); // Calculate stepsize
      // Set Maximum absolut value of Stepsize to 8
      if (abs(MS_DCDC_Delta_PWM)>8){                          
        if (MS_DCDC_Delta_PWM>0) {                            
          MS_DCDC_Delta_PWM=8;
        } else if (MS_DCDC_Delta_PWM<0) {
          MS_DCDC_Delta_PWM=-8;
        }
      }

      MS_DCDC_PWM = MS_DCDC_PWM + MS_DCDC_Delta_PWM;    // Adjust the DC/DC PWM     
      if (MS_DCDC_PWM>255) MS_DCDC_PWM=255;             // Set Maximum value of DC/DC PWM to 255
      if (MS_DCDC_PWM<50) MS_DCDC_PWM=50;               // Set Minimum value of DC/DC PWM to 50 
      analogWrite(DCDC_PWM_PIN,MS_DCDC_PWM);            // Run the DC/DC at the set DC/DC PWM

      Print_data_Serial("4");                           // Print Data at Datapoint "4"
      LCD_print();                                      // Print Data LCD Screen
    }                                                   // End loop when MS_V1_target is reached
    Measure();                                          // Measure Data
    Print_data_Serial("5");
    LCD_print();                                        // Print Data LCD Screen
    
    //// Check the motor controllers stability
    SU_stable=0;                                        // Initialize stability variable
    if (MS_tick_fin>0) {                                // Check for signals coming from the motor controller
      for (SU_i=0; SU_i<SU_stable_tryouts ; SU_i++) {   // Check stability "SU_stable_tryouts" times
        for (i=0; i<SU_Signal_tests ; i++) {            // Use "SU_Signal_tests" signals to check the stabilty
          SU_Signal_length[i]=pulseIn(MS_Sensor_pulsewidth_PIN, HIGH,200000); //Measure signal length
          delay(25);
        }
        
        SU_Signal_length_min=32000;                     // Initialization
        SU_Signal_length_max=0;                         // Initialization
        
        for (i=0 ; i<SU_Signal_tests ; i++) {           // Determine longest and shortest signal
          SU_Signal_length_min=min(SU_Signal_length[i],SU_Signal_length_min);
          SU_Signal_length_max=max(SU_Signal_length[i],SU_Signal_length_max);      
        }
        
        // Increase Stability criterion if the difference between longest and shortest signal is less than 1000 us
        // The motor controller will be regarded as stable, if more or equal than than "SU_stable_tryouts-1" tests will be stable
        if (SU_Signal_length_max-SU_Signal_length_min < 1000){ 
          SU_stable=SU_stable+1;
        }
      }
    }
    
    //// Start Up the motor
    if (now-SU_step_time >=1 && abs(V_1-float(MS_V1_target))< 1) {  // Increase control parameter only once per second and only if MS_V1_target is reached
      if (SU_stable>=SU_stable_tryouts-1){                // Check for controller stability
        SU_MS_stepsize=SU_MS_P*(MS_RPM_target-MS_RPM);    // Determine step size of the P-Controller to control SU_MS
        if (SU_MS_stepsize>10){SU_MS_stepsize=10;}        // Set the maximum stepszise to 10
        else if (SU_MS_stepsize<-10) {SU_MS_stepsize=-10;}// Set the minimum stepszise to -10
        SU_step_time=now;                                 // Record when the stepsitze has been altered
        SU_MS=SU_MS+SU_MS_stepsize;                       // Adjust SU_MS

        //// Store how much power it takes to run the motor at targeted RPM
        if (MS_RPM-MS_RPM_target>-5){                     // If Motor is at targeted RPM
          if (SU_P_1_target==0 || P_1<SU_P_1_target) {    // In Starup mode P_1 is always negative, so abs(SU_P_1_target) is increased
            SU_P_1_target=P_1;
          }
          if (P_1/SU_P_1_target >= 0.8) {                 // If no decrese in power is detected
            SU_Gen_Start_Counter=0;                       // Set the counter to 0

          } else if (abs(P_1/SU_P_1_target) < 0.8) {      // If a decrease in power is detected
            if (SU_Gen_Start_Counter<2) {                 // If the couter is below 2
              SU_Gen_Start_Counter++;                     // Increse the counter 
            } else if (SU_Gen_Start_Counter>=2){          // If it is higher than 2, start generator mode!
              digitalWrite(Relais_FET_PIN,LOW);           // Switch relay to generator mode             
              Relais_state=0;                             // Set relay satatus variable to 0
              SU_finished=1;                              // Set SU_finished to 1 to end the while loop
              delay(500);
              MPPT_DCDC_PWM = MS_DCDC_PWM;                // Transfer the variable, so MPPT mode starts with same DC/DC PWM
            }
          }
        }
        
      } else if (SU_stable<SU_stable_tryouts-1){          // If motor controller not stable
        SU_MS=SU_MS+10;                                   // Increase the motor stage by 10
        SU_step_time=now;                                 // Store current step time
        SU_P_1_target=0;                                  // Reset the stored power P_1_target
      }
    }

  if (now-SU_start_time>SU_start_time_max) {              // No decrease in power for too long time -> abort the start up process  
    MPPT_DCDC_PWM = MS_DCDC_PWM;                          // Transfer the variable, so MPPT mode starts with same DC/DC PWM
    digitalWrite(Relais_FET_PIN,LOW);                     // Switch relay to generator mode  
    Relais_state=0;                                       // Set relay satatus variable to 0
    SU_finished=1;                                        // Set SU_finished to 1 to end the while loop
    delay(500);
  }

  if (SU_MS>255) SU_MS=255;                               // Set Maximum value of Motor Stage to 255
  analogWrite(MS_outputPin,SU_MS);                        // Run the motor controller at the new Motor Stage
  delay(250);
  Measure();                                              // Measure Data
  Print_data_Serial("6");                                 // Print Data at Datapoint "6"
       
    //// If rotor acceleration has problems, the Power rises significantly, if this happens (P_1>P_1,max) restart the start up process
    if (abs(P_1)>SU_P_1_max) {
      SU_MS=0;                                            // Set the Starut Up Motor Stage Variable to 0
      analogWrite(MS_outputPin,SU_MS);                    // Run the motor controller at the Starut Up Motor Stage 0
      Measure();                                          // Measure Data
      Print_data_Serial("7");                             // Print Data at Datapoint "7"
      LCD_print();                                        // Print Data LCD Screen
    }
  }
  SU_MS=0;                                                // Set the Starut Up Motor Stage Variable to 0
  analogWrite(MS_outputPin,SU_MS);                        // Run the motor controller at the Starut Up Motor Stage 0
}
