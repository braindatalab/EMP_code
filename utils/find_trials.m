function [man,nat,old,new,hit,miss,rem,forg] = find_trials(trialinfo)
% finds index of trials by trial info
trials = num2str(trialinfo); %convert to char array
% first digit indicates manmade vs natural
man = find(trials(:,1)=='1'); 
nat = find(trials(:,1)=='2');
% second digit indicates old vs new 
new = find(trials(:,2)=='0');
old = find(trials(:,2)=='1');
% third digit indicates correct recognition
hit = find(trials(:,3)=='1'); %3rd digit indicates hit = 1, miss = 2, na = 9, corrrej = 4, false alarm = 3
miss = find(trials(:,3)=='2');
%4th digit indicates rememembered vs forgotten
rem = find(trials(:,4)=='1'); 
forg = find(trials(:,4)=='0');
end