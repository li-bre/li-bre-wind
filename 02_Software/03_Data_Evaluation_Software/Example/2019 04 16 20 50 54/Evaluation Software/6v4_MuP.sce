clear
clc

// Auswerten wenn RPM Motor und Generator gleich sind und über der Zieldrehzahl des Motors liegen

savefile=0; // 1 Wenn plots gespeichert werden sollen, 0 wenn nicht

version='_6v4';
//path="E:\P\TubCloud\Shared\Masterarbeit\"; // Für Avia
path="C:\Users\J B\tubcloud\Module\Masterarbeit\" // Für Julian
//path="D:\Stuff\noodlz\TU\Module\Masterarbeit\" // Für Julian

exec(strcat([path 'Testen\Programme\zeitable4_v2_h.sci']),-1)  //Programm für die Zeitableitung
h=2; //[s] Schrittweite der Zeitableitung

legendlocation=2;
figuresize=[600,650];
//Rotormomentberechnung
//allgemeine Daten
J_rotor=8.2; //[kg*m^2]
R=0.75; // [m]
A=1.2*1.5; //[m^2]
rho_Luft=1.2; //[kg/m³]
M_Freilauf=0.075; //[Nm]
M_Gen_OC=1.3; //[Nm]

jj=10; //Datenauswahl

    //filedir_al_vec(1)="Testen\Daten_bearbeitet\2019 04 16 12 19 47\2019 04 16 12 19 47_all_v3.txt";
filedir_al_vec(1)="Testen\Daten_bearbeitet\2019 04 16 12 19 47\2019 04 16 12 19 47_all_v2.txt";
filedir_al_vec(2)="Testen\Daten_bearbeitet\2019 04 16 13 00 26\2019 04 16 13 00 26_all.txt";
filedir_al_vec(3)="Testen\Daten_bearbeitet\2019 04 16 13 24 30\2019 04 16 13 24 30_all.txt";
filedir_al_vec(4)="Testen\Daten_bearbeitet\2019 04 16 13 58 24\2019 04 16 13 58 24_all_v2.txt";
//filedir_al_vec(4)="Testen\Daten_bearbeitet\2019 04 16 13 58 24\2019 04 16 13 58 24_all_v3_1s.txt";
//filedir_al_vec(41)="Testen\Daten_bearbeitet\2019 04 16 13 58 24\2019 04 16 13 58 24_all_1_v3.txt";
//filedir_al_vec(42)="Testen\Daten_bearbeitet\2019 04 16 13 58 24\2019 04 16 13 58 24_all_2_v3.txt";
filedir_al_vec(5)="Testen\Daten_bearbeitet\2019 04 16 14 45 29\2019 04 16 14 45 29_all_v2.txt";
filedir_al_vec(6)="Testen\Daten_bearbeitet\2019 04 16 15 02 55\2019 04 16 15 02 55_all_v2.txt";
filedir_al_vec(7)="Testen\Daten_bearbeitet\2019 04 16 15 35 26\2019 04 16 15 35 26_all_v2.txt";  //DQ3
filedir_al_vec(8)="Testen\Daten_bearbeitet\2019 04 16 17 50 13\2019 04 16 17 50 13_all.txt";

filedir_al_vec(9)="Testen\Daten_bearbeitet\2019 04 16 19 17 26\2019 04 16 19 17 26_all.txt";
filedir_al_vec(10)="Testen\Daten_bearbeitet\2019 04 16 19 29 08\2019 04 16 19 29 08_all.txt";
filedir_al_vec(11)="Testen\Daten_bearbeitet\2019 04 16 19 58 19\2019 04 16 19 58 19_all.txt";
filedir_al_vec(12)="Testen\Daten_bearbeitet\2019 04 16 20 23 30\2019 04 16 20 23 30_all.txt";
filedir_al_vec(13)="Testen\Daten_bearbeitet\2019 04 16 20 50 54\2019 04 16 20 50 54_all_v2.txt";
//filedir_al_vec(15)="Testen\Daten_bearbeitet\2019 04 16 15 21 22\2019 04 16 15 21 22_wind_v2.txt"; //Kurzschlussbremse
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
//plot (Datenum)

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

/////////////////////Berechnungen///////////////////
omega=RPM_Turb*2*%pi/60; // [1/s]
omega_punkt=zeitable4_v2_h(omega,Seconds,h);

M_Freilauf=0.075;
M_Gen_OC=1.3;
M_ges=J_rotor*omega_punkt;
P_ges=M_ges.*omega;
M_Rotor_free=J_rotor*omega_punkt-M_Freilauf;    //Rotormomente wenn Rotor vom Freilauf (free) angetrieben wird
P_Rotor=M_Rotor_free.*omega;
M_Rotor_gen_OC=J_rotor*omega_punkt+M_Gen_OC;  //Rotormomente wenn Rotor den Generator im Leerlauf (Open Circuit) antreibt
//    J_rotor*omega_punkt=M_Rotor+M_Freilauf
//    M_Rotor=J_rotor*omega_punkt-M_Freilauf

x_v1_nichtnull=find(v1_new~=0);
lambda=zeros(v1_new)
lambda(x_v1_nichtnull)=RPM_Turb(x_v1_nichtnull)*2*%pi*R./(60.*v1_new(x_v1_nichtnull));
L_Mr_v1_RPMm_RPMt=[lambda M_Rotor_free v1_new MS_RPM RPM_Turb];
L_Mr_v1_RPMm_RPMt_evRPM=[lambda M_Rotor_gen_OC v1_new MS_RPM RPM_Turb];

/////////////////////////// DATEN FILTERN ////////////////////////////
// Motor RPM nur wenn Daten gut
x_MS_RPM_bad_Data=find(SU_Stability<4); //L_Mr_v1_RPMm_RPMt(:,4)=MS_RPM
MS_RPM(x_MS_RPM_bad_Data)=%nan;

// Nur die Daten bei denen MS_RPM Ziel erreicht ist für die Auswertung bei gleicher Drehzahl
//x_evRPM=find(abs(L_Mr_v1_RPMm_RPMt_evRPM(:,4)-(L_Mr_v1_RPMm_RPMt_evRPM(:,5)))<2 &...
//L_Mr_v1_RPMm_RPMt_evRPM(:,4)>median(L_Mr_v1_RPMm_RPMt_evRPM(:,4))); //L_Mr_v1_RPMm_RPMt_evRPM(:,4)=MS_RPM
//L_Mr_v1_RPMm_RPMt_evRPM=L_Mr_v1_RPMm_RPMt_evRPM(x_evRPM,:);
//
//    figure
//    plot(L_Mr_v1_RPMm_RPMt_evRPM(:,4))
//    plot(L_Mr_v1_RPMm_RPMt_evRPM(:,5))


// Nur die Daten bei denen MS_RPM Ziel erreicht ist
x_full_MS_RPM=find(abs(L_Mr_v1_RPMm_RPMt(:,4)-median(L_Mr_v1_RPMm_RPMt(:,4)))<3); //L_Mr_v1_RPMm_RPMt(:,4)=MS_RPM
L_Mr_v1_RPMm_RPMt=L_Mr_v1_RPMm_RPMt(x_full_MS_RPM,:);

// Nur die Daten bei denen MS_RPM nicht gleich RPM_Turb Ziel erreicht ist
x_M_schneller_T=find((L_Mr_v1_RPMm_RPMt(:,4)-L_Mr_v1_RPMm_RPMt(:,5))>3); //L_Mr_v1_RPMm_RPMt(:,5)=RPM_Turb
L_Mr_v1_RPMm_RPMt=L_Mr_v1_RPMm_RPMt(x_M_schneller_T,:);

// Nur Daten bei denen RPM_Turb >20 RPM (darunter unzuverlässig)
x_M_schneller_T=find((L_Mr_v1_RPMm_RPMt(:,5)>20)); //L_Mr_v1_RPMm_RPMt(:,5)=RPM_Turb
L_Mr_v1_RPMm_RPMt=L_Mr_v1_RPMm_RPMt(x_M_schneller_T,:);

//Daten nach Lambda aufsteigend sortieren
L_Mr_v1_RPMm_RPMt_sort=gsort(L_Mr_v1_RPMm_RPMt,'lr','i');
//L_Mr_v1_m_t_eR_sor=gsort(L_Mr_v1_RPMm_RPMt_evRPM,'lr','i');

// Daten in Windgeschwindigkeiten einteilen
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


//Seconds=Seconds-100;
////////////////////////// DATEN PLOTTEN ///////////////////////
colormat=[[0 0.9 0.5];[0.75 0 0.75];[0 0 0];[0.25 0.75 1];[1 0 0];[0 1 0];[0.75 0.5 0];[0.5 0 0.5];[0 0 0.6];[0 0.5 0]];

/////////////// PLOT AUSWERTUNG Momente über Lambda ///////////////

scf(0); clf();
f=get("current_figure");
f.figure_size=figuresize
//    plot(L_Mr_v1_RPMm_RPMt(L_Mr_v1_RPMm_RPMt_v1,1),L_Mr_v1_RPMm_RPMt(L_Mr_v1_RPMm_RPMt_v1,2),'color',[0 0.9 0.5],'marker','x')

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

a=gca(); // get the handle of the current axes
f=get("current_figure");
//a.grid=[1 1];
a.font_size=4; //set the tics label font size

a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 4;
a.axes_visible="on"; // makes the axes visible
//a.data_bounds=[0,-3,0;5,2,0]; //set the boundary values for the x, y and z coordinates.

if savefile==1 then 
    filename_new=part(filedir_all,1:length(filedir_all)-4);
    filename_new=strcat([filename_new, '_M_Rotor_vs_lambda']);
    filename_new=strcat([filename_new, version]);
    xs2pdf(0,filename_new);
    xs2pdf(gcf(),filename_new);
end


/////////////// PLOT AUSWERTUNG Leistung über Lambda ///////////////

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

a=gca(); // get the handle of the current axes
f=get("current_figure");
//a.grid=[1 1];
a.font_size=4; //set the tics label font size
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 4;
a.axes_visible="on"; // makes the axes visible
//      //a.L_Mr_v1_RPMm_RPMt_bounds=[0,0,0;550,10,1]; //set the boundary values for the x, y and z coordinates.

if savefile==1 then 
    filename_new=part(filedir_all,1:length(filedir_all)-4);
    filename_new=strcat([filename_new, '_P_Rotor_vs_lambda']);
    filename_new=strcat([filename_new, version]);
    xs2pdf(0,filename_new);
    xs2pdf(gcf(),filename_new);
end


/////////////// PLOT AUSWERTUNG Momentenbeiwert über Lambda ///////////////

// M=0.5*rho*A*R*v1^2*c_T
//c_T=M/(0.5*rho*A*R*v_1^2)

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

a=gca(); // get the handle of the current axes
f=get("current_figure");
a.grid=[1 1];
a.font_size=4; //set the tics label font size
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 4;
a.axes_visible="on"; // makes the axes visible
//      //a.L_Mr_v1_RPMm_RPMt_bounds=[0,0,0;550,10,1]; //set the boundary values for the x, y and z coordinates.

if savefile==1 then 
    filename_new=part(filedir_all,1:length(filedir_all)-4);
    filename_new=strcat([filename_new, '_cT_vs_lambda']);
    filename_new=strcat([filename_new, version]);
    xs2pdf(0,filename_new);
    xs2pdf(gcf(),filename_new);
end

/////////////// PLOT AUSWERTUNG Leistungsbeiwert über Lambda ///////////////

// P=rho/2*a*v1^3*cp
//cp=P/(0.5*rho*A*v_1^3)

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

a=gca(); // get the handle of the current axes
f=get("current_figure");
//a.grid=[1 1];
a.font_size=4; //set the tics label font size
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 4;
a.axes_visible="on"; // makes the axes visible
//      //a.L_Mr_v1_RPMm_RPMt_bounds=[0,0,0;550,10,1]; //set the boundary values for the x, y and z coordinates.

if savefile==1 then 
    filename_new=part(filedir_all,1:length(filedir_all)-4);
    filename_new=strcat([filename_new, '_cp_vs_lambda']);
    filename_new=strcat([filename_new, version]);
    xs2pdf(0,filename_new);
    xs2pdf(gcf(),filename_new);
end


//////////////////////////// PLOT AUSWERTUNG ALLG ///////////////

scf(10); clf();
f=get("current_figure");
f.figure_size=[800,1000]

Gen_RPM=Gen_RPM*26/25;

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
//xlabel ("$time [s]$")

a=gca(); // get the handle of the current axes
a.grid=[1 1];
a.font_size=4; //set the tics label font size
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 4;
a.axes_visible="on"; // makes the axes visible
a.tight_limits="off";
//a.data_bounds=[0,0,0;1200,250,1]; // for data 19
a.data_bounds=[0,0,0;700,180,1]; // for data 10


subplot(3,1,2)
plot(Seconds,M_ges,"thickness",2)

ylabel ("$T_{tot}\ [Nm]$")
//xlabel ("$time [s]$")

a=gca(); // get the handle of the current axes
f=get("current_figure");
//    f.figure_size=[800,700]
a.grid=[1 1];
a.font_size=4; //set the tics label font size
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 4;
a.axes_visible="on"; // makes the axes visible
a.tight_limits="off";
//a.data_bounds=[0,-4,0;1200,3,0]; // for data 19
a.data_bounds=[0,-1,0;700,2,0]; // for data 10


//subplot(4,1,3)
//plot(Seconds,P_ges,"thickness",2)
////    plot(Seconds,P_Rotor,'k',"thickness",2)
//
//set(gca(),"grid",[1 1])
//ylabel ("$P_{tot}\ [W]$")
//ylabel ("$P_{tot}\ [W]$")
//
//a=gca(); // get the handle of the current axes
//f=get("current_figure");
////    f.figure_size=[800,700]
////a.grid=[1 1];
//a.font_size=4; //set the tics label font size
//a.title.font_size=4;
//a.x_label.font_size=4;
//a.y_label.font_size=4;
//l.font_size = 4;
//a.axes_visible="on"; // makes the axes visible
//a.tight_limits="off";
//a.data_bounds=[0,-1,0;700,2,0]; // for data 10



subplot(3,1,3)
plot(Seconds,v1_new,'r',"thickness",2)
plot(Seconds,lambda,'k',"thickness",2)

l=legend([...
'$v_1$';...
'$\lambda$';...
],3);


ylabel ("$v_1\ [m/s],\ \lambda [1]$")
xlabel ("$time [s]$")

a=gca(); // get the handle of the current axes
f=get("current_figure");
a.grid=[1 1];
a.font_size=4; //set the tics label font size
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 4;
a.axes_visible="on"; // makes the axes visible
a.tight_limits="off";
//a.data_bounds=[0,0,0;1200,6,0]; // for data 19
a.data_bounds=[0,0,0;700,7,0]; // for data 10


if savefile==1 then
    filename_new=part(filedir_all,1:length(filedir_all)-4);
    filename_new=strcat([filename_new, '_Auswertung_allg_MuP_4']);
    filename_new=strcat([filename_new, version]);
    xs2pdf(0,filename_new);
    xs2pdf(gcf(),filename_new);
end
