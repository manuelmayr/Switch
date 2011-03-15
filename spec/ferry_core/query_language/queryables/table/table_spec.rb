require "spec_helper"

module Switch
  describe Table do
    context "Basics" do
      before do
      end

      describe "When we are only specifying a key without order" do
        it "the table is automatically ordered by the key." do
          Table.new(:article, {id:TInt.type, name:TStr.type, price:TDbl.type},
              :keys => [:id]).should ==
            Table.new(:article, {id:TInt.type, name:TStr.type, price:TDbl.type},
                :keys => [:id], :order => [:id])
        end
      end
    end
  end
end
