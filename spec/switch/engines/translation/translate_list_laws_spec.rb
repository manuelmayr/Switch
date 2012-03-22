require "spec_helper"
require "rushcheck"


class RandomIntegerArray < RandomArray; end
RandomIntegerArray.set_pattern(Integer) { |ary, i| Integer }

module Switch

  def forall(*cs, &f)
    RushCheck::Claim.new(*cs, &f).check.should eql(true)
  end

  describe TranslateToAlgebra do
    context "Check list laws on the database" do

      before do
      end

      describe "ary.take(x).append(ary.drop(x))" do
        it "should be ary" do
          forall(RandomIntegerArray, Integer) do |ary, i|
            RushCheck.guard { i < ary.length and i >= 0 }
            res = DBValue(ary).
                    take(i).append(ary.drop(i)).all
            res.should eql(ary)
          end
        end
      end

      describe "record.zip.unzip" do
        it "should be record" do
          forall(RandomIntegerArray, RandomIntegerArray) do |ary1, ary2|
            RushCheck.guard { ary1.length > 0 and ary2.length > 0 }
            rec = { a:ary1, b:ary2 }
            res = DBValue(rec).zip.unzip.all
            res.should eql(
              case
                when ary1.length == ary2.length then
                  rec
                when ary1.length < ary2.length then
                  { a:ary1, b:ary2[0...ary1.length] }
                else
                  { a:ary1[0...ary2.length], b:ary2 }
              end)
          end
        end
      end

    end
  end
end

