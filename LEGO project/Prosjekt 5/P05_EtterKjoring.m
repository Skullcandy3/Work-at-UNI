%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% P05_Etterkjoring
% 
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%         EXPERIMENT SETUP, FILENAME AND FIGURE

clear; close all                      % Rydd workspace først!
filename = 'P05_Manuell_test.mat';    % Henter data fra fil!

%Laster data
load(filename) 

% Utfører beregning slik at det kan plottes i histogram
StandardAvvik = std(Lys);  % Standardavvik fra gjennomsnitt
MiddelVerdi = mean(Lys);   % Middelverdi y

% Plot histogram
figure(1);
histogram(Lys, 'Normalization', 'count');
xlabel('Lysm{\aa}ling');
ylabel('Antall m{\aa}linger');
title('Fordeling av lysm{\aa}linger');
hold on;

% Legger til Standardavvik linjer og Middelverdi avvik i linjer
xline(MiddelVerdi, 'r-', 'LineWidth', 5); % Rød for Middelverdi
plot([MiddelVerdi, (MiddelVerdi + StandardAvvik)], [20, 20], 'g-', 'LineWidth', 5)

% Add labels and title
title('Histogram av Lys-data med Middelverdi og Standardavvik');
xlabel('Lys-verdi');
ylabel('Frekvens');
legend('Lys-data fordeling', ['Middelverdi ' '$\bar{y} = $',num2str(MiddelVerdi, '%.1f'),],['Standardavvik $\sigma = $',num2str(StandardAvvik, '%.1f'),],'Location', 'best');
grid on;
hold off;