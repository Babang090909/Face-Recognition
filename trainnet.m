function NET = trainnet(net,IMGDB);
% Version : 4.1
% Author  : Dano Bagus

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define train parameters for the network

net.trainFcn = 'trainscg';
net.trainParam.lr = 0.4;
net.trainParam.epochs = 400;
net.trainParam.show = 10;
net.trainParam.goal = 1e-3;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% IMGDB is a large database of vectors with desired network output
% corresponding to them which is loaded to the workspace by 'load imgdb'
% imgdb.mat is created with loadimages the first time of the execution by
% loadimages.m
T{1,1} = cell2mat(IMGDB(2,:));
P{1,1} = cell2mat(IMGDB(3,:));
net = train(net,P,T);
save net net
NET = net;