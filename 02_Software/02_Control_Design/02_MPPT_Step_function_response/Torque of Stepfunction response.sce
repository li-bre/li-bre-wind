// Rotor vs. Generator Power
clear
close
scf(0); clf();
//
//Beispiel: Erhöhung der PWM von 90 auf 95

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


n_6m=[7.639 15.279 22.918 30.558 38.197 45.837 53.476 61.115 68.755 76.394 84.034 91.673 99.313 106.952 114.592 122.231 129.87 137.51 145.149 152.789 160.428 168.068 175.707 183.346 190.986 198.625 206.265];
T_6m=[0.595 0.636 0.685 0.704 0.735 0.763 0.784 0.821 0.858 0.924 1.068 1.243 1.448 1.678 1.959 2.425 2.847 3.267 3.666 3.975 4.361 5.078 4.715 4.243 3.755 3.385 3.082];

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
PWM8=find(PWM==100);;

//// Linearisierung
x_omega=100:250;

//M_gen_PWM95=M_95_0+C_M95*x_omega

M_95=T(PWM7);
M_90=T(PWM6);
omega_95=RPM(PWM7);
omega_90=RPM(PWM6);

C_95=(M_95(2)-M_95(1))/(omega_95(2)-omega_95(1));
C_90=(M_90(2)-M_90(1))/(omega_90(2)-omega_90(1));

M_95_0=M_95(1)-C_95*omega_95(1);
M_90_0=M_90(1)-C_90*omega_90(1);

M_95_lin=M_95_0+C_95*x_omega;
M_90_lin=M_90_0+C_90*x_omega;

n_ABC=[194.24 194.24 185.48];
T_ABC=[3.597 4.533 4.106];

//T_v6=T_v6_0+C_v6*x_omega
C_v6=(T_ABC(3)-T_ABC(1))/(n_ABC(3)-n_ABC(1));
T_v6_0=T_ABC(1)-C_v6*n_ABC(1);

T_v6_lin=T_v6_0+C_v6*x_omega;

/// Plotten////
//plot(n_Gen_KS,T_Gen_KS,'color',[0 0.8 0],'linest','-','marker','*',"thickness",2,'markersize',10)

plot(RPM(PWM7),T(PWM7),'color',[0 0.8 0],'linest','-','marker','x',"thickness",2,'markersize',10)
plot(x_omega,M_95_lin,'color',[0 0.8 0],'linest','--',"thickness",2,'markersize',10)
plot(RPM(PWM6),T(PWM6),'color',[0.25 0.25 0.25],'linest','-','marker','x',"thickness",2,'markersize',10)
plot(x_omega,M_90_lin,'color',[0.25 0.25 0.25],'linest','--',"thickness",2,'markersize',10)

//plot(n_Gen_LL,T_Gen_LL,'color',[0 0.75 1],'linest','-','marker','*',"thickness",2,'markersize',10)

plot(n_6m,T_6m,'color',[1 0 0],'linest','-',"thickness",2,'markersize',10)
plot(x_omega,T_v6_lin,'color',[1 0 0],'linest','--',"thickness",2,'markersize',10)


plot(n_ABC,T_ABC,'color',[0 0 1],'linest','-','marker','+',"thickness",2,'markersize',12)
// Ploteigenschaften
xset("font",6,5)  
xstring(n_ABC-12,T_ABC-0.2,['A' 'B' 'C'])
xset("font",6,4)
xtitle("$ $", "$Rotational\ speed\ [rpm]$","$Torque\ [Nm]$");

l=legend([...
//'$T_{turb,\ opt}$';...
//'$T_{gen}\ short\ circuit$';...
//'$T_{gen}\ uncontrolled$';...
//'$T_{gen}\ PWM\ 100$';...
'$T_{gen}\ D=95/255$';...
'$T_{gen,lin}\ D=95/255$';...
'$T_{gen}\ D=90/255$';...
'$T_{gen,lin}\ D=90/255$';...
//'$T_{gen}\ PWM\ 85$';...
//'$T_{gen}\ PWM\ 80$';...
//'$T_{gen}\ PWM\ 75$';...
//'$T_{gen}\ PWM\ 70$';...
//'$T_{gen}\ PWM\ 65$';...
//'$T_{gen}\ PWM\ 60$';...
//'$T_{gen}\ open\ circuit$';...
'$T_{turb}\ v_1=6\,m/s$';...
'$T_{turb,lin}\ v_1=6\,m/s$';...
'$path\ of\ step\ function\ response$';
],2);

a=gca(); // get the handle of the current axes
f=get("current_figure");
f.figure_size=[800,600]
a.grid=[1 1];
a.font_size=4; //set the tics label font size
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 3;
a.axes_visible="on"; // makes the axes visible
a.tight_limits="on";
a.data_bounds=[0,0,0;250,5.5,1]; //set the boundary values for the x, y and z coordinates.

filename='moments_for_timeconsideration_MPPT';
xs2pdf(0,filename);
xs2pdf(gcf(),filename);
