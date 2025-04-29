%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% P01_NumeriskIntegrasjonKonstant
%
% Hensikten med programmet er å numerisk integrere målesignal u_k som
% representere strømning [cl/s] til å beregne y_k som volum [cl]
% 
% Følgende sensorer brukes:
% - Lyssensor
%
%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%         EXPERIMENT SETUP, FILENAME AND FIGURE

clear; close all   % Alltid lurt å rydde workspace opp først
online = false;     % Online mot EV3 eller mot lagrede data?
plotting = false;  % Skal det plottes mens forsøket kjøres
filename = 'P01_konstant.mat'; 

if online
    
    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

    % sensorer
    myColorSensor = colorSensor(mylego);
    
    % motorer
    %  Handbevegelse ble benyttet for å måle data
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
    LysInit = Lys(1);
    u(k) = Lys(k) - LysInit;
    
    if k==1
        % Spesifisering av initialverdier og parametere
        T_s(1) = 0.05;  % nominell verdi
         y_Trapes(1) = u(1);
    else
        % Beregning av faktisk tidssteg
        T_s(k) = Tid(k) - Tid(k-1);
    
        % Trapesformelen for numerisk integrasjon
        y_Trapes(k) = TrapesMetoden(y_Trapes(k-1), T_s(k), u(k-1), u(k));

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
        plot(Tid(1:k), u(1:k))
        title('M{\aa}le verdier fra lyssensor!')
        legend('$\{u_k\}$')
        ylabel('Rate [cl/s]')

        subplot(2,1,2)
        plot(Tid(1:k),y_Trapes(1:k));
        title("Trapes metoden for integrasjon av konstant!")
        legend('$\{y_k\}$')
        xlabel('Tid [sek]')
        ylabel('Volum [cl]')
       

        % tegn nå (viktig kommando)
        drawnow
    end
    %--------------------------------------------------------------

end


subplot(2,1,1)
plot(Tid(1:k), u(1:k))
title('M{\aa}le verdier fra lyssensor!')
legend('$\{u_k\}$')
ylabel('Rate [cl/s]')

subplot(2,1,2)
plot(Tid(1:k),y_Trapes(1:k));
title("Trapes metoden for integrasjon av konstant!")
legend('$\{y_k\}$')
xlabel('Tid [sek]')
ylabel('Volum [cl]')
