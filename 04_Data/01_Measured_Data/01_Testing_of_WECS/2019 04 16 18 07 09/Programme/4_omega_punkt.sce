clear
clc

// Auswerten der Messdaten vom Arduino Serial Monitor

//path="E:\P\TubCloud\Shared\Masterarbeit\"; // Für Avia
path="C:\Users\J B\tubcloud\Module\Masterarbeit\" // Für Julian


filedir_all="Testen\Daten_bearbeitet\2019 04 16 18 07 09\2019 04 16 18 07 09 _all.txt";

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

////////////////////////////////////////

omega=RPM_Turb*2*%pi/60; // [1/s]
h=2; //[s] Schrittweite zur Bilung der zeitlichen Ableitung 

//////////////// Berechnung der Winkelbeschleunigung als Funktion der Zeit////////////
omega_punkt=%nan*zeros(Seconds); // 

for x=1+h:length(Seconds)-h // jeder Schritt (x) wird einzeln berechnet
    x_1=find(abs(Seconds-(Seconds(x)-h))<0.1,1); //Schauen ob es die gesuchte Sekunde gibt
    x_2=find(abs(Seconds-(Seconds(x)+h))<0.1,1);

    if x_1==[] then //Wenn keine Daten vorhande werden die Daten interpoliert
        
        [a,x_1_min]=min(abs(Seconds-(Seconds(x)-h))); //Vom nähesten Abstand zur gesuchten Zeit 
        
        if ((Seconds(x)-h)-Seconds(x_1_min))<0 then //wenn x_1_min rechts von s(x)-h dann nach links verschieben 
            x_1_min=x_1_min-1;
        end
        omega_1=omega(x_1_min)+(omega(x_1_min+1)-omega(x_1_min))*((Seconds(x)-h)-Seconds(x_1_min)); //interpolation
        
    else 
        omega_1=omega(x_1);
    end
    
    if x_2==[] then //Wenn keine Daten vorhande werden die Daten interpoliert
        
        [a,x_2_min]=min(abs(Seconds-(Seconds(x)+h))); // Vom nähesten Abstand zur gesuchten Zeit
        
        if ((Seconds(x)+h)-Seconds(x_2_min))<0 then  //wenn x_2_min rechts von x+h nach links verschieben
            x_2_min=x_2_min-1;
        end
        omega_2=omega(x_2_min)+(omega(x_2_min+1)-omega(x_2_min))*((Seconds(x)+h)-Seconds(x_2_min)); //interpolation
        
    else 
        omega_2=omega(x_2);
    end

        omega_punkt(x)=(omega_2-omega_1)/(2*h); // Berechnung der Ableitung mit zentralen Differenzenquotienten

end


    lambda=RPM_Turb*2*%pi./(60.*v1_new);
    
    
figure
subplot(2,1,1)
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

subplot(4,1,3)
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

subplot(4,1,4)
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



//filename_new=part(filedir_all,1:length(filedir_all)-8);
//filename_new=strcat([filename_new, '_auswertung_Momente']);
//xs2pdf(0,filename_new);
//xs2pdf(gcf(),filename_new);
