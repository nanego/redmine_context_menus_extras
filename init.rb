require_relative "lib/context_menus_extras_listener"
require_relative 'lib/redmine_context_menus_extras/hooks'

Redmine::Plugin.register :redmine_context_menus_extras do
  name 'Redmine Context Menus Extras plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/nanego/redmine_context_menus_extras'

  requires_redmine_plugin :redmine_base_deface, :version_or_higher => '0.0.1'
end
