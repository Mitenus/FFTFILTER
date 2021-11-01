clear all
close all
%% Acquires the data from the folder
for j = 0:3
    im = imread(sprintf("Tile_%d/led_0.tif",j));
    im = im/15;
    for i = 1:15
       im2 = imread(sprintf("Tile_%d/led_%d.tif",j, i));
       im = imadd(im,im2/15);
    end
    imwrite(im,sprintf("avg_%d.tif",j),"tiff");
end
for j= 1:4
    image{j}= imread(sprintf("avg_%d.tif", j-1));
end
%merges and cut the images in order to show only the full area of the wafer
im = [image{1},image{2}; image{3},image{4}];
im = imcrop(im, [78.5 114.5 1460 1448]);
im2 = histeq(im);
figure, imshow(im2);
imwrite(im2, "im_raw_eq.tif", "tiff");
imwrite(im, "im_raw.tif", "tiff");

 %%even illumination, remove glares and bigger grains from the image
 se = strel("disk",30)
 background = imopen(im,se);
 im = im - background;

%%fft FILTER
frequencyImage = fftshift(fft2(im));
% Take log magnitude so we can see it better in the display.
amplitudeImage = log(abs(frequencyImage));
minValue = min(min(amplitudeImage))
maxValue = max(max(amplitudeImage))
figure
imshow(amplitudeImage, []);
imwrite(amplitudeImage, "fft.tif", "tiff");
axis on;
amplitudeThreshold = 17.5; %treshold for the strength of the waves in the image
brightSpikes = amplitudeImage > amplitudeThreshold; % Binary image.
brightSpikes(710:740, :) = 0; %ignores central line of the fft image
frequencyImage(brightSpikes) = 19*randi([0, 1]);
amplitudeImage2 = log(abs(frequencyImage));
minValue = min(min(amplitudeImage2));
maxValue = max(max(amplitudeImage2));
filteredImage = ifft2(fftshift(frequencyImage));
amplitudeImage3 = abs(filteredImage);
maxValue = max(max(amplitudeImage3));
im = amplitudeImage3/maxValue;
figure, imshow(im);
imwrite(im, "im_filtered_nobg.tif", "tiff")


