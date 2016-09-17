require 'date'

module MkCalJpl
  class Argument
    def initialize(*args)
      @args = *args
    end

    #=========================================================================
    # 引数取得
    #
    # @return: [BIN_PATH, JST]
    #=========================================================================
    def get_args
      bin_path = get_binpath
      jst      = get_jst
      check_bin_path(bin_path)
      return [bin_path, jst]
    rescue => e
      raise
    end

    def get_binpath
      raise Const::USAGE unless bin_path = @args.shift
      return bin_path
    end

    def get_jst
      jst = @args.shift
      unless jst
        now = Time.now
        return [now.year, now.month, now.day]
      end
      raise Const::MSG_ERR_2 unless jst =~ /^\d{8}$/
      year, month, day = jst[ 0, 4].to_i, jst[ 4, 2].to_i, jst[ 6, 2].to_i
      raise Const::MSG_ERR_3 unless Date.valid_date?(year, month, day)
      return [year, month, day]
    end

    def check_bin_path(bin_path)
      raise Const::MSG_ERR_1 unless File.exist?(bin_path)
    end
  end
end
