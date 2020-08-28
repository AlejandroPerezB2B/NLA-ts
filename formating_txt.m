function formating_txt
%FORMATING_TXT  .txt files obtained from the Google Cloud Shell
%               (speech-to-text) are formated to .csv
%   This function works over .TXT files created by using the procedure
%   described below:
%   1.- Run the command: "gcloud alpha ml speech recognize-long-running etc. etc."
%       to create a file containing the speech-to-text transcription in .JSON format.
%   2.- Copy the number printed in the cloud shell related to that operation, e.g. 1234567890
%   3.- Convert the .JSON file to .TXT by using the command:
%       "gcloud alpha ml speech operations --format=text describe 1234567890> filename.txt"
%   4.- Download the newly created .TXT file by using:
%       "cloudshell download filename.txt"
%   FORMATING_TXT converts the .TXT files to a .csv format with a particular
%   structure that will be assumed by the timeseries (i.e. xxx_ts) functions.
%   Works in a loop across files inside a selected folder.
%   INPUTS:
%           % Function will prompt for the path of the folder
%             containing the files to be converted to the desired format.
%   OUTPUTS:
%           % Formated files will be automatically saved in the same
%             folder
%
% Author: Alejandro Perez, MRC-CBU, Dec 18, 2019

text_path = uigetdir([],'Select folder with the transcribed audio files');
cd (text_path);

% specify how to import tabular data from the delimited .TXT file
varNames = {'response_type','conf_end_start_word'};
varTypes = {'char','char'};
delimiter = ':';
dataStartLine = 9; % check this value since it could variate
% extraColRule = 'ignore';
opts = delimitedTextImportOptions('VariableNames',varNames, ...
'VariableTypes',varTypes,'Delimiter',delimiter,'DataLines', dataStartLine, ...
'Encoding','UTF-8');

% Getting all the .txt files in the folder
A = dir('*.txt');

% Loop across the .txt files
for i = 1:length(A)
    display([A(i).name ' case ' num2str(i)]);
    
    % Reading the .txt as a table by using the declared import parameters
    T = readtable(A(i).name,opts);
    
    % Finding the rows containing 'languageCode' in order to remove it
    kk = find(endsWith(cellstr(T.response_type),'languageCode'));
    
    % The following are conditionals to deal with the possibility of having
    % a 'languageCode' in the last row of the table.
    % This will lead to an error if you try to remove any row after.
    if kk(end)==size(T,1)
        T(kk(end),:)=[]; kk(end)=[];
    elseif kk(end)==size(T,1) - 1
        T(kk(end):end,:)=[]; kk(end)=[];
    elseif kk(end)==size(T,1) - 2
        T(kk(end):end,:)=[]; kk(end)=[];
    end
    
    % The row with 'languageCode' could be followed by 2 other rows that
    % should be also removed since they also contain irrelevant info.
    %     kk=[kk;kk+1;kk+2]; % comment if it is not the case
    T(kk,:)=[];
    
    % Finding the rows containing 'transcript' in order to remove it
    kk1 = find(endsWith(cellstr(T.response_type),'transcript'));
    
    % The following are conditionals to deal with the possibility of having
    % a 'transcript' in the last row of the table.
    % This will lead to an error if you try to remove any row after
    if kk1(end)==size(T,1)
        T(kk1(end),:)=[]; kk1(end)=[];
    elseif kk1(end)==size(T,1) - 1
        T(kk1(end):end,:)=[]; kk1(end)=[];
    elseif kk1(end)==size(T,1) - 2
        T(kk1(end):end,:)=[]; kk1(end)=[];
    end
    
    T(kk1,:)=[];
    
    % The row with 'transcript' could be followed (also preceeded in
    % weird cases) by a 'confidence' row that should be also removed.
    % Thus, we are including a check for confidence not related to words but excerpts.
    
    kk2 = find(endsWith(cellstr(T.response_type),'confidence'));
    varS2 = [];
    
    for conf=1:length(kk2)
        varT1 = table2cell(T(kk2(conf),1)); varT1 = varT1{1};
        punto = strfind(varT1,'.');
        varS1 = varT1(punto(end-1)+1:punto(end-1)+4);
        if ~strcmp(varS1,'word')
            varS2 = [varS2 kk2(conf)];
        end
    end
 
    T(varS2,:)=[];
    
    % Finding the info we want to keep in the formated (.csv) table
    kkw = endsWith(cellstr(T.response_type),'word');
    kkc = endsWith(cellstr(T.response_type),'confidence');
    kks = endsWith(cellstr(T.response_type),'startTime');
    kke = endsWith(cellstr(T.response_type),'endTime');
    
    kkw = cellstr(T.conf_end_start_word(kkw));
    kkc = cellstr(T.conf_end_start_word(kkc));
    kks = cellstr(T.conf_end_start_word(kks));
    kke = cellstr(T.conf_end_start_word(kke));
    % Strings corresponding to time ends with 's' to indicate seconds e.g. '60.400s'
    % Replacing the character right before the end of string with nothingness
    kks = regexprep(kks, '.$', '', 'lineanchors');
    kke = regexprep(kke, '.$', '', 'lineanchors');
    
    % Creating a new table with the desired format
    T_new = table('Size',[size(T,1)/4 4],'VariableTypes',{'string','double','double','double'},'VariableNames',{'Word','Confidence','Starts','Ends'} );
    T_new.Word = kkw;
    T_new.Confidence = str2double(kkc);
    T_new.Starts = str2double(kks);
    T_new.Ends = str2double(kke);
    
    % Saving the table
    writetable(T_new,[A(i).name(1:end-4) '.csv']);
    clear kk* T* var*;
end

end

