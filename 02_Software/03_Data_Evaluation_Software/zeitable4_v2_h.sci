function omega_punkt=zeitable4_v2_h(omega,Seconds,h)

    omega_punkt=%nan*zeros(Seconds); // 
    j=1;
    k=1;
    j11=1;
    k22=1;


    for x=1+2*h:length(Seconds)-2*h // jeder Schritt (x) wird einzeln berechnet
        x_1=find(abs(Seconds-(Seconds(x)-h))<0.1,1); //Schauen ob es die gesuchte Sekunde gibt
        x_2=find(abs(Seconds-(Seconds(x)+h))<0.1,1);
        x_11=find(abs(Seconds-(Seconds(x)-2*h))<0.1,1); //Schauen ob es die gesuchte Sekunde gibt
        x_22=find(abs(Seconds-(Seconds(x)+2*h))<0.1,1);

        if x_1==[] then //Wenn nicht werden die Daten interpoliert
            no_x1(j)=x;
            j=j+1;
            [a,x_1_min]=min(abs(Seconds-(Seconds(x)-h))); //Vom nähesten Abstand zur gesuchten Zeit 
            if Seconds(x_1_min+1)==Seconds(x_1_min) then //Sonst kann Division durch 0 auftretren
                x_1_min=x_1_min+1;
            end 

            while ((Seconds(x)-h)-Seconds(x_1_min))<0  //wenn x_1_min rechts von s(x)-h dann nach links verschieben 
                x_1_min=x_1_min-1;
            end
            omega_1=omega(x_1_min)+(omega(x_1_min+1)-omega(x_1_min))/(Seconds(x_1_min+1)-Seconds(x_1_min))*((Seconds(x)-h)-Seconds(x_1_min)); //interpolation

        else 
            omega_1=omega(x_1);
        end

        if x_2==[] then
            no_x2(k)=x;
            k=k+1;
            [a,x_2_min]=min(abs(Seconds-(Seconds(x)+h))); // Vom nähesten Abstand zur gesuchten Zeit
            if Seconds(x_2_min+1)==Seconds(x_2_min) then //Sonst kann Division durch 0 auftretren
                x_2_min=x_2_min+1;
            end 

            while ((Seconds(x)+h)-Seconds(x_2_min))<0   //wenn x_2_min rechts von x+h nach links verschieben
                x_2_min=x_2_min-1;
            end
            omega_2=omega(x_2_min)+(omega(x_2_min+1)-omega(x_2_min))/(Seconds(x_2_min+1)-Seconds(x_2_min))*((Seconds(x)+h)-Seconds(x_2_min)); //interpolation

        else 
            omega_2=omega(x_2);
        end


        if x_11==[] then //Wenn nicht werden die Daten interpoliert
            no_x11(j11)=x;
            j11=j11+1;
            [a,x_11_min]=min(abs(Seconds-(Seconds(x)-2*h))); //Vom nähesten Abstand zur gesuchten Zeit 
            if Seconds(x_11_min+1)==Seconds(x_11_min) then //Sonst kann Division durch 0 auftretren
                x_11_min=x_11_min+1;
            end 

            while ((Seconds(x)-2*h)-Seconds(x_11_min))<0  //wenn x_1_min rechts von s(x)-h dann nach links verschieben 
                x_11_min=x_11_min-1;
            end
            omega_11=omega(x_11_min)+(omega(x_11_min+1)-omega(x_11_min))/(Seconds(x_11_min+1)-Seconds(x_11_min))*((Seconds(x)-2*h)-Seconds(x_11_min)); //interpolation

        else 
            omega_11=omega(x_11);
        end

        if x_22==[] then
            no_x22(k22)=x;
            k22=k22+1;
            [a,x_22_min]=min(abs(Seconds-(Seconds(x)+2*h))); // Vom nähesten Abstand zur gesuchten Zeit
            if x_22_min+1<=length(Seconds) then
                if Seconds(x_22_min+1)==Seconds(x_22_min) then //Sonst kann Division durch 0 auftretren
                    x_22_min=x_22_min+1;
                end 
                while ((Seconds(x)+2*h)-Seconds(x_22_min))<0   //wenn x_2_min rechts von x+h nach links verschieben
                    x_22_min=x_22_min-1;
                end
                omega_22=omega(x_22_min)+(omega(x_22_min+1)-omega(x_22_min))/(Seconds(x_22_min+1)-Seconds(x_22_min))*((Seconds(x)+2*h)-Seconds(x_22_min)); //interpolation
            else 
                omega_22=%nan;
            end
            
        else 
            omega_22=omega(x_22);
        end

        //        omega_punkt(x)=(omega_2-omega_1)/(2*h);
        omega_punkt(x)=1/h*(1/12*omega_11-2/3*omega_1+2/3*omega_2-1/12*omega_22);

    end

endfunction
