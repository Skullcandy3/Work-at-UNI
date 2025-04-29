%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% P05_ManuellKjoring
% 
%  Sensorer:
%  - Lyssensor
%
%   Motorer:
%  - motor A
%  - motor B
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%         EXPERIMENT SETUP, FILENAME AND FIGURE

clear; close all   % Rydd workspace først
online = false;     % Online mot EV3 eller mot lagrede data?
plotting = false;   % Skal det plottes mens forsøket kjøres
filename = 'P05_Manuell_test.mat'; 

if online
    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes, JoyButtons] = HentJoystickVerdier(joystick);

    % Sensor
    myColorSensor = colorSensor(mylego);

    % Motorer
    motorA = motor(mylego, 'A');
    motorA.resetRotation;
    motorB = motor(mylego, 'B');
    motorB.resetRotation;
else
    load(filename)
end

fig1 = figure;
drawnow;

% Setter skyteknapp til å stoppe programmet
JoyMainSwitch = 0;
k = 0;

%--------------------------------------------------------------
while ~JoyMainSwitch
    k = k + 1;

    if online
        if k == 1
            tic;
            Tid(1) = 0;
            % Unngå indekseringsfeil ved start
            motorA_power(1) = 0;
            motorB_power(1) = 0;
        else
            Tid(k) = toc;
        end
        
        % Sensorer 
        Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));

        % Henter joystick-data
        [JoyAxes, JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        JoyForover(k) = JoyAxes(2); % Frem og bak
        JoySving(k) = JoyAxes(3);   % Sidebevegelse
    else
        if k == length(Tid)
            JoyMainSwitch = 1;
        end
        if plotting
            pause(0.03)
        end
    end

 % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER
    % Gjør matematiske beregninger og motorkraftberegninger.

    % Tilordne målinger til variabler
    y(k) = Lys(k);         % Lysmålinger
    r(k) = y(1);           % Referanse punkt
    e(k) = r(k) - y(k);    % Regulerings avvik
    e_abs(k) = abs(e(k));  % Absolutt avvik
 
    if k==1
        % Spesifisering av initialverdier og parametere
        T_s(1) = 0.05;  % nominell verdi til Ts
        MAE(1) = 0;
        IAE(1) = 0;
        TV_A(1) = 0;
        TV_B(1) = 0;
        motorA_power(1) = 0; % starter motor ved 0 naturligvis
        motorB_power(1) = 0;
    else
        % Beregninger av T_s(k) og andre variable
        % Beregner motorkraft og andre data typer!
        motorA_power(k) = a * JoyForover(k) + a * JoySving(k);
        motorB_power(k) = a * JoyForover(k) - a * JoySving(k);
        T_s(k) = Tid(k) - Tid(k-1);
        MAE(k) = mean(e_abs(1:k)); % Legger til steps slik at den utfører kalkulasjon!
        IAE(k) = TrapesMetoden(IAE(k-1), T_s(k), e_abs(k-1), e_abs(k));
        TV_A(k) = TV_A(k-1) + abs(motorA_power(k) - motorA_power(k-1));
        TV_B(k) = TV_B(k-1) + abs(motorB_power(k) - motorB_power(k-1));

    end

 %-------------Kjøring og kalkulering av legorobot manuellkjoring-------
    % Parametre
    a = 0.4; % Motorstyrke-skala

    % Beregner motorkraft
    motorA_power(k) = a * JoyForover(k) + a * JoySving(k);
    motorB_power(k) = a * JoyForover(k) - a * JoySving(k);

    % Setter motorhastighet på EV3
    if online
        motorA.Speed = motorA_power(k);
        motorB.Speed = motorB_power(k);
        start(motorA);
        start(motorB);

        % Leser av motorvinkel
        VinkelPosMotorA(k) = double(motorA.readRotation);
        VinkelPosMotorB(k) = double(motorB.readRotation);
    end

 %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 %                  PLOT DATA    
 % Plotter joystick-input og motorkraft
    if plotting || JoyMainSwitch
        subplot(3,2,1)
        hold on;
        plot(Tid(1:k), y(1:k), 'b');
        plot(Tid(1:k), r(1:k), 'r');
        hold off;
        title('Lysm{\aa}ling og referanse');
        legend('$y(k)$', '$r(k)$');
        
        subplot(3,2,2)
        plot(Tid(1:k), e(1:k), 'b');
        title('Reguleringsavvik');
        legend('$\{e_k\}$');
       
        subplot(3,2,3)
        hold on;
        plot(Tid(1:k), motorA_power(1:k), 'b');
        plot(Tid(1:k), motorB_power(1:k), 'r');
        hold off;
        title('Motorp{\aa}drag');
        legend('$\{u_{A,k}\}$', '$\{u_{B,k}\}$');

        subplot(3,2,4)
        plot(Tid(1:k), IAE(1:k), 'b');
        title('Integralet av absolut avvik');
        legend('$\{IAE_k\}$');

        subplot(3,2,5)
        hold on;
        plot(Tid(1:k), TV_A(1:k), 'b');
        plot(Tid(1:k), TV_B(1:k), 'r');
        hold off;
        title('Total variasjon');
        legend('$\{TV_{A,k}\}$', '$\{TV_{B,k}\}$');

        subplot(3,2,6)
        plot(Tid(1:k), MAE(1:k), 'b');
        title('Middelverdi av reguleringsavvik');
        legend('$\{MAE_k\}$');

        drawnow;
    end
end

subplot(3,2,1)
hold on;    
plot(Tid(1:k), y(1:k), 'b');
plot(Tid(1:k), r(1:k), 'r');
hold off;
title('Lysm{\aa}ling og referanse');
legend('$y(k)$', '$r(k)$');
        
subplot(3,2,2)
plot(Tid(1:k), e(1:k), 'b');
title('Reguleringsavvik');
legend('$\{e_k\}$');
       
subplot(3,2,3)
hold on;
plot(Tid(1:k), motorA_power(1:k), 'b');
plot(Tid(1:k), motorB_power(1:k), 'r');
hold off;
title('Motorp{\aa}drag');
legend('$\{u_{A,k}\}$', '$\{u_{B,k}\}$');

subplot(3,2,4)
plot(Tid(1:k), IAE(1:k), 'b');
title('Integralet av absolut avvik');
legend('$\{IAE_k\}$');

subplot(3,2,5)
hold on; 
plot(Tid(1:k), TV_A(1:k), 'b');
plot(Tid(1:k), TV_B(1:k), 'r');
hold off;
title('Total variasjon');
legend('$\{TV_{A,k}\}$', '$\{TV_{B,k}\}$');
xlabel('Tid [s]');

subplot(3,2,6)
plot(Tid(1:k), MAE(1:k), 'b');
title('Middelverdi av reguleringsavvik');
legend('$\{MAE_k\}$');
xlabel('Tid [s]');

% Stopper motorene
if online
    stop(motorA);
    stop(motorB);
end