require 'spec_helper'

class Includer
  include ApplicationHelper
end

describe ApplicationHelper do
  context "valid time instance" do
  	it "formats time with no exception" do
  		t = Time.mktime(2000,"jan",1,20,15,1)
  		d = Date.parse("2000-jan-1")
  		dt = DateTime.parse('2000-01-01T00:00:00+05:30')
  		expect(Includer.new.fmt_time(t)).to eq("2000-01-01 20:15+0530")
  		expect(Includer.new.fmt_time(d)).to eq("2000-01-01 00:00+0000")
  		expect(Includer.new.fmt_time(dt)).to eq("2000-01-01 00:00+0530")
  	end
  end
end
