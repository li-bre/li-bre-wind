clear
clc

// Auswerten der Messdaten vom Arduino Serial Monitor

//path="E:\P\TubCloud\Shared\Masterarbeit\"; // Für Avia
//path="C:\Users\J B\tubcloud\Module\Masterarbeit\" // Für Julian
path="D:\Stuff\noodlz\TU\Module\Masterarbeit" // Für Julian 2


filedir_all="\2019 04 16 18 07 09\2019 04 16 18 07 09 _all.txt";

filedir_all=strcat([path,filedir_all]);

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

omega=RPM_Turb*2*%pi/60;

////////////////////////////////////////
x=86
h=2

omega_punkt2=%nan*zeros(Seconds);
for x=1:length(Seconds)
    x_2=find(abs(Seconds-(Seconds(x)+h))<0.1,1);
    x_1=find(abs(Seconds-(Seconds(x)-h))<0.1,1);
    omega_punkt2(x)=(omega(x_2)-omega(x_1))/(Seconds(x_2)-Seconds(x_1));
end

Seconds(x_1)
Seconds(x_2)

//figure
//plot(omega_punkt2)

omega_punkt=%nan*zeros(Seconds);
j=1;
k=1;
for x=1+h:length(Seconds)-h
    x_1=find(abs(Seconds-(Seconds(x)-h))<0.1,1);
    x_2=find(abs(Seconds-(Seconds(x)+h))<0.1,1);

    if x_1==[] then
        no_x1(j)=x;
        j=j+1;
        
        [a,x_1_min]=min(abs(Seconds-(Seconds(x)-h)))
        if ((Seconds(x)-h)-Seconds(x_1_min))<0 then  //wenn position des minimalen abstandes links von x-h
            omega_1=omega(x_1_min)+(omega(x_1_min+1)-omega(x_1_min))*((Seconds(x)-h)-Seconds(x_1_min)) //interpolation von links
        elseif ((Seconds(x)-h)-Seconds(x_1_min))>0 then //wenn position des minimalen abstandes rechts von x-h
            omega_1=omega(x_1_min)+(omega(x_1_min+1)-omega(x_1_min))*((Seconds(x)-h)-Seconds(x_1_min)) //interpolation von links!!!!!!!!!!!!!!!!!!!!!!!!!
        end
    else 
        omega_1=omega(x_1);
    end
    
    if x_2==[] then
        no_x2(k)=x;
        k=k+1;
        
        [a,x_2_min]=min(abs(Seconds-(Seconds(x)+h)))
        if (Seconds(x_2_min)-(Seconds(x)+h))<0 then  //wenn position des minimalen abstandes links von x+h
            omega_2=omega(x_2_min)+(omega(x_2_min+1)-omega(x_2_min))*((Seconds(x)+h)-Seconds(x_2_min)) //interpolation von links
        elseif ((Seconds(x)-h)-Seconds(x_1_min))>0 then //wenn position des minimalen abstandes rechts von x-h
            omega_2=omega(x_2_min)+(omega(x_2_min+1)-omega(x_2_min))*((Seconds(x)+h)-Seconds(x_2_min)) //interpolation von links!!!!!!!!!!!!!!!!!!!!!!!!!!!
        end
    else 
        omega_2=omega(x_2);
    end

        omega_punkt(x)=(omega_2-omega_1)/(2*h);

end


//Rotormomentberechnung
    //allgemeine Daten
    rho=2700.00;//[kg/m³]
    V_Strebe=0.000245;//[m³]
    V_HS=0.000055;//[m³]
    m_blatt=3.86;// [kg]
    m_Strebe=0.6615;// [kg]
    m_HS=0.1485;// [kg]
    r=0.75;// [m]
    
    //Berechnungen
    J_rotor=3*(m_blatt*r^2+(2*m_Strebe)*(r/2)^2+(2*m_HS)*(2*r/3)^2);
    M_Freilauf=0.075;
    M_Rotor=J_rotor*omega_punkt-M_Freilauf;
//    J_rotor*omega_punkt=M_Rotor+M_Freilauf
//    M_Rotor=J_rotor*omega_punkt-M_Freilauf

    lambda=RPM_Turb*2*%pi./(60.*v1_new);
    Data=[lambda M_Rotor v1_new MS_RPM RPM_Turb];
    
    
    // Nur die Daten bei denen MS_RPM Ziel erreicht ist
    x_full_MS_RPM=find(abs(Data(:,4)-median(Data(:,4)))<3); //Data(:,4)=MS_RPM
    Data=Data(x_full_MS_RPM,:);
    
    // Nur die Daten bei denen MS_RPM nicht gleich rotor RPM Ziel erreicht ist
    x_M_schneller_T=find((Data(:,4)-Data(:,5))>3); //Data(:,5)=RPM_Turb
    Data=Data(x_M_schneller_T,:);
    
    
//    // Nur die Daten bei denen MS_RPM Ziel erreicht ist
//    x_full_MS_RPM=find(abs(MS_RPM-median(MS_RPM))<3);
//    Data=Data(x_full_MS_RPM,:);
//    
//    // Nur die Daten bei denen MS_RPM nicht gleich rotor RPM Ziel erreicht ist
//    x_M_schneller_T=find((MS_RPM-RPM_Turb)>3);
//    Data=Data(x_M_schneller_T,:);
    
    
    Data_sort=gsort(Data,'lr','i');
    
//    for i=1:10
//        Dat_v=find(abs(Data(:,3)-i)<0.5);
//        Data_v{1:length(Dat_v),i}=Dat_v';
//    end
//    Data_v(find(Data_v==0))=%nan;
    
    Data_v1=find(abs(Data(:,3)-1)<0.5);
    Data_v2=find(abs(Data(:,3)-2)<0.5);
    Data_v3=find(abs(Data(:,3)-3)<0.5);
    Data_v4=find(abs(Data(:,3)-4)<0.5);
    Data_v5=find(abs(Data(:,3)-5)<0.5);
    Data_v6=find(abs(Data(:,3)-6)<0.5);
    Data_v7=find(abs(Data(:,3)-7)<0.5);
    Data_v8=find(abs(Data(:,3)-8)<0.5);
    Data_v9=find(abs(Data(:,3)-9)<0.5);
    Data_v10=find(abs(Data(:,3)-10)<0.5);
    
    figure
    plot(Data(Data_v4,1),Data(Data_v4,2),'xr')
    plot(Data(Data_v5,1),Data(Data_v5,2),'xb')
    plot(Data(Data_v6,1),Data(Data_v6,2),'xk')
    plot(Data(Data_v7,1),Data(Data_v7,2),'xg')
    plot(Data(Data_v8,1),Data(Data_v8,2),'xc')
    
    set(gca(),"grid",[1 1])
    ylabel ("$M_{Rotor}\ [Nm]$")
    xlabel ("$\lambda\ [1]$")
    
    a=gca(); // get the handle of the current axes
    f=get("current_figure");
    f.figure_size=[800,700]
    //a.grid=[1 1];
    a.font_size=4; //set the tics label font size
    a.title.font_size=4;
    a.x_label.font_size=4;
    a.y_label.font_size=4;
    l.font_size = 3;
    a.axes_visible="on"; // makes the axes visible
    //a.data_bounds=[0,0,0;550,10,1]; //set the boundary values for the x, y and z coordinates.


figure
subplot(3,1,1)
plot(Seconds,RPM_Turb)
plot(Seconds,MS_RPM,'k')
plot(Seconds,Gen_RPM,'g')
plot(Seconds,omega_punkt*500,'r')
set(gca(),"grid",[1 1])
ylabel ("RPM [1]")

a=gca(); // get the handle of the current axes
f=get("current_figure");
f.figure_size=[800,700]
//a.grid=[1 1];
a.font_size=4; //set the tics label font size
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 3;
a.axes_visible="on"; // makes the axes visible
//a.data_bounds=[0,0,0;550,10,1]; //set the boundary values for the x, y and z coordinates.

subplot(6,1,5)
plot(Seconds,v1_new)
set(gca(),"grid",[1 1])
ylabel ("$v_1\ [m/s]$")

a=gca(); // get the handle of the current axes
f=get("current_figure");
f.figure_size=[800,700]
//a.grid=[1 1];
a.font_size=4; //set the tics label font size
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 3;
a.axes_visible="on"; // makes the axes visible
//a.data_bounds=[0,0,0;550,10,1]; //set the boundary values for the x, y and z coordinates.

subplot(6,1,6)
plot(Seconds,lambda)
set(gca(),"grid",[1 1])
ylabel ("$\lambda [1]$")

a=gca(); // get the handle of the current axes
f=get("current_figure");
f.figure_size=[800,700]
//a.grid=[1 1];
a.font_size=4; //set the tics label font size
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 3;
a.axes_visible="on"; // makes the axes visible
//a.data_bounds=[0,0,0;550,10,1]; //set the boundary values for the x, y and z coordinates.


subplot(3,1,2)
plot(Seconds,M_Rotor)
set(gca(),"grid",[1 1])
ylabel ("$M_{Rotor}\ [Nm]$")

a=gca(); // get the handle of the current axes
f=get("current_figure");
f.figure_size=[800,700]
//a.grid=[1 1];
a.font_size=4; //set the tics label font size
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 3;
a.axes_visible="on"; // makes the axes visible
//a.data_bounds=[0,0,0;550,10,1]; //set the boundary values for the x, y and z coordinates.



//filename_new=part(filedir_all,1:length(filedir_all)-8);
//filename_new=strcat([filename_new, '_auswertung_Momente']);
//xs2pdf(0,filename_new);
//xs2pdf(gcf(),filename_new);
