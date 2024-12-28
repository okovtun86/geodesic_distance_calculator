function nerve_fiber_distance_calculator()
    
    fig = uifigure('Name', 'Nerve Fiber Distance Calculator', 'Position', [600, 300, 400, 200]);
    
    uilabel(fig, 'Position', [20, 150, 250, 20], 'Text', 'Select Nerve Fiber GDT Image (16-bit TIFF):');
    vesselLabel = uilabel(fig, 'Position', [20, 120, 360, 20], 'Text', 'No file selected');
    vesselBtn = uibutton(fig, 'Position', [300, 150, 80, 20], 'Text', 'Browse', ...
                         'ButtonPushedFcn', @(vesselBtn, event) selectFile(fig, 'vessel', vesselLabel));
                     
    uilabel(fig, 'Position', [20, 90, 200, 20], 'Text', 'Select Cell Image (8-bit TIFF):');
    cellLabel = uilabel(fig, 'Position', [20, 60, 360, 20], 'Text', 'No file selected');
    cellBtn = uibutton(fig, 'Position', [300, 90, 80, 20], 'Text', 'Browse', ...
                       'ButtonPushedFcn', @(cellBtn, event) selectFile(fig, 'cell', cellLabel));
    
    calcBtn = uibutton(fig, 'Position', [150, 20, 150, 30], 'Text', 'Calculate and Save', ...
                       'ButtonPushedFcn', @(calcBtn, event) runCalculation(fig, vesselLabel, cellLabel));
end

function selectFile(fig, fileType, label)
    
    [file, path] = uigetfile('*.tif');
    if file == 0
        return;
    end
    
    filePath = fullfile(path, file);
    if strcmp(fileType, 'vessel')
        setappdata(fig, 'vesselFile', filePath);
        label.Text = file;
    else
        setappdata(fig, 'cellFile', filePath);
        label.Text = file; 
    end
end

function runCalculation(fig, vesselLabel, cellLabel)
    
    vesselFile = getappdata(fig, 'vesselFile');
    cellFile = getappdata(fig, 'cellFile');
    
    if isempty(vesselFile) || isempty(cellFile)
        uialert(fig, 'Please select both images.', 'Error');
        return;
    end
    
    try
        distances = calculateVesselDistances(vesselFile, cellFile);
        
        [file, path] = uiputfile('*.xlsx', 'Save as');
        if file == 0
            return;
        end
        outputFilePath = fullfile(path, file);
        writetable(distances, outputFilePath);
        
        uialert(fig, 'Data saved successfully!', 'Success');
    catch ME
        uialert(fig, sprintf('An error occurred: %s', ME.message), 'Error');
    end
end

function distancesTable = calculateVesselDistances(vesselPath, cellPath)
   
    vesselImage = double(imread(vesselPath));
    cellImage = imread(cellPath);
    
    cellLabels = bwlabel(cellImage);
    stats = regionprops(cellLabels, 'Centroid', 'Area');
    
    [nonZeroY, nonZeroX] = find(vesselImage);
    nonZeroValues = vesselImage(sub2ind(size(vesselImage), nonZeroY, nonZeroX));
    nonZeroPixels = [nonZeroX, nonZeroY];
    
    numCells = numel(stats);
    labels = (1:numCells)';
    centroidsX = zeros(numCells, 1);
    centroidsY = zeros(numCells, 1);
    areas = zeros(numCells, 1);
    distances = zeros(numCells, 1); 
    
    for i = 1:numCells
        centroid = round(stats(i).Centroid);
        centroidsX(i) = centroid(1);
        centroidsY(i) = centroid(2);
        areas(i) = stats(i).Area;
        
        distToPixels = sqrt((nonZeroPixels(:, 1) - centroid(1)).^2 + ...
                            (nonZeroPixels(:, 2) - centroid(2)).^2);
        
        [~, closestPixelIndex] = min(distToPixels);
       
        distances(i) = nonZeroValues(closestPixelIndex);
    end
    
    distancesTable = table(labels, centroidsX, centroidsY, areas, distances, ...
        'VariableNames', {'Label', 'Centroid_X', 'Centroid_Y', 'Area', 'Distance'});
end
