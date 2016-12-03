module ObjectHelper
  def TimeEntryActivity.generate!(options = {})
    activity = TimeEntryActivity.new options
    activity.name = "Test Activity #{TimeEntryActivity.count + 1}"
    activity.save
    activity
  end

  def Rate.generate(options = {})
    rate = Rate.new options
    rate.user_id ||= User.generate!.id
    rate.date_in_effect ||= Time.zone.today
    rate.amount ||= 200
    rate
  end

  def Rate.generate!(options = {})
    rate = generate options
    rate.save
    rate
  end
end
