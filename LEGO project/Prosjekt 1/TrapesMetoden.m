function Nyverdi = TrapesMetoden(Forverdi, Tidsskritt, Forverdifunskjon, Nyverdifunksjon)
    Nyverdi = Forverdi + (Tidsskritt / 2) * (Forverdifunskjon + Nyverdifunksjon);
end

%Merk at du må gi navnet på filen det samme Navnet som funksjonen heter: "TrapesMetoden.m"