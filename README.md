# EEGManyPipelines

This repository contains the code for the [EEGManyPipelines](https://www.eegmanypipelines.org/) project from the Brain Data Lab team.

The data is assumed to be in EEGLAB format. The main functions are: 

- A_preprocess.m (preprocessing of the EEG data in FieldTrip)
- B_get_gata.m (deriving voltage/time-frequency matrices for further analysis) 
- C_statistics.m (statistical analysis of voltage and spectral power, multiple comparisons correction)

The letters describe the intended order of running the scripts. /utils contains utility functions used in the main scripts, path definitions and so on. 

Dependencies not included in the repository: FieldTrip 2021.
