namespace :after_party do
  desc 'Deployment task: setup_sms_providers'
  task setup_sms_providers: :environment do
    puts "Running deploy task 'setup_sms_providers'"

    SmsProvider.create(url: 'https://mock-text-provider.parentsquare.com/provider1', weight: 0.30)
    SmsProvider.create(url: 'https://mock-text-provider.parentsquare.com/provider2', weight: 0.70)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
