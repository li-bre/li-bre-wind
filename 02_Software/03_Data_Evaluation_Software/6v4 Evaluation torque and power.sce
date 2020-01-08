// Program to evaluate Test Data from wind turbine Testing:
// Plot T_turb, P_turb, c_T, c_P, n_turb, n_gen, n_motor, T_tot, (P_tot), v1, TSR

clear
clc

savefile=0; // 1 to save plots, 0 not to

version='_6v4'; // Version of Program

//// Define Path for Data source

//path="E:\P\TubCloud\Shared\Masterarbeit\"; // Avia
path="C:\Users\J B\tubcloud\Module\Masterarbeit\" //  Julian
//path="D:\Stuff\noodlz\TU\Module\Masterarbeit\" //  Julian

exec(strcat([path 'Testen\Programme\zeitable4_v2_h.sci']),-1)  //Programm for time derivative
h=2; //[s] step size for time derivative

//// Figure properties
legendlocation=2;
figuresize=[600,650];

////General Turbine Data
J_rotor=8.2; //[kg*m^2]
R=0.75; // [m]
A=1.2*1.5; //[m^2]
rho_Luft=1.24; //[kg/m³]
M_Freilauf=0.075; //[Nm]
M_Gen_OC=1.3; //[Nm]


//// Read Data

jj=10; //Data selection

filedir_al_vec(1)="Testen\Daten_bearbeitet\2019 04 16 12 19 47\2019 04 16 12 19 47_all_v2.txt";
filedir_al_vec(2)="Testen\Daten_bearbeitet\2019 04 16 13 00 26\2019 04 16 13 00 26_all.txt";
filedir_al_vec(3)="Testen\Daten_bearbeitet\2019 04 16 13 24 30\2019 04 16 13 24 30_all.txt";
filedir_al_vec(4)="Testen\Daten_bearbeitet\2019 04 16 13 58 24\2019 04 16 13 58 24_all_v2.txt";
filedir_al_vec(5)="Testen\Daten_bearbeitet\2019 04 16 14 45 29\2019 04 16 14 45 29_all_v2.txt";
filedir_al_vec(6)="Testen\Daten_bearbeitet\2019 04 16 15 02 55\2019 04 16 15 02 55_all_v2.txt";
filedir_al_vec(7)="Testen\Daten_bearbeitet\2019 04 16 15 35 26\2019 04 16 15 35 26_all_v2.txt";
filedir_al_vec(8)="Testen\Daten_bearbeitet\2019 04 16 17 50 13\2019 04 16 17 50 13_all.txt";
filedir_al_vec(9)="Testen\Daten_bearbeitet\2019 04 16 19 17 26\2019 04 16 19 17 26_all.txt";
filedir_al_vec(10)="Testen\Daten_bearbeitet\2019 04 16 19 29 08\2019 04 16 19 29 08_all.txt";
filedir_al_vec(11)="Testen\Daten_bearbeitet\2019 04 16 19 58 19\2019 04 16 19 58 19_all.txt";
filedir_al_vec(12)="Testen\Daten_bearbeitet\2019 04 16 20 23 30\2019 04 16 20 23 30_all.txt";
filedir_al_vec(13)="Testen\Daten_bearbeitet\2019 04 16 20 50 54\2019 04 16 20 50 54_all_v2.txt";
filedir_al_vec(15)="Testen\Daten_bearbeitet\2019 04 16 15 21 22\2019 04 16 15 21 22_wind_v2.txt";
filedir_al_vec(16)="Testen\Daten_bearbeitet\2019 05 12 10 17 42\2019 05 12 10 17 42_all_v3_2.txt";
filedir_al_vec(17)="Testen\Daten_bearbeitet\2019 05 12 10 42 34\2019 05 12 10 42 34_all_v3.txt";
filedir_al_vec(18)="Testen\Daten_bearbeitet\2019 05 12 10 56 02\2019 05 12 10 56 02_all_v3.txt";
filedir_al_vec(19)="Testen\Daten_bearbeitet\2019 05 12 11 58 23\2019 05 12 11 58 23_all_v4.txt";
filedir_al_vec(20)="Testen\Daten_bearbeitet\2019 05 12 12 18 22\2019 05 12 12 18 22_all_v4.txt";

filedir_all=strcat([path,filedir_al_vec(jj)]);
[Data,text] = fscanfMat(filedir_all);

Datevec=Data(:,1:6);
Datenum=datenum(Datevec);
Seconds=(Datenum-Datenum(1))*24*3600;

Delimiter=strindex(text,' ');
for i=1:length(Delimiter)+1
    if i==1 then
        header(1)=part(text,[1:Delimiter(i)]);
    elseif i == length(Delimiter)+1 then
        header(length(Delimiter)+1)=part(text,[Delimiter(i-1):length(text)]);
    else
        header(i)=part(text,[Delimiter(i-1)+1:Delimiter(i)]);
    end
end

for i=7:size(header,1)
    str=strcat([header(i) '=Data(:,i);']);
    execstr(str);
end

//// Calculations

Gen_RPM=Gen_RPM*26/25; // Correct generator speed

omega=RPM_Turb*2*%pi/60; // [1/s]
omega_punkt=zeitable4_v2_h(omega,Seconds,h); // Time derivative

M_ges=J_rotor*omega_punkt; //T_total
P_ges=M_ges.*omega; // P_total
M_Rotor_free=J_rotor*omega_punkt-M_Freilauf; //T_turb
P_Rotor=M_Rotor_free.*omega; //P_turb

// Calculate TSR
x_v1_nichtnull=find(v1_new~=0);
lambda=zeros(v1_new)
lambda(x_v1_nichtnull)=RPM_Turb(x_v1_nichtnull)*2*%pi*R./(60.*v1_new(x_v1_nichtnull));
L_Mr_v1_RPMm_RPMt=[lambda M_Rotor_free v1_new MS_RPM RPM_Turb];

//// DATA Filter

// n_Motor only if reliable Data
x_MS_RPM_bad_Data=find(SU_Stability<4);
MS_RPM(x_MS_RPM_bad_Data)=%nan;

// Only Data where n_Motor = n_Motor_target
x_full_MS_RPM=find(abs(L_Mr_v1_RPMm_RPMt(:,4)-median(L_Mr_v1_RPMm_RPMt(:,4)))<3); //L_Mr_v1_RPMm_RPMt(:,4)=n_motor
L_Mr_v1_RPMm_RPMt=L_Mr_v1_RPMm_RPMt(x_full_MS_RPM,:);

// Only Data where n_turb < n_motor
x_M_schneller_T=find((L_Mr_v1_RPMm_RPMt(:,4)-L_Mr_v1_RPMm_RPMt(:,5))>3); //L_Mr_v1_RPMm_RPMt(:,5)=n_Turb
L_Mr_v1_RPMm_RPMt=L_Mr_v1_RPMm_RPMt(x_M_schneller_T,:);

// Only Data where n_turb > 20 rpm
x_M_schneller_T=find((L_Mr_v1_RPMm_RPMt(:,5)>20)); //L_Mr_v1_RPMm_RPMt(:,5)=RPM_Turb
L_Mr_v1_RPMm_RPMt=L_Mr_v1_RPMm_RPMt(x_M_schneller_T,:);

// Sort ascending by TSR
L_Mr_v1_RPMm_RPMt_sort=gsort(L_Mr_v1_RPMm_RPMt,'lr','i');
//L_Mr_v1_m_t_eR_sor=gsort(L_Mr_v1_RPMm_RPMt_evRPM,'lr','i');

// Divide Data in wind speed ranges
L_Mr_v1_RPMm_RPMt_v1=find(abs(L_Mr_v1_RPMm_RPMt(:,3)-1)<0.5);
L_Mr_v1_RPMm_RPMt_v2=find(abs(L_Mr_v1_RPMm_RPMt(:,3)-2)<0.5);
L_Mr_v1_RPMm_RPMt_v3=find(abs(L_Mr_v1_RPMm_RPMt(:,3)-3)<0.5);
L_Mr_v1_RPMm_RPMt_v4=find(abs(L_Mr_v1_RPMm_RPMt(:,3)-4)<0.5);
L_Mr_v1_RPMm_RPMt_v5=find(abs(L_Mr_v1_RPMm_RPMt(:,3)-5)<0.5);
L_Mr_v1_RPMm_RPMt_v6=find(abs(L_Mr_v1_RPMm_RPMt(:,3)-6)<0.5);
L_Mr_v1_RPMm_RPMt_v7=find(abs(L_Mr_v1_RPMm_RPMt(:,3)-7)<0.5);
L_Mr_v1_RPMm_RPMt_v8=find(abs(L_Mr_v1_RPMm_RPMt(:,3)-8)<0.5);
L_Mr_v1_RPMm_RPMt_v9=find(abs(L_Mr_v1_RPMm_RPMt(:,3)-9)<0.5);
L_Mr_v1_RPMm_RPMt_v10=find(abs(L_Mr_v1_RPMm_RPMt(:,3)-10)<0.5);

j=1;
for i=1:10
    name=[strcat(['L_Mr_v1_RPMm_RPMt_v', string(i)])];
    if find(eval(name),1) then
        v_avail(j)=i;
        j=j+1;
    end
end

////// Plot Data
colormat=[[0 0.9 0.5];[0.75 0 0.75];[0 0 0];[0.25 0.75 1];[1 0 0];[0 1 0];[0.75 0.5 0];[0.5 0 0.5];[0 0 0.6];[0 0.5 0]];

////PLOT  Torque over TSR
scf(0); clf();
f=get("current_figure");
f.figure_size=figuresize

for i=1:length(v_avail)
    LAMBDA=strcat(['L_Mr_v1_RPMm_RPMt(L_Mr_v1_RPMm_RPMt_v', string(v_avail(i)), ',1)']);
    M_ROTOR=strcat(['L_Mr_v1_RPMm_RPMt(L_Mr_v1_RPMm_RPMt_v', string(v_avail(i)), ',2)']);
    RPM_TURBINE=strcat(['L_Mr_v1_RPMm_RPMt(L_Mr_v1_RPMm_RPMt_v', string(v_avail(i)), ',5)']);
    plot(eval(LAMBDA),eval(M_ROTOR),'color',colormat(v_avail(i),:),'marker','x','linest','none')
end

set(gca(),"grid",[1 1])
ylabel ("$T_{turb}\ [Nm]$")
xlabel ("$\lambda\ [1]$")

legend_str=[]
for i=1:length(v_avail)
    legend_str=([legend_str strcat(["$v_1=" string(v_avail(i)) '\ m/s$'])])
end
l=legend(legend_str,legendlocation)
a=gca();
f=get("current_figure");
a.font_size=4;
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 4;
a.axes_visible="on";
//a.data_bounds=[0,-3,0;5,2,0];

// Safe plot
if savefile==1 then 
    filename_new=part(filedir_all,1:length(filedir_all)-4);
    filename_new=strcat([filename_new, '_M_Rotor_vs_lambda']);
    filename_new=strcat([filename_new, version]);
    xs2pdf(0,filename_new);
    xs2pdf(gcf(),filename_new);
end

////PLOT  Power over TSR
scf(1); clf();
f=get("current_figure");
f.figure_size=figuresize

for i=1:length(v_avail)
    LAMBDA=strcat(['L_Mr_v1_RPMm_RPMt(L_Mr_v1_RPMm_RPMt_v', string(v_avail(i)), ',1)']);
    M_ROTOR=strcat(['L_Mr_v1_RPMm_RPMt(L_Mr_v1_RPMm_RPMt_v', string(v_avail(i)), ',2)']);
    RPM_TURBINE=strcat(['L_Mr_v1_RPMm_RPMt(L_Mr_v1_RPMm_RPMt_v', string(v_avail(i)), ',5)']);
    plot(eval(LAMBDA),eval(M_ROTOR).*(eval(RPM_TURBINE)*2*%pi/60),'color',colormat(v_avail(i),:),'marker','x','linest','none')
end

set(gca(),"grid",[1 1])
ylabel ("$P_{turb}\ [W]$")
xlabel ("$\lambda\ [1]$")

legend_str=[]
for i=1:length(v_avail)
    legend_str=([legend_str strcat(["$v_1=" string(v_avail(i)) '\ m/s$'])])
end
l=legend(legend_str,legendlocation)

a=gca();
f=get("current_figure");
a.font_size=4;
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 4;
a.axes_visible="on";
//a.data_bounds=[0,-3,0;5,2,0];

if savefile==1 then 
    filename_new=part(filedir_all,1:length(filedir_all)-4);
    filename_new=strcat([filename_new, '_P_Rotor_vs_lambda']);
    filename_new=strcat([filename_new, version]);
    xs2pdf(0,filename_new);
    xs2pdf(gcf(),filename_new);
end

////PLOT  c_T over TSR
scf(2); clf();
f=get("current_figure");
f.figure_size=figuresize

for i=1:length(v_avail)
    LAMBDA=strcat(['L_Mr_v1_RPMm_RPMt(L_Mr_v1_RPMm_RPMt_v', string(v_avail(i)), ',1)']);
    M_ROTOR=strcat(['L_Mr_v1_RPMm_RPMt(L_Mr_v1_RPMm_RPMt_v', string(v_avail(i)), ',2)']);
    WIND=strcat(['L_Mr_v1_RPMm_RPMt(L_Mr_v1_RPMm_RPMt_v', string(v_avail(i)), ',3)']);
    RPM_MOTOR=strcat(['L_Mr_v1_RPMm_RPMt(L_Mr_v1_RPMm_RPMt_v', string(v_avail(i)), ',4)']);
    RPM_TURBINE=strcat(['L_Mr_v1_RPMm_RPMt(L_Mr_v1_RPMm_RPMt_v', string(v_avail(i)), ',5)']);
    c_T=eval(M_ROTOR)./(0.5*rho_Luft*A*R.*eval(WIND).^2);
    plot(eval(LAMBDA),c_T,'color',colormat(v_avail(i),:),'marker','x','linest','none')
end

ylabel ("$c_T\ [1]$")
xlabel ("$\lambda\ [1]$")

legend_str=[]
for i=1:length(v_avail)
    legend_str=([legend_str strcat(["$v_1=" string(v_avail(i)) '\ m/s$'])])
end

l=legend(legend_str,legendlocation)

a=gca();
f=get("current_figure");
a.grid=[1 1];
a.font_size=4;
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 4;
a.axes_visible="on";
//a.data_bounds=[0,-3,0;5,2,0];

if savefile==1 then 
    filename_new=part(filedir_all,1:length(filedir_all)-4);
    filename_new=strcat([filename_new, '_cT_vs_lambda']);
    filename_new=strcat([filename_new, version]);
    xs2pdf(0,filename_new);
    xs2pdf(gcf(),filename_new);
end

////PLOT  c_P over TSR
scf(3); clf();
f=get("current_figure");
f.figure_size=figuresize

for i=1:length(v_avail)
    LAMBDA=strcat(['L_Mr_v1_RPMm_RPMt(L_Mr_v1_RPMm_RPMt_v', string(v_avail(i)), ',1)']);
    M_ROTOR=strcat(['L_Mr_v1_RPMm_RPMt(L_Mr_v1_RPMm_RPMt_v', string(v_avail(i)), ',2)']);
    WIND=strcat(['L_Mr_v1_RPMm_RPMt(L_Mr_v1_RPMm_RPMt_v', string(v_avail(i)), ',3)']);
    RPM_MOTOR=strcat(['L_Mr_v1_RPMm_RPMt(L_Mr_v1_RPMm_RPMt_v', string(v_avail(i)), ',4)']);
    RPM_TURBINE=strcat(['L_Mr_v1_RPMm_RPMt(L_Mr_v1_RPMm_RPMt_v', string(v_avail(i)), ',5)']);
    plot(eval(LAMBDA),(eval(M_ROTOR).*eval(RPM_TURBINE)*2*%pi/60)./(0.5*rho_Luft*A*eval(WIND).^3),'color',colormat(v_avail(i),:),'marker','x','linest','none')
end

set(gca(),"grid",[1 1])
ylabel ("$c_P\ [1]$")
xlabel ("$\lambda\ [1]$")

legend_str=[];
for i=1:length(v_avail)
    legend_str=([legend_str strcat(["$v_1=" string(v_avail(i)) '\ m/s$'])])
end

l=legend(legend_str,legendlocation)

a=gca();
f=get("current_figure");
a.font_size=4;
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 4;
a.axes_visible="on";
//a.data_bounds=[0,-3,0;5,2,0];

if savefile==1 then 
    filename_new=part(filedir_all,1:length(filedir_all)-4);
    filename_new=strcat([filename_new, '_cp_vs_lambda']);
    filename_new=strcat([filename_new, version]);
    xs2pdf(0,filename_new);
    xs2pdf(gcf(),filename_new);
end

//// PLOT general Test_ n,T,v1,TSR

scf(10); clf();
f=get("current_figure");
f.figure_size=[800,1000]

subplot(3,1,1)
plot(Seconds,RPM_Turb,'b',"thickness",2)
plot(Seconds,MS_RPM,'k',"thickness",2)
plot(Seconds,Gen_RPM,'r',"thickness",2)

l=legend([...
'$n_{turb}$';...
'$n_{motor}$';...
'$n_{gen}$';...
],2);

ylabel ("$Rotational\ Speed\ [rpm]$")
a=gca(); 
a.grid=[1 1];
a.font_size=4;
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 4;
a.axes_visible="on";
a.tight_limits="off";
//a.data_bounds=[0,0,0;700,180,1];

subplot(3,1,2)
plot(Seconds,M_ges,"thickness",2)

ylabel ("$T_{tot}\ [Nm]$")

a=gca();
f=get("current_figure");
a.grid=[1 1];
a.font_size=4;
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 4;
a.axes_visible="on";
a.tight_limits="off";
//a.data_bounds=[0,-1,0;700,2,0];

// only if power shall be shown  subplot(3,1,x) ->subplot(4,1,x)

//subplot(4,1,3)
//plot(Seconds,P_ges,"thickness",2)
//
//ylabel ("$P_{tot}\ [W]$")
//ylabel ("$P_{tot}\ [W]$")
//
//a=gca();
//f=get("current_figure");
//a.grid=[1 1];
//a.font_size=4;
//a.title.font_size=4;
//a.x_label.font_size=4;
//a.y_label.font_size=4;
//l.font_size = 4;
//a.axes_visible="on"; 
//a.tight_limits="off";
////a.data_bounds=[0,-1,0;700,2,0];

subplot(3,1,3)
plot(Seconds,v1_new,'r',"thickness",2)
plot(Seconds,lambda,'k',"thickness",2)

l=legend([...
'$v_1$';...
'$\lambda$';...
],3);

ylabel ("$v_1\ [m/s],\ \lambda [1]$")
xlabel ("$time [s]$")

a=gca();
f=get("current_figure");
a.grid=[1 1];
a.font_size=4;
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 4;
a.axes_visible="on";
a.tight_limits="off";
//a.data_bounds=[0,0,0;700,7,0];


if savefile==1 then
    filename_new=part(filedir_all,1:length(filedir_all)-4);
    filename_new=strcat([filename_new, '_Auswertung_allg_MuP_4']);
    filename_new=strcat([filename_new, version]);
    xs2pdf(0,filename_new);
    xs2pdf(gcf(),filename_new);
end
