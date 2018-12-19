## `knitwit` ##
Create your own [Winter Bash 2018](https://winterbash2018.stackexchange.com/) knitted image!

In addition to the usual hat challenges, [Stack Exchange](https://stackexchange.com/) added a tool for making knitted images. `knitwit` is my attempt at a MATLAB tool to mimic the results, with a few extra options. Some sample images can be found in [my answer](https://meta.stackexchange.com/a/319970/52738) to a [Meta question](https://meta.stackexchange.com/q/319846/52738) where everyone was showing off their creations.

### Usage: ###
`KNITIMG = knitwit(IMAGEFILE)` will load the image data in file `IMAGEFILE` and resize, pad, and recolor the image to create an output image `KNITIMG` that mimics what would be created by the Winter Bash 2018 knitting tool.

`KNITIMG = knitwit(IMAGEDATA)` will use the image data in `IMAGEDATA` instead of loading from a file. `IMAGEDATA` must be an N-by-M-by-3 matrix.

`KNITIMG = knitwit(..., 'PropertyName', PropertyValue, ...)` will modify how the images are generated based on the property/value pairs specified. Valid properties that the user can set are:
* **`'BackFill'`** - A logical value determining if the code will attempt to identify a background solid color (abutting the borders) and fill it with the default blue background value. Default is `FALSE`.
* **`'Dither'`** - A logical value determining if dithering will be used when performing color quantization. Default is `FALSE`.
* **`'AddKnit'`** - A logical value determining if the knit pattern will be added to the image created. A value of `FALSE` will create a resampled, color-quantized image that can be uploaded to the Winter Bash 2018 knitting tool to add the pattern. Default is `TRUE`.

*"Never gonna give you up!"*

![](https://i.stack.imgur.com/rTqyY.gif)
