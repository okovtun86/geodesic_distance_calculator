# Geodesic Distance Calculator

This MATLAB tool calculates the geodesic distance values of the closest non-zero pixels in a geodesic distance transform (GDT) 16-bit image for labeled regions in a binary (8-bit) cell image. The tool provides a graphical user interface (GUI) to load input images, process the data, and save the results as an Excel file.

### Features
- **Input**: Handles 16-bit TIFF files for GDT images and 8-bit TIFF files for cell images.
- **Region Analysis**: Labels connected regions in the cell image and calculates the GDT values for their centroids.
- **Excel Export**: Outputs the results as an Excel file, including region labels, centroids, areas, and distances.

### Requirements
- MATLAB (R2021a or newer recommended)
- Image Processing Toolbox
- GDT image generated using the MorpholibJ ImageJ plugin

### Usage
1. Clone the repository and run the `nerve_fiber_distance_calculator.m` script in MATLAB.
2. Use the GUI to load the input files: `geoddist.tif` and `cell_binary.tif`.
3. Click "Calculate and Save" to process the data and export the results.


