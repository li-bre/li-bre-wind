clear
close
// Zeit Größenordung Regelung

// Änderung der PWM bis 90% der Enddrehzahl erreicht sind
Theta=9; //[kg m^2]

M1=3.597;  //[Nm]
M2=4.533;
M3=4.106;


w1=194.24*2*%pi/60; //[rad/s] //=w2
w3=185.48*2*%pi/60;

N1=194.24; //[rad/s] //=w2
N3=185.48;
goal2=N1+0.2*(N3-N1);
goal5=N1+0.5*(N3-N1);
goal8=N1+0.8*(N3-N1);

c_MR=(M3-M1)/(w3-w1);
c_ML=(M3-M2)/(w3-w1);

c1=(c_MR-c_ML)/Theta;

M_R0=M1-w1*c_MR;
M_L0=M2-w1*c_ML;

c2=(M_R0-M_L0)/Theta;

t=0:0.1:50;
t11=-10:0;
n11=N1*ones(t11);
w=(w1+c2/c1)*exp(c1*t)-c2/c1;
n=w*60/(2*%pi);
goal2=goal2*ones(t);
goal5=goal5*ones(t);
goal8=goal8*ones(t);

scf(0); clf();

plot(t,n,'color',[0 0 1],'linest','-',"thickness",2)
plot(t,goal2,'color',[0.9 0 0],'linest','--',"thickness",2)
plot(t,goal5,'color',[0 0.7 0],'linest','--',"thickness",2)
plot(t,goal8,'color',[0 0 0],'linest','--',"thickness",2)
plot(t11,n11,'color',[0 0 1],'linest','-',"thickness",2)


l=legend([...
'$n_{turb}$';...
'$20\ \%\ of\ final\ RPM$';
'$50\ \%\ of\ final\ RPM$';
'$80\ \%\ of\ final\ RPM$';
],1);



xlabel("$Time\ [s]$");
ylabel("$Rotaional\ speed\ [RPM]$")
a=gca(); // get the handle of the current axes
f=get("current_figure");
f.figure_size=[800,600];
a.grid=[1 1];
a.font_size=4; //set the tics label font size
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 3;
a.axes_visible="on"; // makes the axes visible
a.data_bounds=[-10,185,0;50,195,0]; //set the boundary values for the x, y and z coordinates.

filename='Timeconsideration_MPPT';
xs2pdf(0,filename);
xs2pdf(gcf(),filename);
