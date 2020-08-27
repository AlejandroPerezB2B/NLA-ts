function [nw_signal_det,nw_signal_cum] = number_of_words_ts(T,audio_signal,Fs)
%NUMBER_OF_WORDS_TS   % Returns a number-of-words timeserie corresponding to
%                       a list of words with corresponding timestamps, 
%                       as provided by a table.
%   Each time point reflects the relative total number of words preceeding 
%   that point in the speech block.
%   INPUTS:
%   T              % Table with the fields: T.Words, T.Starts and T.Ends
%   audio_signal   % Audio signal corresponding to the text
%   OUTPUTS:
%   nw_signal_cum  % cumulative signal with the number of words as a
%                    magnitude.
%   nw_signal_det  % detrend of the cumulative signal.
%
% Author: Alejandro Perez, MRC-CBU, Dec 20, 2019

% Creating variable for cumulative word count
nw_signal_cum = zeros(length(audio_signal),1);

% loop across the words
for nw = 1: size(T,1)-1
    S = single(T.Starts(nw)*Fs);
    E = single(T.Starts(nw+1)*Fs); % words ends when the next starts
    nw_signal_cum( S : E) = nw; % onset to offset time related to that word will have a value corresponding to the rank of that word
    nw_signal_cum( E : end) = nw; % to avoid the zeros for the last word in the table
    clear S E;
end 
nw_signal_det = detrend(nw_signal_cum); % signal detrended

end

