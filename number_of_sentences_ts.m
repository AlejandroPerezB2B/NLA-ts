function [ns_signal_det,ns_signal_cum] = number_of_sentences_ts(T,audio_signal,Fs)
%NUMBER_OF_SENTENCES_TS   % Returns a number-of-sentence timeserie corresponding to
%                           a list of words and its respective timestamps
%                           as provided by a table.
%   Each time point reflects the relative total number of sentences preceeding
%   that point in the speech block.
%   INPUTS:
%   T              % Table with the fields: T.Words, T.Starts and T.Ends
%   audio_signal   % Audio signal corresponding to the text
%   OUTPUTS:
%   ns_signal_cum  % cumulative signal with the number of words as a
%                    magnitude.
%   ns_signal_5ss  % detrend of the cumulative signal.
%
% Author: Alejandro Perez, MRC-CBU, Jan 04, 2020

% Creating variable for cumulative semtence count
ns_signal_cum = zeros(length(audio_signal),1);

% Finding the end of sentences
point = contains(T.Word,'.');
question = contains(T.Word,'?');
exclamation = contains(T.Word,'!');
sentence = point + question + exclamation; clear question exclamation;

% sanity check
if isempty(find(sentence, 1))
    error('No sentences were detected');
end

% Finding one word sentences
Index1  = strfind(sentence', [1 1]);

% Finding the commas
comma = 2 * contains(T.Word,','); % index for commas will be 2

punctuation = sentence + comma;

% Finding commas before and after sentences. (Most probably interjections)
Index2  = strfind(punctuation', [1 2]);
Index3  = strfind(punctuation', [2 1]);

% Finding commas before and after sentences. (Most probably 'empty expressions')
Index4  = strfind(punctuation', [1 0 2]);
Index5  = strfind(punctuation', [2 0 1]);

% Eliminating one word sentences
if ~isempty(Index1)
    punctuation(Index1+1)=0;
end

% Eliminating commas after a sentence ends
if ~isempty(Index2)
    punctuation(Index2+1)=0;
end

% Eliminating commas before a sentence ends
if ~isempty(Index3)
    punctuation(Index3)=0;
end

% Eliminating commas two words after a sentence ends
if ~isempty(Index4)
    punctuation(Index4+2)=0;
end

% Eliminating commas two words before a sentence ends
if ~isempty(Index5)
    punctuation(Index5)=0;
end

cont = 0; % initializing counter

% loop across the words
for ns = 2:size(punctuation,1)-1 % avoiding one word sentence at the beggining of speech with ns=2
    if punctuation(ns) == 1 || punctuation(ns)==2 % being comma or point (utterances)
        cont = cont + 1;
        S = single(T.Starts(ns)*Fs);
        E = single(T.Starts(ns+1)*Fs);
        ns_signal_cum( S : E) = cont; % onset to offset time related to that word will have a value corresponding to the rank of that word
        ns_signal_cum( E : end) = cont; % to avoid the zeros for the last word in the table
        clear S E;
    end
end
ns_signal_det = detrend(ns_signal_cum); % signal detrended

end