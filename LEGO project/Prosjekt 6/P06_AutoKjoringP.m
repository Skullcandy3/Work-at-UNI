%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt06_Automatisk_Kjøring
%
% Følgende  motorer brukes: 
%  - motor A
%  - motor B
%--------------------------------------------------------------------------

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%         EXPERIMENT SETUP, FILENAME AND FIGURE

clear; close all   % Alltid lurt å rydde workspace opp først
online = true;     % Online mot EV3 eller mot lagrede data?
plotting = false;  % Skal det plottes mens forsøket kjøres 
filename = 'P06_auto_p_del.mat'; % Navnet på datafilen når online=0.

if online
   mylego = legoev3('USB');
   joystick = vrjoystick(1);
   [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

   % sensorer
   myColorSensor = colorSensor(mylego);
   % motorer
   motorA = motor(mylego,'A');
   motorA.resetRotation;
   motorB = motor(mylego, 'B');
   motorB.resetRotation;

else
    % Dersom online=false lastes datafil.
    load(filename)
end

fig1 = figure;
drawnow

% setter skyteknapp til 0, og initialiserer tellevariabel k
JoyMainSwitch = 0;
k = 0;
%----------------------------------------------------------------------

% Starter stoppeklokke for å stoppe
duration = tic;

while ~JoyMainSwitch

    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                       GET TIME AND MEASUREMENT
    % Få tid og målinger fra sensorer, motorer og joystick

    % oppdater tellevariabel
    k = k + 1;

    if online
        if k == 1
            tic
            Tid(1) = 0;

        else
            Tid(k) = toc;
        end
        % sensorer
        Lys(k) = double(readLightIntensity(myColorSensor, 'reflected'));

        % motorer
        VinkelPosMotorA(k) = double(motorA.readRotation);
        VinkelPosMotorB(k) = double(motorB.readRotation);

        % Data fra styrestikke. Utvid selv med andre knapper og akser
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);

        if JoyButtons(1)
            JoyMainSwitch = 1;
        end
    else
        % online=false
        % Når k er like stor som antall elementer i datavektpren Tid,
        % simuleres det at bryter på styrestikke trykkes inn.
        if k == length(Tid)
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

    % Stopper automatisk når den kjører av banen
    if Lys(k) > 60
        JoyMainSwitch = 1;
    end

    % parametre
    u0 = 13;
    Kp = 2.15;   % start med lave verdier, typisk 0.001
    alfa = 0.5;


    if k == 1
        % Initialverdier
        T_s(1) = 0.05;

        y(1) = Lys(1);
        r(1) = Lys(1);
        e(1) = r(1)-y(1);    % reguleringsavvik
        e_f(1) = e(1);

        % Initialverdi PID-regulatorens deler
        P(1) = 0;       % P-del

        u_A(1) = 0;

        motorA_power(1) = 0;
        motorB_power(1) = 0;

        % IC beregninger
        MAE(1) = 0;
        IAE(1) = 0;
        TV_A(1) = 0;
        TV_B(1) = 0;

    else
        % Beregninger av tidsskritt
        T_s(k) = Tid(k) - Tid(k-1);

        y(k) = Lys(k);      % faktisk lysverdi
        r(k) = Lys(1);      % ønsket lysverdi

        e(k) = r(k)-y(k);   % Reguleringssavvik

        % Lag kode for bidragene P(k), I(k) og D(k)
        P(k) = Kp * e(k);

        % Sum bidrag fra PID
        u_A(k) = P(k);

        % Konstant fart
        motorA_power(k) = u0 - u_A(k);
        motorB_power(k) = u0 + u_A(k);

        % Beregner TV_A, TV_B, IAE og MAE
        IAE(k) = TrapesMetoden(IAE(k-1), T_s(k), abs(e(k-1)), abs(e(k)));
        MAE(k) = mean(abs(e));

        TV_A(k) = TV_A(k-1) + abs(motorA_power(k) - motorA_power(k-1));
        TV_B(k) = TV_B(k-1) + abs(motorB_power(k) - motorB_power(k-1));
    end


    if online
        motorA.Speed = motorA_power(k);
        motorB.Speed = motorB_power(k);

        start(motorA)
        start(motorB)
    end
 %--------------------------------------------------------------



 %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 %                  PLOT DATA
 % Plotter joystick-input og motorkraft
    if plotting || JoyMainSwitch
        subplot(3,2,1)
        hold on
        plot(Tid(1:k), y(1:k), 'b')
        plot(Tid(1:k), r(1:k), 'r')
        hold off
        title('Lysmaaling og referanse')
        legend('$y(k)$', '$r(k)$')

        subplot(3,2,2)
        plot(Tid(1:k), e(1:k), 'b')
        title('Reguleringsavvik')
        legend('$\{e_k\}$')

        subplot(3,2,3)
        hold on
        plot(Tid(1:k), motorA_power(1:k), 'b')
        plot(Tid(1:k), motorB_power(1:k), 'r')
        hold off
        title('Motorpadrag')
        legend('$\{u_{A,k}\}$', '$\{u_{B,k}\}$')

        subplot(3,2,4)
        plot(Tid(1:k), IAE(1:k), 'b')
        title('Integralet av absolut avvik')
        legend('$\{IAE_k\}$')

        subplot(3,2,5)
        hold on
        plot(Tid(1:k), TV_A(1:k), 'b')
        plot(Tid(1:k), TV_B(1:k), 'r')
        hold off
        title('Total variasjon')
        legend('$\{TV_{A,k}\}$', '$\{TV_{B,k}\}$')

        subplot(3,2,6)
        plot(Tid(1:k), MAE(1:k), 'b')
        title('Middelverdi av reguleringsavvik')
        legend('$\{MAE_k\}$')

        drawnow
    end
end

if online
    stop(motorA);
    stop(motorB);
end

figure(fig1)
subplot(3,2,1)
hold on
plot(Tid(1:k), y(1:k), 'b')
plot(Tid(1:k), r(1:k), 'r')
hold off
title('Lysmaaling og referanse')
legend('$y(k)$', '$r(k)$')

subplot(3,2,2)
plot(Tid(1:k), e(1:k), 'b')
title('Reguleringsavvik')
legend('$\{e_k\}$')

subplot(3,2,3)
hold on
plot(Tid(1:k), motorA_power(1:k), 'b')
plot(Tid(1:k), motorB_power(1:k), 'r')
hold off
title('Motorpadrag')
legend('$\{u_{A,k}\}$', '$\{u_{B,k}\}$')

subplot(3,2,4)
plot(Tid(1:k), IAE(1:k), 'b')
title('Integralet av absolut avvik')
legend('$\{IAE_k\}$')

subplot(3,2,5)
hold on
plot(Tid(1:k), TV_A(1:k), 'b')
plot(Tid(1:k), TV_B(1:k), 'r')
hold off
title('Total variasjon')
legend('$\{TV_{A,k}\}$', '$\{TV_{B,k}\}$')
xlabel('Tid [s]')

subplot(3,2,6)
plot(Tid(1:k), MAE(1:k), 'b')
title('Middelverdi av reguleringsavvik')
legend('$\{MAE_k\}$')
xlabel('Tid [s]')

% Stopper motorene
if online
    stop(motorA);
    stop(motorB);
end



