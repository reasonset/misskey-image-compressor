# misskey-image-compressor

## Synopsis

Image compression script for posting to Misskey instance.

## Requirement

* Bash
* file
* ImageMagick
* opegoptim
* pngquant
* cwebp (for WebP)
* avifenc (for AVIF)

## Usage

```
misyimg.bash [-aw] [-s<px>] [-p<pict|ss|photo|photohd>] sourcefile
```

Compression image is generated on current directory.
You cannot do that on same directory as source file.

## Options

|option|意味|
|------|----------------------------------------------|
|`-a`|Convert to AVIF|
|`-w`|Convert to WebP|
|`-s<px>`|Limit pixel size `<px>` on long side. Set `1000` by default.|
|`-p<profile>`|Specify image type `pict`, `ss`, `photo` or `photohd`. If not specified, it compresses more.|

## Conversion rules

* When `-a` or `-w` given, follow the option.
* When source file is PNG, compress to PNG.
* When source file is JPEG, compress to JPEG.

## Notice

This script strips all metadata on PNG or JPEG because it focuses to Misskey.
