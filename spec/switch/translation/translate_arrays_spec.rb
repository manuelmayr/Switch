require "spec_helper"

module Switch
  describe TranslateToAlgebra do
    context "Translate arrays to SQL" do
      before do
        @sql_dir = File.dirname(__FILE__) +
                        "/sql/arrays/"
        @ary1 = Ary.new(1,2,3)
        @ary2 = Ary.new([1,2,3],[4,5,6])
        @ary3 = Ary.new([[[1],[2],[3]],[[4],[5],[6]]])
      end

      describe "When we are translating an array [1,2,3]" do
        it "it should return a corresponding SQL query" do
          @ary1.to_sql.should is_SQL(
            IO.read(@sql_dir + "ary1.sql"))
        end
      end

      describe "When we are translating an array [[1,2,3],[4,5,6]]" do
        it "it should return a corresponding SQL query" do
          @ary2.to_sql.should is_SQL(
            IO.read(@sql_dir + "ary2.sql"))
        end
      end

      describe "When we are translating an array " \
               "[[[[1],[2],[3]],[[4],[5],[6]]]]" do
        it "it should return a corresponding SQL query" do
          @ary3.to_sql.should is_SQL(
            IO.read(@sql_dir + "ary3.sql"))
        end
      end

    end
  end
end
