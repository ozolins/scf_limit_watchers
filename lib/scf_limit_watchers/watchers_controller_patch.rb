module ScfLimitWatchers
  module WatchersControllerPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method :users_for_new_watcher_without_limit, :users_for_new_watcher
        alias_method :users_for_new_watcher, :users_for_new_watcher_with_limit
      end
    end

    module InstanceMethods
      def users_for_new_watcher_with_limit
            scope = nil
            if params[:q].blank? && @project.present?

              looker_ids = []
    
              roles = (Setting.plugin_scf_limit_watchers['roles_to_remove'] || [])
              roles.each do |r|
                r.to_i
                Role.find_by_id(r.to_i)
                looker_ids.concat( (@project.principals_by_role[Role.find_by_id(r.to_i)] || []).collect(&:id) )
              end

              scope = @project.users.where.not(:id => looker_ids.uniq)
            else
              scope = User.all.limit(100)
            end
            users = scope.active.visible.sorted.like(params[:q]).to_a
            if @watchables && @watchables.size == 1
              users -= @watchables.first.watcher_users
            end
            users
      end

    end
  end
end

WatchersController.send(:include, ScfLimitWatchers::WatchersControllerPatch)

