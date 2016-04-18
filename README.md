Automated macular pathology diagnosis in retinal oct images using multi-scale spatial pyramid and local binary patterns in texture and shape encoding
=====================================================================================================================================================

```
@article{liu2011automated,
  title={Automated macular pathology diagnosis in retinal OCT images using multi-scale spatial pyramid and local binary patterns in texture and shape encoding},
  author={Liu, Yu-Ying and Chen, Mei and Ishikawa, Hiroshi and Wollstein, Gadi and Schuman, Joel S and Rehg, James M},
  journal={Medical image analysis},
  volume={15},
  number={5},
  pages={748--759},
  year={2011},
  publisher={Elsevier}
}
```

How to use the pipeline?
-------

### Pre-processing pipeline

The follwoing pre-processing routines were applied:

- Flattening,
- Cropping.

#### Data variables

In the file `pipeline/feature-preprocessing/pipeline_preprocessing.m`, you need to set the following variables:

- `data_directory`: this directory contains the orignal SD-OCT volume. The format used was `.img`.
- `store_directory`: this directory corresponds to the place where the resulting data will be stored. The format used was `.mat`.

#### Algorithm variables

The variables which are not indicated in the inital publication and that can be changed are:

- `x_size`, `y_size`, `z_size`: the original size of the SD-OCT volume. It is needed to open `.img` file.
- `h_over_rpe`, `h_under_rpe`, `width_crop`: the different variables driving the cropping.
- `thres_method`, `thres_val`: method to threshold and its associated value to binarize the image.
- `gpu_enable`: method to enable GPU.
- `median_sz`: size of the kernel when applying the median filter.
- `se_op`, `se_cl`: size of the kernel when applying the closing and opening operations.

#### Run the pipeline

From the root directory, launch MATLAB and run:

```
>> run pipeline/feature-preprocessing/pipeline_preprocessing.m
```

### Extraction pipeline

For this pipeline, the following features were extracted:

- Canny,
- LBP in MSSP strategy on Canny and original images.

#### Data variables

In the file `pipeline/feature-extraction/pipeline_extraction_***.m`, you need to set the following variables:

- `data_directory`: this directory contains the pre-processed SD-OCT volume. The format used was `.mat`.
- `store_directory`: this directory corresponds to the place where the resulting data will be stored. The format used was `.mat`.

#### Run the pipeline

From the root directory, launch MATLAB and run:

```
>> run pipeline/feature-extraction/pipeline_extraction_canny.m
>> run pipeline/feature-extraction/pipeline_extraction_canny_lbp_mssp.m
>> run pipeline/feature-extraction/pipeline_extraction_original_lbp_mssp.m
```

### Classification pipeline

The method for classification used was:

- Linear SVM,
- RBF SVM.

#### Data variables

In the file `pipeline/feature-preprocessing/pipeline_classifier_***.m`, you need to set the following variables:

- `data_directory`: this directory contains the feature extracted from the SD-OCT volumes. The format used was `.mat`.
- `store_directory`: this directory corresponds to the place where the resulting data will be stored. The format used was `.mat`.
- `gt_file`: this is the file containing the label for each volume. You will have to make your own strategy.
- `k`: this is the number of words for the BoW approach.

#### Run the pipeline

From the root directory, launch MATLAB and run:

```
>> run pipeline/feature-classification/pipeline_classifier_linear_SVM.m
>> run pipeline/feature-classification/pipeline_classifier_rbf_SVM.m
```

### Validation pipeline

#### Data variables

In the file `pipeline/feature-validation/pipeline_validation.m`, you need to set the following variables:

- `data_directory`: this directory contains the classification results. The format used was `.mat`.
- `gt_file`: this is the file containing the label for each volume. You will have to make your own strategy.

#### Run the pipeline

From the root directory, launch MATLAB and run:

```
>> run pipeline/feature-validation/pipeline_validation.m
```
