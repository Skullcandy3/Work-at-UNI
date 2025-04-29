%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% P02_FiltreringTemperatur
%
% Hensikten med programmet er å lavpassfiltrere målesignalet u_k som
% representere temperaturmåling [C]
% 
% Følgende sensorer brukes:
% - Lyssensor
%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%         EXPERIMENT SETUP, FILENAME AND FIGURE

clear; close all   % Alltid lurt å rydde workspace opp først
online = false;     % Online mot EV3 eller mot lagrede data?
plotting = false;  % Skal det plottes mens forsøket kjøres
filename = 'P02_temp_ploton.mat'; 

if online
    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

    % sensorer
    myColorSensor = colorSensor(mylego);

    % motorer
    % Vi benytter håndbevegelse istedet for motor i denne delen
else
    % Dersom online=false lastes datafil.
    load(filename)

end

fig1=figure;
drawnow

% setter skyteknapp til 0, og initialiserer tellevariabel k
JoyMainSwitch=0;
k=0;
%----------------------------------------------------------------------
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

        % sensorer
        Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));

        % Data fra styrestikke. 
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        
    else
        % Når k er like stor som antall elementer i datavektoren Tid,
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
    % Gjør matematiske beregninger og motorkraftberegninger.

    % Tilordne målinger til variabler
    u(k) = Lys(k);

    if k==1
        % Spesifisering av initialverdier og parametere
        T_s(1) = 0.05;  % nominell verdi
        M = 10; %Endrer FIR-filter
        alfa = 0.6; %Endrer IIR-filter
        y_IIR(1) = u(1);
        y_FIR(1) = u(1);
       
    else
        % Beregninger av T_s(k), y_FIR(k) og y_IIR(k)
        T_s(k) = Tid(k) - Tid(k-1);
        y_FIR(k) = FIR_filter_lego(u(1:k), M);
        y_IIR(k) = IIR_filter_lego(y_IIR(k-1), u(k), alfa);
        
    
    end


    %--------------------------------------------------------------


    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    %
    % Husk at syntaksen plot(Tid(1:k),data(1:k))
    % gir samme opplevelse i online=0 og online=1 siden
    % hele datasettet (1:end) eksisterer i den lagrede .mat fila

    % Plotter enten i sann tid eller når forsøk avsluttes
    if plotting || JoyMainSwitch
        subplot(2,1,1)
        plot(Tid(1:k),u(1:k));
        title('Kaffekopp temperatur');
        ylabel('Temperatur [Celsius]');
        xlabel('Tid (sek)');
        legend('$\{u_k\}$');
        
        subplot(2,1,2)
        hold on;
        plot(Tid(1:k), u(1:k));
        plot(Tid(1:k), y_FIR(1:k), 'r');
        plot(Tid(1:k), y_IIR(1:k), 'g');
        hold off;
        title('FIR-filtrert temperatur');
        ylabel('Temperatur [Celsius]');
        xlabel('Tid (sek)');
        legend('$\{y_k\}$');

        drawnow;
    end
    %--------------------------------------------------------------

end

% Offline plotting av data
subplot(2,1,1)
plot(Tid(1:k),u(1:k));
title('Kaffekopp temperatur');
ylabel('Temperatur [Celsius]');
xlabel('Tid (sek)');
legend('$\{u_k\}$');
        
subplot(2,1,2)
hold on;
plot(Tid(1:k), u(1:k));
plot(Tid(1:k), y_FIR(1:k), 'r');
plot(Tid(1:k), y_IIR(1:k), 'g');
hold off;
title('FIR-filtrert temperatur');
ylabel('Temperatur [Celsius]');
xlabel('Tid (sek)');
legend('$\{y_k\}$');


