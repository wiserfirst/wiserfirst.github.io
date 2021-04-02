---
title: "Converting mov/avi to mp4 with ffmpeg"
date: 2021-04-02 11:50:00 +1000
tags: ffmpeg
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

Luckily there is a neat cli tool named [ffmpeg] that can do the trick. If you
don't already have it, you can install (on macOS) by

```sh
brew install ffmpeg
```

Or if you are on Linux, most likely you can install it with your package
manager; if not, go to its [download page] to find the appropriate installer.

To convert a .mov file to .mp4, you can run

```sh
ffmpeg -i input-video-name.mov -vcodec h264 output-video-name.mp4
```

For more details, please refer to the [ffmpeg documentation].

This is good enough if there are only a handful of videos to convert, but it can
become tedious to run the command manually for say 20 videos. So I created a
quick and dirty Ruby script for converting all the .mov or .avi videos in a
directory. And yes, thanks to ffmpeg, the same command can work with .avi videos
as well.

```ruby
#!/usr/bin/env ruby

def usage
  puts <<~HEREDOC
    Usage:
    ./video-converter.rb [dir]
    to convert mov/avi files to mp4 with H.264 video codec and AAC audio codec"
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

Dir.chdir(dir)
Dir.glob('*.{avi,mov}') do |filename|
  basename = filename.split('.')[0]
  puts "\n\e[32mConverting #{filename} to #{basename}.mp4\e[0m"
  system("ffmpeg -i #{filename} -vcodec h264 #{basename}.mp4")
end
```

I understand there are various ways to improve this script to make it more
flexible/robust, but for now this is good enough for my purpose and hopefully
it is useful for someone else too.

[download page]: https://www.ffmpeg.org/download.html
[ffmpeg]: https://www.ffmpeg.org/
[ffmpeg documentation]: https://www.ffmpeg.org/ffmpeg.html
