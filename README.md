Biomedical Signal Processing & Biomedical Images
PROJECT
Abbiamo:
        ◦ 8 h di registrazione EEG
        ◦ 512 Hz
        ◦ In sede frontale (SS 10-20 ipoteticamente FP1)
Vogliamo:
    •  caratterizzare le fasi del sonno del paziente (stage NREM 1/2/3/4 e REM)
Metodo:
    • Pre-processing del segnale (filtraggio in banda [0.1-90 Hz] + rimozione della 50 Hz)
    • Attraverso la stima dello spettro di densità di potenza di epoche lunghe 3 minuti che avviene con il periodogramma modificato di Bartlett il quale utilizza finestra di Hann/Hamming lunga 30 secondi.
        ◦ 
    • Per ogni PSD (Spettro di Densità di Potenza) Γ(f) ottenuto si esegue il seguente procedimento:
        ◦ 
        ◦ 
