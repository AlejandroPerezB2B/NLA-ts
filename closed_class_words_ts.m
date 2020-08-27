function [cc_signal_cum] = closed_class_words_ts(T)
%CLOSED_CLASS_WORDS_TS  % Returns a timeserie corresponding to the
%                       proportion of closed-class for each given time point.
%                       This is #closed-class/#total words.
%
%   Each time point reflects the relative total number of closed-class words 
%   preceeding that point in the speech block.
%   INPUTS:
%   T              % A list of words with its respective timestamps 
%                    as provided by a table with the fields: T.Words, T.Starts and T.Ends.
%   OUTPUTS:
%   cc_signal_cum  % signal with the number of closed-class words as a
%                    magnitude.
%
% Author: Alejandro Perez, MRC-CBU, Dec 20, 2019

% Creating the document
newStr = join(T.Word);

% Convert document to lowercase
newStr = lower(newStr);

% Tokenize the text.
cleanedDocuments = tokenizedDocument(newStr);
tdetails = tokenDetails(cleanedDocuments);
mask = size(find(ismember(tdetails{:,4}, 'punctuation')),1);

% add part-of-speech tags to documents i.e. noun, verb, adjective, ...
cleanedDocuments = addPartOfSpeechDetails(cleanedDocuments);
tdetails = tokenDetails(cleanedDocuments);

% Erase punctuation.
cleanedDocuments = erasePunctuation(cleanedDocuments);
tdetails = tokenDetails(cleanedDocuments);

% Removing the added 'particles' e.g. didn't -> did + nt. The 'nt' is
% removed, mantaining otherwise the same amount of words as in the original
% document.
mask = ismember(tdetails{:,7}, 'particle');
tdetails(mask,:) = [];
clear mask;

% Sanity check since the length of resulting document should be equal to
% the length of the original document
if size(tdetails,1) ~=  size(T,1)
  warndlg('There is an issue with the number of words in the function CLOSED_CLASS_WORDS_TS','Warning');
end

cc_signal_cum = zeros(length(audio_signal),1); % signal for the closed-class proportion
count_cc = 0; % Initializing a counter of the closed-class words

% loop across the words
for nm = 1: size(T,1)-1
    if (tdetails.PartOfSpeech(nm) == 'pronoun') || ...
            (tdetails.PartOfSpeech(nm) == 'numeral') || ...
            (tdetails.PartOfSpeech(nm) == 'adposition') || ...
            (tdetails.PartOfSpeech(nm) == 'coord-conjunction') || ...
            (tdetails.PartOfSpeech(nm) == 'determiner') || ...
            (tdetails.PartOfSpeech(nm) == 'auxiliary-verb')
 count_cc = count_cc + 1;
    end

    S = single(T.Starts(nm)*1000);
    E = single(T.Starts(nm+1)*1000);
    cc_signal_cum( S : E) = count_cc/nm; % onset to offset time related to that word will have a value corresponding to the rank of that word
    cc_signal_cum( E : end) = count_cc/nm; % to avoid the zeros for the last word in the table
    clear S E;
end 
 
end

