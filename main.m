% Version : 4.1
% Author  : Dano Bagus

clear all;
clc;
close all;

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% create_gabor is a s script . it's purpose is to craete a file 
% with name 'gabor.mat'.
% This file contains a cell array matrix with name 'G'
% and 'G' has 40 32x32 matrixes coresponding to Gabor filter
% in frequency domain
if ~exist('gabor.mat','file')
    fprintf ('Creating 40 Gabor Filters ...');
    create_gabor;
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% createffnn create a feedforward neural network with 100 neurons
% in input layer and one neuron in output layers
% the network input is a 27x18 window of the picture in vector
% form . it's purpose is to determine if the window is a face or not
% the output of the network is close to 0.9 for a face and close to
% -0.9 for a non-face
if exist('net.mat','file')
    load net;
else
    createffnn
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% loadimages prepare images in face and non-face folders
% for network traning phase.
% See the source for more information
if exist('imgdb.mat','file')
    load imgdb;
else
    IMGDB = loadimages;
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

while (1==1)
    
    choice=menu('Face Detection',...
                'Create Database',...
                'Initialize Network',...
                'Train Network',...
                'Image Scanner',...
                'Exit');
            
    if (choice ==1)
        IMGDB = loadimages;
    end
    if (choice == 2)
        createffnn
    end    
      
    if (choice == 3)
        % trainnet is a fuction which train the network
        net = trainnet(net,IMGDB);
    end

    if (choice == 4)
        [file_name, file_path] = uigetfile ('*.jpg');
        im = imread ([file_path,file_name]);
        % if the input image happenes to be an RGB image
        % try-end will convert it to gray image
        try
            im = rgb2gray(im);
        end
        % imscan is a function which scan the whole photo for faces
        % im_out is the output image of the function
        % with green rectangles across the faces 
        im_out = imscan (net,im);
        figure;imshow(im_out,'notruesize');
    end

    if (choice == 5)
        clear all;
        clc;
        close all;
        return;
    end    
end