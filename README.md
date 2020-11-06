# uplot

[![Build Status](https://travis-ci.com/kojix2/uplot.svg?branch=master)](https://travis-ci.com/kojix2/uplot)
[![Gem Version](https://badge.fury.io/rb/u-plot.svg)](https://badge.fury.io/rb/u-plot)
[![Docs Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://rubydoc.info/gems/u-plot)
[![The MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)

Create ASCII charts on the terminal with data from standard streams in the pipeline. 

:bar_chart: Powered by [UnicodePlot](https://github.com/red-data-tools/unicode_plot.rb)

## Installation

```
gem install u-plot
```

Note the hyphen between u and the plot.

## Screenshots

**histogram**

```sh
ruby -r numo/narray -e "puts Numo::DFloat.new(1000).rand_norm.to_a" \
  | uplot hist --nbins 15
```

<img src="https://i.imgur.com/wpsoGJq.png" width="75%" height="75%">

```sh
echo -e "from numpy import random;" \
        "n = random.randn(10000);"  \
        "print('\\\n'.join(str(i) for i in n))" \
| python \
| uplot hist --nbins 20
```

<img src="https://i.imgur.com/97R2MQx.png" width="75%" height="75%">

**scatter**

```sh
curl -s https://raw.githubusercontent.com/uiuc-cse/data-fa14/gh-pages/data/iris.csv \
| cut -f1-4 -d, \
| uplot scatter -H -d, -t IRIS
```

<img src="https://i.imgur.com/STX7bFT.png" width="75%" height="75%">

**line**

```sh
curl -s https://www.mhlw.go.jp/content/pcr_positive_daily.csv \
| cut -f2 -d, \
| uplot line -w 50 -h 15 -t 'PCR positive tests' --xlabel Date --ylabel number
```

<img src="https://i.imgur.com/PVl5dsa.png" width="75%" height="75%">

**box**

```sh
curl -s https://raw.githubusercontent.com/uiuc-cse/data-fa14/gh-pages/data/iris.csv \
| cut -f1-4 -d, \
| uplot box -H -d, -t IRIS
```

<img src="https://i.imgur.com/sNI4SmN.png" width="75%" height="75%">

**colors**

```sh
uplot colors
```

<img src="https://i.imgur.com/LxyHQsz.png">

## Usage

`uplot --help`

```
Program: uplot (Tools for plotting on the terminal)
Version: 0.2.7 (using UnicodePlot 0.0.4)
Source:  https://github.com/kojix2/uplot

Usage:   uplot <command> [options] <in.tsv>

Commands:
    barplot    bar
    histogram  hist
    lineplot   line
    lineplots  lines
    scatter    s
    density    d
    boxplot    box
    colors                   show the list of available colors

    count      c             baplot based on the number of occurrences
                             (slower than `sort | uniq -c | sort -n -k1`)

Options:
    -O, --pass [VAL]         file to output standard input data to [stdout]
                             for inserting uplot in the middle of Unix pipes
    -o, --output VAL         file to output results to [stderr]
    -d, --delimiter VAL      use DELIM instead of TAB for field delimiter
    -H, --headers            specify that the input has header row
    -T, --transpose          transpose the axes of the input data
    -t, --title VAL          print string on the top of plot
    -x, --xlabel VAL         print string on the bottom of the plot
    -y, --ylabel VAL         print string on the far left of the plot
    -w, --width VAL          number of characters per row
    -h, --height VAL         number of rows
    -b, --border VAL         specify the style of the bounding box
    -m, --margin VAL         number of spaces to the left of the plot
    -p, --padding VAL        space of the left and right of the plot
    -c, --color VAL          color of the drawing
        --[no-]labels        hide the labels
        --fmt VAL            xyxy : header is like x1, y1, x2, y2, x3, y3...
                             xyy  : header is like x, y1, y2, y2, y3...


```

## Development

Let's keep it simple.

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/kojix2/uplot](https://github.com/kojix2/uplot).

## License

[MIT License](https://opensource.org/licenses/MIT).
