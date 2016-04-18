clear all;
close all;
clc;

% Give the information about the data location
% Location of the features
data_directory = ['/data/retinopathy/OCT/SERI/feature_data/' ...
                    'liu_2011/lopo_cv/'];
% Location to store the results
store_directory = ['/data/retinopathy/OCT/SERI/results/' ...
                   'liu_2011/'];
% Location of the ground-truth
gt_file = '/data/retinopathy/OCT/SERI/data.xls';

% Load the csv data
[~, ~, raw_data] = xlsread(gt_file);
% Extract the information from the raw data
% Store the filename inside a cell
filename = { raw_data{ 2:end, 1} };
% Store the label information into a vector
data_label = [ raw_data{ 2:end, 2 } ];
% Get the index of positive and negative class
idx_class_pos = find( data_label ==  1 );
idx_class_neg = find( data_label == -1 );

% poolobj = parpool('local', 48);

% Nunber of B-scans
x_size = 128;

% Pre-allocate where the data will be locate
pred_label_cv = zeros( length(idx_class_pos), 2 );

% Cross-validation using Leave-Two-Patients-Out
for idx_cv_lpo = 1:length(idx_class_pos)
    disp([ 'Round #', num2str(idx_cv_lpo), ' of the L2PO']);

    % Load the data
    filename_cv = ['cv_', num2str(idx_cv_lpo), '.mat'];
    load(strcat(data_directory, filename_cv));
    
    % We need to replicate the training and testing label for the
    % majority voting classification
    training_label_mj = [];
    for i = 1:length(training_label)
        training_label_mj = [training_label_mj ...
                            repmat(training_label(i), 1, x_size)];
    end
    testing_label_mj = [];
    for i = 1:length(testing_label)
        testing_label_mj = [testing_label_mj ...
                            repmat(training_label(i), 1, x_size)];
    end

    % Perform the training of the SVM
    % svmStruct = svmtrain( training_data, training_label );
    SVMModel = fitcsvm(training_data, training_label_mj);
    disp('Trained SVM classifier');
    % Test the performance of the SVM
    % pred_label = svmclassify(svmStruct, testing_data);
    pred_label = predict(SVMModel, testing_data);
    disp('Tested SVM classifier');

    % We need to split the data to get a prediction for each volume
    % tested
    % Compute the majority voting for each testing volume
    maj_vot = [ mode(pred_label(1:x_size)) ...
                mode(pred_label(x_size + 1:end))];

    pred_label_cv( idx_cv_lpo, : ) = maj_vot;    
    disp('Applied majority voting');
end

save(strcat(store_directory, ['predicition_linear_maj_vot.mat']), 'pred_label_cv');

%delete(poolobj);