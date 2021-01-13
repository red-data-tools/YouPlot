<p align="center">
  <img src="https://user-images.githubusercontent.com/5798442/103439598-9e952a00-4c81-11eb-881f-67c593bb7861.png" width="75%" height="75%" />
</p>

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

* `cat data.tsv | uplot <command> [options]` or
* `uplot <command> [options] <data.tsv>`

### barplot

```sh
curl -sL https://git.io/ISLANDScsv \
| sort -nk2 -t, \
| tail -n15 \
| uplot bar -d, -t "Areas of the World's Major Landmasses"
```

<p align="center">
<img alt="barplot" src="https://user-images.githubusercontent.com/5798442/101999903-d36a2d00-3d24-11eb-9361-b89116f44122.png">
</p>

### histogram

```sh
echo -e "from numpy import random;" \
        "n = random.randn(10000);"  \
        "print('\\\n'.join(str(i) for i in n))" \
| python \
| uplot hist --nbins 20
```

<p align="center">
  <img alt="histogram" src="https://user-images.githubusercontent.com/5798442/101999820-21cafc00-3d24-11eb-86db-e410d19b07df.png">
</p>

### lineplot

```sh
curl -sL https://git.io/AirPassengers \
| cut -f2,3 -d, \
| uplot line -d, -w 50 -h 15 -t AirPassengers --xlim 1950,1960 --ylim 0,600
```

<p align="center">
  <img alt="lineplot" src="https://user-images.githubusercontent.com/5798442/101999825-24c5ec80-3d24-11eb-99f4-c642e8d221bc.png">
</p>

### scatter

```sh
curl -sL https://git.io/IRIStsv \
| cut -f1-4 \
| uplot scatter -H -t IRIS
```

<p align="center">
  <img alt="scatter" src="https://user-images.githubusercontent.com/5798442/101999827-27284680-3d24-11eb-9903-551857eaa69c.png">
</p>

### density

```sh
curl -sL https://git.io/IRIStsv \
| cut -f1-4 \
| uplot density -H -t IRIS
```

<p align="center">
  <img alt="density" src="https://user-images.githubusercontent.com/5798442/101999828-2abbcd80-3d24-11eb-902c-2f44266fa6ae.png">
</p>

### boxplot

```sh
curl -sL https://git.io/IRIStsv \
| cut -f1-4 \
| uplot boxplot -H -t IRIS
```

<p align="center">
  <img alt="boxplot" src="https://user-images.githubusercontent.com/5798442/101999830-2e4f5480-3d24-11eb-8891-728c18bf5b35.png">
</p>

### count

In this example, YouPlot counts the number of chromosomes where the gene is located from the human gene annotation file and it creates a bar chart. The human gene annotation file can be downloaded from the following website.

* https://www.gencodegenes.org/human/

```sh
cat gencode.v35.annotation.gff3 \
| grep -v '#' | grep 'gene' | cut -f1 | \
 uplot count -t "The number of human gene annotations per chromosome"  -c blue
```

<p align="center">
  <img alt="count" src="https://user-images.githubusercontent.com/5798442/101999832-30b1ae80-3d24-11eb-96fe-e5000bed1f5c.png">
</p>

Note: `count` is not very fast because it runs in a Ruby script.
This is fine in most cases, as long as the data size is small. If you want to visualize huge data, it is faster to use a combination of common Unix commands as shown below.

```sh
cat gencode.v35.annotation.gff3 | grep -v '#' | grep 'gene' | cut -f1 \
|sort | uniq -c | sort -nrk2 | awk '{print $2,$1}' \
| uplot bar -d ' ' -t "The number of human gene annotations per chromosome"  -c blue
```

## Usage

### Why YouPlot?

Wouldn't it be a pain to have to run R, Python, Julia, gnuplot or whatever REPL just to check your data?
YouPlot is a command line tool for this purpose. With YouPlot, you can continue working without leaving your terminal and shell.

### how to use YouPlot?

`uplot` is the shortened form of `youplot`. You can use either.

|                                   |                                                |
|-----------------------------------|------------------------------------------------|
| Reads data from standard input    | `cat data.tsv \| uplot <command> [options]`    |
| Reads data from files             | `uplot <command> [options] data.tsv ...`       |
| Outputs data from stdin to stdout | `pipeline1 \| uplot <command> -O \| pipeline2` |

### Where to output the plot?

By default, the plot is output to *standard error output*.
The output file or stream for the plot can be specified with the `-o` option.

### Where to output the input data?

By default, the input data is not shown anywhere.
The `-O` option, with no arguments, outputs the input data directly to the standard output. This is useful when passing data to a subsequent pipeline.

### What types of plots are available?

The following sub-commands are available.

| command   | short | how it works                           |
|-----------|-------|----------------------------------------|
| barplot   | bar   | draw a horizontal barplot              |
| histogram | hist  | draw a horizontal histogram            |
| lineplot  | line  | draw a line chart                      |
| lineplots | lines | draw a line chart with multiple series |
| scatter   | s     | draw a scatter plot                    |
| density   | d     | draw a density plot                    |
| boxplot   | box   | draw a horizontal boxplot              |

See Quick Start for `count`.

| command   | short | how it works                                             |
|-----------|-------|----------------------------------------------------------|
| count     | c     |  draw a barplot based on the number of occurrences (slow) |

### What if the header line is included?

If your input data contains a header line, you need to specify the `-H` option.

### How to specify the delimiter?

Use the `-d` option. To specify a blank space, you can use `uplot bar -d ' ' data.txt`. You do not need to use `-d` option for tab-delimited text since the default value is tab.

### Is there a way to specify a column as the x-axis or y-axis?

Not yet. In principle, YouPlot treats the first column as the X axis and the second column as the Y axis. When working with multiple series, the first row is the X axis, the second row is series 1, the third row is series 2, and so on. If you pass only one column of data for `line` and `bar`, YouPlot will automatically use a sequential number starting from 1 as the X-axis. The　`--fmt xyy`, `--fmt xyxy` and `--fmt yx` options give you a few more choices. See `youplot <command> --help` for more details. YouPlot has limited functionalities, but you can use shell scripts such as `awk '{print $2, $1}'` to swap lines.

### How to plot real-time data?

Experimental progressive mode is currently under development.

```sh
ruby -e 'loop{puts rand(100)}' | uplot line --progress
```

### How to view detailed command line options?

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

### How to view the list of available colors?

```sh
uplot colors
```

## Contributing

* [Report bugs](https://github.com/kojix2/youplot/issues)
* Fix bugs and [submit pull requests](https://github.com/kojix2/youplot/pulls)
* Write, clarify, or fix documentation
  * English corrections by native speakers are welcome.
* Suggest or add new features


### Development

```sh
git clone https://github.com/your_name/GR.rb # Clone the Git repo
cd GR.rb
bundle install             # Install the gem dependencies
bundle exec rake test      # Run the test
bundle exec rake install   # Installation from source code
```

### Acknowledgements

* [Red Data Tools](https://github.com/red-data-tools) - Technical support
* [sampo grafiikka](https://jypg.net/sampo_grafiikka) - Project logo creation
* [yutaas](https://github.com/yutaas) - English proofreading

## License

[MIT License](https://opensource.org/licenses/MIT).
