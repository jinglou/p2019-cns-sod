%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This code implements the proposed salient object detection model in the following paper:
% 
% Jing Lou*, Huan Wang, Longtao Chen, Fenglei Xu, Qingyuan Xia, Wei Zhu, Mingwu Ren*, 
% "Exploiting Color Name Space for Salient Object Detection," Multimedia Tools and Applications, 
% vol. 79, no. 15, pp. 10873-10897, 2020. doi:10.1007/s11042-019-07970-x
% 
% Project page: http://http://www.loujing.com/cns-sod/
%
% References:
%   [46] van de Weijer J, Schmid C, Verbeek J (2007) Learning color names from real-world images. 
%        In: Proceedings of the IEEE conference on computer vision and pattern recognition, pp 1-8
%   [52] Zhang J, Sclaroff S (2013) Saliency detection: a Boolean map approach. 
%        In: Proceedings of the IEEE international conference on computer vision, pp 153-160
%
%
% Copyright (C) 2020 Jing Lou (Â¥¾º)
% 
% The usage of this code is restricted for non-profit research usage only and using of the code is at the user's risk.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clc; clear; close all;

load w2c;


%% Parameter Settings
param.resize_width = 400;
param.delta		   = 8;
param.omega_c	   = 14;
param.omega_r      = 14;
param.theta_r	   = 0.02;
param.theta_g	   = 1.5;


%% Path
if exist('SalMaps', 'dir') ~= 7
    system('md SalMaps');
end

imgPath = 'images\';
rstPath = 'SalMaps\';


%% Read Images
imgJPG = dir([imgPath, '*.jpg']);
imgBMP = dir([imgPath, '*.bmp']);
imgs   = [imgJPG; imgBMP];


%% Color Name Space (CNS) Based Saliency Map
for imgno = 1:length(imgs)	
    imgname = imgs(imgno).name;
	if exist([rstPath, imgname(1:end-4), '_CNS.png'], 'file') ~= 2
		t1 = clock;
		fprintf('%04d/%04d - %s\t', imgno, length(imgs), imgname);

		img = imread([imgPath, imgname]);
		salmap = CNS(img, param);
		imwrite(salmap, [rstPath, imgname(1:end-4), '_CNS.png']);

		t2 = clock;
		fprintf('(Time: %fs)\n', etime(t2,t1));
	end
end


