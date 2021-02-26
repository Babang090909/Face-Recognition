% Version : 4.1
% Author  : Dano Bagus

function out = drawrec (in,w)

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function will draw a 27x18 rectangle 
% Inputs are an image 'in' abd w is a binary image same size as the input
% image , in the binary image each 1 is the center of a rectangle and the
% function leaves zeros alone.
%

[m n]=size(in);
[LUTm LUTn]=find(in);
out = zeros (m,n);
for i =1:size(LUTm,1)
    out (LUTm(i),LUTn(i))=0;
    out (LUTm(i)-14:LUTm(i)+13,LUTn(i)-9)=1;
    out (LUTm(i)-14:LUTm(i)+13,LUTn(i)+8)=1;
    out (LUTm(i)-14,LUTn(i)-9:LUTn(i)+8)=1;
    out (LUTm(i)+13,LUTn(i)-9:LUTn(i)+8)=1;
end