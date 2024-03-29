// Data preparation of measurement system II (wind data)
clear
clc

Date=[2019 05 12]; //Date of measurement
windfactor=1;
timedifference=0;
RPM_Factor=1;
filedir="C:\Users\J B\tubcloud\Module\Masterarbeit\Testen\Daten_bearbeitet\2019 05 12 11 58 23\2019 05 12 11 58 23_wind.txt";

[Data,text] = fscanfMat(filedir);
Datevec=Data(:,1:3);
Datevec(:,4:6)=Datevec;
Datevec(:,1)=Date(1);
Datevec(:,2)=Date(2);
Datevec(:,3)=Date(3);

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

NAN_RPM=find(RPM==999);
RPM(NAN_RPM)=%nan;
NAN_RPM=find(RPM==999.9);
RPM(NAN_RPM)=%nan;

//////////////////// Data preparation //////////////////////////
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

lambda_neu=interpln([Datenum_work';lambda'],Datenum_neu);
lambda_neu=lambda_neu';

Data_neu=[Datevec_neu RPM_neu v1_neu];
text_neu=['Year Month Day Hour Minute Second RPM_Turb v1_new']
//////////////////// Save new file /////////////////////////
filedir_neu=part(filedir,1:length(filedir)-4)
filedir_neu=strcat([filedir_neu, '_v2.txt']);
fprintfMat(filedir_neu, Data_neu, "%.2f", text_neu);
