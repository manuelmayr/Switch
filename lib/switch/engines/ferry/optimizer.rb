module Ferry
  module Optimizer
    attr_accessor :optimizer_path

    def optimize
      raise StandardError, "Implement this!"
    end
  end

  module DotPrinter
    attr_accessor :dotprinter_path

    def print
    end
  end

  module SQLPrinter
    attr_accessor :sql_path

    def to_sql
    end
  end
end
