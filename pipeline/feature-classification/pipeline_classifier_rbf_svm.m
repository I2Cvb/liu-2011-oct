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

% Number of words in the BoW
k = 40;

% Pre-allocate where the data will be locate
pred_label_cv = zeros( length(idx_class_pos), 2 );

% Cross-validation using Leave-Two-Patients-Out
for idx_cv_lpo = 1:length(idx_class_pos)
    disp([ 'Round #', num2str(idx_cv_lpo), ' of the L2PO']);

    % Load the data
    filename_cv = ['cv_', num2str(idx_cv_lpo), '.mat'];
    load(strcat(data_directory, filename_cv));

    % Applying BoW on the data 
    [idxs C] = kmeans(training_data,k);
    training_histogram=[];
    for train_id = 1 : x_size : size(training_data,1)
        [knn_idxs D] = knnsearch( C, training_data(train_id : train_id ...
                                                   + x_size - 1,:));
        histogram = hist(knn_idxs,k);
        norm_histogram = histogram ./ sum(histogram);
        training_histogram = [training_histogram; norm_histogram];
    end
    disp('Creation of training set using BoW');
    training_data = training_histogram;

    testing_histogram = [];
    for test_id = 1 : x_size : size(testing_data,1)
        [knn_idxs D] = knnsearch( C, testing_data(test_id : test_id ...
                                                  + x_size - 1,:));
        histogram = hist(knn_idxs,k);
        norm_histogram = histogram ./ sum(histogram);
        testing_histogram=[testing_histogram; norm_histogram];
    end
    testing_data = testing_histogram;
    disp('Creation of testing set using BoW');
    
    % Perform the training of the SVM
    % svmStruct = svmtrain( training_data, training_label );
    SVMModel = fitcsvm(training_data, training_label, 'Standardize', ...
                       true, 'KernelFunction','RBF', 'KernelScale', ...
                       'auto');
    disp('Trained SVM classifier');
    % Test the performance of the SVM
    % pred_label = svmclassify(svmStruct, testing_data);
    pred_label = predict(SVMModel, testing_data);
    disp('Tested SVM classifier');


    pred_label_cv( idx_cv_lpo, : ) = pred_label;    
    disp('Applied majority voting');
end

save(strcat(store_directory, ['predicition_rbf_k_', num2str(k), ...
                    '.mat']), 'pred_label_cv');

%delete(poolobj);