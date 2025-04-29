function [FiltrertIIR] = IIR_filter(Forfiltrertverdi, Maaling, Parameter)

    FiltrertIIR = ((1 - Parameter) * Forfiltrertverdi + Parameter * Maaling);
    end    