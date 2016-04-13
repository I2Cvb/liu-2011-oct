clear all;
close all;
clc;

% Execute the setup for protoclass matlab
run('../../../../third-party/protoclass_matlab/setup.m');

% Data after the pre-processing
data_directory = ['/data/retinopathy/OCT/SERI/pre_processed_data/' ...
                  'liu_2011/'];
store_directory = ['/data/retinopathy/OCT/SERI/feature_data/' ...
                   'liu_2011/lbp/'];
directory_info = dir(data_directory);

poolobj = parpool('local', 40);

for idx_file = 1:size(directory_info)

    % Get only of the extension is .img
    if ( ~isempty( strfind( directory_info(idx_file).name, '.mat' ) ...
                   ) )
        % Find the full path for the current file
        filename = strcat( data_directory, directory_info(idx_file).name ...
                           );

        % Read the file
        load( filename );

        % Extract the HOG features
        pyr_num_lev = 3;
        NumNeighbors = 8 ; 
        Radius = 1 ;
        % Normalized histogram 
        MODE = 'nh'; 
        % no mapping, normal LBP with 256 dimension is applied
        mapping = 'none'; 
        % Needs to be checked 
        CellSize = [4 4];

        [lbp_feat, pyr_info, feat_desc_dim] = extract_lbp_volume_mssp( vol_cropped, pyr_num_lev, ...
                                       NumNeighbors,Radius, CellSize, ...
                                       MODE, mapping) ; 
        disp( [ 'Feature for file  ', directory_info(idx_file).name, ...
                ' extracted' ] );

        % Store the data
        store_filename = strcat( store_directory, ...
                                 directory_info(idx_file).name ); 
        save( store_filename, 'lbp_feat', 'pyr_info', 'feat_desc_dim');
        disp( [ 'Feature for file  ', directory_, info(idx_file).name, ...
                ' stored' ] );
    end
end

delete(poolobj);
