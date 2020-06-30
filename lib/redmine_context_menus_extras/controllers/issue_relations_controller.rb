require_dependency "issue_relations_controller"

class IssueRelationsController
  before_action :find_issues, :only => [:bulk_new, :bulk_create]

  helper RedmineContextMenusExtras::ApplicationHelper

  def bulk_new
    # TODO: connfirm
    if !@issues.all?(&:attributes_editable?) || !User.current.allowed_to?(:manage_issue_relations, @project)
      raise ::Unauthorized
    end

    @issues.sort!
    @issue = @issues.first
    @project = @issues.first.project
    @relation = IssueRelation.new
  end

  def bulk_create
    # TODO: connfirm
    if !@issues.all?(&:attributes_editable?) || !User.current.allowed_to?(:manage_issue_relations, @project)
      raise ::Unauthorized
    end

    @issues.sort!

    unsaved_relations = []
    saved_relations = []

    @issues.each do |issue|
      next if issue.id == params[:relation][:issue_to_id].to_i

      relation = IssueRelation.new
      relation.issue_from = issue
      relation.safe_attributes = params[:relation]
      relation.init_journals(User.current)

      if relation.save
        saved_relations << relation
      else
        unsaved_relations << relation
      end
    end

    if unsaved_relations.empty?
      flash[:notice] = l(:notice_successful_create) unless saved_relations.empty?
      redirect_to _project_issues_path(@project)
    else
      @saved_relations = saved_relations
      @unsaved_relations = unsaved_relations
      @issues = Issue.visible.where(:id => @unsaved_relations.map(&:issue_from_id)).to_a
      @issue = @issues.first
      bulk_new
      render :action => 'bulk_new'
    end
  end
end
