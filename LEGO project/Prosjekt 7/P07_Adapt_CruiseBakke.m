%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt07_Adaptiv_CruiseBakke
%
% Hensikten med programmet er å tune er regulator
% for styring av hastigheten til to motor
%
% Følgende  motorer brukes: 
%  - motor A
%  - motor B
%
%--------------------------------------------------------------------------

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%         EXPERIMENT SETUP, FILENAME AND FIGURE
clear; close all  
online = false;     % Online mot EV3 eller mot lagrede data?
plotting = false;  % Skal det plottes mens forsøket kjøres 
filename = 'P07_CruiseBakke.mat'; % Navnet på datafilen når online=0.

if online  
   mylego = legoev3('USB');
   joystick = vrjoystick(1);
   [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

   % motorer
   motorA = motor(mylego,'A');
   motorB = motor(mylego, 'B');
   motorA.resetRotation;
   motorB.resetRotation;
else
    % Dersom online=false lastes datafil.
    load(filename)
end
fig1 = figure;
drawnow

% setter skyteknapp til 0, og initialiserer tellevariabel k
JoyMainSwitch=0;
k=0;
%----------------------------------------------------------------------

% Starter stoppeklokke for å stoppe  
% Du kan også stoppe med skyteknappen som før.
duration = tic;

while ~JoyMainSwitch

    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                       GET TIME AND MEASUREMENT
    % Få tid og målinger fra sensorer, motorer og joystick
    
    % oppdater tellevariabel
    k=k+1;

    if online
        if k==1
            tic
            Tid(1) = 0;
        else
            Tid(k) = toc;
        end
        
        % motorer
        VinkelPosMotorA(k) = double(motorA.readRotation);
        VinkelPosMotorB(k) = double(motorB.readRotation);
           
        % Data fra styrestikke. Utvid selv med andre knapper og akser
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
    else
        % online=false
        % Når k er like stor som antall elementer i datavektpren Tid,
        % simuleres det at bryter på styrestikke trykkes inn.
        if k==length(Tid)
            JoyMainSwitch=1;
        end
        
        if plotting
            % Simulerer tiden som EV3-Matlab bruker på kommunikasjon 
            % når du har valgt "plotting=true" i offline
            pause(0.03)
        end
    end
    %--------------------------------------------------------------
    

    
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER

    % Stopper automatisk når t>29 sekund
    if toc(duration) > 29
        JoyMainSwitch = 1;
    end

    % parametre (Kontroll bord)
    u0_A = 4;        % Start PID verdi
    u0_B = 0;
    Kp = 0.17;          % start med lave verdier, typisk 0.005
    Ki = 1;          % start med lave verdier, typisk 0.005
    Kd = 0;          % start med lave verdier, typisk 0.001
    I_max = 100;     % Integrator begrensning max
    I_min = -100;    % Integrator begrensning min
    fart = 500;

 
    if k==1
        % Initialverdier
        T_s(1) = 0.05;      % nominell verdi

        % Motorens tilstander
        x1_A(1) = VinkelPosMotorA(1);  % posisjon lego motor A
        x2_A(1) = 0;                   % hastighet lego motor A
        x1_B(1) = VinkelPosMotorB(1); 
        x2_B(1) = 0;

        % Måling intiale verdier motor A
        x2_f_A(1) = 0;
        y_A(1) = 0;
        r(1) = fart;            % Globalt referanse så endre ikke!
        e_A(1) = r(1) - y_A(1);
        e_f_A(1) = e_A(1);
        u_A(1) = 0;

        % Måling initiale verdier motor B
        x2_f_B(1) = 0;
        y_B(1) = 0;
        e_B(1) = r(1) - y_B(1);
        e_f_B(1) = e_B(1); 
        u_B(1) = 0;

        % Initialverdi PID-regulatorens deler
        P_A(1) = 0;       % P-del
        I_A(1) = 0;       % I-del
        D_A(1) = 0;       % D-del

        P_B(1) = 0;       % P-del
        I_B(1) = 0;       % I-del
        D_B(1) = 0;       % D-del
    else 
        % Beregninger av tidsskritt
        T_s(k) = Tid(k)-Tid(k-1); 

        % Motorens tilstander
        % x1: posisjon plate
        % x2: endring av posisjon av plate (derivert av posisjon)
        x1_A(k) = VinkelPosMotorA(k);
        x2_A(k) = BakoverDerivasjon([x1_A(k-1), x1_A(k)], T_s(k));
        x1_B(k) = VinkelPosMotorB(k);
        x2_B(k) = BakoverDerivasjon([x1_B(k-1), x1_B(k)], T_s(k));

        % Målingen y er lavpassfiltrert vinkelhastighet
        %tau = 10;      % tidskonstant til filteret
        alfa(k)  = 0.5; %1-exp(-T_s(k)/tau);  % tidsavhengig alfa
        x2_f_A(k) = IIR_filter(x2_f_A(k-1), x2_A(k), alfa(k));
        x2_f_B(k) = IIR_filter(x2_f_B(k-1), x2_B(k), alfa(k));
        y_A(k) = x2_f_A(k);
        y_B(k) = x2_f_B(k);

        % Referanse r(k)
        r(k) = fart;

        % Reguleringsavvik for motor A og B
        e_A(k) = r(k) - y_A(k);
        e_B(k) = r(k) - y_B(k);

        % Beregn PID for motor A
        para = [Kp, Ki, Kd, I_max, I_min, alfa(k)];
        [P_A(k), I_A(k), D_A(k), e_f_A(k)] = MinPID(I_A(k-1), e_f_A(k-1), e_A(k-1:k), T_s(k), para);
        u_A(k) = u0_A + P_A(k) + I_A(k) + D_A(k);

        % Beregn PID for motor B
        [P_B(k), I_B(k), D_B(k), e_f_B(k)] = MinPID(I_B(k-1), e_f_B(k-1), e_B(k-1:k), T_s(k), para);
        u_B(k) = u0_B + P_B(k) + I_B(k) + D_B(k);

    end

    % Begrens motorpådraget for å unngå overbelastning
    u_A(k) = max(min(u_A(k), 100), 0);
    u_B(k) = max(min(u_B(k), 100), 0);

    % Sett motorhastighet
    if online
       motorA.Speed = u_A(k);
       motorB.Speed = u_B(k);
       start(motorA);
       start(motorB);
    end

    %--------------------------------------------------------------

 
    
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    % Husk at syntaksen plot(Tid(1:k),data(1:k))
    % for gir samme opplevelse i online=0 og online=1 siden
    % hele datasettet (1:end) eksisterer i den lagrede .mat fila

    % Plotter enten i sann tid eller når forsøk avsluttes
    if plotting || JoyMainSwitch
        figure(fig1)
        subplot(3,1,1)
        hold on;
        plot(Tid(1:k),r(1:k),'r-');
        plot(Tid(1:k),x2_A(1:k),'g-');
        plot(Tid(1:k),y_A(1:k),'b-');
        hold off;
        grid on;
        ylabel('[$^{\circ}$/s]');
        text(Tid(k),r(k),['$',sprintf('%1.0f',r(k)),'^{\circ}$/s']);
        text(Tid(k),y_A(k),['$',sprintf('%1.0f',y_A(k)),'^{\circ}$/s']);
        title('Filtrert vinkelhastighet $y(t)$ og referanse $r(t)$');
        legend('$r(k)$','$e_f(k)$', '$y(k)$');

        subplot(3,1,2)
        hold on;
        plot(Tid(1:k),e_A(1:k),'b-');
        plot(Tid(1:k),e_f_A(1:k),'r--');
        hold off;
        grid on;
        title('Reguleringsavvik $e(t)$');
        ylabel('[$^{\circ}$/s]');
        legend('$e(k)$', '$e_f(k)$');

        subplot(3,1,3)
        hold on;
        plot(Tid(1:k),P_A(1:k),'b-');
        plot(Tid(1:k),I_A(1:k),'r-');
        plot(Tid(1:k),u_A(1:k),'k-');
        hold off;
        grid on;
        title('Bidragene P, I og totalp{\aa}drag $u(t)$');
        xlabel('Tid [sek]');
        legend('$P-del$', '$I-del$', '$u(k)$');

        drawnow;
    end
    %--------------------------------------------------------------
end


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%           STOP MOTORS

if online
    stop(motorA);
    stop(motorB);
end

subplot(3,1,1)
hold on;
plot(Tid(1:k),r(1:k),'r-');
plot(Tid(1:k),x2_A(1:k),'g-');
plot(Tid(1:k),y_A(1:k),'b-');
hold off;
grid on;
ylabel('[$^{\circ}$/s]');
text(Tid(k),r(k),['$',sprintf('%1.0f',r(k)),'^{\circ}$/s']);
text(Tid(k),y_A(k),['$',sprintf('%1.0f',y_A(k)),'^{\circ}$/s']);
title('Filtrert vinkelhastighet $y(t)$ og referanse $r(t)$');
legend('$r(k)$', '$e_f(k)$', '$y(k)$');

subplot(3,1,2)
hold on;
plot(Tid(1:k),e_A(1:k),'b-');
plot(Tid(1:k),e_f_A(1:k),'r--');
hold off;
grid on;
title('Reguleringsavvik $e(t)$');
ylabel('[$^{\circ}$/s]');
legend('$e(k)$', '$e_f(k)$');

subplot(3,1,3)
hold on;
plot(Tid(1:k),P_A(1:k),'b-');
plot(Tid(1:k),I_A(1:k),'r-');       
plot(Tid(1:k),u_A(1:k),'k-');
hold off;
grid on;
title('Bidragene P, I og totalp{\aa}drag $u(t)$');
xlabel('Tid [sek]');
legend('$P-del$', '$I-del$', '$u(k)$');
%------------------------------------------------------------------