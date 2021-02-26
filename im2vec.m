% Version : 4.1
% Author  : Dano Bagus

function IMVECTOR = im2vec (W27x18)

%{
The input of the function is a 27x18 window . At first the function adjusts
the histogram of the window . Then to convolve the window with Gabor 
filters , the window in frequency domain will multiply by gabor filters

Gabor filters are stored in gabor.mat . to save time they have been saved 
in frequency domain before.
%} 

load gabor; %loading Gabor filters

% Adjust the window histogram , the parameters are set with try and error
W27x18 = adapthisteq(W27x18,'Numtiles',[8 3]); 

Features135x144 = cell(5,8);
for s = 1:5
    for j = 1:8
        Features135x144{s,j} = ifft2(G{s,j}.*fft2(double(W27x18),32,32),27,18);
    end
end

% Features135x144 is a cell array contains the result of the convolution of
% the window with each of the fourty gabor filters. These matrixes will
% concate to form a big 135x144 matrix of complex numbers/
% We only need the magnitude of the result That is why the abs is used.
Features135x144 = abs(cell2mat(Features135x144));

% 135x144 is very painful to be an input for the network . it has 19,400
% pixels . It means that the input vector of the network should have 19,400
% pixels which means a large amount of computation and waste of time.
% so We reduce the matrix size to one-third of it's original size.
% There are so many ways to reduce the matrix size like using PCA , using
% the median of each 3x3 pixels or deleting the rows and colums
% Deleting is not the best way , but it save more time compare with
% others
Features135x144 (3:3:end,:)=[];
Features135x144 (2:2:end,:)=[];
Features135x144 (:,3:3:end)=[];
Features135x144 (:,2:2:end)=[];

% The numbers in the input vector of the network should be between -1,1
% and the line below will fulfill this concept.
Features45x48 = premnmx(Features135x144);

% Change the matrix to a vector 
IMVECTOR = reshape (Features45x48,[2160 1]);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% notes : This function is very critical . consider that we have a big
% photo say 400x300 . Can you say how may 27x18 windows we have ? 
% If we do not preprocess the photo to predict the location of the faces
% we have a window for each and every single pixel of the photo which means
% 120,000 windows ( A little less because of the borders ) . and each pixel
% is the center of a new window.
% if this function takes .4 sec to be executed , the whole photo will take
% about 13 hours only for the network preprocess .
% so any unnecessary line in this function can be a hell for the whole 
% process and we should optimize this function as possible as we can.