function knitImage = knitwit(imageFile, varargin)
%knitwit   Create your own Winter Bash 2018 knitted image.
%   KNITIMG = knitwit(IMAGEFILE) will load the image data in file IMAGEFILE
%   and resize, pad, and recolor the image to create an output image
%   KNITIMG that mimics what would be created by the Winter Bash 2018
%   knitting tool.
%
%   KNITIMG = knitwit(IMAGEDATA) will use the image data in IMAGEDATA
%   instead of loading from a file. IMAGEDATA must be an N-by-M-by-3
%   matrix.
%
%   KNITIMG = knitwit(..., 'PropertyName', PropertyValue, ...) will modify
%   how the images are generated based on the property/value pairs
%   specified. Valid properties that the user can set are:
%
%     'BackFill'    - A logical value determining if the code will attempt
%                     to identify a background solid color (abutting the
%                     borders) and fill it with the default blue background
%                     value. Default is FALSE.
%     'Dither'      - A logical value determining if dithering will be used
%                     when performing color quantization. Default is FALSE.
%     'AddKnit'     - A logical value determining if the knit pattern will
%                     be added to the image created. A value of FALSE will
%                     create a resampled, color-quantized image that can be
%                     uploaded to the Winter Bash 2018 knitting tool to add
%                     the pattern. Default is TRUE.
%
%   See also ind2rgb.

% Author: Ken Eaton
% Version: MATLAB R2016b
% Last modified: 12/19/18
% Copyright 2018 by Kenneth P. Eaton
%--------------------------------------------------------------------------

  % Parse input arguments:
  p = inputParser();
  addRequired(p, 'imageFile', @validImage);
  addParameter(p, 'BackFill', false, @islogical);
  addParameter(p, 'Dither', false, @islogical);
  addParameter(p, 'AddKnit', true, @islogical);
  parse(p, imageFile, varargin{:});
  if p.Results.Dither
    ditherOpt = 'dither';
  else
    ditherOpt = 'nodither';
  end

  % Colormap to use:
  cmap = [39 39 39
          144 215 244
          24 69 158
          52 109 180
          83 83 178
          237 28 36
          236 147 231
          230 141 32
          198 156 109
          254 206 5
          140 198 63
          255 255 255];

  % Load/process raw image:
  if ischar(imageFile)
    [rawImage, rawMap] = imread(imageFile);
    if ~isempty(rawMap)
      rawImage = ind2rgb(rawImage, rawMap);
    end
  else
    rawImage = imageFile;
  end
  if isa(rawImage, 'double') && (max(rawImage(:)) <= 1)
    rawImage = uint8(255.*rawImage);
  end
  rawSize = size(rawImage);

  % Load pattern image:
  patternImage = imread('knitting_pattern.png');
  patternSize = size(patternImage);
  knitSize = [55 136];

  % Fill background, if specified:
  if p.Results.BackFill

    % Find background mask:
    rawRecolor = rgb2ind(rawImage, cmap./255);
    backColor = mode([rawRecolor(1, :) ...
                      rawRecolor(rawSize(1), :) ...
                      rawRecolor(2:(rawSize(1)-1), 1).' ...
                      rawRecolor(2:(rawSize(1)-1), rawSize(2)).']);
    backMask = imfill(rawRecolor ~= backColor, 4, 'holes');
    CC = bwconncomp(backMask, 4);
    nRegions = numel(CC.PixelIdxList);
    nPixels = cellfun(@numel, CC.PixelIdxList);
    [~, index] = max(nPixels);
    backMask(vertcat(CC.PixelIdxList{setdiff(1:nRegions, index)})) = false;
    backMask = find(imdilate(~backMask, [0 1 0; 1 1 1; 0 1 0]));

    % Fill background with default color:
    rawImage(backMask) = cmap(3, 1);
    rawImage(backMask+rawSize(1)*rawSize(2)) = cmap(3, 2);
    rawImage(backMask+2*rawSize(1)*rawSize(2)) = cmap(3, 3);

  end

  % Resize, pad, recolor, and block the image:
  scale = min(patternSize(1:2)./rawSize(1:2));
  newSize = min(round(scale.*rawSize(1:2)), patternSize(1:2));
  knitImage = rgb2ind(imresize(rawImage, newSize), cmap./255, ditherOpt);
  padSize = (patternSize(1:2)-newSize)./2;
  knitImage = padarray(knitImage, floor(padSize), 2, 'pre');
  knitImage = padarray(knitImage, ceil(padSize), 2, 'post');
  knitImage = ind2rgb(knitImage, cmap./255);
  knitImage = imresize(knitImage, knitSize, 'nearest');
  knitImage = repelem(knitImage, [9 8.*ones(1, 53) 9], ...
                      repmat([9 9 8 9], 1, 34), 1);

  % Apply knit pattern, if specified:
  if p.Results.AddKnit

    % Shift some image columns to fit the knit pattern:
    index = logical(repmat([1 1 1 0 0 0 1 1 1 1 1 1 0 0 0 1 1 1 ...
                            1 1 0 0 0 0 1 1 1 1 1 0 0 0 1 1 1], 1, 34));
    knitImage(:, index, :) = knitImage([2:end end], index, :);
    knitImage = double(knitImage);

    % Create pattern mask:
    mask = double(rgb2gray(patternImage));
    minMask = min(mask(:));
    maxMask = max(mask(:));
    mask = (mask-minMask)./(maxMask-minMask);

    % Apply pattern mask:
    backColor = double(patternImage(1, 1, :))./255;
    knitImage(:, :, 1) = mask.*knitImage(:, :, 1)+(1-mask).*backColor(1);
    knitImage(:, :, 2) = mask.*knitImage(:, :, 2)+(1-mask).*backColor(2);
    knitImage(:, :, 3) = mask.*knitImage(:, :, 3)+(1-mask).*backColor(3);

  end
  knitImage = uint8(255.*knitImage);

end

function isValid = validImage(imageInput)

  if ischar(imageInput)
    isValid = (exist(imageInput, 'file') == 2);
  elseif isnumeric(imageInput) 
    isValid = ~isempty(imageInput) && (ndims(imageInput) == 3) && ...
              (size(imageInput, 3) == 3);
  else
    isValid = false;
  end

end