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

![barplot](https://user-images.githubusercontent.com/5798442/101999903-d36a2d00-3d24-11eb-9361-b89116f44122.png)

### histogram

```sh
echo -e "from numpy import random;" \
        "n = random.randn(10000);"  \
        "print('\\\n'.join(str(i) for i in n))" \
| python \
| uplot hist --nbins 20
```
![histogram](https://user-images.githubusercontent.com/5798442/101999820-21cafc00-3d24-11eb-86db-e410d19b07df.png)

### lineplot

```sh
curl -sL https://git.io/AirPassengers \
| cut -f2,3 -d, \
| uplot line -d, -w 50 -h 15 -t AirPassengers --xlim 1950,1960 --ylim 0,600
```

![lineplot](https://user-images.githubusercontent.com/5798442/101999825-24c5ec80-3d24-11eb-99f4-c642e8d221bc.png)

### scatter

```sh
curl -sL https://git.io/IRIStsv \
| cut -f1-4 \
| uplot scatter -H -t IRIS
```

![scatter](https://user-images.githubusercontent.com/5798442/101999827-27284680-3d24-11eb-9903-551857eaa69c.png)

### density

```sh
curl -sL https://git.io/IRIStsv \
| cut -f1-4 \
| uplot density -H -t IRIS
```

![density](https://user-images.githubusercontent.com/5798442/101999828-2abbcd80-3d24-11eb-902c-2f44266fa6ae.png)

### boxplot

```sh
curl -sL https://git.io/IRIStsv \
| cut -f1-4 \
| uplot boxplot -H -t IRIS
```

![boxplot](https://user-images.githubusercontent.com/5798442/101999830-2e4f5480-3d24-11eb-8891-728c18bf5b35.png)

### count

```sh
cat gencode.v35.annotation.gff3 \
| grep -v '#' | grep 'gene' | cut -f1 | \
 uplot count -t "The number of human gene annotations per chromosome"  -c blue
```

![count](https://user-images.githubusercontent.com/5798442/101999832-30b1ae80-3d24-11eb-96fe-e5000bed1f5c.png)

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
