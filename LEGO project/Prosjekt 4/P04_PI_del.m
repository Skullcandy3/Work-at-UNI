%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt04_PI_del
%
% Følgende  motorer brukes: 
%  - motor A
%--------------------------------------------------------------------------

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%         EXPERIMENT SETUP, FILENAME AND FIGURE

clear; close all   % Alltid lurt å rydde workspace opp først
online = false;     % Online mot EV3 eller mot lagrede data?
plotting = false;  % Skal det plottes mens forsøket kjøres 
filename = 'P04_PI_del.mat'; % Navnet på datafilen når online=0.

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
    Kp = 0.2;    % start med lave verdier, typisk 0.005
    Ki = 0.3;      % start med lave verdier, typisk 0.005
    Kd = 0;      % start med lave verdier, typisk 0.001
    I_max = 100;
    I_min = -100;
    alfa = 0.5;   

    if k==1
        % Initialverdier
        T_s(1) = 0.05;      % nominell verdi

        % Motorens tilstander
        x1(1) = VinkelPosMotorA(1);  % vinkelposisjon motor
        x2(1) = 0;                   % vinkelhastighet motor

        % Måling, referansen, reguleringsavvik
        x2_f(1) = 0;         % filtrert vinkelhastighet motor
        y(1) = x2_f(1);      % måling filtrert vinkelhastighet
        r(1) = 0;            % referanse
        e(1) = r(1)-y(1);    % reguleringsavvik
        e_f(1) = e(1);       % filtrert reg.avvik for D-ledd

        % Initialverdi PID-regulatorens deler
        P(1) = 0;       % P-del
        Int_I(1) = 0;   % Integral verdi til 0
        I(1) = 0;       % I-del
        D(1) = 0;       % D-del
    else 
        % Beregninger av tidsskritt
        T_s(k) = Tid(k)-Tid(k-1);

        % Motorens tilstander
        % x1: vinkelposisjon og 
        % x2: vinkelhastighet (derivert av posisjon)
        x1(k) = VinkelPosMotorA(k);
        x2(k) = (x1(k)-x1(k-1))/T_s(k);

        % Målingen y er lavpassfiltrert vinkelhastighet
        tau = 0.2;                      % tidskonstant til filteret
        alfa(k)  = 1-exp(-T_s(k)/tau);  % tidsavhengig alfa
        x2_f(k) = (1-alfa(k))*x2_f(k-1) + alfa(k)*x2(k);
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
        P(k) = Kp * e(k);
        Int_I(k) = Ki * e(k);
        I(k) = TrapesMetoden(I(k-1), T_s(k), Int_I(k-1), Int_I(k));
        e_f(k) = 0;
        D(k) = 0;
        
    end
    
    % Integratorbegrensing
    if I(k)>I_max
        I(k) = I_max;

    elseif I(k)<I_min
        I(k) = I_min;

    else
        I(k) = I(k);
    end

    u_A(k) = u0 + P(k) + I(k) + D(k);

    % Prøve å begrense ytteligere for å sørge for at den ikke går over 100
    if u_A(k) > 100        % Sett maks motorkraft her
       u_A(k) = 100;
       I(k) = I(k-1);      % Stopper integralet fra å øke videre
    elseif u_A(k) < -100
           u_A(k) = -100;
           I(k) = I(k-1);
    end
    
    if online
        motorA.Speed = u_A(k);
        start(motorA)
    end
    %--------------------------------------------------------------

    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    % Husk at syntaksen plot(Tid(1:k),data(1:k))
    % for gir samme opplevelse i online=0 og online=1 siden
    % hele datasettet (1:end) eksisterer i den lagrede .mat fila

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
        plot(Tid(1:k),u_A(1:k),'k-');
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
ylabel('[$^{\circ}$/s]')
text(Tid(k),r(k),['$',sprintf('%1.0f',r(k)),'^{\circ}$/s']);
text(Tid(k),y(k),['$',sprintf('%1.0f',y(k)),'^{\circ}$/s']);
title('Filtrert vinkelhastighet $y(t)$ og referanse $r(t)$')

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
plot(Tid(1:k),u_A(1:k),'k-');
hold off;
grid on;
title('Bidragene P, I, og D og totalp{\aa}drag $u(t)$');
xlabel('Tid [sek]');
%------------------------------------------------------------------