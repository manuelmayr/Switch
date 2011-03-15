require "spec_helper"

module Switch
  describe TranslateToAlgebra do
    context "Translate more complex queries to SQL" do
      before do
        @sql_dir = File.dirname(__FILE__) +
                        "/sql/complex/"
        @qry1 = Table.new(:article,
                          { id:TInt.type, name:TStr.type, price:TDbl.type },
                          { :keys => [:id], :order => [:name]}).map { |x| x[:name]}.take(5)
        @qry2 = Table.new(:article,
                          { id:TInt.type, name:TStr.type, price:TDbl.type },
                          { :keys => [:id], :order => [:name]}).map { |x| x[:name]}.
                  append([1.2, 2.4]).
                  append(["foobar", "snafu"])
        @qry3 = Ary.new(1,2,3,4,5,6).map { |x|
                                DBValue([1,2,3,4,5,6]).map { |y| [x,y] } }.
                             flatten.select { |x| x.at(1) + x.at(2) == 7 }
        @qry4 = Ary.new(1,2,3).map { |x|
                        { arrays:[x+1, x+2, x+3] } }.
                     select { |x| x[:arrays].at(1) == 3 }
        t = Table.new(:article, { id:TInt.type, name:TStr.type, price:TDbl.type },
                                { :keys => [:id], :order => [:name]}).map { |x| x[:name] }
        @qry5 = [10,9,8].reduce(t) do |x,y|
                           x.take(y)
                end.append(["snafu","foobar"]).
                    drop(5).
                    append([12,42]).
                    drop(5)
        @qry6 = DBValue([1,2,3]).map { |x|
                  DBValue([4,5,6]).map { |y|
                    DBValue([7,8,9]).map { |z|
                      { a:x, b:y, c:z } } } }.
                flatten.
                flatten.
                select { |g|
                  g[:a] * g[:b] * g[:c] <= 28 }

        @qry7 = DBValue([[1,2,3], [3,3], [4]]).
                  select { |x| x.all? { |x| x == 3 } }

        @qry8 = DBValue([[1,2,3], [3,3], [4]]).
                  select { |x| x.any? { |x| x == 3 } }
      end

      describe "When translating Query1" do
        it "the translation should emit" do
          @qry1.to_sql.should is_SQL(
            IO.read(@sql_dir + "qry1.sql"))
        end
      end

      describe "When translating Query2" do
        it "the translation should emit" do
          @qry2.to_sql.should is_SQL(
            IO.read(@sql_dir + "qry2.sql"))
        end
      end

      describe "When translating Query3" do
        it "the translation should emit" do
          @qry3.to_sql.should is_SQL(
            IO.read(@sql_dir + "qry3.sql"))
        end
      end

      describe "When translating Query4" do
        it "the translation should emit" do
          @qry4.to_sql.should is_SQL(
            IO.read(@sql_dir + "qry4.sql"))
        end
      end

      describe "When translating Query5" do
        it "the translation should emit" do
          @qry5.to_sql.should is_SQL(
            IO.read(@sql_dir + "qry5.sql"))
        end
      end

      describe "When translating Query6" do
        it "the translation should emit" do
          @qry6.to_sql.should is_SQL(
            IO.read(@sql_dir + "qry6.sql"))
        end
      end

      describe "When translating Query7" do
        it "the translation should emit" do
          @qry7.to_sql.should is_SQL(
            IO.read(@sql_dir + "qry7.sql"))
        end
      end

      describe "When translating Query8" do
        it "the translation should emit" do
          @qry8.to_sql.should is_SQL(
            IO.read(@sql_dir + "qry8.sql"))
        end
      end

    end
  end
end
