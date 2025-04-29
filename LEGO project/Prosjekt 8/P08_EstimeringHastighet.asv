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
filename = 'P04_P_del.mat'; % Navnet på datafilen når online=0.

if online  
   mylego = legoev3('USB');
   joystick = vrjoystick(1);
   [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
   
   % sensorer
   myColorSensor = colorSensor(mylego);     % Lyssensor
   mySonicSensor = sonicSensor(mylego);     % Ultralydsensor

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
        Avstand(k) = readDistance(mySonicSensor);

        % motorer
        VinkelPosMotorA(k) = double(motorA.readRotation);
        VinkelPosMotorB(k) = double(motorB.readRotation);
           
        % Data fra styrestikke. Utvid selv med andre knapper og akser
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        JoyForover(k) = JoAxes(2);

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

    % parametre
    fart = 0.5;
    alfa = 0.5;
    diameter = 0.054;
    omkrets = pi * diameter;

    if k == 1
        % Initialverdier
        T_s(1) = 0.05;
        Lys_f(1) = Lys(1);
        Avstand_f(1) = Avstand(1);
        FartUltraLyd(1) = 0;
        FartLys(1) = 0;

        DistanseA_f = 0;
        DistanseB_f = 0;

        % IC beregninger
        MAE(1) = 0;
        IAE(1) = 0;
        TV_A(1) = 0;
        TV_B(1) = 0;
        
    else 
        % Beregninger av tidsskritt
        T_s(k) = Tid(k) - Tid(k-1);

        Lys_f(k) = IIR_filter_lego(Lys_f(k-1), Lys(k), alfa);
        Avstand_f(k) = IIR_filter_lego(Avstand_f(k-1), Avstand(k), alfa);
        FartUltraLyd(k) = BakoverDerivasjon(Avstand_f(k-1:k), T_s(k));
    end
    
    if Lys(k) > 50
        farge(k) = 0;     % Hvit
    else
        farge(k) = 1;     % Sort
    end


    % Beregninger med lyssensor
    if k == 1
        feltbytte(1) = 0;
        FartLys_f(1) = 0;
    else
        if Lys(k) < 50 && Lys(k-1) > 50
            passering(n) = Tid(k);
            p = p + 1;
        end
    end
    if sum(feltbytte) >= 2
        feltbytte_indeks = find(feltbytte);

        siste_tid_feltbytte = Tid(feltbytte_indeks(end));
        forrige_tid_feltbytte = Tid(feltbytte_indeks(end-1));

        dt_felt = siste_tid_feltbytte - forrige_tid_feltbytte;

        dt_mellom_felt = Tid(k) - siste_tid_feltbytte;

        if dt_felt > dt_mellom_felt
            dt = dt_mellom_felt;
        end

        FartLys(k) = felt / dt;
    else
        FartLys(k) = FartLys(k-1);
    end

    if k == 1
        DistanseA(k) = 0;
        DistanseB(k) = 0;
        FartA(k) = 0;
        FartB(k) = 0;
        SnittFart(k) = 0;

    else
        VinkelHastighetA = pi/180 * (VinkelPosMotorA(k) - VinkelPosMotorA(k-1)) / T_s(k);
        VinkelHastighetB = pi/180 * (VinkelPosMotorB(k) - VinkelPosMotorB(k-1)) / T_s(k);

        FartA(k) = diameter/2 * VinkelHastighetA(k);
        FartB(k) = diameter/2 * VinkelHastighetB(k);

        SnittFart(k) = (FartA(k) + FartB(k)) / 2;
    end

    if k == 1
        AvvikUltraLyd(k) = 0;
        AvvikLys(k) = 0;
        IAE_Lys(k) = 0;
        IAE_UltraLyd(k) = 0;
    else
        AvvikUltraLyd(k) = abs(FartUltraLyd(k)) - abs(SnittFart(k));
        AvvikLys(k) = abs(FartLys_f(k) - abs(SnittFart(k)));

        IAE_Lys(k) = TrapesMetoden(IAE_Lys(k-1), abs(AvvikLys(k-1)), T_s(k));
        IAE_UltraLys(k) = TrapesMetoden(IAE_UltraLyd(k-1), abs(AvvikUltraLyd(k-1)), T_s(k));
    end

    PowerA(k) = fart * JoyForover(k);
    PowerB(k) = fart * JoyForover(k);

    if online
        motorA.Speed = PowerA(k);
        motorB.Speed = PowerB(k);
        
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
        plot(Tid(1:k), PowerA(1:k), 'b')
        plot(Tid(1:k), PowerB(1:k), 'r')
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
plot(Tid(1:k), PowerA(1:k), 'b')
plot(Tid(1:k), PowerB(1:k), 'r')
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



