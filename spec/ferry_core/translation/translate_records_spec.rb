
require "spec_helper"

module Switch
  describe TranslateToAlgebra do
    context "Translate records values to SQL" do
      before do
        @sql_dir = File.dirname(__FILE__) +
                        "/sql/records/"
        @rec1 = Record.new(a:1, b:2, c:3)
        @rec2 = Record.new(a:[1,2], b:10, c:{ d:"a", e:"b"})
      end

      describe "When we are translating a record { a:1, b:2, c:3 }" do
        it "the SQL query returns a record" do
          @rec1.to_sql.should is_SQL(
            IO.read(@sql_dir + "rec1.sql"))
        end
      end

      describe "When we are translating a record { :[1,2], b:10, b:{ d:'a', e:'b'} }" do
        it "the SQL query returns a record" do
          @rec2.to_sql.should is_SQL(
            IO.read(@sql_dir + "rec2.sql"))
        end
      end

    end
  end
end
