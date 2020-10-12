# uplot

[![Build Status](https://travis-ci.com/kojix2/uplot.svg?branch=master)](https://travis-ci.com/kojix2/uplot)
[![Gem Version](https://badge.fury.io/rb/u-plot.svg)](https://badge.fury.io/rb/u-plot)
[![Docs Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://rubydoc.info/gems/u-plot)
[![The MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)

Create ASCII charts on the terminal with data from standard streams in the pipeline. 

:bar_chart: Powered by [UnicodePlot](https://github.com/red-data-tools/unicode_plot.rb)

:construction: Under development! :construction:

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

<img src="https://i.imgur.com/wpsoGJq.png" width="75%" height="75%"></img>

<img src="https://i.imgur.com/97R2MQx.png" width="75%" height="75%"></img>

**scatter**

<img src="https://i.imgur.com/STX7bFT.png" width="75%" height="75%"></img>

**line**

<img src="https://i.imgur.com/PVl5dsa.png" width="75%" height="75%"></img>

**box**

<img src="https://i.imgur.com/sNI4SmN.png" width="75%" height="75%"></img>


## Development

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/kojix2/uplot](https://github.com/kojix2/uplot).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
