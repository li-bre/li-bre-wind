// Model of System of the Siumlation tool that communicates with the Arduino...
// to test the MPPT algorithm
clear
close

omega_mat=[];
y_Power_mat=[];
legend_str=[];
legend_str2=[];

colormat=[[0 0.9 0.5];[0.75 0 0.75];[0 0 0];[0.25 0.75 1];[1 0 0];[0.75 0.5 0];[0.5 0 0.5];[0 0 0.6];[0 0.5 0]];

scf(0); clf();
f=get("current_figure");
f.figure_size=[1200,800];

scf(1); clf();
f=get("current_figure");
f.figure_size=[800,600];

for i=3:8
    scf(0)
    END=0;
    data=0;
    D=0;
    Duty=0;
    v1=i;
    omega_max=255*v1/5;
    change=0;
    Verz_fak=0.05;

    rho=1.4;
    R=0.75;
    H=1.2;
    A=2*R*H;

    verz_fak2=0.7;
    Verz_x1=sin(verz_fak2)+rand()*verz_fak2;
    Verz_x2=%pi-asin(verz_fak2)-rand()*verz_fak2; 
    Verzerrer=sin(linspace(Verz_x1,Verz_x2,256))-0.2;
    Verzerrer=Verzerrer+rand([Verzerrer])*Verz_fak;

    omega_stern_vec=[];
    Power_stern_vec=[];
    i_stern_vec=[];

    y_Power_vec=zeros(1,256);
    x_D=255:-1:0;
    x_omega=(255-x_D)*v1/5;
    x_omega_max=255*v1/5;
    x_c_p=(255*v1/5*x_omega.^2-x_omega.^3);
    c_p_norm=1/max(x_c_p);
    x_c_p=x_c_p*0.35*c_p_norm;
    x_lambda=(x_omega*2*%pi*R)/(60*v1);
    y_Power=x_c_p*0.5*rho*v1^3*A.*Verzerrer;
    y_Voltage=linspace(12,13,256);
    y_Current=y_Power./y_Voltage;


    Duty=10:30:160;
    duty_length=length(Duty);
    omega=x_omega(255-Duty);
    omega_mat=[omega_mat;omega];
    y_Power_mat=[y_Power_mat; y_Power(255-Duty)];
    plot(x_omega,y_Power,'color',colormat(i-2,:),"thickness",2)
    legend_str=[legend_str strcat(['$v_1=' string(i) '\ m/s$'])];

    scf(1);
    plot(x_omega,Verzerrer,'color',colormat(i-2,:),"thickness",2)

end
xlabel ("$n_{turb}\ [RPM]$")
ylabel ("$\eta_{turb,O}\ [W]$")
l=legend(legend_str,4)
a=gca();
f=get("current_figure");
a.grid=[1 1];
a.font_size=4;
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 3;
a.axes_visible="on";
filename='eta_turbO';
xs2pdf(0,filename);
xs2pdf(gcf(),filename);

scf(0);
for i=1:duty_length
    plot(omega_mat(:,i),y_Power_mat(:,i),'color',colormat(i,:),'linest','--',"thickness",2)
    legend_str2=[legend_str2 strcat(['$D=' string(Duty(i)) '/255$'])];
end

xlabel ("$n_{turb}\ [RPM]$")
ylabel ("$P_2\ [W]$")

l=legend([legend_str legend_str2],2)

a=gca(); // get the handle of the current axes
f=get("current_figure");
a.grid=[1 1];
a.font_size=4; //set the tics label font size
a.title.font_size=4;
a.x_label.font_size=4;
a.y_label.font_size=4;
l.font_size = 3;
a.axes_visible="on"; // makes the axes visible

filename='scilab_model_of_system_verz';
xs2pdf(0,filename);
xs2pdf(gcf(),filename);
