clc;
clear;
close all;

while true
    %get input from user
    cmd = input('1- bird_1.jpg \n2- bird_2.jpg \n3- bird_3.bmp\n0- exit \n Choose an image: ');
    inputName = '';
    
    %change the name of the input based on user's comment
    switch cmd
        case 1
            inputName = 'bird_1.jpg';
        case 2
            inputName = 'bird_2.jpg';
        case 3
            inputName = 'bird_3.bmp';
        case 0
            close all
            break
        otherwise
            disp('Error try again!')
            continue
    end      
       
    %read the image
    img = imread(inputName);
    figure('Name','Input image');
    imshow(img);
    
    %convert image to grayscale
    img = rgb2gray(img);
    figure('Name','Grayscale image');
    imshow(img);

    %blur the image to reduce noise using Gaussian filter
    img = imgaussfilt(img,1.2);
    %img = mygauss(img, 1.2);
    figure('Name','Blurred image');
    imshow(img);
                  
    %find the ideal threshold value
    %if the number of dark pixels are considirably high (10% in this case)
    %threshold for binary image should be close to black
    %if the image has mostly light pixels(object&background are light)
    %threshold for binary conversion should be close to the white
    
    T = 0; %initial threshold value
    %find number of rows and columns in image since they will be used
    %during the entire program
    nrRows = size(img,1);
    nrCols = size(img,2);
    imageSize = nrRows * nrCols;
    totalDarkPixels = 0;
    
    for i=1:nrRows
        for j=1:nrCols
            if img(i,j) < 200
                totalDarkPixels = totalDarkPixels + 1;
            end
        end
    end
    
    if (totalDarkPixels/imageSize) < 0.1
       T = 200;
    else
       T = 75;
    end   
    
    %convert the image to binary image based on found threshold
    for i=1:nrRows
        for j=1:nrCols
            if img(i,j) > T 
                img(i,j)=0; %convert the background to zeros
            else
                img(i,j)=255; %convert the foreground to ones
            end
        end
    end

    figure('Name','Binary image');
    imshow(img);
  
    
    %find connected components in the binary image    
    visited = false(size(img)); %visited list, initially all pixels are unvisited   
    CC_list = zeros(nrRows,nrCols); %connected component list, 0 valued pixels do not belong to any CC. 
    % nonzero pixels in the list belong to a CC (value = their id)
    idVal = 1; %id of connected component, initially 1 since 0 means not a CC
    
    for i = 1 : nrRows
        for j = 1 : nrCols
            %if the current pixel is not 1 change the flag and mark as visited
            if img(i,j) == 0
                visited(i,j) = true;
    
            %if the current pixel is already visited, continue
            elseif visited(i,j)
                continue;
              
            else
                %the image traversed using DFS algorithm, we need a stack
                %create a stack keeping current pixel's location
                stack = [i j];
    
                while ~isempty(stack)
                    %pop from the stack
                    element = stack(1,:);
                    stack(1,:) = [];
    
                    %/if this element already visited, continue
                    if visited(element(1),element(2))
                        continue;
                    end
    
                    %change the flag for this element and assign the
                    %current id to it in CC list
                    visited(element(1),element(2)) = true;
                    CC_list(element(1),element(2)) = idVal;
    
                    %check 8 neighbouring locations (8-connectivity)
                    [locs_y, locs_x] = meshgrid(element(2)-1:element(2)+1, element(1)-1:element(1)+1);
                    locs_y = locs_y(:);
                    locs_x = locs_x(:);                  
    
                    %check the locations exceeding the image
                    out_of_bounds = locs_x < 1 | locs_x > nrRows | locs_y < 1 | locs_y > nrCols;
    
                    locs_y(out_of_bounds) = [];
                    locs_x(out_of_bounds) = [];
    
                    %check the already visited pixels                  
                    is_visited = visited(sub2ind([nrRows nrCols], locs_x, locs_y));
    
                    locs_y(is_visited) = [];
                    locs_x(is_visited) = [];
    
                    %check the pixels having 0 value
                    is_1 = img(sub2ind([nrRows nrCols], locs_x, locs_y));
                    locs_y(~is_1) = [];
                    locs_x(~is_1) = [];
    
                    %push the rest of the pixel to the stack
                    stack = [stack; [locs_x locs_y]];
                end
    
                %increase the value of the id since we are done with
                %current CC
                idVal = idVal + 1;
            end
        end 
     end   
    
     
    %the last assigned id value - 1 will give number of birds in the image
    %namely number of connected regions in the image
    numberOfBirds = idVal - 1; 
             
    
    %Show Output
    realCount = [10, 3, 22];
    fprintf(2, ' Actual count: %d\n', realCount(cmd));    
    fprintf(2, ' Program count: %d\n', numberOfBirds);    
    
end
