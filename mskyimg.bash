#!/bin/bash

# DEFAULT SETTINGS
declare -g TARGET_FMT=""
declare -g -i RESIZE_MAXSIZE=1000
declare -g PICTURE_PROFILE="image"

usage() {
  echo "Usage: misyimg.bash [-aw] [-s<px>] [-p<pict|ss|photo|photohd>] sourcefile" >&2
  exit 1
}

fail() {
  echo "Failed to convert image." >&2
  exit 1
}

compress2 () {
  sf="$1"
  fmt="$2"

  declare fmt_out
  declare csf

  #Decide final format.
  if [[ "$TARGET_FMT" == avif ]]
  then
    fmt_out=avif
  elif [[ "$TARGET_FMT" == webp ]]
  then
    fmt_out=webp
  elif [[ "$PICTURE_PROFILE" == photo* ]]
  then
    fmt_out=jpeg
  elif [[ "$fmt" == png ]]
  then
    fmt_out=png
  else
    fmt_out=jpeg
  fi

  csf=${sf##*/}

  if [[ $fmt_out == jpeg && -e ${csf%.*}.jpeg ]]
  then
    echo "Destination already exists."
    exit 1
  fi

  if [[ $fmt_out == jpeg && -e ${csf%.*}.jpeg ]]
  then
    # Photo mode.
    convert -strip -resize "${RESIZE_MAXSIZE}x${RESIZE_MAXSIZE}>" "$sf" "$csf" || fail
    if [[ $PICTURE_PROFILE == photohd ]]
    then
      jpegoptim -s --max=80 "$csf" || fail
    else
      jpegoptim -s --max=70 "$csf" || fail
    fi
  else
    # Picture mode
    if ! [[ "${csf##*.}" == [Pp][Nn][Gg] || "${csf##*.}" == [Jj][Pp][Ee][Gg] || "${csf##*.}" == [Jj][Pp][Gg] ]]
    then
      csf=${csf%.*}.png
    fi
    
    convert -resize "${RESIZE_MAXSIZE}x${RESIZE_MAXSIZE}>" "$sf" "$csf" || fail
    case $fmt_out in
      avif)
        echo "Process to AVIF..."
        avifenc --ignore-exif --ignore-xmp -s 0 "$csf" "${csf%.*}.avif" || fail
        rm "$csf"
        ;;
      webp)
        echo "Process to WebP..."
        case $PICTURE_PROFILE in
          pict)
            cwebp -q 80 -preset drawing -metadata icc "$csf" -o "${csf%.*}".webp || fail
            ;;
          ss)
            cwebp -q 70 -preset text -metadata none "$csf" -o "${csf%.*}".webp || fail
            ;;
          photohd)
            cwebp -q 75 -preset photo -metadata icc "$csf" -o "${csf%.*}".webp || fail
            ;;
          photo)
            cwebp -q 65 -preset photo -metadata icc "$csf" -o "${csf%.*}".webp || fail
            ;;
          *)
            cwebp -q 55 -metadata none "$csf" -o "${csf%.*}".webp || fail
            ;;
        esac
        rm "$csf"
        ;;
      png)
        echo "Process to PNG..."
        case $PICTURE_PROFILE in
          picture)
            pngquant -f --strip --ext .png --speed=1 --quality=70-85 "$csf" || fail
            ;;
          ss)
            pngquant -f --strip --ext .png --speed=1 --quality=65-80 "$csf" || fail
            ;;
          photohd)
            pngquant -f --strip --ext .png --speed=1 --quality=60-80 "$csf" || fail
            ;;
          photo)
            pngquant -f --strip --ext .png --speed=1 --quality=50-75 "$csf" || fail
            ;;
          *)
            pngquant -f --strip --ext .png --speed=1 --quality=40-65 "$csf" || fail
            ;;
        esac
        ;;
      jpeg)
        echo "Process to JPEG..."
        convert -quality 100 "$csf" "${csf%.*}.jpeg" || fail
        rm "$csf"
        jpegoptim -s --max=85 "${csf%.*}.jpeg" || fail
        ;;
    esac
  fi
}

while getopts 'awp:s:' opt
do
  case "$opt" in
    a)
      TARGET_FMT="avif"
      ;;
    w)
      TARGET_FMT="webp"
      ;;
    p)
      PICTURE_PROFILE="$OPTARG"
      ;;
    s)
      RESIZE_MAXSIZE="$OPTARG"
      ;;
    ?|h)
      usage
      ;;
  esac
done
shift $(( OPTIND - 1 ))

sf="$1"

(( RESIZE_MAXSIZE > 0 )) || usage
[[ -f "$sf" ]] || usage

filetype=$(file --mime-type "$sf")
filetype=${filetype##* }

if [[ "$filetype" != image/* ]]
then
  echo "Given source file is not an image." >&2
  exit 1
fi

echo "Source file MIME Type is $filetype"

filetype=${filetype#image/}

declare sfd="${sf##*/}"

if [[ -e "${sfd}" || -e "${sfd%.*}.png" || -e "${sfd%.*}.${TARGET_FMT}" ]]
then
  echo "Destination already exists."
  exit 1
fi

compress2 "$sf" "$filetype"