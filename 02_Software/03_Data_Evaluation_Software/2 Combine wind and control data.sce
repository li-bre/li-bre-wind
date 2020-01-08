// Combining data from measurement system I (Control data) and II (wind data)
clear 
clc

filedir_w="C:\Users\J B\tubcloud\Module\Masterarbeit\Testen\Daten_bearbeitet\2019 05 12 11 58 23\2019 05 12 11 58 23_wind_v2_1.txt"; //only _v2.txt Daten
filedir_c="C:\Users\J B\tubcloud\Module\Masterarbeit\Testen\Daten_bearbeitet\2019 05 12 11 58 23\2019 05 12 11 58 23.txt";

///////////////////// read Control Data /////////////////////////
[Data_c,text_c] = fscanfMat(filedir_c);
Datevec_c=Data_c(:,[4:6 1:3]);
Datenum_c=datenum(Datevec_c);
Seconds_c=(Datenum_c-Datenum_c(1))*24*3600;
text_edit=strindex(text_c,'*10^6');
text_c_work=strcat([part(text_c,[1:text_edit-1]) '_e6' part(text_c,[text_edit+5:length(text_c)]) ]);
text_edit=strindex(text_c_work,'Reason');
text_c_work=strcat([part(text_c_work,[1:text_edit]) part(text_c_work,[text_edit+6:length(text_c_work)]) ]);

////////////////////// Fill gaps longer than 5 sec in Control Data //////
Datenum_c_work=Datenum_c;
Data_c_work=Data_c(:,4:size(Data_c,2));
Data_c_work(:,1:3)=Data_c(:,4:6);
Data_c_work(:,4:6)=Data_c(:,1:3);

////////////////////////Extra time in the end/////////////////
Datenum_c_work(length(Datenum_c_work)+1)=...
Datenum_c_work(length(Datenum_c_work))+360/(24*60*60);  //Fill in seconds here
Data_c_work(length(Datenum_c_work),:)=%nan;             //Fill gaps with Nan
Data_c_work(length(Datenum_c_work),1:6)=...
datevec(Datenum_c_work(length(Datenum_c_work)));
Seconds_c_work=(Datenum_c_work-Datenum_c_work(1))*24*3600;
Seconds_c_dt=Seconds_c_work(2:length(Seconds_c_work))-Seconds_c_work(1:length(Seconds_c_work)-1);
c_dt_gap=find(Seconds_c_dt>1.1);

for i=length(c_dt_gap):-1:1
    Datenum_c_gapfill=Datenum_c_work(c_dt_gap(i)):1/(24*60*60):Datenum_c_work(c_dt_gap(i)+1); //create data each second
    Datenum_c_gapfill=Datenum_c_gapfill';
    Datenum_c_gapfill(1)=[];
    Datenum_c_gapfill(length(Datenum_c_gapfill))=[];
    length_gap=length(Datenum_c_gapfill);
    length_data=length(Datenum_c_work);
    Datenum_c_work((c_dt_gap(i)+1+length_gap):length_data+length_gap)=...
    Datenum_c_work((c_dt_gap(i)+1):length_data);
    Data_c_work((c_dt_gap(i)+1+length_gap):length_data+length_gap,:)=...
    Data_c_work((c_dt_gap(i)+1):length_data,:);
    Datenum_c_work(c_dt_gap(i)+1:c_dt_gap(i)+length_gap)=...
    Datenum_c_gapfill(1:length_gap);
    Data_c_work(c_dt_gap(i)+1:c_dt_gap(i)+length_gap,:)=%nan;
    Data_c_work(c_dt_gap(i)+1:c_dt_gap(i)+length_gap,1:6)=datevec(Datenum_c_gapfill(1:length_gap));
end

Datevec_neu=Data_c_work(:,1:6);
Datenum_neu=datenum(Datevec_neu);

Date_corr=find(Datevec_neu(:,6)>59.5)
Datevec_neu(Date_corr,6)=0;
Datevec_neu(Date_corr,5)=Datevec_neu(Date_corr,5)+1;

Date_corr=find(Datevec_neu(:,5)>59.5)
Datevec_neu(Date_corr,5)=0;
Datevec_neu(Date_corr,4)=Datevec_neu(Date_corr,4)+1;

Data_c_work(:,1:6)=Datevec_neu;

////////////////////// continue processing control data //////
Delimiter_c=strindex(text_c_work,' ');
for i=1:length(Delimiter_c)+1
    if i==1 then
        header_c(1)=part(text_c_work,[1:Delimiter_c(i)]);
    elseif i == length(Delimiter_c)+1 then
        header_c(length(Delimiter_c)+1)=part(text_c_work,[Delimiter_c(i-1):length(text_c_work)]);
    else
        header_c(i)=part(text_c_work,[Delimiter_c(i-1)+1:Delimiter_c(i)]);
    end
end

header_c(1:3)=[];

for i=10:size(header_c,1)
    str_c=strcat([header_c(i) '=Data_c_work(:,i);']);
    execstr(str_c);
end
text_c_work=part(text_c_work,20:length(text_c_work));

////////////////////////// read wind data /////////////////////////

[Data_w,text_w] = fscanfMat(filedir_w);
Datevec_w=Data_w(:,1:6);
Datenum_w=datenum(Datevec_w);
Seconds_w=(Datenum_w-Datenum_w(1))*24*3600;

figure;
plot (Datenum_c,'r')
plot (Datenum_w)

Delimiter_w=strindex(text_w,' ');
for i=1:length(Delimiter_w)+1
    if i==1 then
        header_w(1)=part(text_w,[1:Delimiter_w(i)]);
    elseif i == length(Delimiter_w)+1 then
        header_w(length(Delimiter_w)+1)=part(text_w,[Delimiter_w(i-1):length(text_w)]);
    else
        header_w(i)=part(text_w,[Delimiter_w(i-1)+1:Delimiter_w(i)]);
    end
end
for i=7:size(header_w,1)
    str_w=strcat([header_w(i) '=Data_w(:,i);']);
    execstr(str_w);
end

////////////////////// Matching //////////////////////////

v1_new(length(v1_new)+1)=%nan;
RPM_Turb(length(RPM_Turb)+1)=%nan;
for i=1:length(Datenum_c_work)
    match(i)=find (abs(Datenum_w-Datenum_c_work(i))<(0.5/(24*3600)),1);
end
match(i+1)=0;
match(i+1)=[];
No_match=find(match==0);
match(No_match)=length(v1_new);
text_all=strcat([text_c_work ' v1_new RPM_Turb']);
Data_all=[Data_c_work v1_new(match) RPM_Turb(match)];
Seconds_c_work=(Datenum_c_work-Datenum_c_work(1))*24*3600;

figure;
plot(RPM_Turb(match),'-x')
plot(MS_RPM,'r')
plot(Gen_RPM,'k')

///////////////////// MS RPM FILTER /////////////////
// Delete erroneous n_motor datapoints
x_MS_RPM_erreicht_start=400; // Fill in correct times for when the set n_motor is reached
x_MS_RPM_erreicht_stop=600;  // and when it stops
x_MS_RPM_ausreiser=find(MS_RPM(x_MS_RPM_erreicht_start:x_MS_RPM_erreicht_stop)<median(MS_RPM)-20);
x_MS_RPM_ausreiser=x_MS_RPM_ausreiser+x_MS_RPM_erreicht_start-1;
MS_RPM_work=MS_RPM;
MS_RPM_work(x_MS_RPM_ausreiser)=%nan;
x_MS_RPM_nonan=find(~isnan(MS_RPM_work));
MS_RPM_work(1:1517)=interpln([Datenum_neu(x_MS_RPM_nonan)';MS_RPM_work(x_MS_RPM_nonan)'],Datenum_neu(1:1517))';
Data_all(:,16)=MS_RPM_work;

figure;
plot(RPM_Turb(match),'-x')
plot(MS_RPM_work,'r')
plot(Gen_RPM,'k')

//////////////////// ABSPEICHERN /////////////////////////
filedir_neu=part(filedir_c,1:length(filedir_c)-4);
filedir_neu=strcat([filedir_neu, '_all_v3_2.txt']);

fprintfMat(filedir_neu, Data_all, "%.3f", text_all);
