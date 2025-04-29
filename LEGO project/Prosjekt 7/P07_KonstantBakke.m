%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt07_Adaptiv_Cruise_Bakke_Konsant_Uten_Regulering...
%
% Hensikten med programmet er å sjekke hva som skjer når du ikke regulerer
% farten til lego opp en bakke
%
% Motorer brukt: 
%  - Motor A
%  - Motor B
%
%--------------------------------------------------------------------------
%---------------------- EXPERIMENT SETUP, FILENAME AND FIGURE -------------
clear; close all;


online = false;     % Online mot EV3 eller mot lagrede data?
plotting = false;   % Skal det plottes mens forsøket kjøres?
filename = 'P07_BakkeUC.mat'; % Datafil ved offline-modus

if online  
    mylego = legoev3('USB');
    joystick = vrjoystick(1);

    % Motorer
    motorA = motor(mylego,'A');
    motorB = motor(mylego, 'B');
    motorA.resetRotation;
    motorB.resetRotation;
else
    load(filename); % Last inn datafil
end

fig1 = figure;

duration = tic; % Start stoppeklokke
JoyMainSwitch = 0;
k = 0;

%---------------------- HOVEDLØKKE ----------------------
while ~JoyMainSwitch
    k = k + 1;
    
    if online
        if k == 1
            tic;
            Tid(1) = 0;
        else
            Tid(k) = toc;
        end
        
        VinkelPosMotorA(k) = double(motorA.readRotation);
        [JoyAxes, JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
    else
        if k == length(Tid)
            JoyMainSwitch = 1;
        end
        if plotting
            pause(0.03); % Simulerer kommunikasjonsforsinkelse
        end
    end

    fart = 500;
    
    if k == 1
        T_s(1) = 0.05;
        x1(1) = VinkelPosMotorA(1); % Posisjon
        x2(1) = 0; % Hastighet
        x2_f(1) = 0; 
        r(1) = fart;
        y(1) = 0;
        
    else
        T_s(k) = Tid(k) - Tid(k-1);
        x1(k) = VinkelPosMotorA(k);
        x2(k) = BakoverDerivasjon([x1(k-1), x1(k)], T_s(k));
        alfa(k) = 0.08;
        x2_f(k) = IIR_filter(x2_f(k-1), x2(k), alfa(k));
        y(k) = x2_f(k);     
        r(k) = fart;
    end

    if online
       motorA.Speed = 71.3;
       motorB.Speed = 70;
       start(motorA);
       start(motorB);
    end

    if plotting || JoyMainSwitch
        figure(fig1);
        subplot(1,1,1);
        hold on;
        plot(Tid(1:k), r(1:k), 'r-');
        plot(Tid(1:k), y(1:k), 'b-');
        hold off;
        grid on;
        ylabel('[$^{\circ}$/s]');
        text(Tid(k), r(k), ['$', sprintf('%1.0f', r(k)), '^{\circ}$/s']);
        text(Tid(k), y(k), ['$', sprintf('%1.0f', y(k)), '^{\circ}$/s']);
        title('Filtrert vinkelhastighet $y(t)$ og referanse $r(t)$');
        drawnow;
    end
end

%---------------------- STOPP MOTORER ----------------------
if online
    stop(motorA);
    stop(motorB);
end

subplot(1,1,1);
hold on;
plot(Tid(1:k), r(1:k), 'r-');
plot(Tid(1:k), y(1:k), 'b-');
hold off;
grid on;
ylabel('[$^{\circ}$/s]');
text(Tid(k), r(k), ['$', sprintf('%1.0f', r(k)), '^{\circ}$/s']);
text(Tid(k), y(k), ['$', sprintf('%1.0f', y(k)), '^{\circ}$/s']);
title('Filtrert vinkelhastighet $y(t)$ og referanse $r(t)$');