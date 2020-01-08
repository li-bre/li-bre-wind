// Rotor vs. Generator Power
clear
close
scf(0); clf();
//
v1=3:10;
//n_Rotor=[84.034 112.045 140.056 168.068 196.079 224.090 252.101 280.113];
//P_Rotor=[0.008 0.022 0.049 0.089 0.143 0.214 0.303 0.409] * 1000;
n_Rotor=[84.034 112.045 140.056 168.068 196.079 224.090];
P_Rotor=[0.008 0.022 0.049 0.089 0.143 0.214] * 1000;
T_Rotor=[0.895 1.881 3.307 5.078 6.953 9.109];
n_Gen=[49.6 90.6 100.4 106.6 120.4];
P_Gen=[0 14.5 33.0 45.5 80.7 ]; 
T_Gen=[0.83 2.78 4.90 7.44 %nan];
n_Gen_LL=[88.9 124.3 244.2 372.4 483.7 580.1];
n_Gen_KS=[6.6 15 19.8 21.6];
T_Gen_LL=[1.02 1.17 1.46 1.70 1.80 1.71];
T_Gen_KS=[1.51 4.12 8.92 9.32];


n_Rotor_arb=1:250;


omega_Rotor_arb=n_Rotor_arb*2*%pi/60;
lambda_arb=2; // Hat den größten Einfluss auf das Moment
R_arb=0.75;
H_arb=1.2;
v1_arb=omega_Rotor_arb*R_arb/lambda_arb;
rho=1.2;
c_p_arb=0.3;

P_Rotor_arb=0.5*rho*2*R_arb*H_arb*c_p_arb*v1_arb.^3;
T_Rotor_arb=P_Rotor_arb./omega_Rotor_arb;


P_max=100;
T_max=P_max./omega_Rotor_arb;

PWM=[60 65 70 75 80 85 90 95 100 85 90 95 100];
T=[1.73 1.67 1.89 1.86 2.36 2.33 2.46 2.64 2.76 4.04 3.79 4.19 4.11];
P1=[4.845 5.755 10.862 11.021 14.950 17.329 18.562 18.880 20.884 50.995 50.630 51.168 48.732];
P2=[4.128 4.845 8.750 9.851 13.462 14.821 15.543 17.390 17.517 39.054 40.322 36.517 33.492];
V1=[31.600 33.200 34.300 32.100 30.100 27.800 25.900 24.000 22.700 32.900 30.500 28.800 27.900];
V2=[12.510 12.530 12.620 12.630 12.700 12.740 12.810 12.850 12.880 13.120 13.120 13.120 13.100];
I1=P1./V1;
I2=P2./V2;
RPM=[192.000 199.200 210.600 195.000 187.200 174.000 165.000 155.400 147.600 211.200 199.200 187.200 178.800];

PWM0=find(PWM==60);
PWM1=find(PWM==65);
PWM2=find(PWM==70);
PWM3=find(PWM==75);
PWM4=find(PWM==80);
PWM5=find(PWM==85);
PWM6=find(PWM==90);
PWM7=find(PWM==95);
PWM8=find(PWM==100);


V1_1=find(abs(V1-22)<1);
V1_2=find(abs(V1-24)<1);
V1_3=find(abs(V1-26)<1);
V1_4=find(abs(V1-28)<1);
V1_5=find(abs(V1-30)<1);
V1_6=find(abs(V1-32)<1);
V1_7=find(abs(V1-34)<1);


//plot(n_Rotor,P_Rotor,'x-k',"thickness",2,"MarkerSize",10)

//plot(n_Rotor,T_Rotor,'color',[0 0 0],'linest','-','marker','o',"thickness",2,'markersize',10)

plot(n_Rotor_arb,T_Rotor_arb,'color',[0 0 0],'linest','-',"thickness",2,'markersize',10)

plot(n_Gen_KS,T_Gen_KS,'color',[0 0.8 0],'linest','-','marker','*',"thickness",2,'markersize',14)

plot(n_Gen,T_Gen,'color',[0 0 1],'linest','-','marker','o',"thickness",2,'markersize',10)

plot(RPM(V1_1),T(V1_1),'color',[0.75 0 0.75],'linest','-','marker','x',"thickness",2,'markersize',10)
plot(RPM(V1_2),T(V1_2),'color',[0.25 0.75 1],'linest','-','marker','x',"thickness",2,'markersize',10)
plot(RPM(V1_3),T(V1_3),'color',[0.25 0.25 0.25],'linest','-','marker','x',"thickness",2,'markersize',10)
plot(RPM(V1_4),T(V1_4),'color',[0.75 0.75 0],'linest','-','marker','x',"thickness",2,'markersize',10)
plot(RPM(V1_5),T(V1_5),'color',[0 0.5 0.5],'linest','-','marker','x',"thickness",2,'markersize',10)
plot(RPM(V1_6),T(V1_6),'color',[0 0.75 0.75],'linest','-','marker','x',"thickness",2,'markersize',10)
plot(RPM(V1_7),T(V1_7),'color',[1 0 0],'linest','-','marker','x',"thickness",2,'markersize',10)
//plot(RPM(PWM1),T(PWM1),'color',[0 0.5 0],'linest','-','marker','x',"thickness",2,'markersize',10)
//plot(RPM(PWM0),T(PWM0),'color',[0.75 0.75 0.5],'linest','-','marker','x',"thickness",2,'markersize',10)

plot(n_Gen_LL,T_Gen_LL,'color',[0 0.75 1],'linest','-','marker','*',"thickness",2,'markersize',14)

//plot(n_Rotor_arb,T_max,'color',[0 1 0],'linest','-',"thickness",2,'markersize',10)

// Ploteigenschaften
xtitle("$ $", "$Rotational\ speed\ [rpm]$","$Torque\ [Nm]$");

l=legend(['$T_{turb,\ ref}$';'$T_{gen}\ short\ circuit$';'$T_{gen}\ V_1 = 12\,V=V_{Bat}$';'$T_{gen}\ V_1 = 22\,V$';'$T_{gen}\ V_1 = 24\,V$';'$T_{gen}\ V_1 = 26\,V$';'$T_{gen}\ V_1 = 28\,V$';'$T_{gen}\ V_1 = 30\,V$';'$T_{gen}\ V_1 = 32\,V$';'$T_{gen}\ V_1 = 34\,V$';'$T_{gen}\ open\ circuit$'],1);


//l=legend(['$P_{turb,\ opt}$';'$P_{gen,el}\ V_1 = 12\,V=V_{Bat}$';'$P_{gen,el}\ V_1 = 22\,V$';'$P_{gen,el}\ V_1 = 24\,V$';'$P_{gen,el}\ V_1 = 26\,V$';'$P_{gen,el}\ V_1 = 28\,V$';'$P_{gen,el}\  V_1 = 30\,V$';'$P_{gen,el}\ V_1 = 32\,V$';'$P_{gen,el}\  V_1 = 34\,V$'],2);

a=gca(); // get the handle of the current axes
f=get("current_figure");
f.figure_size=[800,700]
a.grid=[1 1];
a.font_size=4; //set the tics label font size
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 3;
a.axes_visible="on"; // makes the axes visible
a.data_bounds=[0,0,0;550,10,1]; //set the boundary values for the x, y and z coordinates.

//filename='Rotor_vs_Gen_Torque_Voltage_DCDC_v3';
//xs2pdf(0,filename);
//xs2pdf(gcf(),filename);
//
