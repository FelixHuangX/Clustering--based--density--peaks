clear ; 
close all;
[filename, pathname, filterindex] = uigetfile({'*.jpg','image-files (*.jpg)';'*.mdl','Models (*.mdl)'; '*.*',  'All Files (*.*)'}, ...
        'Pick a file', 'MultiSelect', 'on');   
%输入图片
I = imread([pathname filename]);
imshow(I);
%选择一个点，切割图片，获得像素点更少的图片段
[x, y, button] = ginput(1);
J = I(x-63:x+64,y-63:y+64,:);
[m, n, p] = size(J);
[C,cl] = cluster_density_image(J);
J_seg = reshape(C(cl, :), m, n, p);
%画图比较
figure
subplot(1, 2, 1), imshow(J, []), title('原图')
subplot(1, 2, 2), imshow(uint8(J_seg), []), title('聚类图')
