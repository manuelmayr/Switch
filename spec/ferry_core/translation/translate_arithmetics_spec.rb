require "spec_helper"

module Switch
  describe TranslateToAlgebra do
    context "Translate aggregates" do
      before do
        @sql_dir = File.dirname(__FILE__) +
                        "/sql/arithmetics/"
        @plus   = Int.new(40) + 2
        @minus  = Int.new(44) - 2
        @mult   = Int.new(21) * 2
        @divide = Int.new(84) / 2
      end

      describe "When we are translating 40 + 2" do
        it "it should return a corresponding SQL query" do
          @plus.to_sql.should is_SQL(
            IO.read(@sql_dir + "plus.sql"))
        end
      end

      describe "When we are translating 44 - 2" do
        it "it should return a corresponding SQL query" do
          @minus.to_sql.should is_SQL(
            IO.read(@sql_dir + "minus.sql"))
        end
      end

      describe "When we are translating 21 * 2" do
        it "it should return a corresponding SQL query" do
          @mult.to_sql.should is_SQL(
            IO.read(@sql_dir + "mult.sql"))
        end
      end

      describe "When we are translating 84 / 2" do
        it "it should return a corresponding SQL query" do
          @divide.to_sql.should is_SQL(
            IO.read(@sql_dir + "divide.sql"))
        end
      end
    end
  end
end




