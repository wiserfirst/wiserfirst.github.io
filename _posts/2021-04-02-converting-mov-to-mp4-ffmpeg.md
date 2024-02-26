---
title: "Converting mov/avi to mp4 with ffmpeg"
date: 2021-04-02 11:50:00 +1000
last_modified_at: 2024-02-26 17:40:00 +1100
tags: ffmpeg mov avi mp4
header:
  image: /assets/images/2021-05-16/hobbit_1440_420.jpg
  image_description: "Hobbiton Movie Set"
  teaser: /assets/images/2021-05-16/hobbit_1440_420.jpg
  overlay_image: /assets/images/2021-05-16/hobbit_1440_420.jpg
  overlay_filter: 0.4
  caption: >
    Image by [Andres Iga](https://unsplash.com/@andresiga?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
    from [Unsplash](https://unsplash.com/s/photos/movie?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
excerpt: Explore a great cli tool for converting between video formats
---

Since I have a camera that captures video in Quicktime movie format, I end up
with a lot of .mov videos. While it's a reasonable format, it does have a big
drawback: the video files are really big and therefore my SSD is running out of
space.

In order to save some space, I'd like to convert the .mov files to .mp4.

There are various online tools that I can use for the conversion, but uploading
the original videos and downloading the resulting videos would take a long time,
especially considering I have multiple videos that are several Gigabytes. So the
online tools aren't right for me.

Luckily there is a neat cli tool named [ffmpeg][] that can do the trick. If you
don't already have it, you can install (on macOS) by

```sh
brew install ffmpeg
```

Or if you are on Linux, most likely you can install it with your package
manager; if not, go to its [download page][] to find the appropriate installer.

To convert a .mov file to .mp4, you can run

```sh
ffmpeg -i input-video-name.mov -vcodec h264 output-video-name.mp4
```

For more details, please refer to the [ffmpeg documentation][].

This is good enough if there are only a handful of videos to convert, but it can
become tedious to run the command manually for say 20 videos. So I created a
quick and dirty Ruby script for converting all the .mov or .avi videos in a
directory. And yes, thanks to ffmpeg, the same command can work with .avi videos
as well.

```ruby
#!/usr/bin/env ruby
require 'shellwords'

def usage
  puts <<~HEREDOC
    Usage:
    ./video-converter.rb [dir]
    to convert mov/avi files to mp4 with H.264 video codec and AAC audio codec
  HEREDOC
end

if ARGV.length > 1
  usage
  exit 1
end

dir = ARGV.length == 1 ? ARGV[0] : '.'

unless Dir.exist?(dir)
  puts "\e[31mDirectory #{dir} not found\e[0m"
  exit 1
end

output_dir = File.join(dir, 'output')

Dir.chdir(dir)
Dir.mkdir(output_dir) unless Dir.exist?(output_dir)

Dir.glob('*.{avi,mov,mp4}') do |original_filename|
  basename = File.basename(original_filename, '.*')
  filename = Shellwords.escape(original_filename)
  output_path = File.join('output', "#{basename}.mp4") # Keep for display
  escaped_output_path = Shellwords.escape(output_path) # Use for command
  puts "\n\e[32mConverting #{original_filename} to #{output_path}\e[0m"
  system("ffmpeg -i #{filename} -vcodec h264 -acodec aac #{escaped_output_path}")
end
```

Note: Script updated on 2024-02-26 to: a) create an output directory if it does
not already exist, b) escape special characters (such as spaces) for shell
commands, and c) add support for converting .mp4 files in addition to .mov and
.avi files.

I understand there are various ways to improve this script to make it more
flexible/robust, but for now this is good enough for my purpose and hopefully
it is useful for someone else too.

[download page]: https://www.ffmpeg.org/download.html
[ffmpeg]: https://www.ffmpeg.org/
[ffmpeg documentation]: https://www.ffmpeg.org/ffmpeg.html
