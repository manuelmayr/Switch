require "spec_helper"

module Switch
  describe TranslateToAlgebra do
    context "Execute complex queries on an engine" do
      before do
        @qry1 = Articles.map { |x|
                  ShoppingCarts.map { |y|
                    Clients.map { |z|
                      { article:x, shcart:y, client:z } } } }.
                flatten.flatten.
                select { |art, sh, cli|
                  (art.id == sh.a_id).and(cli.id == sh.c_id) }.
                 group_with { |x| x.article.name }.
                 select { |k,v| k == "IPhone" }.
                 map { |k,v| v.map { |_,_,c| c.name }}.flatten
      end

      describe "Who bought an IPhone?" do
        it "it should be [\"Manuel\",\"Torsten\"]" do
          @qry1.all.should eql(["Manuel","Torsten"])
        end
      end

    end
  end
end

