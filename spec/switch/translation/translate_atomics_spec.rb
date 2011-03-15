require "spec_helper"

module Switch
  describe TranslateToAlgebra do
    context "Translate atomic values to SQL" do
      before do
        @sql_dir = File.dirname(__FILE__) +
                        "/sql/atomics/"
        @int = Int.new(42)
        @str = Str.new("foobar")
        @dbl = Dbl.new(42.42)
      end

      describe "When we are translating an Integer" do
        it "the SQL query returns an Integer" do
          @int.to_sql.should is_SQL(
            IO.read(@sql_dir + "int.sql"))
        end
      end

      describe "When we are translating a String" do
        it "the SQL query returns a String " do
          @str.to_sql.should is_SQL(
            IO.read(@sql_dir + "str.sql"))
        end
      end

      describe "When we are translating a Double" do
        it "the SQL query returns a Double " do
          @dbl.to_sql.should is_SQL(
            IO.read(@sql_dir + "dbl.sql"))
        end
      end

    end
  end
end
