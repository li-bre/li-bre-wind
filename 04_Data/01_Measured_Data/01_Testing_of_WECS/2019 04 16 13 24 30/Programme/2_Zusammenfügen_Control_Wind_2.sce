clear 
clc

// Auswerten der Messdaten vom Arduino Serial Monitor
filedir_w="C:\Users\J B\tubcloud\Module\Masterarbeit\Testen\Daten_bearbeitet\2019 04 16 13 24 30\2019 04 16 13 24 30_wind2_v2.txt"; //Nur _v2.txt Daten
filedir_c="C:\Users\J B\tubcloud\Module\Masterarbeit\Testen\Daten_bearbeitet\2019 04 16 13 24 30\2019 04 16 13 24 30.txt";

///////////////////// Control Daten Einlesen /////////////////////////

[Data_c,text_c] = fscanfMat(filedir_c);
Datevec_c=Data_c(:,1:6);
Datenum_c=datenum(Datevec_c);
Seconds_c=(Datenum_c-Datenum_c(1))*24*3600;

text_edit=strindex(text_c,'*10^6');
text_c_work=strcat([part(text_c,[1:text_edit-1]) '_e6' part(text_c,[text_edit+5:length(text_c)]) ]);

text_edit=strindex(text_c_work,'Reason');
text_c_work=strcat([part(text_c_work,[1:text_edit]) part(text_c_work,[text_edit+6:length(text_c_work)]) ]);

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

for i=7:size(header_c,1)
    str_c=strcat([header_c(i) '=Data_c(:,i);']);
    execstr(str_c);
end

////////////////////////// WInd Daten Einlesen /////////////////////////

[Data_w,text_w] = fscanfMat(filedir_w);
Datevec_w=Data_w(:,1:6);
Datenum_w=datenum(Datevec_w);
Seconds_w=(Datenum_w-Datenum_w(1))*24*3600;

figure
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

for i=1:length(Datenum_c)
    match(i)=find (abs(Datenum_w-Datenum_c(i))<(0.5/(24*3600)));
end
match(i+1)=0;
match(i+1)=[];


No_match=find(match==0);
match(No_match)=length(v1_new);


find (abs(Datenum_w-Datenum_c(140))<(0.5/(24*3600)))
//Datevec_c(9,:)
//Datevec_w(29,:)
//Datevec_c(i,:)
//Datevec_w(match,:)


text_all=strcat([text_c_work ' v1_new RPM_Turb']);
Data_all=[Data_c v1_new(match) RPM_Turb(match)];

figure
plot(Seconds_c,RPM_Turb(match))
plot(Seconds_c,MS_RPM,'r')
plot(Seconds_c,Gen_RPM,'k')

//////////////////// ABSPEICHERN /////////////////////////
filedir_neu=part(filedir_c,1:length(filedir_c)-4)
filedir_neu=strcat([filedir_neu, '_all_2.txt']);

fprintfMat(filedir_neu, Data_all, "%.3f", text_all);
