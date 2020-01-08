// Siumlation tool that communicates with the Arduino...
// to test the MPPT algorithm

clear
close
port='COM7';
colormat=[[0 0.9 0.5];[0.75 0 0.75];[0 0 0];[0.25 0.75 1];[1 0 0];[0.75 0.5 0];[0.5 0 0.5];[0 0 0.6];[0 0.5 0];[0 0.9 0.5];[0.75 0 0.75];[0 0 0];[0.25 0.75 1];[1 0 0];[0.75 0.5 0];[0.5 0 0.5];[0 0 0.6];[0 0.5 0];[0 0.9 0.5];[0.75 0 0.75];[0 0 0];[0.25 0.75 1];[1 0 0];[0.75 0.5 0];[0.5 0 0.5];[0 0 0.6];[0 0.5 0]];
jj=1;
END=0;
data=0;
D=0;
Duty=0;
v1=7;
i=0;
omega_max=255*v1/5;
change=0;
Verz_fak=0.05;
rho=1.4;
A=1.2*1.5;
omega_stern_vec=[];
Power_stern_vec=[];
i_stern_vec=[];
y_Power_vec=zeros(1,256);
// Manipulate P_turb
verz_fak2=0.6;
Verz_x1=sin(verz_fak2)+rand()*verz_fak2;
Verz_x2=%pi-asin(verz_fak2)-rand()*verz_fak2;
Verzerrer=sin(linspace(Verz_x1,Verz_x2,256))-0.2;
Verzerrer=Verzerrer+rand([Verzerrer])*Verz_fak;

//      Start serial communication
Serial_communication=openserial(port,"9600,n,8,1");
if Serial_communication == -1 then
    disp("USB not working");
else
    disp("USB OK");
end

scf(0); clf();
f=get("current_figure");
f.figure_size=[1200,800]

//Start of Working loop
while END==0

//      Read data from Arduino
    readserial(Serial_communication);
    sleep(200);
    while readserial(Serial_communication,1) ~= "D"
    end
    sleep(50);

    D=readserial(Serial_communication,3);
    if part(D,3)=="X" then
        D=part(D,1:2);
    end
    Duty=strtod(D);


    while readserial(Serial_communication,1) ~= "E"
    end
    kopt=readserial(Serial_communication,5);
    kopt=strtod(kopt)/1000000;

    while readserial(Serial_communication,1) ~= "G"
    end
    omega_stern=readserial(Serial_communication,6);
    omega_stern=strtod(omega_stern);
    
    while readserial(Serial_communication,1) ~= "S"
    end
    MODE=readserial(Serial_communication,5);
    MODE=strtod(MODE);

    while readserial(Serial_communication,1) ~= "V"
    end
    DeltaV1=readserial(Serial_communication,1);
    DeltaV1=strtod(DeltaV1);

    disp("DeltaV1, kopt, omega_stern, MODE");
    disp([DeltaV1 kopt*1000000 omega_stern MODE]);

    disp("change und i -------------------------");
    disp([change i]);

    // Decide if wind speed changes
    
    if MODE==2 then
        i_stern_vec(length(i_stern_vec)+1)=i;
        omega_stern_vec(length(omega_stern_vec)+1)=omega_stern;
        Power_stern_vec(length(Power_stern_vec)+1)=Power;
    end

    if change == 2 then
        v1=2+10*rand();
        Verz_x1=sin(verz_fak2)+rand()*verz_fak2;
        Verz_x2=%pi-asin(verz_fak2)-rand()*verz_fak2;
        Verzerrer=sin(linspace(Verz_x1,Verz_x2,256))-0.2;
        Verzerrer=Verzerrer+rand([Verzerrer])*Verz_fak;
        change=0;
    end

    if change == 1 then
        change=change+1;
    end

    // Calculate output variables

    x_D=255:-1:0;
    x_omega=(255-x_D)*v1/5;
    x_omega_max=255*v1/5;
    x_c_p=(255*v1/5*x_omega.^2-x_omega.^3);
    c_p_norm=1/max(x_c_p);
    x_c_p=x_c_p*0.35*c_p_norm;
    y_Power=x_c_p*0.5*rho*v1^3*A.*Verzerrer;
    y_Voltage=linspace(12,13,256);
    y_Current=y_Power./y_Voltage;

    omega=x_omega(255-Duty);
    omega_max=255*v1/5;
    c_p=x_c_p(255-Duty);
    Power=y_Power(255-Duty);
    Voltage=y_Voltage(255-Duty);
    Current=y_Current(255-Duty);

    omega_st=string(int(omega*1000));
    Voltage_st=string(int(Voltage*1000));
    Current_st=string(int(Current*1000));

    disp("Duty, omega, Voltage, Current, Power");
    disp([Duty omega Voltage Current Power]);

//       Send output variables to Arduino

    writeserial(Serial_communication,ascii(119)); //w
    writeserial(Serial_communication,omega_st);
    writeserial(Serial_communication,ascii(86)); //V
    writeserial(Serial_communication,Voltage_st);
    writeserial(Serial_communication,ascii(73)); //I
    writeserial(Serial_communication,Current_st);

//      For plotting

    i=i+1;
    Duty_vec(i)=Duty;
    kopt_vec(i)=kopt;
    MODE_vec(i)=MODE;
    DeltaV1_vec(i)=DeltaV1;
    omega_vec(i)=omega;
    x_omega_vec(i,:)=x_omega;
    
    Voltage_vec(i)=Voltage;
    Current_vec(i)=Current;
    Power_vec(i)=Power;
    change_vec(i)=change;
    v1_vec(i)=v1;
    y_Power_vec(i,:)=y_Power;

    if i>4 & change==0 & Power_vec(i)==Power_vec(i-4) then
        change=1;
    end

    if i>1 then
        if v1_vec(i) ~= v1_vec(i-1) then
            new_vec(jj)=i;
            legend_str=[legend_str strcat(['$v_{1,' string(jj) '}=' part(string(v1),1:4) '\ m/s$'])];
            jj=jj+1;
        end
    elseif i==1 then
        new_vec(jj)=i;
        jj=jj+1;
        legend_str=strcat(['$v_{1,1}=' string(v1) '.00\ m/s$']);
    end

    //PLOT LIVE
    plot(x_omega,y_Power,'k','color',colormat(jj,:),"thickness",2)
    if kopt~=0 & kopt_vec(i) ~= kopt_vec(i-1) then
        plot(x_omega(1:190),(kopt*x_omega(1:190).^3),'color',colormat(jj,:),"thickness",2,'linestyle','--')
    end
    if MODE==2 then
        plot(omega_stern_vec,Power_stern_vec,'rx')
    end

    Duty_vec=double(Duty_vec);
    omega_vec=double(omega_vec);
    Voltage_vec=double(Voltage_vec);
    Current_vec=double(Current_vec);
    Power_vec=double(Power_vec);
    omega_stern_vec=double(omega_stern_vec);
    Power_stern_vec=double(Power_stern_vec);

    plot(omega_vec, Power_vec,'x-')
    
end     // End of working loop

// Plot results

scf(3); clf();
f=get("current_figure");
f.figure_size=[1200,800];
for ii=1:length(new_vec)
    plot(x_omega_vec(new_vec(ii),:),y_Power_vec(new_vec(ii),:),'color',colormat(ii,:),"thickness",2)
    if (ii+1<=length(new_vec)) then
        plot(x_omega_vec(new_vec(ii+1),1:210),(kopt_vec(new_vec(ii+1))*x_omega_vec(new_vec(ii+1),1:210).^3),'color',colormat(ii,:),"thickness",2,'linestyle','--')
    end
end

plot(omega_vec,Power_vec,'color',[0 0 1],"thickness",2,'marker','x')
plot(omega_vec(1),Power_vec(1),'color',[0 0 1],"thickness",2,'marker','d','markersize',16,'linest','none')

plot(omega_stern_vec,Power_stern_vec,'color',[1 0 0],"thickness",2,'marker','x','linest','none')
for ii=1:length(omega_stern_vec)
        plot([omega_vec(i_stern_vec(ii)) omega_stern_vec(ii)],[Power_stern_vec(ii) Power_stern_vec(ii)],'color',[1 0 0],"thickness",1,'linest','--')
end

legend_str2=[];
for i=1:size(legend_str,2)-1
    legend_str2=[legend_str2 legend_str(i) strcat(['$k_{opt}(' part(legend_str(i),2:8) ')\cdot \omega_{turb}^3$']) ];
end
legend_str2=[legend_str2 legend_str(i+1)];

l=legend([legend_str2 ...
'$path\ of\ system\ states$' ...
'$starting\ point\ of \ path$' ...
'$\omega_{turb}^*$' ...
],2)

xlabel ("$n_{turb}\ [RPM]$")
ylabel ("$P_2\ [W]$")

a=gca();
f=get("current_figure");
a.grid=[1 1];
a.font_size=4;
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 4;
a.axes_visible="on";
a.data_bounds=[0,0,0;max(x_omega_vec),max(y_Power_vec),0];

filename='MPPT_simulation';
xs2pdf(0,filename);
xs2pdf(gcf(),filename);

// Before restarting the program
abort
closeserial(Serial_communication);
