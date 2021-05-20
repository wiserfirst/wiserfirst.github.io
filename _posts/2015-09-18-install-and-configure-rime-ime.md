---
title: "神级输入法鼠鬚管的安装和基本配置"
date: "2015-09-18 10:00:00 +1000"
last_modified_at: 2021-05-20 21:50:00 +1000
tag: rime ime
header:
  image: /assets/images/2021-05-20/squirrel_1280_400.jpg
  image_description: "Squirrel on a lawn"
  teaser: /assets/images/2021-05-20/squirrel_1280_400.jpg
  overlay_image: /assets/images/2021-05-20/squirrel_1280_400.jpg
  overlay_filter: 0.2
  caption: >
    Image by [Cristina Schek](https://unsplash.com/@cristinaschek)
    from [Unsplash](https://unsplash.com/photos/oJieg2n8duk)
excerpt: Squirrel (Rime) is probably the best IME for Chinese on OSX
---

鼠鬚管应该是OSX操作系统上最优秀的中文输入法（没有之一），其好处我就不多讲了，有兴趣自己去[官方网站][offical site]或者文末列出的参考链接里面自己看吧。这里主要介绍一下鼠鬚管的安装和基本的配置。

## 鼠鬚管的安装

可以直接到官方网站的[下载页面][download page]下载安装文件并手动安装，
或者使用[Homebrew Cask][]:

```bash
brew install --cask squirrel
```

> 注：Cask安装命令更新于2021-05-20

## 鼠鬚管的基本配置

鼠鬚管的唯一缺点就是目前还没有一个图形界面的配置工具，修改配置需要直接编辑YAML格式的配置文件。其实这也不能完全算是缺点，而是一把双刃剑。一方面通过配置文件可以最大程度上对输入法进行定制，从而精确控制自己想要的效果；另一方面没有图形界面也让新手望而却步，面对一堆配置文件不知该从哪里下手。本文是面向新手的（包括我自己），只介绍几个最基本的配置，让我日常打字舒服就够了。至于高级的配置方式，还请移步官方的[定制指南][customisation
guide]。

点击OSX右上角的鼠鬚管图标，在下拉菜单中选择Setting/用户设定，即可在Finder中打开配置文件所在目录。另外，修改配置文件之后不会立即生效，需要点击鼠鬚管图标，在下拉菜单中选择deploy/重新部署。

### 切换到简体输入

鼠鬚管默认是繁体输入，如需切换到简体输入，请选择Rime输入法并把焦点放在任意文字输入框内，用`Ctrl+~`调出待选项，然后选择 “明月拼音 简化字"

### 修改待选字为排列方式和字体大小

待选字默认是纵向排列的，不太符合我的习惯，所以需要改为横向排列。在`squirrel.yaml`文件中将`horizontal`改为`true`，`font_point`改为`16`，如下

```yaml
horizontal: true
font_point: 16
```

### 修改配色方案

鼠鬚管自带的配置文件中已经定义了几个预设的配色方案，如果觉得没有合适的还可以自己定制配色方案。我个人觉得预设的Google配色方案就蛮好的。仍然是修改`squirrel.yaml`，将`color_scheme`改为`google`

```yaml
color_scheme: google
```

### 修改候选词数量

这个可以根据自己喜好设置。我觉得6个候选词合适，就将`default.yaml`中的`page_size`改为`6`

```yaml
menu:
  page_size: 6
```

### 修改候选词词频调整阀限

鼠鬚管默认有智能词频调整，但是频次阀限较高，所以调整比较慢。如果希望根据当前的输入更快进行词频调整，在`luna_pinyin_simp.schema.yaml`的`version`下方加一行`sort:
by_weight`，如下

```yaml
schema:
  schema_id: luna_pinyin_simp
  name: 朙月拼音·简化字
  version: "0.22"
  sort: by_weight
  author:
    - 佛振 <chen.sst@gmail.com>
  description: |
    朙月拼音，簡化字輸出模式。
```

## 参考

1. [官方网站上的文档][offical docs]，其实内容都是放在[Rime Github项目的Wiki页面][rime-wiki]中的
2. [鼠须管，“神级”输入法][ifanr-rime] from 爱范儿
3. [推薦一個神級輸入法——Rime][byvoid-rime] by @byvoid

[Homebrew Cask]: https://github.com/Homebrew/homebrew-cask
[byvoid-rime]: https://www.byvoid.com/blog/recommend-rime
[customisation guide]: https://github.com/rime/home/wiki/CustomizationGuide
[download page]: https://rime.im/download/
[ifanr-rime]: https://www.ifanr.com/156409
[offical docs]: https://rime.im/docs/
[offical site]: https://rime.im/
[rime-wiki]: https://github.com/rime/home/wiki
