% Version : 4.1
% Author  : Dano Bagus

function IMGDB = loadimages
%{
This function will prepare faces and non-faces for the train set
all data will be gathered in a large cell array . each colume represent
a window for the network , which could be a face or not.
rows are as follows :

Row 1 ----> File Name
Row 2 ----> Desired output of the net in responding to the vector
Row 3 ----> Prepaired vector for training phase

you can see for yourself this large database out of the program.
type 
    IMGDB = loadimages
in the command window .

Also the function save the database to a file 'imgdb.mat' to save time
so this function is a one time function except you want to change something
in the 'im2vec.m' . In that case you should build the database again.
%}

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
face_folder = 'face\';      %location of faces for the train set
non_face_folder = 'non-face\';      %location of non-faces
file_ext = '.png';
out_max = 0.9;      % desired output of the net for detecting a face 
out_min = -0.9;     % desired output of the net for not detecting a face
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IMGDB = cell (3,[]);
fprintf ('Loading Faces ');
folder_content = dir ([face_folder,'*',file_ext]);
nface = size (folder_content,1);
for k=1:nface
    string = [face_folder,folder_content(k,1).name];
    image = imread(string);
    [m n] = size(image);
    if (m~=27 || n~=18)
        continue;
    end
    fprintf ('.');    
    % as you see , each face in the face folder becomes 10 vectors
    IM {1} = im2vec (image);    % the original face
    IM {2} = im2vec (fliplr(image));    % the mirror of the face which is a face
    % for better response of the network , 1-pixel shifted face in any
    % direction is used to train network invariant to 1-pixel.
    IM {3} = im2vec (circshift(image,1)); 
    IM {4} = im2vec (circshift(image,-1));
    IM {5} = im2vec (circshift(image,[0 1]));
    IM {6} = im2vec (circshift(image,[0 -1]));
    IM {7} = im2vec (circshift(fliplr(image),1));
    IM {8} = im2vec (circshift(fliplr(image),-1));
    IM {9} = im2vec (circshift(fliplr(image),[0 1]));
    IM {10} = im2vec (circshift(fliplr(image),[0 -1]));
    for i=1:10
        IMGDB {1,end+1}= string;
        IMGDB {2,end} = out_max;
        IMGDB (3,end) = {IM{i}};
    end    
end
fprintf ('\nLoading non-faces ');    
folder_content = dir ([non_face_folder,'*',file_ext]);
nnface = size (folder_content,1);
for k=1:nnface
    string = [non_face_folder,folder_content(k,1).name];
    image = imread(string);
    [m n] = size(image);
    if (m~=27 || n~=18)
        continue;
    end
    fprintf ('.');
    % here we need some examples to train the network with non-face vectors
    % so now we do not have a face here . we can do what ever we want with
    % the photo. strike it with a hammer ,...
    % I have chosen only the fliped version of non-faces. flip left-right
    % and up-down
    IM {1} = im2vec (image);
    IM {2} = im2vec (fliplr(image));
    IM {3} = im2vec (flipud(image));
    IM {4} = im2vec (flipud(fliplr(image)));    
    for i=1:4
        IMGDB {1,end+1}= string;
        IMGDB {2,end} = out_min;
        IMGDB (3,end) = {IM{i}};
    end    
end
fprintf('\n');
save imgdb IMGDB