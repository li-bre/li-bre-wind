// Auswerten der Messdaten vom Arduino Serial Monitor

path="E:\P\TubCloud\Shared\Masterarbeit\"; // Für Avia
//path="C:\Users\J B\tubcloud\Module\Masterarbeit\" // Für Julian

filedir_all="Testen\Daten_bearbeitet\2019 04 16 13 00 26\2019 04 16 13 00 26_all.txt";

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


figure
subplot(2,1,1)
plot(Seconds,RPM_Turb)
plot(Seconds,MS_RPM,'k')
plot(Seconds,Gen_RPM,'r')
set(gca(),"grid",[1 1])
ylabel ("RPM [1]")

subplot(4,1,3)
plot(Seconds,v1_new)
set(gca(),"grid",[1 1])
ylabel ("v1 [m/s]")

subplot(4,1,4)
plot(Seconds,RPM_Turb*2*%pi./(60.*v1_new))
set(gca(),"grid",[1 1])
ylabel ("$\lambda$")
//


filename_new=part(filedir_all,1:length(filedir_all)-8);
filename_new=strcat([filename_new, '_auswertung_allg']);
xs2pdf(0,filename_new);
xs2pdf(gcf(),filename_new);
