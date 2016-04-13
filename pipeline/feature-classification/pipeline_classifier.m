clear all;
close all;
clc;

% Give the information about the data location
% Location of the features
data_directory_original_lbp = ['/data/retinopathy/OCT/SERI/feature_data/' ...
                    'liu_2011/original_lbp/'];
data_directory_canny_lbp = ['/data/retinopathy/OCT/SERI/feature_data/' ...
                    'liu_2011/canny_lbp/'];
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

% Pre-allocate where the data will be locate
pred_label_cv = zeros( length(idx_class_pos), 2 );

% Cross-validation using Leave-Two-Patients-Out
for idx_cv_lpo = 1:length(idx_class_pos)
    disp([ 'Round #', num2str(idx_cv_lpo), ' of the L2PO']);

    % The two patients for testing will corresspond to the current
    % index of the cross-validation

    % Initialization of training and testing
    testing_data = [];
    testing_data_tem = []; 
    testing_data_org_lbp = [];
    testing_label = [];
    training_data = [];
    training_data_tem = []; 
    training_label = [];
    training_data_org_lbp = [];
    
    % load the original LBP data
    % Loading the testing temporary data 
    % Load the positive patient
    load( strcat( data_directory_original_lbp, filename{ idx_class_pos(idx_cv_lpo) } ) );
    % Concatenate the data
    testing_data_tem = [ testing_data_tem ; lbp_feat ];
    % Create and concatenate the label
    testing_label = [ testing_label (1 * ones(1, 1)) ];
    % Load the negative patient
    load( strcat( data_directory_original_lbp, filename{ idx_class_neg(idx_cv_lpo) } ) );
    % Concatenate the data
    testing_data_tem = [ testing_data_tem ; lbp_feat ];
    % Create and concatenate the label
    testing_label = [ testing_label (-1 * ones(1, 1)) ];

    disp('Loaded the testing set');
    
    % Number of the slices per volume 
    B_scans = size(lbp_feat, 1);

    % Loadind the training temporary file 
    for tr_idx = 1:length(idx_class_pos)
        % Consider only the data which where not used for the
        % testing set
        if ( tr_idx ~= idx_cv_lpo)
            % Load the positive patient
            load( strcat( data_directory_original_lbp, filename{ idx_class_pos(tr_idx) ...
                   } ) );
            % Concatenate the data
            training_data_tem = [ training_data_tem ; lbp_feat ];
            % Create and concatenate the label
            training_label = [  training_label (1 * ones(1, 1)) ];
            % Load the negative patient
            load( strcat( data_directory_original_lbp, filename{ idx_class_neg(tr_idx) ...
                   } ) );
            % Concatenate the data
            training_data_tem = [ training_data_tem ; lbp_feat ];
            % Create and concatenate the label
            training_label = [  training_label (-1 * ones(1, 1)) ];
        end
    end
    disp('Loaded the training set')
    
    % PCA should be applied according to each pyramid level 
    % pyr_info, feat_desc_dim
    for lev = 1 : size(pyr_info,1)
        % Make PCA decomposition keeping the 59 (equal to the size of uniform lbp) first components which
        % are the one > than 0.1 % of significance
        training_data_lev = training_data_tem(:, pyr_info(lev,1) : ...
                                           pyr_info(lev,2) );
        training_data_lev_patch = reshape(training_data_lev, [size(training_data_tem,1) * pyr_info(lev,4) , feat_desc_dim]); 
        
        % training a PCA model based on the training to reduce the
        % lbp dimensions to 59 
        [coeff, score, latent, tsquared, explained, mu] = ...
        pca(training_data_lev_patch, 'NumComponents', 59);
        % Apply the transformation to the training data
        clear training_data_lev_patch training_data_lev
        training_data_lev = reshape(score, [size(training_data_tem, 1)  , pyr_info(lev,4) * 59]); 
        training_data_org_lbp = [training_data_org_lbp, training_data_lev];
        
        % Apply the transformation to the testing data
        % Remove the mean computed during the training of the PCA
        testing_data_lev = testing_data_tem(:, pyr_info(lev,1) : pyr_info(lev,2)); 
        testing_data_lev_patch = reshape(testing_data_lev, [size(testing_data_tem,1) * pyr_info(lev,4), feat_desc_dim]); 
        clear testing_data_lev
        testing_data_lev = reshape(((bsxfun(@minus, testing_data_lev_patch, mu)) * coeff), [size(testing_data_tem,1) , pyr_info(lev,4) * 59] ) ; 
        testing_data_org_lbp = [testing_data_org_lbp, testing_data_lev]; 
        
    end 
    disp('Projected the data using PCA for the original LBP');

    % Initialization of training and testing
    testing_data_tem = []; 
    testing_data_canny_lbp = [];
    training_data_tem = []; 
    training_data_canny_lbp = [];    
    
    % load the original LBP data
    % Loading the testing temporary data 
    % Load the positive patient
    load( strcat( data_directory_canny_lbp, filename{ idx_class_pos(idx_cv_lpo) } ) );
    % Concatenate the data
    testing_data_tem = [ testing_data_tem ; lbp_feat ];
    % Load the negative patient
    load( strcat( data_directory_canny_lbp, filename{ idx_class_neg(idx_cv_lpo) } ) );
    % Concatenate the data
    testing_data_tem = [ testing_data_tem ; lbp_feat ];

    disp('Loaded the testing set');
    
    % Number of the slices per volume 
    B_scans = size(lbp_feat, 1);

    % Loadind the training temporary file 
    for tr_idx = 1:length(idx_class_pos)
        % Consider only the data which where not used for the
        % testing set
        if ( tr_idx ~= idx_cv_lpo)
            % Load the positive patient
            load( strcat( data_directory_canny_lbp, filename{ idx_class_pos(tr_idx) ...
                   } ) );
            % Concatenate the data
            training_data_tem = [ training_data_tem ; lbp_feat ];
            % Load the negative patient
            load( strcat( data_directory_canny_lbp, filename{ idx_class_neg(tr_idx) ...
                   } ) );
            % Concatenate the data
            training_data_tem = [ training_data_tem ; lbp_feat ];
        end
    end
    disp('Loaded the training set')
    
    % PCA should be applied according to each pyramid level 
    % pyr_info, feat_desc_dim
    for lev = 1 : size(pyr_info,1)
        % Make PCA decomposition keeping the 59 (equal to the size of uniform lbp) first components which
        % are the one > than 0.1 % of significance
        training_data_lev = training_data_tem(:, pyr_info(lev,1) : pyr_info(lev,2) ) ; 
        training_data_lev_patch = reshape(training_data_lev, [size(training_data_tem,1) * pyr_info(lev,4) , feat_desc_dim]); 
        
        % training a PCA model based on the training to reduce the
        % lbp dimensions to 59 
        [coeff, score, latent, tsquared, explained, mu] = ...
        pca(training_data_lev_patch, 'NumComponents', 59);
        % Apply the transformation to the training data
        clear training_data_lev_patch training_data_lev
        training_data_lev = reshape(score, [size(training_data_tem, 1) , pyr_info(lev,4) * 59]); 
        training_data_canny_lbp = [training_data_canny_lbp, training_data_lev];
        
        % Apply the transformation to the testing data
        % Remove the mean computed during the training of the PCA
        testing_data_lev = testing_data_tem(:, pyr_info(lev,1) : pyr_info(lev,2)); 
        testing_data_lev_patch = reshape(testing_data_lev, [size(testing_data_tem,1) * pyr_info(lev,4) , feat_desc_dim]); 
        clear testing_data_lev
        testing_data_lev = reshape(((bsxfun(@minus, testing_data_lev_patch, mu)) * coeff), [size(testing_data_tem,1), pyr_info(lev,4) * 59] ) ; 
        testing_data_canny_lbp = [testing_data_canny_lbp, testing_data_lev]; 
        
    end 
    disp('Projected the data using PCA for canny LBP');

    % Combined the original LBP and the Canny LBP
    training_data = [training_data_org_lbp, ...
                     training_data_canny_lbp];
    testing_data = [testing_data_org_lbp, ...
                    testing_data_canny_lbp];

    % Applying BoW on the data 
    k = 60;
    [idxs C] = kmeans(training_data,k);
    training_histogram=[];
    for train_id = 1 : size(lbp_feat,1) :size(training_data,1)
        [knn_idxs D] = knnsearch( C, training_data(train_id : train_id + size(lbp_feat,1)-1,:));
        histogram = hist(knn_idxs,k);
        norm_histogram = histogram ./ sum(histogram);
        training_histogram = [training_histogram; norm_histogram];
    end
    disp('Creation of training set using BoW');
    training_data = training_histogram;

    testing_histogram = [];
    for test_id = 1 : size(lbp_feat,1) : size(testing_data,1)
        [knn_idxs D] = knnsearch( C, testing_data(test_id : test_id + size(hog_feat,1)-1,:));
        histogram = hist(knn_idxs,k);
        norm_histogram = histogram ./ sum(histogram);
        temp_res=[testing_histogram; norm_histogram];
    end
    testing_data = testing_histogram;
    disp('Creation of testing set using BoW');
    
    % Perform the training of the SVM
    % svmStruct = svmtrain( training_data, training_label );
    SVMModel = fitcsvm(training_data, training_label);
    disp('Trained SVM classifier');
    % Test the performance of the SVM
    % pred_label = svmclassify(svmStruct, testing_data);
    pred_label = predict(SVMModel, testing_data);
    disp('Tested SVM classifier');


    pred_label_cv( idx_cv_lpo, : ) = pred_label;    
    disp('Applied majority voting');
end

save(strcat(store_directory, 'predicition.mat'), 'pred_label_cv');

%delete(poolobj);