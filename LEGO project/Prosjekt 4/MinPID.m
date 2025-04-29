function [P, I_ny, D, e_f_ny] = MinPID(I_for, e_f_for, e, T_s, para)
    % -------------------------------------------------------------
    % Parametere
    % -------------------------------------------------------------
    Kp = para(1);
    Ki = para(2);
    Kd = para(3);
    I_max = para(4);
    I_min = para(5);
    alfa = para(6);
    
    % -------------------------------------------------------------
    % Beregning av PID-komponentene
    % Benytter end slik at vi ungår å benytte k for å komme gjennom alle maalinger og ikke får index error!
    % -------------------------------------------------------------
    P = Kp * e(end); % Proposjonal del 
    
    % Integral del med trapesmetoden
    I_ny = TrapesMetoden(I_for, T_s, e(end-1), e(end)) * Ki;
    
    % Begrensning av integral
    I_ny = max(I_min, min(I_max, I_ny));
    
    % Filtrert feil for derivatleddet
    e_f_ny = IIR_filter(e_f_for, e(end), alfa);
    
    % Derivatledd med bakoverderivasjon
    D = BakoverDerivasjon([e(end-1), e(end)], T_s) * Kd;
    
    % -------------------------------------------------------------
    % Begrensning av utsignal u
    % -------------------------------------------------------------
    u = P + I_ny + D;
    
    if u > 100
        u = 100;
        I_ny = I_for; % Stopper integralet fra å øke
    elseif u < -100
        u = -100;
        I_ny = I_for;
    end
    
    end
    