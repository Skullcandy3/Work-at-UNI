clear; close all; clc

% Laster inn .mat-fil bestående av tidsvektor "Tid" og måling "Lys"
load('P01_chirp.mat')         

% Gir variablene nytt navn i henhold til kompendiet
u = Lys;
t = Tid;

% Figur 1 med 3x1 subplot
figure

% -----------------------------------------
% Plotting av data kun mot indeks
%subplot(3,1,1)
%plot(u,'b')  % Kun ett argument i plot-kallet = plotting mot indeks
%grid
%title('M{\aa}lesignal $\{u_k\}$ som funksjon av indeks $k$', 'Interpreter', 'latex')
%xlabel('Indeks $k$', 'Interpreter', 'latex')
%ylim([0 80])

% -----------------------------------------
% Fjerne de første og siste signalene som ikke ser ut som en sinusfunksjon
fjerner_start = 3; % Antall verdier som fjernes i starten
fjerner_slutt = 2; % Antall verdier som fjernes i slutten
u_clean = u(fjerner_start:end-fjerner_slutt);
t_clean = t(fjerner_start:end-fjerner_slutt);

% Justere tidsvektor så den starter i t = 0
t_clean = t_clean - t_clean(1);

% -----------------------------------------
% Fjerne uteliggere (outliers)
outlier_threshold = 1.5; % Definerer terskel for uteliggere
u_mean = mean(u_clean, 'omitnan');
u_std = std(u_clean, 'omitnan');

outliers = abs(u_clean - u_mean) > outlier_threshold * u_std;
u_clean(outliers) = NaN;

% Fyll inn manglende verdier der uteliggere ble fjernet
u_clean = fillmissing(u_clean, 'linear');

% Plot etter fjerning av støy i starten, slutten og uteliggere
%subplot(3,1,2)
%plot(t_clean, u_clean, 'b')
%grid
%title('Signal etter fjerning av st{\o}y i starten og slutten','Interpreter','latex')
%xlabel('Tid $t$ [s]','Interpreter','latex')
%ylabel('M{\aa}ling $u_k$','Interpreter','latex')

% -----------------------------------------
% Fjerner likevektsverdien C fra signalet
C = mean(u_clean, 'omitnan'); % Setter C lik middelverdien

u_clean = u_clean - C; % Trekker fra middelverdien fra alle signalene

% Plot det ferdig justerte sinus-signalet
%subplot(3,1,3)
%plot(t_clean, u_clean, 'b')
%grid
%title('Justert sinus-signal','Interpreter','latex')
%xlabel('Tid $t$ [s]','Interpreter','latex')
%ylabel('Signal $u(t)$','Interpreter','latex')


%%
% Parametre for den teoretiske sinusfunksjonen
A = 12; % Amplitude
w = (2*pi)/1.5;  % Vinkelfrekvens

% Tidsvektor (samme lengde som renset signal)
t_est = linspace(0, max(t_clean), length(t_clean));
Tid = t_clean;
Lys = u_clean;
% Beregning av den teoretiske sinusfunksjonen
u_est = A * sin(w * t_est);

% Plot renset signal og teoretisk sinusfunksjon
figure;
plot(t_clean, u_clean, 'b')
hold on
plot(t_est, u_est, 'r');
grid on;
title('Renset signal og teoretisk sinusfunksjon', 'Interpreter', 'latex');
xlabel('Tid $t$ [s]', 'Interpreter', 'latex');
ylabel('Signal $u(t)$', 'Interpreter', 'latex');
legend({'Renset signal', 'Teoretisk sinus'}, 'Interpreter', 'latex');