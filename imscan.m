% Version : 4.1
% Author  : Dano Bagus

function im_out = imscan (net,im)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function gets the network and an image , select some 27x18 windows
% of the image and send them to network .
% The result of the network determins if the window is a face or not
% It is not as easy as that . follow the comments 


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REPORT_FILE = 'report.txt';     %name of the report file
SCAN_FOLDER = 'imscan\';        %folder for storing the detected faces
UT_FOLDER = 'imscan\under-thresh\';
TEMPLATE = 'template.png';      
%if the network result for a 27x18 window gets over thresh , that window is
%detected as a face.
thresh = 0.8;   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

warning off;
delete ([UT_FOLDER,'*.*']);
delete ([SCAN_FOLDER,'*.*']);
mkdir (UT_FOLDER);
mkdir (SCAN_FOLDER);
fid = fopen([SCAN_FOLDER,REPORT_FILE],'wt');

[m n]=size(im);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% It is not possible to send all 27x18 windows in a photo to the network
% ( see notes in 'im2vec.m'
% so we should chose some windows in a large photo which the existent 
% probapility of the face is more in these windows
% A window is determined by it's center which is a pixel on the image.
% Template is a 27x18 image or window containing a face without background
% Correlation between the Template and the image will give us an image
% which have peaks over the faces area. 
% imregonalmax is MATLAB function which extract the peaks in the binary mask
% each pixel in the binary mask will be used as a center for a window 
%

C1 = adapthisteq(im,'NumTiles',[20 20]);
C2 = imread (TEMPLATE);
Co = conv2 (single(C1),single(C2),'same');
mask = imregionalmax(Co);
% four lines below erase the peaks from the border of the image
mask (1:14,:)=0;
mask (end-14:end,:)=0;
mask (:,1:9)=0;
mask (:,end-10:end)=0;
[LUTm LUTn]= find(mask);
Length = size(LUTm,1);
% two lines below show the image on the screen with the preprecessed
% centers in red
imshow(im);hold on
plot(LUTn,LUTm,'.r');pause(0);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%~~~~~~~~~~~~~~~~~~~~~~~ SOS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% The predication of centers will not always work properly but it's good
% for must of the times
% If anyone have a suggestion about the above algorithm , I will 
% be glad to hear

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Now that we predict some centers for the windows , these loops find the
% maximum result of the network around these centers which is the exact
% location of the face . remember each 27x18 window is determined by it's
% center .
% type spiral(18) in the command window and compare the numbers in it with
% the location of the centers you see on screen with yellow color.
xy_ = zeros(m,n);
t = cputime;
SEARCH = [zeros(4,18);spiral(18);zeros(5,18)];
for i=1:Length        
        iter=0;
        itermax=5;
        result_max=-1;
        while (iter~=itermax)
                iter=iter+1;
                [offm offn]=find(SEARCH==iter);
                n_=LUTn(i)-9+offn;
                m_=LUTm(i)-13+offm;                
                plot(n_,m_,'.y');pause(0);
                try
                    imcut = im(m_-13:m_+13,n_-9:n_+8); 
                    P = im2vec(imcut);
                    result_ = sim(net,P);
                    fprintf(fid,'\n@x=%5.2f,y=%5.2f\tr=%5.2f\n',n_,m_,result_);
                    if result_max<result_
                        n__=n_;
                        m__=m_;
                        result_max=result_;
                        imcut_ = imcut;
                    end                
                    if result_max>0
                        itermax=50;
                    end
                end
                if (iter == 20 && result_max<thresh)
                    break;
                end
        end        
        if result_max>thresh
           xy_(m__,n__)=result_max;        
           plot(n__,m__,'.g');
           text(n__,m__,num2str(result_max,'%2.2f'),'Color',[1 1 1],'BackgroundColor',[0 0 0]);
           fprintf(fid,'****************\n');            
           imwrite(imcut_,[SCAN_FOLDER,'@',int2str(m__),',',int2str(n__),' (',int2str(fix(result_max*100)),'%).png']);                       
        else
           imwrite(imcut_,[UT_FOLDER,'@',int2str(m__),',',int2str(n__),' (',int2str(fix(result_max*100)),'%).png']);            
        end
end

hold off
e = (cputime-t)/Length;
fprintf(fid,'\nTotal Time : %5.2f',e*Length);
fprintf(fid,'\nTotal Pixels : %5.2f',Length);
fprintf(fid,'\n~~~~~~~~~~~~~~~~~~~~\n\nAuthor : Omid Sakhi');
fprintf(fid,'\nomid.sakhi@gmail.com');
fclose(fid);

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% now we have and image called xy_ , to draw the green rectangles we should
% find the centers of rectangles which is pixles with nwtrork results
% over threshold

xy_ = xy_>thresh;
xy_ = imregionalmax(xy_);
xy_ = imdilate (xy_,strel('disk',2,4));
[LabelMatrix,nLabel] = bwlabeln(xy_,4);
CentroidMatrix = regionprops(LabelMatrix,'centroid');
xy_ = zeros(m,n);
for i = 1:nLabel
    xy_(fix(CentroidMatrix(i).Centroid(2)),...
           fix(CentroidMatrix(i).Centroid(1))) = 1;
end
xy_ = drawrec(xy_,[27 18]);
im_out (:,:,1) = im;
im_out (:,:,2) = im;
im_out (:,:,3) = im;
for i = 1:m
    for j=1:n
        if xy_(i,j)==1
            im_out (i,j,1)=0;
            im_out (i,j,2)=255;
            im_out (i,j,3)=0;            
        end
    end
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

