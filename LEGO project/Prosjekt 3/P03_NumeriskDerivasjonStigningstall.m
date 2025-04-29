%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% P03_NumeriskDerivasjonStigningstall
%
% Hensikten med programmet er å numerisk derivere filtrert 
% målesignal u_{f,k} som representere avstandsmåling [m]
% til å beregne v_{f,k} som fart [km/t]
% 
% Følgende sensorer brukes:
% - Ultralydsensor
% - Bryter
%--------------------------------------------------------------------------

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%         EXPERIMENT SETUP, FILENAME AND FIGURE

clear; close all   % Alltid lurt å rydde workspace opp først
online = false;    % Online mot EV3 eller mot lagrede data?
plotting = false;   % Skal det plottes mens forsøket kjøres 
filename = 'P03_Derivertstigning.mat'; 

if online
    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
    
    % sensorer
    mySonicSensor = sonicSensor(mylego); % Ultralyd sensor
    myTouchSensor = touchSensor(mylego); % Bryter 'sensor'
    
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
        Avstand(k) = double(readDistance(mySonicSensor));
        Bryter(k)  = double(readTouch(myTouchSensor));
           
        % Data fra styrestikke. Utvid selv med andre knapper og akser
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
    else
        % online=false
        % Naar k er like stor som antall elementer i datavektpren Tid,
        % simuleres det at bryter paa styrestikke trykkes inn.
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
    u(k) = 1000*Avstand(k); % Øker til meter og scaler for mer data        
 
    if k==1
        % Spesifisering av initialverdier og parametere
        T_s(1) = 0.05;  % nominell verdi
        fc = 0.2; % Knekk-frekvens
        tau = 1 / (2*pi*fc);
        u_filtrert(1) = u(1);
        v_Bakover(1) = Avstand(1);

    else
        % beregner tidsskritt
        T_s(k) = Tid(k) - Tid(k-1);
        alfa(k) = 1 - exp(-T_s(k) / tau);
        u_filtrert(k) = IIR_filter_lego(u_filtrert(k-1), u(k), alfa(k));
        %v_Bakover(k) = BakoverDerivasjon(Avstand(1:k), T_s(k));
    end
    
    % Setter statement slik at når bryter er trykket skal den derivere
    % Slik at det blir en fartspistol!
    if Bryter(k) == 1
        v_Bakover(k) = BakoverDerivasjon(Avstand(k-1:k), T_s(k));
        v_Bakover_filter(k) = BakoverDerivasjon(u_filtrert(k-1:k), T_s(k));
    else
        v_Bakover(k) = 0;
        v_Bakover_filter(k) = 0;
    end
    %--------------------------------------------------------------

    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    %
    % Husk at syntaksen plot(Tid(1:k),data(1:k))
    % for gir samme opplevelse i online=true og online=false siden
    % hele datasettet (1:end) eksisterer i den lagrede .mat fila
    
    % Plotter enten i sann tid eller når forsøk avsluttes
    if plotting || JoyMainSwitch
        subplot(4,1,1)
        hold on;
        plot(Tid(1:k),u(1:k),'b-');
        plot(Tid(1:k), u_filtrert(1:k), 'r-');
        hold off;
        grid on;

        subplot(4,1,2)
        plot(Tid(1:k),Bryter(1:k),'k');
        grid on;
        xlabel('Tid [sek]');
        
        subplot(4,1,3)
        plot(Tid(1:k), v_Bakover(1:k), 'r-');
        grid on;
        title('Bakover ufiltrert (Relativt ubrukelig)');

        subplot(4,1,4)
        plot(Tid(1:k), v_Bakover_filter(1:k), 'g-');
        grid on;
        title('Bakover IIR-filtrert');

        drawnow;
    end

end

% Offline plotting av data
subplot(4,1,1)
hold on;
plot(Tid(1:k),u(1:k),'b-');
plot(Tid(1:k), u_filtrert(1:k), 'r-');
hold off;
grid on;

subplot(4,1,2)
plot(Tid(1:k),Bryter(1:k),'k');
grid on;
xlabel('Tid [sek]');
        
subplot(4,1,3)
plot(Tid(1:k), v_Bakover(1:k), 'r-');
title('Bakover ufiltrert (Relativt ubrukelig)');
grid on;

subplot(4,1,4)
plot(Tid(1:k), v_Bakover_filter(1:k), 'g-');
title('Bakover IIR-filtrert');
grid on;

