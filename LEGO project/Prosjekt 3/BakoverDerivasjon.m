function [Derivertverdi] = BakoverDerivasjon(Funksjonverdi,Tidsskritt)
    Derivertverdi = (Funksjonverdi(2) - Funksjonverdi(1)) / Tidsskritt;
end

