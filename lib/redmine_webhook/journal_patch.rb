module RedmineWebhook
  module JournalPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class 
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        after_create :send_create_hook
      end
    end

    module ClassMethods
    end
    
    module InstanceMethods
      # This will update the KanbanIssues associated to the issue
      def send_create_hook
        Redmine::Hook.call_hook(:model_redmine_webhook_journal_after_create, journal: self)
        true
      end
    end    
  end
end
