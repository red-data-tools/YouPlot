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

## Quick Start

### barplot

```sh
curl -sL https://git.io/ISLANDScsv \
| sort -nk2 -t, \
| tail \
| uplot bar -d, -t "Areas of the World's Major Landmasses"
```

![image](https://user-images.githubusercontent.com/5798442/101988075-038cde00-3cdb-11eb-81be-bbd403a318db.png)

### histogram

```sh
echo -e "from numpy import random;" \
        "n = random.randn(10000);"  \
        "print('\\\n'.join(str(i) for i in n))" \
| python \
| uplot hist --nbins 20
```

![image](https://user-images.githubusercontent.com/5798442/101988180-63838480-3cdb-11eb-8b4f-67286f8ebe05.png)

### lineplot

```sh
curl -sL https://git.io/AirPassengers \
| cut -f2,3 -d, \
| uplot line -d, -w 50 -h 15 -t AirPassengers --xlim 1950,1960 --ylim 0,600
```

![image](https://user-images.githubusercontent.com/5798442/101988206-86159d80-3cdb-11eb-95fe-b7fbf2a1faf4.png)

### scatter

```sh
curl -sL https://git.io/IRIStsv \
| cut -f1-4 \
| uplot scatter -H -t IRIS
```

![image](https://user-images.githubusercontent.com/5798442/101988233-ac3b3d80-3cdb-11eb-9916-658bf631d72f.png)

### density

```sh
curl -sL https://git.io/IRIStsv \
| cut -f1-4 \
| uplot density -H -t IRIS
```

![image](https://user-images.githubusercontent.com/5798442/101988248-c5dc8500-3cdb-11eb-906b-59afaac98773.png)

### boxplot

```sh
curl -sL https://git.io/IRIStsv \
| cut -f1-4 \
| uplot boxplot -H -t IRIS
```

![image](https://user-images.githubusercontent.com/5798442/101988276-f02e4280-3cdb-11eb-8cef-cd5a9dee4fd8.png)

### count

```sh
curl -sL https://git.io/TITANICcsv \

```

Note: `count` is slower than other Unix commands because it runs in a Ruby script.


## Usage

### file

### stream

### help

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

### colors

```sh
uplot colors
```


## Development

Let's keep it simple.

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/kojix2/youplot](https://github.com/kojix2/youplot).

## License

[MIT License](https://opensource.org/licenses/MIT).
