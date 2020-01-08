//Simulation of the Start-up process at v1=3.5 m/s
close
clear
exec('polyfit.sci');

R=0.75;
H=1.2;
A=2*R*H;
rho=1.22;
J_rotor=8.2;

v1=3.5;
omega_3_5=[0.467 0.933 1.400 1.867 2.333 2.800 3.267 3.733 4.200 4.667 5.133 5.600 6.067 6.533 7.000 7.467 7.933 8.400 8.867 9.333 9.800 10.267 10.733 11.200 11.667 12.133 12.600];
n_3_5=omega_3_5*60/(2*%pi);

CM_3_5=[0.0265 0.0265 0.027 0.0275 0.0285 0.0295 0.03 0.03 0.031 0.032 0.034 0.0385 0.044 0.05 0.0575 0.0665 0.0775 0.0895 0.1035 0.1145 0.12 0.131 0.1495 0.1455 0.132 0.1185 0.104];
T_3_5=0.5*rho*A*R*v1.^2*CM_3_5; // Turbine torque

omega_4=[0.533 1.067 1.600 2.133 2.667 3.200 3.733 4.267 4.800 5.333 5.867 6.400 6.933 7.467 8.000 8.533 9.067 9.600 10.133 10.667 11.200 11.733 12.267 12.800 13.333 13.867 14.400];
n_4=omega_4*60/(2*%pi);

omega_5=[0.667 1.333 2.000 2.667 3.333 4.000 4.667 5.333 6.000 6.667 7.333 8.000 8.667 9.333 10.000 10.667 11.333 12.000 12.667 13.333 14.000 14.667 15.333 16.000 16.667 17.333 18.000];
n_5=omega_5*60/(2*%pi);

T_4=[0.272 0.267 0.279 0.296 0.32 0.347 0.366 0.383 0.404 0.428 0.469 0.537 0.619 0.712 0.821 0.958 1.119 1.302 1.505 1.638 1.695 1.881 2.092 1.945 1.76 1.575 1.364];

T_5=[0.363 0.383 0.41 0.443 0.498 0.555 0.599 0.63 0.651 0.674 0.743 0.86 0.978 1.136 1.304 1.557 1.873 2.189 2.458 2.69 2.886 3.307 3.328 3.002 2.673 2.336 2.089];

//n_Gen_LL=[0 88.9 124.3 244.2 372.4 483.7 580.1];
//omega_Gen_LL=n_Gen_LL*2*%pi/60;
//T_Gen_LL=[0.87 1.02 1.17 1.46 1.70 1.80 1.71];
n_Gen_LL=[0 88.9 124.3 244.2];
omega_Gen_LL=n_Gen_LL*2*%pi/60;
T_Gen_LL=[0.87 1.02 1.17 1.46];


T_3_5_fun=polyfit(omega_3_5,T_3_5,5); // Fit a polynomial function
T_4_fun=polyfit(omega_4,T_4,5); // Fit a polynomial function
T_5_fun=polyfit(omega_5,T_5,7); // Fit a polynomial function
T_gen_LL_fun=polyfit(omega_Gen_LL,T_Gen_LL,3); // Fit a polynomial function

omega_fit=(0:0.1:18);

T_3_5_fit=horner(T_3_5_fun,omega_fit);    //Evaluate polynomial function
T_4_fit=horner(T_4_fun,omega_fit);    //Evaluate polynomial function
T_5_fit=horner(T_5_fun,omega_fit);    //Evaluate polynomial function
T_gen_LL_fit=horner(T_gen_LL_fun,omega_fit);    //Evaluate polynomial function

//
//scf(0); clf();
//plot(omega_fit,T_3_5_fit)
//plot(omega_3_5,T_3_5,'g')
//plot(omega_fit,T_4_fit)
//plot(omega_4,T_4,'g')
//plot(omega_fit,T_5_fit)
//plot(omega_5,T_5,'g')

T_ges_3_5=T_3_5_fit-T_gen_LL_fit;
[Tges_3_5_pos,posloc_3_5]=find(T_ges_3_5>0);
P_ges_3_5=T_ges_3_5.*omega_fit;
P1_3_5=P_ges_3_5*0.6;

T_ges_4=T_4_fit-T_gen_LL_fit;
[Tges_4_pos,posloc_4]=find(T_ges_4>0);
P_ges_4=T_ges_4.*omega_fit;
P1_4=P_ges_4*0.6;

T_ges_5=T_5_fit-T_gen_LL_fit;
[Tges_5_pos,posloc_5]=find(T_ges_5>0);
P_ges_5=T_ges_5.*omega_fit;
P1_5=P_ges_5*0.6;

n_fit=omega_fit*60/(2*%pi);

scf(1); clf();
//plot(n_fit,T_3_5_fit)
//plot(n_fit,T_4_fit,'g')
//plot(n_fit,T_5_fit,'k')
plot(n_fit(posloc_3_5),P1_3_5(posloc_3_5),"thickness",2)
plot(n_fit(posloc_4),P1_4(posloc_4),'r',"thickness",2)
plot(n_fit(posloc_5),P1_5(posloc_5),'k',"thickness",2)

//plot(n_fit,T_gen_LL_fit,'r')

l=legend([...
'$v_1=3.5\ m/s$';...
'$v_1=4\ m/s$';...
'$v_1=5\ m/s$';...
],2);

xlabel ("$Rotational\ speed\ n_{turb}\ [RPM]$")
//ylabel ("$Torque\ [Nm],\ Power\, [W]$")
ylabel ("$expected\ power\, P_2\ [W]$")
a=gca(); 
f=get("current_figure");
f.figure_size=[800,550];
a.grid=[1 1];
a.font_size=4; 
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 3;
a.axes_visible="on"; 
a.data_bounds=[0,0,0;180,20,0]; //set the boundary values for the x, y and z coordinates.
////
filename='start_up_P_2_payback';
xs2pdf(gcf(),filename);

