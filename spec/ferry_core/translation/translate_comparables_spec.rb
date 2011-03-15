require "spec_helper"

module Switch
  describe TranslateToAlgebra do
    context "Translate comparables" do
      before do
        @sql_dir = File.dirname(__FILE__) +
                        "/sql/comparables/"
        @eq = DBValue(1) == 1
        @uneq = DBValue(1) != 1
        @greater = DBValue(2) > 3
        @less    = DBValue(2) < 3
        @lessEqual1 = DBValue(2) <= 3
        @lessEqual2 = DBValue(2) <= 2
        @greaterEqual1 = DBValue(3) >= 2
        @greaterEqual2 = DBValue(3) >= 3
      end

      describe "When we are translating 1 == 1" do
        it "it should return a corresponding SQL query" do
          @eq.to_sql.should is_SQL(
            IO.read(@sql_dir + "eq.sql"))
        end
      end

      describe "When we are translating 1 != 1" do
        it "it should return a corresponding SQL query" do
          @uneq.to_sql.should is_SQL(
            IO.read(@sql_dir + "uneq.sql"))
        end
      end

      describe "when we are translating 2 > 3" do
        it "it should return a corresponding sql query" do
          @greater.to_sql.should is_SQL(
            IO.read(@sql_dir + "greater.sql"))
        end
      end

      describe "when we are translating 2 < 3" do
        it "it should return a corresponding sql query" do
          @less.to_sql.should is_SQL(
            IO.read(@sql_dir + "less.sql"))
        end
      end

      describe "when we are translating 2 <= 3" do
        it "it should return a corresponding sql query" do
          @lessEqual1.to_sql.should is_SQL(
            IO.read(@sql_dir + "lessEqual1.sql"))
        end
      end

      describe "when we are translating 2 <= 2" do
        it "it should return a corresponding sql query" do
          @lessEqual2.to_sql.should is_SQL(
            IO.read(@sql_dir + "lessEqual2.sql"))
        end
      end

      describe "when we are translating 3 >= 2" do
        it "it should return a corresponding sql query" do
          @greaterEqual1.to_sql.should is_SQL(
            IO.read(@sql_dir + "greaterEqual1.sql"))
        end
      end

      describe "when we are translating 2 >= 2" do
        it "it should return a corresponding sql query" do
          @greaterEqual2.to_sql.should is_SQL(
            IO.read(@sql_dir + "greaterEqual2.sql"))
        end
      end

    end
  end
end
