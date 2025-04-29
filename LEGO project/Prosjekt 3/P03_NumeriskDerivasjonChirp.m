%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% P03_NumeriskDerivasjonStigningstall
%
% Hensikten med programmet er å numerisk derivere filtrert 
% målesignal u_{f,k} som representere avstandsmåling [m]
% til å beregne v_{f,k} som fart [km/t]
% 
% Følgende sensorer brukes:
% - Lyssensor
% 
%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%         EXPERIMENT SETUP, FILENAME AND FIGURE
clear; close all   % Alltid lurt å rydde workspace opp først
online = false;    % Online mot EV3 eller mot lagrede data?
plotting = false;   % Skal det plottes mens forsøket kjøres 
filename = 'P01_chirp_justert.mat'; 

if online

    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
    
    % sensorer
    myColorSensor = colorSensor(mylego);
    
else
    % Dersom online=false lastes datafil. 
    load(filename)
end

fig1 = figure;
drawnow;

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
        
           
        % Data fra styrestikke. Utvid selv med andre knapper og akser
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
    else
        if k==numel(Tid)
            JoyMainSwitch=1;
        end
       
        if plotting
            % Simulerer tiden som EV3-Matlab bruker på kommunikasjon 
            % når du har valgt "plotting=true" i offline
            pause(0.03)
        end

    end
    
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER
    % Gjør matematiske beregninger og motorkraftberegninger.
   
    % Tilordne målinger til variabler
    u(k) = Lys(k) + 40;        
 
    if k==1
        % Spesifisering av initialverdier og parametere
        T_s(1) = 0.05;            % nominell verdi
        fc = 1;                   % Knekk-frekvens
        tau = 1 / (2*pi*fc);      % Tau
        u_filtrert(1) = u(1);
        v_Bakover(1) = Lys(1);
    else
        % Komponenter til filtrasjon
        T_s(k) = Tid(k) - Tid(k-1);
        alfa(k) = 1 - exp(-T_s(k) / tau);

        %Filtrering og derivering med funksjoner laget
        u_filtrert(k) = IIR_filter_lego(u_filtrert(k-1), u(k), alfa(k));
        v_Bakover(k) = BakoverDerivasjon(Lys(1:k), T_s(k));
        v_Bakover_filter(k) = BakoverDerivasjon(u_filtrert(k-1:k), T_s(k));
    end
    
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    %
    % Plotter enten i sann tid eller når forsøk avsluttes
    if plotting || JoyMainSwitch
        subplot(3,1,1)
        hold on;
        plot(Tid(1:k),u(1:k),'b-');
        plot(Tid(1:k), u_filtrert(1:k), 'r-')
        hold off;
        grid on;
        title('Chirp signal m{\aa}linger');
        
        subplot(3,1,2)
        plot(Tid(1:k), v_Bakover(1:k), 'r-');
        title('Bakover ufiltrert (Relativt ubrukelig)');
        grid on;

        subplot(3,1,3)
        plot(Tid(1:k), v_Bakover_filter(1:k), 'g-');
        title('Bakover IIR-filtrert');
        grid on;

        drawnow;
    end        
end

subplot(3,1,1)
hold on;
plot(Tid(1:k),u(1:k),'b-');
plot(Tid(1:k), u_filtrert(1:k), 'r-');
hold off;
grid on; 
title('Chirp signal m{\aa}linger');

subplot(3,1,2)
plot(Tid(1:k), v_Bakover(1:k), 'r-');
title('Bakover ufiltrert (Relativt ubrukelig)');
grid on;

subplot(3,1,3)
plot(Tid(1:k), v_Bakover_filter(1:k), 'g-');
title('Bakover IIR-filtrert');
grid on;

