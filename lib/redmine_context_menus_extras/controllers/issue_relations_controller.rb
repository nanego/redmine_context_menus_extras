require_dependency "issue_relations_controller"

class IssueRelationsController
  before_action :find_issues, :only => [:bulk_create]

  def bulk_create
    @issues.sort!
    issue_from = @issues.shift

    unless @issues.all?(&:attributes_editable?) # TODO: connfirm
      raise ::Unauthorized
    end

    unsaved_relations = []
    saved_relations = []

    @issues.each do |issue|
      issue.reload
      relation = IssueRelation.new
      relation.issue_from = issue_from
      relation.safe_attributes = params
      relation.issue_to = issue
      relation.init_journals(User.current)

      if relation.save
        saved_relations << relation
      else
        unsaved_relations << relation
      end
    end

    if unsaved_relations.empty?
      flash[:notice] = l(:notice_successful_create) unless saved_relations.empty?
    end
    redirect_back_or_default _project_issues_path(@project)
  end
end