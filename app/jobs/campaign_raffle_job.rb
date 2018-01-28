class CampaignRaffleJob < ApplicationJob
  queue_as :email

  def perform(campaign)
    result = RaffleService.new(campaign).call

    campaign.members.each { |m| m.set_pixel }
    result.each do |r|
      CampaignMailer.raffle(campaign, r.first, r.last).delivery_now
    end
    campaign.update(status: :finished)

    # TODO
    # if result == false
      # Send mail to owner of campaign
    # end
  end
end
