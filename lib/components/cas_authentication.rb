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
    biola_id: { employeeId: Integer },
    first_name: :eduPersonNickname,
    last_name: :sn,
    email: :mail,
    photo_url: :url,
    entitlements: { eduPersonEntitlement: Array },
    affiliations: { eduPersonAffiliation: Array }
  }.freeze

  def present?
    session['cas'].present?
  end

  def new_user?
    user.try(:new_record?)
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
    USER_CAS_MAP.each do |k, v|
      user[k] = attr_value(v, extra_attrs)
    end
    user.save
  end
  alias create_user! update_extra_attributes!

  def username
    (session[:username] || attrs[:user]).downcase
  end

  def attrs
    @attrs ||= (session[:cas] || {}).with_indifferent_access
  end

  def extra_attrs
    @extra_attrs ||= (attrs[:extra_attributes] || {}).with_indifferent_access
  end

  def attr_value(key, opts = {})
    return String(opts[key]) if key.is_a? Symbol
    attr_hash(key, opts)
  end

  def attr_hash(hash, opts = {})
    return unless hash.is_a? Hash

    key, type = hash.first
    return Array(opts.try(:[], key)).compact if type == Array
    return Integer(opts.try(:[], key)) if type == Integer &&
                                          /\A\d+\z/ =~ opts[key].to_s
  end
end
