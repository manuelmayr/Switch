require "spec_helper"

module Switch
  describe TranslateToAlgebra do
    context "Translate aggregates" do
      before do
        @sql_dir = File.dirname(__FILE__) +
                        "/sql/aggr/"
        @max = Ary.new(1,2,3,4).max
        @min = Ary.new(1,2,3,4).min
        @sum = Ary.new(1,2,3,4,5).sum
        @avg = Ary.new(1.5,6.0).avg
        @uniq = Ary.new(1,2,3,4,4,3,2,1).uniq
        @max_complex = Ary.new(1,Ary.new(1,2,3).max,2).max
        @max_macro = Ary.new(1,2,3,4).max_over { |x| x }
        @min_macro = Ary.new(1,2,3,4).min_over { |x| x }
        @sum_macro = Ary.new(1,2,3,4,5).sum_over { |x| x }
        @avg_macro = Ary.new(1.5,6.0).avg_over { |x| x }
      end

      describe "When we are translating [1,2,3,4].max" do
        it "it should return a corresponding SQL query" do
          @max.to_sql.should is_SQL(
            IO.read(@sql_dir + "max.sql"))
        end
      end

      describe "When we are translating [1,2,3,4].min" do
        it "it should return a corresponding SQL query" do
          @min.to_sql.should is_SQL(
            IO.read(@sql_dir + "min.sql"))
        end
      end

      describe "When we are translating [1,2,3,4,5].sum" do
        it "it should return a corresponding SQL query" do
          @sum.to_sql.should is_SQL(
            IO.read(@sql_dir + "sum.sql"))
        end
      end

      describe "When we are translating [1.5,6.0].avg" do
        it "it should return a corresponding SQL query" do
          @avg.to_sql.should is_SQL(
            IO.read(@sql_dir + "avg.sql"))
        end
      end

      describe "When we are translating [1,2,3,4,4,3,2,1].uniq" do
        it "it should return a corresponding SQL query" do
          @uniq.to_sql.should is_SQL(
            IO.read(@sql_dir + "uniq.sql"))
        end
      end

      describe "When we are translating [1,[1,2,3].max,2].max" do
        it "it should return a corresponding SQL query" do
          @max_complex.to_sql.should is_SQL(
            IO.read(@sql_dir + "max_complex.sql"))
        end
      end

      describe "When we are translating [1,2,3,4].max_over { |x| x }" do
        it "it should return a corresponding SQL query" do
          @max_macro.to_sql.should is_SQL(
            IO.read(@sql_dir + "max.sql"))
        end
      end

      describe "When we are translating [1,2,3,4].min_over { |x| x }" do
        it "it should return a corresponding SQL query" do
          @min_macro.to_sql.should is_SQL(
            IO.read(@sql_dir + "min.sql"))
        end
      end

      describe "When we are translating [1,2,3,4,5].sum_over { |x| x }" do
        it "it should return a corresponding SQL query" do
          @sum_macro.to_sql.should is_SQL(
            IO.read(@sql_dir + "sum.sql"))
        end
      end

      describe "When we are translating [1.5,6.0].avg_over { |x| x }" do
        it "it should return a corresponding SQL query" do
          @avg_macro.to_sql.should is_SQL(
            IO.read(@sql_dir + "avg.sql"))
        end
      end

    end
  end
end
