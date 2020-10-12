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

## Usage

**histogram**

```sh
ruby -r numo/narray -e "puts Numo::DFloat.new(1000).rand_norm.to_a" \
  | uplot hist --nbins 15
```

<img src="https://i.imgur.com/wpsoGJq.png" width="75%" height="75%">

```sh
echo "from numpy import random;" \
     "n = random.randn(10000);"  \
     "print('\n'.join(str(i) for i in n))" \
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


## Development

Let's keep it simple.

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/kojix2/uplot](https://github.com/kojix2/uplot).

## License

[MIT License](https://opensource.org/licenses/MIT).
