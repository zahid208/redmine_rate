class RateConversion
  round_to = 10

  MemberRateDataFile = "#{RAILS_ROOT}/tmp/budget_member_rate_data.yml".freeze
  DeliverableDataFile = "#{RAILS_ROOT}/tmp/budget_deliverable_data.yml".freeze
  VendorInvoiceDataFile = "#{RAILS_ROOT}/tmp/billing_vendor_invoice_data.yml".freeze

  def self.compare_values(pre, post, message)
    pre = pre.to_f.round(round_to)
    post = post.to_f.round(round_to)

    puts "ERROR: #{message} (pre: #{pre}, post: #{post})" unless pre == post
    pre == post
  end
end
