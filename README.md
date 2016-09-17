# MkCalendar

## Introduction

This is the gem library which calculates calendar datas, including old-calendar.(by JPL DE430)

### Computable items

julian day(utc), julian day(jst), holiday, sekki_24, zassetsu,  
yobi, kanshi, sekku, lambda(sun), alpha(moon), moonage,  
old-calendar(year, month, day, leap flag), rokuyo

### Original Text

[旧暦計算サンプルプログラム](http://www.vector.co.jp/soft/dos/personal/se016093.html)  
Copyright (C) 1993,1994 by H.Takano

### Remark

However, the above program includes some problems for calculating the future  
old-calendar datas. So, I have done some adjustments.(by JPL DE430 etc.)

## Preparation

This library needs a JPL's DE430 binary file.

Download linux_p1550p2650.430 from [ftp://ssd.jpl.nasa.gov/pub/eph/planets/Linux/de430/](ftp://ssd.jpl.nasa.gov/pub/eph/planets/Linux/de430/), and place at a suitable directory.

If neccessary, rename the binary file.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mk_cal_jpl'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mk_cal_jpl

## Usage

### Instantiation

    require 'mk_cal_jpl'
    
    o = MkCalJpl.new("/path/to/<JPL DE430 binary>")
    
    # Otherwise
    o = MkCalJpl.new("/path/to/<JPL DE430 binary>", "20160916")

### Calculation

    year     = o.year
    month    = o.month
    day      = o.day
    jd       = o.jd
    jd_jst   = o.jd_jst
    holiday  = o.holiday
    sekki_24 = o.sekki_24
    zassetsu = o.zassetsu
    yobi     = o.yobi
    kanshi   = o.kanshi
    sekku    = o.sekku
    lambda   = o.lambda
    alpha    = o.alpha
    moonage  = o.moonage
    oc       = o.oc
    str =  sprintf("%04d-%02d-%02d", year, month, day)
    str << " #{yobi}曜日"
    str << " #{holiday}" unless holiday == ""
    str << " #{jd}UTC(#{jd_jst}JST) #{kanshi} "
    str << sprintf("%04d-%02d-%02d", oc[0], oc[2], oc[3])
    str << "(閏)" if oc[1] == 1
    str << " #{oc[4]}"
    str << " #{sekki_24}" unless sekki_24 == ""
    str << " #{zassetsu}" unless zassetsu == ""
    str << " #{sekku}" unless sekku == ""
    str << " #{lambda} #{alpha} #{moonage}"
    puts str

* It takes time for result output, because this library calculates correctly each time on loop processing.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec mk_cal_jpl` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/komasaru/mk_cal_jpl.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

