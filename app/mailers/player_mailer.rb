class PlayerMailer < ApplicationMailer
  default from: 'noreply@smartschedule.com'
  def schedule_email(player, tournament)
    @player = player
    @tournament = tournament
    mail(to: @player.email, subject: Tournament.find(@tournament).name + ' Schedule')
  end
  def welcome_email(player)
    @player = player
    mail(to: @player.email, subject: 'Smart Schedule Registration')
  end
end
