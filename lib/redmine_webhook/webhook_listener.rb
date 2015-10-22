module RedmineWebhook
  class WebhookListener < Redmine::Hook::Listener
    def controller_issues_new_after_save(context = {})
      issue = context[:issue]
      project = issue.project
      webhook = Webhook.where(:project_id => project.project.id).first
      return unless webhook
      post(webhook, issue_to_json(issue))
    end

    def model_redmine_webhook_journal_after_create(context = {})
      journal = context[:journal]
      issue = journal.issue
      project = issue.project
      webhook = Webhook.where(:project_id => project.project.id).first
      return unless webhook
      post(webhook, journal_to_json(issue, journal))
    end

    private
    def issue_url(issue)
      Rails.application.routes.url_helpers.issue_url(issue, Mailer.default_url_options)
    end

    def issue_to_json(issue)
      {
        :payload => {
          :action => 'opened',
          :issue => RedmineWebhook::IssueWrapper.new(issue).to_hash,
          :url => issue_url(issue)
        }
      }.to_json
    end

    def journal_to_json(issue, journal)
      {
        :payload => {
          :action => 'updated',
          :issue => RedmineWebhook::IssueWrapper.new(issue).to_hash,
          :journal => RedmineWebhook::JournalWrapper.new(journal).to_hash,
          :url => issue_url(issue)
        }
      }.to_json
    end

    def post(webhook, request_body)
      Thread.start do
        begin
          Faraday.post do |req|
            req.url webhook.url
            req.headers['Content-Type'] = 'application/json'
            req.body = request_body
          end
        rescue => e
          Rails.logger.error e
        end
      end
    end
  end
end
