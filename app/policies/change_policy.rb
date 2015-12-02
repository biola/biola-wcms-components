class ChangePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy
    attr_reader :user, :scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end
    def resolve
      scope.all
    end
  end

  def undo?
    user.admin?
  end
  alias :undo_destroy? :undo?

  def index?
    true
  end
  alias :object_index? :index?
end
