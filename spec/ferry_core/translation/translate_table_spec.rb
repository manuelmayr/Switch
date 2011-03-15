require "spec_helper"

module Switch
  describe TranslateToAlgebra do
    context "Translate table references to SQL" do
      before do
        @sql_dir = File.dirname(__FILE__) +
                        "/sql/table/"
        @tbl1 =
          Table.new(:article,
            {id:TInt.type, name:TStr.type, price:TDbl.type},
            :keys => [:id])

        @tbl2 =
          Table.new(:article,
            {id:TInt.type, name:TStr.type, price:TDbl.type},
            :keys => [:id], :order => [:name])
      end

      describe "When we are translating a table article" \
               " with key :id" do
        it "the SQL query returns a table reference ordered by :id" do
          @tbl1.to_sql.should is_SQL(
            IO.read(@sql_dir + "tbl1.sql"))
        end
      end

      describe "When we are translating a table article" \
               " with key :id and order by :name" do
        it "the SQL query returns a table reference ordered by :name" do
          @tbl2.to_sql.should is_SQL(
            IO.read(@sql_dir + "tbl2.sql"))
        end
      end

    end
  end
end
