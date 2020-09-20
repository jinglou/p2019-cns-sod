%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This code implements the proposed salient object detection method in the following paper:
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


function salmap = CNS(img, param)
param.ColorName = {
	1,  'Black',  [0    0    0];
	2,  'Blue',	  [0    0    1];
	3,	'Brown',  [.5  .4  .25];
	4,	'Grey',	  [.5  .5   .5];
	5,	'Green',  [0    1    0];
	6,	'Orange', [1   .8    0];
	7,	'Pink',	  [1   .5    1];
	8,	'Purple', [1    0    1];
	9,	'Red',    [1    0    0];
	10,	'White',  [1    1    1];
	11,	'Yellow', [1    1    0]
};

if ismatrix(img)
	img = repmat(img, [1 1 3]);
end

img_resize = imresize(img, [NaN param.resize_width]);

[S, Sw] = getSaliencyMap(img_resize, param);
salmap = (S+Sw)/2;
salmap = adjust(salmap, param.theta_r, param.theta_g);
salmap = imfill(salmap, 'holes');
salmap = imresize(salmap, [size(img,1), size(img,2)]);
salmap = im2uint8(mat2gray(salmap));
end


%% Color Name Space (CNS) Based Saliency Map
function [S, Sw] = getSaliencyMap(img, param)
w2c = evalin('base','w2c');		% color name mapping
img = double(img);
[W, w] = calcWeight(img, param);

cnspace = zeros(size(img,1), size(img,2), 11, 'uint8');  % color name space
cnmaps = cell(11,1);	
cnattmaps = cell(11,1);	
attmap  = zeros(size(img,1), size(img,2));
attmapw = zeros(size(img,1), size(img,2));

for chn = 1:11
	cnspace(:,:,chn) = im2uint8(mat2gray(im2c(img, w2c, chn)));		% C_i
	
	cnattmaps{chn} = zeros(size(img,1), size(img,2));
	tno = 1;
	for thresh = 0 : param.delta : 255
		tmp = cnspace(:,:,chn) >= thresh;
		cnmaps{chn}{tno,1} =  tmp;	% B_i^j
		cnmaps{chn}{tno,2} = ~tmp;	% \widetilde{B}_i^j
		cnmaps{chn}{tno,3} = imclose( tmp, strel('disk', param.omega_c));		% morphological closing
		cnmaps{chn}{tno,3} = imfill(cnmaps{chn}{tno,3},'holes');				% fill image holes
		cnmaps{chn}{tno,4} = imclose(~tmp, strel('disk', param.omega_c));		% morphological closing
		cnmaps{chn}{tno,4} = imfill(cnmaps{chn}{tno,4},'holes');				% fill image holes
		cnmaps{chn}{tno,5} = im2double(imclearborder(cnmaps{chn}{tno,3}));		% A_i^j
		cnmaps{chn}{tno,6} = im2double(imclearborder(cnmaps{chn}{tno,4}));		% \widetilde{A}_i^j
		cnattmaps{chn} = cnattmaps{chn} + cnmaps{chn}{tno,5} + cnmaps{chn}{tno,6};
		tno = tno + 1;
	end
	cnattmaps{chn} = cnattmaps{chn} / size(cnmaps{chn},1) / 2;
	
	attmap = attmap + cnattmaps{chn} / length(cnmaps);				% \bar{A}
	attmapw = attmapw + w(chn) * mat2gray(W{chn}.*cnattmaps{chn});	% \bar{A}_w
end

attmap = mat2gray(attmap);
S = reconstruct(attmap, param);
S = im2uint8(mat2gray(S));
S = adjust(S, param.theta_r, param.theta_g);
S = imfill(S, 'holes');		% S

attmapw = mat2gray(attmapw);
Sw = reconstruct(attmapw, param);
Sw = im2uint8(mat2gray(Sw));
Sw = adjust(Sw, param.theta_r, param.theta_g);
Sw = imfill(Sw, 'holes');	% S_w
end


%% Morphological Reconstruction
function X = reconstruct(I, param)
se		= strel('disk', param.omega_r);
im		= imerode(I, se);
imr		= imreconstruct(im, I);
% invert
imc		= imdilate(imr, se);
imcr	= imreconstruct(imcomplement(imc), imcomplement(imr));
imcr	= imcomplement(imcr);
X  = imcr;
end


%% Adjust Image Intensity Values
function X = adjust(I, ratio, gamma)
C = unique(I(:));
tmpsum = 0;
for k = 1:length(C)
	tmpsum = tmpsum + length(find(I==C(k)));
	if tmpsum >= numel(I) * (1-ratio)
		break;
	end
end
if C(k) > 0
	X = imadjust(I, [0,double(C(k))/255], [0,1], gamma);
else
	X = I;
end
end


%% Weights
function [W, w] = calcWeight(img, param)
w2c = evalin('base','w2c');
cnimg = im2c(img, w2c, 0);

color_count = zeros(11,1);
C = unique(cnimg(:));
for k = 1:length(C)
	color_count(C(k)) = length(find(cnimg(:)==C(k)));
end

W = cell(11,1);
for k = 1:11
	tmp = zeros(size(img,1), size(img,2));
	ind = cnimg(:)==k;
	tmp(ind) = color_count(k)/size(img,1)/size(img,2);
	W{k} = tmp;
end

w = zeros(11,1);
for m = 1:11
	if color_count(m) ~= 0
		for n = 1:11
			w(m) = w(m) + color_count(n)/size(img,1)/size(img,2)*norm(param.ColorName{m,3}-param.ColorName{n,3})^2;
		end
	end
end
end

