clear all;
close all;
clc;

% Execute the setup for protoclass matlab
run('../../../../third-party/protoclass_matlab/setup.m');

% Data after the pre-processing
data_directory = ['/data/retinopathy/OCT/SERI/pre_processed_data/' ...
                  'liu_2011/'];
store_directory = ['/data/retinopathy/OCT/SERI/feature_data/' ...
                   'liu_2011/canny/'];
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

        % Extract the canny volumes
        % threshold 
        threshold = 0.4 ; 
        % method 
        method = 'canny'; 
       
        [ vol_canny ] = extract_edge_volume( vol_aligned, method, threshold) ; 

        % Store the data
        store_filename = strcat( store_directory, ...
                                 directory_info(idx_file).name ); 
        save( store_filename, 'vol_canny');
        disp( [ 'Canny volume for file  ', directory_, info(idx_file).name, ...
                ' stored' ] );
    end
end

delete(poolobj);
