require_dependency 'redmine_webhook'

Rails.configuration.to_prepare do
  unless ProjectsHelper.included_modules.include? RedmineWebhook::ProjectsHelperPatch
    ProjectsHelper.send(:include, RedmineWebhook::ProjectsHelperPatch)
  end
end

Redmine::Plugin.register :redmine_webhook do
  name 'Redmine Webhook plugin'
  author 'suer'
  description 'A Redmine plugin posts webhook on creating and updating tickets'
  version '0.0.1'
  url 'https://github.com/suer/redmine_webhook'
  author_url 'http://d.hatena.ne.jp/suer'

  require_dependency 'journal'
  # Guards against including the module multiple time (like in tests)
  # and registering multiple callbacks
  unless Journal.included_modules.include? RedmineWebhook::JournalPatch
    Journal.send(:include, RedmineWebhook::JournalPatch)
  end
end
