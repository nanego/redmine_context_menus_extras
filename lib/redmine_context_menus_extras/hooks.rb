module RedmineContextMenusExtras
  module Hooks
    class ModelHook < Redmine::Hook::Listener
      def after_plugins_loaded(_context = {})
        require_relative "controllers/issue_relations_controller"
      end
    end
  end
end