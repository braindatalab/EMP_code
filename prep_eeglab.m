%% EEGLAB preprocessing pipeline
% eeglab nogui
%% import data
datapath = '/Users/work/Desktop/EMP/EMP_data/';
fn = 'EMP01.set';
filepath = [datapath fn];
EEG = pop_loadset(fn,datapath);
%% prep
params.name = 'EMP';
params.lineFrequencies = [50 100];
EEG = prepPipeline(EEG,params);