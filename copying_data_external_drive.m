%% organising data in the external drive My Passport

% path to EEG data at Surrey's OneDrive (pre-defined)
% data_path = 'C:\Users\ap0082\OneDrive - University of Surrey\Alejandro\Experiment3_closed-loop\';
data_path = 'C:\Users\ap0082\OneDrive - University of Surrey\Documents\Tecnalia\ExpData\';
cd(data_path);

% getting folders corresponding to each subject and organising data paths
A = dir ('subj*');
A = struct2table(A);

A.BCI2000_folder = append(A.folder, filesep, A.name, '\Experiment\BCI2000\');

for i=5:height(A) % loop across the participants (16)

 bci_path = char(A.BCI2000_folder(i));
 save_path = ['D:\Tecnalia_data\' A.name{i}];
 mkdir(['D:\Tecnalia_data\' A.name{i}]);

    cd(bci_path);
    % getting the info of the blocks. recordings have '.dat' extension
    BCI = dir('*.dat');

    % Var to contain the each blocks onset on the continous BV recording
    blockLatency = []; 

    for i1 = 1:length(BCI) % loop across (4) blocks

        % loading data
        EEG_BCI = pop_loadBCI2000(BCI(i1).name); %, {'PhaseInSequence','StimulusBegin','StimulusCode'});

        % Saving BCI2000 data in eeglab format
        pop_saveset( EEG_BCI, 'filename',['block_' num2str(i1) '_' BCI(i1).name(1:end-4) '.set'],'filepath',save_path);

    end
end

%%


% path to EEG data at Surrey's OneDrive (pre-defined)
data_path = 'C:\Users\ap0082\OneDrive - University of Surrey\Documents\Tecnalia\ExpData\';
cd(data_path);

% getting folders corresponding to each subject and organising data paths
A = dir ('subj*');
A = struct2table(A);

A.BCI2000_folder = append(A.folder, filesep, A.name, '\Experiment\SavedSessions\');

for i=1:height(A) % loop across the participants (16)

 bci_path = char(A.BCI2000_folder(i));
 save_path = ['D:\Tecnalia_data\' A.name{i} '\'];
%  mkdir(['D:\Tecnalia_data\' A.name{i}]);

    cd(bci_path);
    % getting the info of the blocks. recordings have '.dat' extension
    copyfile('*.mat',save_path);

end