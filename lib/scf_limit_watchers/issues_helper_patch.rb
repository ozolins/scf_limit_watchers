module ScfLimitWatchers
  module IssuesHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        alias_method :users_for_new_issue_watchers_without_limit, :users_for_new_issue_watchers
        alias_method :users_for_new_issue_watchers, :users_for_new_issue_watchers_with_limit
      end
    end

    module InstanceMethods
      def users_for_new_issue_watchers_with_limit(issue)
        ActiveSupport::Deprecation.warn "users_for_new_issue_watchers"
        users = issue.watcher_users.select{|u| u.status == User::STATUS_ACTIVE}

        looker_ids = []

        roles = (Setting.plugin_scf_limit_watchers['roles_to_remove'] || [])
        roles.each do |r|
          r.to_i
          Role.find_by_id(r.to_i)
          looker_ids.concat( (issue.project.users_by_role[Role.find_by_id(r.to_i)] || []).collect(&:id) )
        end

        if issue.project.users.where.not(:id => looker_ids).count <= 20
          users = (users + issue.project.users.where.not(:id => looker_ids.uniq).sort).uniq
        end
        users
      end
    end
  end
end


Rails.configuration.to_prepare do
  unless IssuesHelper.included_modules.include?(ScfLimitWatchers::IssuesHelperPatch)
    IssuesHelper.send(:include, ScfLimitWatchers::IssuesHelperPatch)
  end
end

