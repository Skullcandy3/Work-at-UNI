%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt04_PID_del
%
% Hensikten med programmet er å tune er regulator
% for styring av hastigheten til en motor
%
% Følgende  motorer brukes: 
%  - motor A
%--------------------------------------------------------------------------

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%         EXPERIMENT SETUP, FILENAME AND FIGURE

clear; close all   % Alltid lurt å rydde workspace opp først
online = false;     % Online mot EV3 eller mot lagrede data?
plotting = false;  % Skal det plottes mens forsøket kjøres 
filename = 'P04_PID_del.mat'; % Navnet på datafilen når online=0.

if online  
   mylego = legoev3('USB');
   joystick = vrjoystick(1);
   [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

   % motorer
   motorA = motor(mylego,'A');
   motorA.resetRotation;
else
    load(filename)
end

fig1 = figure;
drawnow;

% setter skyteknapp til 0, og initialiserer tellevariabel k
JoyMainSwitch=0;
k=0;
%----------------------------------------------------------------------

% Starter stoppeklokke for å stoppe 
% eksperiment automatisk når t>29 sekund. 
% Du kan også stoppe med skyteknappen!
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
        
        % motor
        VinkelPosMotorA(k) = double(motorA.readRotation);
           
        % Data fra styrestikke.
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
    else
        if k==length(Tid)
            JoyMainSwitch=1;
        end
        
        if plotting
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
    u0 = 0;
    Kp = 0.5;    % start med lave verdier, typisk 0.005
    Ki = 0.6;      % start med lave verdier, typisk 0.005
    Kd = 0.01;      % start med lave verdier, typisk 0.001
    I_max = 100;
    I_min = -100;

    if k==1
        % Initialverdier
        T_s(1) = 0.05;      % nominell verdi

        % Motorens tilstander
        x1(1) = VinkelPosMotorA(1);  % vinkelposisjon motor
        x2(1) = 0;                   % vinkelhastighet motor

        % Måling, referansen, reguleringsavvik
        x2_f(1) = 0;         % filtrert vinkelhastighet moto
        e_f(1) = e(1);       % filtrert reg.avvik for D-ledd

        % Initialverdi PID-regulatorens deler
        P(1) = 0;       % P-del
        I(1) = 0;       % I-del
        D(1) = 0;       % D-del
    else 
        % Beregninger av tidsskritt
        T_s(k) = Tid(k)-Tid(k-1);

        % Motorens tilstander
        % x1: vinkelposisjon og 
        % x2: vinkelhastighet (derivert av posisjon)
        x1(k) = VinkelPosMotorA(k);
        x2(k) = BakoverDerivasjon([x1(k-1), x1(k)], T_s(k));

        % Målingen y er lavpassfiltrert vinkelhastighet
        tau = 0.2;      % tidskonstant til filteret
        alfa(k)  = 1-exp(-T_s(k)/tau);  % tidsavhengig alfa
        x2_f(k) = IIR_filter(x2_f(k-1), x2(k), alfa(k));
        y(k) = x2_f(k);     

        % Referanse r(k), forhåndsdefinert
        tidspunkt =  [0, 2,  5,  8,  11,  14, 21, 30];  % sekund
        RefVerdier = [0 200 500,700, 1000,600,600];  % grader/s
        for i = 1:length(tidspunkt)-1
            if Tid(k) >= tidspunkt(i) && Tid(k) < tidspunkt(i+1)
                r(k) = RefVerdier(i);
            end
        end

        % Reguleringssavvik
        e(k) = r(k)-y(k);

        % Lag kode for bidragene P(k), I(k) og D(k)
        para = [Kp, Ki, Kd, I_max, I_min, alfa(k)];
        [P(k),I(k),D(k),e_f(k)] = MinPID(I(k-1),e_f(k-1),e(k-1:k),T_s(k),para);
        u(k) = u0 + P(k) + I(k) + D(k);
    
    end
    
    if online
        motorA.Speed = u(k);
        start(motorA)
    end
    %--------------------------------------------------------------

    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    % Plotter enten i sann tid eller når forsøk avsluttes

    if plotting || JoyMainSwitch
        subplot(3,1,1)
        hold on;
        plot(Tid(1:k),r(1:k),'r-');
        plot(Tid(1:k),x2(1:k),'g-');
        plot(Tid(1:k),y(1:k),'b-');
        hold off;
        grid on;
        ylabel('[$^{\circ}$/s]');
        text(Tid(k),r(k),['$',sprintf('%1.0f',r(k)),'^{\circ}$/s']);
        text(Tid(k),y(k),['$',sprintf('%1.0f',y(k)),'^{\circ}$/s']);
        title('Filtrert vinkelhastighet $y(t)$ og referanse $r(t)$');

        subplot(3,1,2)
        hold on;
        plot(Tid(1:k),e(1:k),'b-');
        plot(Tid(1:k),e_f(1:k),'r--');
        hold off;
        grid on;
        title('Reguleringsavvik $e(t)$');
        ylabel('[$^{\circ}$/s]');

        subplot(3,1,3)
        hold on;
        plot(Tid(1:k),P(1:k),'b-');
        plot(Tid(1:k),I(1:k),'r-');
        plot(Tid(1:k),D(1:k),'g-');        
        plot(Tid(1:k),u(1:k),'k-');
        hold off;
        grid on;
        title('Bidragene P, I, og D og totalp{\aa}drag $u(t)$');
        xlabel('Tid [sek]');

        drawnow;
    end
    %--------------------------------------------------------------
end

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%           STOP MOTORS

if online
    stop(motorA);
end

subplot(3,1,1)
hold on;
plot(Tid(1:k),r(1:k),'r-');
plot(Tid(1:k),x2(1:k),'g-');
plot(Tid(1:k),y(1:k),'b-');
hold off;
grid on;
ylabel('[$^{\circ}$/s]');
text(Tid(k),r(k),['$',sprintf('%1.0f',r(k)),'^{\circ}$/s']);
text(Tid(k),y(k),['$',sprintf('%1.0f',y(k)),'^{\circ}$/s']);
title('Filtrert vinkelhastighet $y(t)$ og referanse $r(t)$');

subplot(3,1,2)
hold on;
plot(Tid(1:k),e(1:k),'b-');
plot(Tid(1:k),e_f(1:k),'r--');
hold off;
grid on;
title('Reguleringsavvik $e(t)$');
ylabel('[$^{\circ}$/s]');

subplot(3,1,3)
hold on;
plot(Tid(1:k),P(1:k),'b-');
plot(Tid(1:k),I(1:k),'r-');
plot(Tid(1:k),D(1:k),'g-');        
plot(Tid(1:k),u(1:k),'k-');
hold off;
grid on;
title('Bidragene P, I, og D og totalp{\aa}drag $u(t)$');
xlabel('Tid [sek]');
%------------------------------------------------------------------