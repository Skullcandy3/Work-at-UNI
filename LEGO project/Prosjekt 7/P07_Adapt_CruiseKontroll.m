%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% P07_Adaptiv_Cruise_kontroll
%
%  % Motorer
%  - motor A
%  - motor B
%
%  % Sensorer
%  - Ultralydsensor
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
clear; close all
online = false;    % Online mot EV3 eller mot lagrede data?
plotting = false;  % Skal det plottes mens forsøket kjøres
filename = 'P07_CruisePT.mat'; % Offline modus data

if online
    mylego = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes, JoyButtons] = HentJoystickVerdier(joystick);
    
    % Ultralyd sensor 
    mySonicSensor = sonicSensor(mylego);
    
    % Motor A og B
    motorA = motor(mylego, 'A'); resetRotation(motorA);
    motorB = motor(mylego, 'B'); resetRotation(motorB);
else
    load(filename)
end

fig1 = figure;
JoyMainSwitch = 0;
k = 0;

while ~JoyMainSwitch
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                       GET TIME AND MEASUREMENT
    % Få tid og målinger fra sensorer, motorer og joystick
    % Oppdater telle variabel
    k = k + 1;
    
    if online
        if k == 1
            tic; Tid(k) = 0;
        else
            Tid(k) = toc;
        end
        scale = 100;        % Scaling av avstand målinger til meter
        Avstand(k) = double(readDistance(mySonicSensor)) * scale;
        [JoyAxes, JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1); % Trenger bare skyteknappen for å avslutte koden!
    else
        if k >= length(Tid)
            JoyMainSwitch = 1;
        end
        if plotting
            pause(0.03)
        end
    end
    
    % parametre (Kontroll bord for kjøring av Lego)
    u0_A = 0;   % Start PID verdi
    u0_B = 0;   % Start PID verdi
    Kp = 1.8; % 1.8 ved PT og 2       % start med lave verdier, typisk 0.005
    Ki = 0.8;  % 0.8 ved PT og 1    % start med lave verdier, typisk 0.005
    Kd = 0;                        % start med lave verdier, typisk 0.001
    I_max = 100;                 % Integrator begrensning max
    I_min = -100;              % Integrator begrensning min

    if k==1
        % Initialverdier
        T_s(1) = 0.05;      % nominell verdi

        % Motorens tilstander
        x1_A(1) = Avstand(1);  % posisjon lego motor A
        x2_A(1) = 0;           % hastighet lego motor A
        x1_B(1) = Avstand(1);  % posisjon lego motor B
        x2_B(1) = 0;           % hastighet lego motor B

        % Måling initiale verdier motor A
        x2_f_A(1) = 0;
        r(1) = Avstand(1);
        y_A(1) = Avstand(1);
        e_A(1) = r(1) - y_A(1);
        e_f_A(1) = e_A(1);
        u_A(1) = 0;
    
        % Måling initiale verdier motor A
        x2_f_B(1) = 0;
        y_B(1) = Avstand(1);
        e_B(1) = r(1) - y_B(1);
        e_f_B(1) = e_B(1); 
        u_B(1) = 0;

        % Initialverdi PID-regulatorens deler
        % Motor A PID-regulator
        P_A(1) = 0;       % P-del
        I_A(1) = 0;       % I-del
        D_A(1) = 0;       % D-del
        % Motor B PID-regulator
        P_B(1) = 0;       % P-del
        I_B(1) = 0;       % I-del
        D_B(1) = 0;       % D-del
    else 
        % Beregninger av tidsskritt
        T_s(k) = Tid(k)-Tid(k-1); 

        % Motorens tilstander
        % x1: posisjon plate
        % x2: endring av posisjon av plate (derivert av posisjon)
        x1_A(k) = Avstand(k);
        x2_A(k) = BakoverDerivasjon([x1_A(k-1), x1_A(k)], T_s(k));
        x1_B(k) = Avstand(k);
        x2_B(k) = BakoverDerivasjon([x1_B(k-1), x1_B(k)], T_s(k));

        % Målingen y er lavpassfiltrert vinkelhastighet
        alfa(k)  = 0.05; % Fast bestemt alfa
        x2_f_A(k) = IIR_filter(x2_f_A(k-1), x2_A(k), alfa(k));
        x2_f_B(k) = IIR_filter(x2_f_B(k-1), x2_B(k), alfa(k));
        y_A(k) = Avstand(k);
        y_B(k) = Avstand(k);

        % Referanse r(k)
        r(k) = Avstand(1);

        % Reguleringsavvik for motor A og B
        e_A(k) = r(k) - y_A(k);
        e_B(k) = r(k) - y_B(k);

        % Beregn PID for motor A
        para = [Kp, Ki, Kd, I_max, I_min, alfa(k)];
        [P_A(k), I_A(k), D_A(k), e_f_A(k)] = MinPID(I_A(k-1), e_f_A(k-1), e_A(k-1:k), T_s(k), para);

        % Beregn PID for motor B
        [P_B(k), I_B(k), D_B(k), e_f_B(k)] = MinPID(I_B(k-1), e_f_B(k-1), e_B(k-1:k), T_s(k), para);

    end
    % Beregn motor pådraget
    u_A(k) = u0_A + P_A(k) + I_A(k) + D_A(k);
    u_B(k) = u0_B + P_B(k) + I_B(k) + D_B(k);

    % Begrens motorpådraget for å unngå overbelastning
    u_A(k) = max(min(u_A(k), 50), -50);
    u_B(k) = max(min(u_B(k), 50), -50);
    
    PowerA(k) = -u_A(k);
    PowerB(k) = -u_B(k);
    
    % Start av motor og beregning av motor kraft til motoren!
    if online
        motorA.Speed = PowerA(k);
        motorB.Speed = PowerB(k);
        start(motorA);
        start(motorB);
    end
    
    if plotting || JoyMainSwitch
        subplot(3,1,1)
        hold on; 
        plot(Tid(1:k), y_A(1:k), 'b'); 
        plot(Tid(1:k), r(1:k), 'r'); 
        grid on;
        hold off;
        title('Avstand og referanse'); 
        legend('$y(k)$', '$r(k)$');
        
        subplot(3,1,2)
        hold on;
        plot(Tid(1:k), e_A(1:k), 'b');
        plot(Tid(1:k), u_A(1:k), 'g');
        grid on;
        hold off;
        title('Reguleringsavvik og P{\aa}drag u(t)'); 
        legend('$e(k)$', '$u(k)$');

        subplot(3,1,3)
        hold on;
        plot(Tid(1:k),P_A(1:k),'b-');
        plot(Tid(1:k),I_A(1:k),'r-');
       %plot(Tid(1:k),D_A(1:k),'g-'); 
        plot(Tid(1:k),u_A(1:k),'k-');
        hold off;
        grid on;
        title('Bidragene P, I og totalp{\aa}drag $u(t)$');
        xlabel('Tid [sek]');
        legend('$P-del$', '$I-del$', '$u(k)$')

        drawnow;
    end
end

% Stopp motor når den har gjort det den skal!
if online
    stop(motorA);
    stop(motorB);
end

subplot(3,1,1)
hold on; 
plot(Tid(1:k), y_A(1:k), 'b'); 
plot(Tid(1:k), r(1:k), 'r'); 
grid on;
hold off;
title('Avstand og referanse'); 
legend('$y(k)$', '$r(k)$');
        
subplot(3,1,2)
hold on;
plot(Tid(1:k), e_A(1:k), 'b');
plot(Tid(1:k), u_A(1:k), 'g');
grid on;
hold off;
title('Reguleringsavvik og P{\aa}drag u(t)'); 
legend('$e(k)$', '$u(k)$');

subplot(3,1,3)
hold on;
plot(Tid(1:k),P_A(1:k),'b-');
plot(Tid(1:k),I_A(1:k),'r-');
%plot(Tid(1:k),D_A(1:k),'g-'); 
plot(Tid(1:k),u_A(1:k),'k-');
legend('$P-del$', '$I-del$', '$u(k)$')
hold off;
grid on;
title('Bidragene P, I og totalp{\aa}drag $u(t)$');
xlabel('Tid [sek]');

    