clear
clc
// Auswerten der Messdaten vom Arduino Serial Monitor

Date=[2019 04 16]; //Messdatum
windfactor=1;
timedifference=18; //zeitunterschied: controltime-windtime in s
RPM_Factor=1; // Bis einschließlich 2019 04 16 13 00 26, Danach 1
filedir="C:\Users\J B\tubcloud\Module\Masterarbeit\Testen\Daten_bearbeitet\2019 04 16 19 29 08\2019 04 16 19 29 08_wind.txt";

[Data,text] = fscanfMat(filedir);
Datevec=Data(:,1:3);
Datevec(:,4:6)=Datevec;
Datevec(:,1)=Date(1);
Datevec(:,2)=Date(2);
Datevec(:,3)=Date(3);

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

for i=4:size(header,1)
    str=strcat([header(i) '=Data(:,i);']);
    execstr(str);
end

NAN_RPM=find(RPM==999);
RPM(NAN_RPM)=%nan;

//figure
//subplot(2,1,1)
//plot(Seconds,RPM)
//set(gca(),"grid",[1 1])
//ylabel ("RPM [1]")
//
//subplot(2,1,2)
//plot(Seconds,v1)
//set(gca(),"grid",[1 1])
//ylabel ("v1 [m/s]")


//////////////////// BEARBEITUNG //////////////////////////

RPM_work=RPM/RPM_Factor;
Datenum_work=Datenum+(timedifference/(24*3600));
v1_work=v1/windfactor;

Datenum_neu=Datenum_work(1):1/(24*3600):Datenum_work(size(Datenum_work,1));
Datevec_neu=datevec(Datenum_neu);

Date_corr=find(Datevec_neu(:,6)>59.5)
Datevec_neu(Date_corr,6)=0;
Datevec_neu(Date_corr,5)=Datevec_neu(Date_corr,5)+1;


Date_corr=find(Datevec_neu(:,5)>59.5)
Datevec_neu(Date_corr,5)=0;
Datevec_neu(Date_corr,4)=Datevec_neu(Date_corr,4)+1;

RPM_neu=interpln([Datenum_work';RPM_work'],Datenum_neu);
RPM_neu=RPM_neu';
v1_neu=interpln([Datenum_work';v1_work'],Datenum_neu);
v1_neu=v1_neu';

//figure
//subplot(2,1,1)
//plot(Datenum_neu,RPM_neu)
//set(gca(),"grid",[1 1])
//ylabel ("RPM [1]")
//
//subplot(2,1,2)
//plot(Datenum_neu,v1_neu)
//set(gca(),"grid",[1 1])
//ylabel ("v1 [m/s]")


Data_neu=[Datevec_neu RPM_neu v1_neu];
text_neu=['Year Month Day Hour Minute Second RPM_Turb v1_new']
//////////////////// ABSPEICHERN /////////////////////////
filedir_neu=part(filedir,1:length(filedir)-4)
filedir_neu=strcat([filedir_neu, '_v2.txt']);

fprintfMat(filedir_neu, Data_neu, "%.2f", text_neu);

