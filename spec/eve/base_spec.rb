module Eve 
  describe Base do
    describe "parse_date" do
      it "returns nil on unexpected input" do
        Base.new.parse_date("HohOhO").should == nil
      end

      it "should parse eve formated dates" do
        Base.new.parse_date("1976-11-04 09:17:23").should == DateTime.new(1976, 11, 4, 9, 17, 23) 
      end
    end
  end
end
