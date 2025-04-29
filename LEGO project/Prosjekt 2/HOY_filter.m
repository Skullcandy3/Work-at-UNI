function [FiltrertHOY] = HOY_filter(Forfiltrertverdi, Maaling, Parameter)

    FiltrertHOY = Parameter*Forfiltrertverdi + Parameter*(Maaling(2) - Maaling(1));
    end
    
    