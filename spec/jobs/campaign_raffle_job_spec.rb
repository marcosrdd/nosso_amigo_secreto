require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe CampaignRaffleJob, type: :job do
  before(:each) do
    @current_user = create(:user)
    @campaign = create(:campaign, user: @current_user)
    @member1 = create(:member, campaign: @campaign)
    @member2 = create(:member, campaign: @campaign)
    @member3 = create(:member, campaign: @campaign)

    CampaignRaffleJob.perform_later @campaign
  end

  describe 'Raffle job' do
    it 'job is created' do
      ActiveJob::Base.queue_adapter = :test
        expect{
          CampaignRaffleJob.perform_later @campaign
        }.to have_enqueued_job.on_queue('emails')
    end

    it 'should have sended the e-mails' do
      expect {
        perform_enqueued_jobs do
          CampaignRaffleJob.perform_later @campaign
        end
      }.to change { ActionMailer::Base.deliveries.size }.by(4)
    end

    it 'should have sended the e-mails to the right members' do
      perform_enqueued_jobs do
        CampaignRaffleJob.perform_later @campaign
      end

      mails = ActionMailer::Base.deliveries
      expect(mails.any? { |m| m.to[0] == @current_user.email }).to be true
      expect(mails.any? { |m| m.to[0] == @member1.email }).to be true
      expect(mails.any? { |m| m.to[0] == @member2.email }).to be true
      expect(mails.any? { |m| m.to[0] == @member3.email }).to be true
    end
  end
end