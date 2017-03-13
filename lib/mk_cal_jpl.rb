require "mk_apos"
require "mk_coord"
require "mk_cal_jpl/version"
require "mk_cal_jpl/argument"
require "mk_cal_jpl/calendar"
require "mk_cal_jpl/compute"
require "mk_cal_jpl/const"
require "mk_cal_jpl/const_saku"
require "mk_cal_jpl/const_sekki_24"

module MkCalJpl
  def self.new(*args)
    bin_path, jst = MkCalJpl::Argument.new(*args).get_args
    return MkCalJpl::Calendar.new(bin_path, jst)
  end
end
