require "spec_helper"
require "rushcheck"

class RandomIntegerArray < RandomArray; end
RandomIntegerArray.set_pattern(Integer) { |ary, i| Integer }

module Switch
  def forall(*cs, &f)
    RushCheck::Claim.new(*cs, &f).check
  end

  describe TranslateToAlgebra do
    context "Check id compilation on database"

    describe "any Integer i" do
      it "should be the same after compilation" do
        forall(Integer) do |i|
          res = DBValue(i).all
          res.should eql(i)
        end
      end
    end

    describe "any String s" do
      it "should be the same after compilation" do
        forall(String) do |s|
          res = DBValue(s).all
          res.should eql(s)
        end
      end
    end

    describe "any Float f" do
      it "should be the same after compilation" do
        forall(Float) do |f|
          res = DBValue(f).all
          res.should eql(f)
        end
      end
    end

    describe "any array ary" do
      it "should be the same after compilation" do
        forall(RandomIntegerArray) do |ary|
          RushCheck::guard { ary.length > 0 }
          res = DBValue(ary).all
          res.should eql(ary)
        end
      end
    end

  end

end
