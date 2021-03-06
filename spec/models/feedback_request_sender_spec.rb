require "spec_helper"

describe FeedbackRequestSender do
  before(:each) { ActionMailer::Base.deliveries.clear }

  context "#appointments" do
    it "finds appointments ready for feedback" do
      sender = FeedbackRequestSender.new
      Appointment.should_receive(:ready_for_feedback)
      sender.appointments
    end
  end

  context "#send_all_requests" do
    it "doesn't send any mail if no appointments found" do
      sender = FeedbackRequestSender.new
      sender.stub(:appointments => [])
      sender.send_all_requests
      ActionMailer::Base.deliveries.should be_empty
    end

    it "sends an email to each user for a given appointment" do
      appointment = FactoryGirl.create(:appointment, 
                                       :start_time => 2.hours.ago,
                                       :end_time => 2.minutes.ago)
      sender = FeedbackRequestSender.new
      sender.stub(:appointments => [appointment])
      sender.send_all_requests
      ActionMailer::Base.deliveries.length.should == 2
    end

    it "updates the appointment as having had feedback sent" do
      appointment = FactoryGirl.create(:appointment)
      sender = FeedbackRequestSender.new
      sender.stub(:appointments => [appointment])

      expect {
        sender.send_all_requests
      }.to change { Appointment.feedback_not_sent.count }.by(-1)
    end
  end
end