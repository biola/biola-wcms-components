##
# Authenticate User and Create Session
class CasAuthentication
  def initialize(session)
    @session = session
  end

  def user
    return unless username.present?
    @user ||= User.find_or_initialize_by(username: username)
  end

  def perform
    return true if authenticated?
    return unless session['cas'].present?

    if new_user?
      authenticate! if create_user!
    elsif unauthenticated?
      authenticate!
      update_extra_attributes!
    end
  end

  private

  attr_reader :session

  USER_CAS_MAP = {
    employeeId: { biola_id: Integer },
    eduPersonNickname: :first_name,
    sn: :last_name,
    mail: :email,
    url: :photo_url,
    eduPersonEntitlement: { entitlements: Array },
    eduPersonAffiliation: { affiliations: Array }
  }.freeze

  def present?
    session['cas'].present?
  end

  def new_user?
    return unless user.present?
    user.new_record?
  end

  def authenticated?
    session[:username].present?
  end

  def unauthenticated?
    !authenticated?
  end

  def authenticate!
    session[:username] = username
  end

  def update_extra_attributes!
    USER_CAS_MAP.each do |attr_key, opt|
      next unless extra_attrs.key?(attr_key)
      key, type = user_key_type(opt)
      user[key] = attr_value(extra_attrs[attr_key], type)
    end

    user.save
  end
  alias create_user! update_extra_attributes!

  def username
    (session[:username] || attrs[:user]).try(:downcase)
  end

  def attrs
    @attrs ||= (session[:cas] || {}).with_indifferent_access
  end

  def extra_attrs
    @extra_attrs ||= (attrs[:extra_attributes] || {}).with_indifferent_access
  end

  def attr_value(value, type = nil)
    return Array(value).compact if type == Array
    return Integer(value) if type == Integer &&
                             /\A\d+\z/ =~ value.to_s
    String(value)
  end

  def user_key_type(opt)
    return opt if opt.is_a? Symbol
    opt.first
  end
end
