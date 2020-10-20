function speech2text_from_MATLAB(API_type)
%SPEECH2TEXT_FROM_MATLAB    Execute the speech recognition by using
%                           the function speech2text.m available at:
%                           https://www.mathworks.com/matlabcentral/fileexchange/65266-speech2text
%               Works in a loop across files inside a selected folder.
%               WARNING! speech2text doesn't work for long audios.
%               It means, LongRunningRecognize or any streaming speech recognition
%               is not supported by speech2text package at this point.
%               Note: by typing 'audioLabeler' at the command window
%               will open the app (GUI).
%   INPUTS:
%   API_type       % API speech client you are going to use
%                   'Google' or 'IBM'
%   OUTPUTS:
%                  % For each audio inside the selected folder, a table in
%                    .csv format containing the audio transcription is 
%                    created and saved.
%
% Author: Alejandro Perez, MRC-CBU, Dec 6, 2019

% Depending on the API of choice, the function ask for the API credential (key)
% (e.g. 'U:\Matlab_functions\Google_Credentials_Speech2text.json')
% and declares the speechObject containing all your desired options.
switch API_type
    case 'Google'
        [file,path] = uigetfile('*.json', 'Select a Google Credentials file');
        API_key = [path file];
        % Desired options should be set manually.
        speechObject = speechClient('Google','LongRunningRecognize','languageCode','en-US','encoding','linear16');
    case 'IBM'
        [file,path] = uigetfile('*.json', 'Select a IBM Credentials file');
        API_key = [path file];
        % Desired options should be set manually.
        speechObject = speechClient('IBM','keywords',"example,keywords",'keywords_threshold',0.5);
    otherwise
        error('API type not supported. Please check the spelling.')
end

% Data path
audio_path = uigetdir([],'Select folder with the stereo audio files');
cd (audio_path);

% Getting all the audios in the folder.
A = dir('*.wav'); % Audio format

% Loop across the audio files
for i = 1:length(A)
    % Reading audio
    [real_sound,Fs] = audioread(A(i).name);
    % Transcription
    tableOut = speech2text(speechObject,real_sound,Fs);
    % Saving the table with the text
    writetable(tableOut, [A(i).name(1:end-4) '.csv']);
end

end

