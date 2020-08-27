function stereo2mono
%STEREO2MONO Bonus function to convert all 2-channel audios inside a folder to mono
% 
%   Converts audios from stereo to mono in order to work with the 
%   speech-to-text Google's API which only accept one-channel audios.
%   Works in a loop across files inside a selected folder.
%   INPUTS:
%          Function will prompt for the folder
%          containing the stereo files to be converted to mono.
%   OUTPUTS:
%          Mono audio files will be automatically saved in a newly
%          created folder named 'mono' located in the audio path.
%
% Author: Alejandro Perez, MRC-CBU, Dec 06, 2019

% Path to the audios 
audio_path = uigetdir([],'Select folder with the stereo audio files');
cd (audio_path);

% Creating directory to save the one-channel audios
mkdir('mono');

% Getting all the audios in the folder.
A = dir('*.wav'); % Audio format

% Loop across the audio files
for i = 1:length(A)
    % Reading the audio
    [real_sound,Fs] = audioread(A(i).name);
    % Averaging the 2 channels
%     real_sound = mean(real_sound,2);
    real_sound = sum(real_sound, 2) / size(real_sound, 2);
    % saving the mono audio
    audiowrite([audio_path filesep 'mono' filesep A(i).name],real_sound,Fs);
end

end

