![Logo](https://user-images.githubusercontent.com/5798442/102004318-ec89d280-3d52-11eb-8608-d890b42593f1.png)

![Build Status](https://github.com/kojix2/youplot/workflows/test/badge.svg)
[![Gem Version](https://badge.fury.io/rb/youplot.svg)](https://badge.fury.io/rb/youplot)
[![Docs Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://rubydoc.info/gems/youplot)
[![The MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)
[![DOI](https://zenodo.org/badge/283230219.svg)](https://zenodo.org/badge/latestdoi/283230219)

YouPlot is a command line tool for Unicode Plotting working with data from standard stream.

:bar_chart: Powered by [UnicodePlot](https://github.com/red-data-tools/unicode_plot.rb)

## Installation

```
gem install youplot
```

## Quick Start

`cat data.tsv | uplot <command> [options]`

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

In this example, YouPlot counts the number of chromosomes where the gene is located from the human gene annotation file and create a bar chart. The human gene annotation file can be downloaded from the following website.

* https://www.gencodegenes.org/human/

```sh
cat gencode.v35.annotation.gff3 \
| grep -v '#' | grep 'gene' | cut -f1 | \
 uplot count -t "The number of human gene annotations per chromosome"  -c blue
```

![count](https://user-images.githubusercontent.com/5798442/101999832-30b1ae80-3d24-11eb-96fe-e5000bed1f5c.png)

Note: `count` is not very fast because it runs in a Ruby script.
This is fine if the data is small, that is, in most cases. However, if you want to visualize huge data, it is faster to use a combination of common Unix commands as shown below.

```sh
cat gencode.v35.annotation.gff3 | grep -v '#' | grep 'gene' | cut -f1 \
|sort | uniq -c | sort -nrk2 | awk '{print $2,$1}' \
| uplot bar -d ' ' -t "The number of human gene annotations per chromosome"  -c blue
```

## Usage

### how to use YouPlot?

`uplot` is the same as `youplot`. You can use either.

|                                   |                                                |
|-----------------------------------|------------------------------------------------|
| Reads data from standard input    | `cat data.tsv \| uplot <command> [options]`    |
| Reads data from a file            | `uplot <command> [options] data.tsv`           |
| Outputs data from stdin to stdout | `pipeline1 \| uplot <command> -O \| pipeline2` |

### plot commands

| command   | short |                                        |
|-----------|-------|----------------------------------------|
| barplot   | bar   | draw a horizontal barplot              |
| histogram | hist  | draw a horizontal histogram            |
| lineplot  | line  | draw a line chart                      |
| lineplots | lines | draw a line chart with multiple series |
| scatter   | s     | draw a scatter plot                    |
| density   | d     | draw a density plot                    |
| boxplot   | box   | draw a horizontal boxplot              |


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

## Why YouPlot?

Wouldn't it be a bit of pain to have to run R, Python, Julia, gnuplot or whatever REPL just to check your data?
YouPlot is a command line tool for this purpose. With YouPlot, you can continue working without leaving your terminal and shell. 

## Development

```sh
git clone https://github.com/your_name/GR.rb # Clone the Git repo
cd GR.rb
bundle install             # Install the gem dependencies
bundle exec rake test      # Run the test
bundle exec rake install   # Installation from source code
```

## Contributing

* [Report bugs](https://github.com/kojix2/youplot/issues)
* Fix bugs and [submit pull requests](https://github.com/kojix2/youplot/pulls)
* Write, clarify, or fix documentation
* Suggest or add new features

## License

[MIT License](https://opensource.org/licenses/MIT).
