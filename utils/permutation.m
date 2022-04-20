%function [] = permutations(data_sub, c1_idx, c2_idx)
% data_sub is chan x sample x trial
% get means of every condition, mean difference, variance (norm)
% perform group analysis
% repeat 1000 times for every 