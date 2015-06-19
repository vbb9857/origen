require "spec_helper"

include RGen::Pins

describe "Pin Clocking Definition" do

  before :each do
    RGen.target.temporary = "debug"
    RGen.target.load!
    $tester.name.should == "j750"
  end

  it "clock pins can be added and removed" do
    $tester.set_timeset("intram", 40)
    $tester.any_clocks_running?.should == false
    $dut.add_pin :pinx
    $dut.add_pin :piny
    $dut.pin(:pinx).is_a_clock?.should == false
    $dut.pin(:piny).is_a_clock?.should == false
    $dut.pin(:pinx).enable_clock(period_in_ns: 100)
    $dut.pin(:pinx).is_a_clock?.should == true
    $dut.pin(:pinx).is_a_running_clock?.should == false
    $dut.pin(:piny).is_a_clock?.should == false
    $tester.any_clocks_running?.should == false
    $dut.pin(:piny).enable_clock(frequency_in_khz: 32)
    $dut.pin(:pinx).is_a_clock?.should == true
    $dut.pin(:pinx).is_a_running_clock?.should == false
    $dut.pin(:piny).is_a_clock?.should == true
    $dut.pin(:piny).is_a_running_clock?.should == false
    $tester.any_clocks_running?.should == false
    $dut.pin(:pinx).disable_clock
    $dut.pin(:pinx).is_a_clock?.should == false
    $dut.pin(:piny).is_a_clock?.should == true
    $tester.any_clocks_running?.should == false

  end

  it "clock pins can be started and stopped" do
    $tester.set_timeset("intram", 40)
    $tester.any_clocks_running?.should == false
    $dut.add_pin :pinx
    $dut.add_pin :piny
    $dut.pin(:pinx).enable_clock(period_in_ns: 80)
    $dut.pin(:pinx).is_a_running_clock?.should == false
    $dut.pin(:pinx).start_clock
    $dut.pin(:pinx).is_a_running_clock?.should == true
    $tester.any_clocks_running?.should == true
    $dut.pin(:pinx).half_period.should == 1
    $dut.pin(:pinx).pause_clock
    $dut.pin(:pinx).is_a_running_clock?.should == false
    $tester.any_clocks_running?.should == false
    $dut.pin(:pinx).resume_clock
    $dut.pin(:pinx).is_a_running_clock?.should == true
    $dut.pin(:pinx).half_period.should == 1
    $tester.any_clocks_running?.should == true
    $dut.pin(:pinx).stop_clock
    $dut.pin(:pinx).is_a_running_clock?.should == false
    $tester.any_clocks_running?.should == false
  end

  it "clock pin are updated for timeset change" do
    $tester.set_timeset("intram", 40)
    $dut.add_pin :pinx
    $dut.add_pin :piny
    $dut.pin(:pinx).enable_clock(period_in_ns: 80)
    $dut.pin(:pinx).is_a_running_clock?.should == false
    $dut.pin(:pinx).start_clock
    $dut.pin(:pinx).is_a_running_clock?.should == true
    $dut.pin(:pinx).half_period.should == 1
    20.times { $tester.cycle }
    $tester.set_timeset("intram_fast", 20)
    $dut.pin(:pinx).update_clock
    $dut.pin(:pinx).half_period.should == 2
  end

end
