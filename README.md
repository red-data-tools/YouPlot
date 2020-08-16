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

```
                ┌                                        ┐ 
   [-4.5, -4.0) ┤ 1                                        
   [-4.0, -3.5) ┤ 0                                        
   [-3.5, -3.0) ┤ 1                                        
   [-3.0, -2.5) ┤▇▇ 9                                      
   [-2.5, -2.0) ┤▇▇▇ 15                                    
   [-2.0, -1.5) ┤▇▇▇▇▇▇▇▇▇ 50                              
   [-1.5, -1.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 97                     
   [-1.0, -0.5) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 154          
   [-0.5,  0.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 193   
   [ 0.0,  0.5) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 165        
   [ 0.5,  1.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 152          
   [ 1.0,  1.5) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 86                       
   [ 1.5,  2.0) ┤▇▇▇▇▇▇▇▇▇ 51                              
   [ 2.0,  2.5) ┤▇▇▇▇ 21                                   
   [ 2.5,  3.0) ┤▇ 3                                       
   [ 3.0,  3.5) ┤ 2                                        
                └                                        ┘ 
                                Frequency
```

**scatter**

```sh
wget https://raw.githubusercontent.com/uiuc-cse/data-fa14/gh-pages/data/iris.csv -qO - \
 | cut -f1-4 -d, \
 | uplot scatter -H -d, -t IRIS -m 10
```

## Development

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/kojix2/uplot](https://github.com/kojix2/uplot).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
