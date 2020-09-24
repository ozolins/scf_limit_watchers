require_dependency 'scf_limit_watchers/watchers_controller_patch'
require_dependency 'scf_limit_watchers/issues_helper_patch'

Redmine::Plugin.register :scf_limit_watchers do
  name 'ScF Limit Watchers plugin'
  author 'Gatis Ozolins'
  description 'Remove project members with configured role from watchers'
  version '0.0.1'
  url 'https://github.com/ozolins/scf_limit_watchers'
  author_url 'https://www.scandicfusion.com/team'
  requires_redmine :version_or_higher => '4.0.0'

settings(partial: 'settings/scf_limit_watchers_settings',
           default: {
             'roles_to_remove': []
           })

end
