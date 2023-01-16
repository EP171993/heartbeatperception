addpath('C:\Users\Eleonora Parrotta\Desktop\MyExperiments\Interoception_exp\1_heartbeat perception\heartbeat_experiment 1_SRBOX\Dati')

[~, typeclean, ~ ] = xlsread('001.xlsx',1,'dk2:dk25');


tapping_heart = importdata ('001.xlsx',2,'a:x');
tapping_heart = tapping_heart.data.heart ;

tapping_warning = importdata ('001.xlsx',3,'a:x');
tapping_warning = tapping_warning.data.warning;

data = load('C:\Users\r01ep20\Desktop\MyExperiments\Interoception_exp\1_heartbeat perception\datiecg\exp_001.mat');
data = data.data;

d0=find(data(:,4)); % prendi il tempo dall'inizio del primo trigger primo trial (trigger su quarta colonna)
utile = data(d0(1):end,:); %taglia la registrazione dal tempo 1 di d0 (taglia dall'inizio dell'esperimento fino alla fine)


%ESTRAZIONE PICCO
control = find(data(:,5));
control_start = control(1);
for i=2:length(control) %estrapola tutti gli start (NUMERO RIGA) di control (inizio picco)
    if (control(i)-control(i-1))>2
        control_start=[control_start; control(i)]; %#ok<AGROW>
    end
end
control_start_time = control_start*0.5; %trasformi punti picchi nel tempo

%ESTRAZIONE TEMPO TRIGGER
trigger_trial = find(data(:,4)); %seleziona canale che triggera inizio e fine trial heart e warning
trigger_start_trial = trigger_trial(1);
for i=2:length(trigger_trial) %estrapola tutti gli start (NUMERO RIGA) di ogni trigger_trial (1-inizio heart, 2-fine heart/inizio warning, 3-fine warning)
    if (trigger_trial(i)-trigger_trial(i-1))>2
        trigger_start_trial = [trigger_start_trial; trigger_trial(i)]; %#ok<AGROW>
    end
end

trigger_start_time = trigger_start_trial*0.5;%trasformi punti trigger nel tempo

diff_trigger = diff(trigger_start_time);
indice_diff_trig = 2:3:length(diff_trigger);
trial_catch = find(diff_trigger(indice_diff_trig) < 15000);
trig_da_eliminare = (trial_catch*3)-2;
trigger_start_time_clean = trigger_start_time;
trigger_start_trial_clean = trigger_start_trial;

tapping_warning(:,trial_catch) = [];%rimuovi catch dal tapping_warning
tapping_heart(:,trial_catch) = []; %rimuovi catch dal tapping_heart
typeclean(trial_catch)=[ ]; %rimuovi catch dalle condizioni safe pain


for j= length(trial_catch):-1:1 %rimuovi catch da tutti i trigger
    trigger_start_time_clean(trig_da_eliminare(j):trig_da_eliminare(j)+2)=[ ];
    trigger_start_trial_clean(trig_da_eliminare(j):trig_da_eliminare(j)+2)=[ ];
end

%% ECG
%% calcolo media battiti per tipo di trial (R-R) WARNING CONDITION
heartbeat_warning_trial=[];
trial_num =[];
heartbeat_warning_trial_freq=[];

for ind = 1:length(typeclean) % per ogni trial
    ind_1 = (ind-1)*3+1;
    inizio_wind = trigger_start_time_clean(ind_1+1);
    for i=1:12 %per tutti gli intervalli di tempo con finestra da 6sec prendi tutti i picchi (control) compresi in ognuno degli intervalli
        fine_wind = inizio_wind + 3500;
        index_time_warning = find(control_start_time < fine_wind & control_start_time > inizio_wind);
        index_time_values_warning = control_start_time(index_time_warning); %differenza R-R diviso 1000 (perche sono millisecondi)
        heartbeat_warning_trial_freq=[heartbeat_warning_trial_freq; 60/(mean(diff(index_time_values_warning))/1000)];
        heartbeat_warning_trial = [heartbeat_warning_trial; length(index_time_values_warning)]; 
        trial_num=[trial_num; ind];%#ok<AGROW> %60/la media delle differenze (hr) quindi 4 valori per ogni trial
        inizio_wind = inizio_wind + 1500;   %sposta la finestra dove calcoli la media di 2 sec
    end
end

time_warn = [
21.75;
23.25;
24.75;
26.25;
27.75;
29.25;
30.75;
32.25;
33.75;
35.25;
36.75;
38.25];

% crea time
alltimewarn=[];
for i=1:20
for m=1:12
alltimewarn =[alltimewarn;time_warn(m,1)];
end
end

%crea stringhe cond
alltrials=[];
for i=1:length(typeclean)
   trial = typeclean(i,1)
   alltrials = [alltrials; repmat(trial,12,1)]
end

%crea trialnum
trialnumber=[1; 2; 3; 4; 5; 6;7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 20];
alltrialnum=[];

for i = 1: 20
    trialn=trialnumber(i,1)
    for i=1:12
alltrialnum =[alltrialnum;trialn];
end
end

% calcolo media battiti per tipo di trial (R-R) HEART CONDITION
heartbeat_heart_trial=[];
heartbeat_heart_trial_freq=[];
for ind = 1:length(typeclean) % per ogni trial
    ind_1 = (ind-1)*3+1;
    inizio_wind = trigger_start_time_clean(ind_1);
    for i=1:12 %per tutti gli intervalli di tempo con finestra da 6sec prendi tutti i picchi (control) compresi in ognuno degli intervalli
       fine_wind = inizio_wind + 3500;
       index_time_heart = find(control_start_time < fine_wind & control_start_time > inizio_wind);
       index_time_values_heart = control_start_time(index_time_heart);
       heartbeat_heart_trial_freq=[heartbeat_heart_trial_freq; 60/(mean(diff(index_time_values_heart))/1000)];
       heartbeat_heart_trial = [heartbeat_heart_trial; length(index_time_values_heart)]; %#ok<AGROW> %60/la media delle differenze (hr) quindi 4 valori per ogni trial
       inizio_wind = inizio_wind + 1500;   %sposta la finestra dove calcoli la media di 2 sec
    end   
end 


time_base = [
    1.75;
    3.25;
    4.75;
    6.25;
    7.75;
    9.25;
    10.75;
    12.25;
    13.75;
    15.25;
    16.75;
    18.25;];

% crea time
alltimebase=[];
for i = 1: 20
for m=1:12
alltimebase =[alltimebase;time_base(m,1)];
end
end

%% TAPPING 
%Ricalcolo tempo tapping GIANNI version
tapping_warning_time = [];

for ind=1:length(typeclean)
    ind_1 = (ind-1)*3+1;
    len = find(tapping_warning(:,ind))
    tapping_warning_time = [tapping_warning_time; tapping_warning(len,ind)+ trigger_start_time_clean(ind_1+1)];
end

tapping_heart_time = [];

for ind=1:length(typeclean)
    ind_1 = (ind-1)*3+1;
    len = find(tapping_heart(:,ind))
    tapping_heart_time = [tapping_heart_time; tapping_heart(len,ind)+ trigger_start_time_clean(ind_1)];
end


%% TAPPING SLIDING WARNIGN

tapping_warning_trial=[];
tapping_warning_trial_freq=[];
 for ind = 1:length(typeclean) % per ogni trial
    ind_1 = (ind-1)*3+1;
    inizio_wind = trigger_start_time_clean(ind_1+1);
    for i=1:12 %per tutti gli intervalli di tempo con finestra da 6sec prendi tutti i picchi (control) compresi in ognuno degli intervalli
        fine_wind = inizio_wind + 3500;
        index_time_warning = find(tapping_warning_time < fine_wind & tapping_warning_time > inizio_wind);
        index_time_values_warning = tapping_warning_time(index_time_warning);
        tapping_warning_trial_freq=[tapping_warning_trial_freq; 60/(mean(diff(index_time_values_warning))/1000)];
        tapping_warning_trial = [tapping_warning_trial; length(index_time_values_warning)]; %#ok<AGROW> %60/la media delle differenze (hr) quindi 4 valori per ogni trial
        inizio_wind = inizio_wind + 1500;   %sposta la finestra dove calcoli la media di 2 sec
    end   
 end 
 
% TAPPING SLIDING BASELINE
tapping_heart_trial=[];
tapping_heart_trial_freq=[];
for ind = 1:length(typeclean) % per ogni trial
    ind_1 = (ind-1)*3+1;
    inizio_wind = trigger_start_time_clean(ind_1);
    for i=1:12 %per tutti gli intervalli di tempo con finestra da 6sec prendi tutti i picchi (control) compresi in ognuno degli intervalli
        fine_wind = inizio_wind + 3500;
        index_time_heart = find(tapping_heart_time < fine_wind & tapping_heart_time > inizio_wind);
        index_time_values_heart = tapping_heart_time(index_time_heart);
        tapping_heart_trial_freq=[tapping_heart_trial_freq; 60/(mean(diff(index_time_values_heart))/1000)];
        tapping_heart_trial = [tapping_heart_trial; length(index_time_values_heart)]; %#ok<AGROW> %60/la media delle differenze (hr) quindi 4 valori per ogni trial
        inizio_wind = inizio_wind + 1500;   %sposta la finestra dove calcoli la media di 2 sec
    end   
end 


subject_size = [alltrials];
sz_sub = size(subject_size);
subject = strings(sz_sub);
subject(:,1) = 's1';


dati1=[subject, heartbeat_heart_trial, heartbeat_heart_trial_freq, tapping_heart_trial, tapping_heart_trial_freq, alltrials, alltimebase, alltrialnum];

dati2=[subject, heartbeat_warning_trial, heartbeat_warning_trial_freq, tapping_warning_trial, tapping_warning_trial_freq, alltrials, alltimewarn,alltrialnum];

data_take=[dati1;dati2];