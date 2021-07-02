<div align="center">
  <img src="logo.svg">
  <hr>
  <img alt="Build Status" src="https://github.com/red-data-tools/YouPlot/workflows/test/badge.svg">
  <a href="https://rubygems.org/gems/youplot/"><img alt="Gem Version" src="https://badge.fury.io/rb/youplot.svg"></a>
  <a href="https://zenodo.org/badge/latestdoi/283230219"><img alt="DOI" src="https://zenodo.org/badge/283230219.svg"></a>
  <a href="https://rubydoc.info/gems/youplot/"><img alt="Docs Stable" src="https://img.shields.io/badge/docs-stable-blue.svg"></a>
  <a href="LICENSE.txt"><img alt="The MIT License" src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
  
  YouPlot is a command line tool that draws plots on the terminal.

  :bar_chart: Powered by [UnicodePlot](https://github.com/red-data-tools/unicode_plot.rb)
</div>

## Installation

```
gem install youplot
```

## Quick Start

<img alt="barplot" src="https://user-images.githubusercontent.com/5798442/101999903-d36a2d00-3d24-11eb-9361-b89116f44122.png" width=160> <img alt="histogram" src="https://user-images.githubusercontent.com/5798442/101999820-21cafc00-3d24-11eb-86db-e410d19b07df.png" width=160> <img alt="scatter" src="https://user-images.githubusercontent.com/5798442/101999827-27284680-3d24-11eb-9903-551857eaa69c.png" width=160> <img alt="density" src="https://user-images.githubusercontent.com/5798442/101999828-2abbcd80-3d24-11eb-902c-2f44266fa6ae.png" width=160> <img alt="boxplot" src="https://user-images.githubusercontent.com/5798442/101999830-2e4f5480-3d24-11eb-8891-728c18bf5b35.png" width=160>

`uplot <command> [options] <data.tsv>`

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

```sh
cat gencode.v35.annotation.gff3 \
| grep -v '#' | grep 'gene' | cut -f1 \
| uplot count -t "The number of human gene annotations per chromosome"  -c blue
```

<p align="center">
  <img alt="count" src="https://user-images.githubusercontent.com/5798442/101999832-30b1ae80-3d24-11eb-96fe-e5000bed1f5c.png">
</p>

In this example, YouPlot counts the number of chromosomes where genes are located. 
* [GENCODE - Human Release](https://www.gencodegenes.org/human/)

Note: `count` is not very fast because it runs in a Ruby script.
This is fine in most cases, as long as the data size is small. If you want to visualize huge data, it is faster to use a combination of common Unix commands as shown below.

```sh
cat gencode.v35.annotation.gff3 | grep -v '#' | grep 'gene' | cut -f1 \
| sort | uniq -c | sort -nrk1 \
| uplot bar --fmt yx -d ' ' -t "The number of human gene annotations per chromosome"  -c blue
```

## Usage

### Commands

`uplot` is the shortened form of `youplot`. You can use either.

| Command                                        | Description                       |
|------------------------------------------------|-----------------------------------|
| `cat data.tsv \| uplot <command> [options]`    | Take input from stdin             |
| `uplot <command> [options] data.tsv ...`       | Take input from files             |
| `pipeline1 \| uplot <command> -O \| pipeline2` | Outputs data from stdin to stdout |

### Subcommands

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
|           |       |                                        |
| count     | c     | draw a barplot based on the number of occurrences (slow) |
|           |       |                                        |
| colors    | color | show the list of available colors      |

### Output the plot

* `-o`
  * By default, the plot is output to **standard error output**.
  * If you want to output to standard input, Use hyphen ` -o -` or no argument `uplot s -o | `.

### Output the input data

* `-O`
  * By default, the input data is not shown anywhere.
  * If you want to pass the input data directly to the standard output, Use hyphen `-O -` or no argument `uplot s -O |`.
  * This is useful when passing data to a subsequent pipeline.

### Header

* `-H`
  * If input data contains a header line, you need to specify the `-H` option.

### Delimiter

* `-d`
  * You do not need to use `-d` option for tab-delimited text since the default value is tab.
  * To specify a blank space, you can use `uplot bar -d ' ' data.txt`. 

### Real-time data

* `-p` `--progress`
  * Experimental progressive mode is currently under development.
  * `ruby -e 'loop{puts rand(100)}' | uplot line --progress`

### Show detailed options for subcommands

* `--help`
  * The `--help` option will show more detailed options for each subcommand.
  * `uplot hist --help`

### Set columns as x-axis or y-axis

* YouPlot treats the first column as the X axis and the second column as the Y axis. When working with multiple series, the first column is the X axis, the second column is series Y1, the third column is series Y2, and so on. 
* If you pass only one column of data for `line` and `bar`, YouPlot will automatically use a sequential number starting from 1 as the X-axis. 

* `--fmt`
  * `--fmt xyy` `--fmt xyxy` `--fmt yx` options give you a few more choices. See `youplot <command> --help` for more details. 
  * The fmt option may be renamed in the future. 
  * The `-x` and `-y` options might be used to specify columns in the future.

* Use `awk '{print $2, $1}'` to swap columns. Use `paste` to concatenate series.

### Categorical data

* With GNU datamash, you can manage to handle categorized data. 
  * `cat test/fixtures/iris.csv | sed '/^$/d' | datamash --header-in --output-delimiter=: -t, -g5 collapse 3,4 | cut -f2-3 -d: | sed 's/:/\n/g' | uplot s -d, -T --fmt xyxy`
  * This is not so easy...

### Time series

* Not yet supported.

## Tools that are useful to use with YouPlot

* [csvtk](https://github.com/shenwei356/csvtk)
* [GNU datamash](https://www.gnu.org/software/datamash/)
* [awk](https://www.gnu.org/software/gawk/)
* [xsv](https://github.com/BurntSushi/xsv)

## Contributing

YouPlot is a library under development, so even small improvements like typofix are welcome!
Please feel free to send us your pull requests.

* [Report bugs](https://github.com/red-data-tools/YouPlot/issues)
* Fix bugs and [submit pull requests](https://github.com/red-data-tools/YouPlot/pulls)
* Write, clarify, or fix documentation
  * English corrections by native speakers are welcome.
* Suggest or add new features
* Make a donation

### Development

```sh
# fork the main repository by clicking the Fork button. 
git clone https://github.com/your_name/YouPlot
bundle install             # Install the gem dependencies
bundle exec rake test      # Run the test
bundle exec rake install   # Installation from source code
bundle exec exe/uplot      # Run youplot (Try out the edited code)
```

### Acknowledgements

* [sampo grafiikka](https://jypg.net/sampo_grafiikka) - Project logo creation
* [yutaas](https://github.com/yutaas) - English proofreading

## License

[MIT License](https://opensource.org/licenses/MIT).
