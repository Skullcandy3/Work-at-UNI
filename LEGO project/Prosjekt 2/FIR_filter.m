function [FiltrertVerdi] = FIR_filter(Maalinger, AntallMaalinger)
    if length(Maalinger) < AntallMaalinger
        AntallMaalinger = length(Maalinger); 
    end
    
    FiltrertVerdi = (1/AntallMaalinger) * sum(Maalinger(end-AntallMaalinger+1:end));
end
    
% In the works ikke bruk for gudsskyld! 