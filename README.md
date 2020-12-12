# YouPlot

![Build Status](https://github.com/kojix2/youplot/workflows/test/badge.svg)
[![Gem Version](https://badge.fury.io/rb/youplot.svg)](https://badge.fury.io/rb/youplot)
[![Docs Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://rubydoc.info/gems/youplot)
[![The MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)

Create ASCII charts on the terminal with data from standard streams in the pipeline. 

:bar_chart: Powered by [UnicodePlot](https://github.com/red-data-tools/unicode_plot.rb)

## Installation

```
gem install youplot
```

## Screenshots

### barplot

```sh

```

### histogram

```sh
echo -e "from numpy import random;" \
        "n = random.randn(10000);"  \
        "print('\\\n'.join(str(i) for i in n))" \
| python \
| uplot hist --nbins 20
```

### lineplot

```sh
curl -sL https://git.io/AirPassengers \
| cut -f2,3 -d, \
| uplot line -d, -w 50 -h 15 -t AirPassengers --xlim 1950,1960 --ylim 0,600
```

### scatter

```sh
curl -sL https://git.io/YouPlotIris \
| cut -f1-4 \
| uplot scatter -H -t IRIS
```

### density

```sh
curl -sL https://git.io/YouPlotIris \
| cut -f1-4 \
| uplot density -H -t IRIS
```

### boxplot

```sh
curl -sL https://git.io/YouPlotIris \
| cut -f1-4 \
| uplot boxplot -H -t IRIS
```

### count(slow)



### colors

```sh
uplot colors
```

## Usage

`uplot --help`

Use `--help` to print command-specific options.

`uplot hist --help`

```
Usage: uplot histogram [options] <in.tsv>

Options for histogram:
        --symbol VAL         character to be used to plot the bars
        --closed VAL
    -n, --nbins VAL          approximate number of bins

Options:
...
```

## Development

Let's keep it simple.

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/kojix2/youplot](https://github.com/kojix2/youplot).

## License

[MIT License](https://opensource.org/licenses/MIT).
