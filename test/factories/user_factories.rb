# New User factory. Used for testing when it comes to validations, or a brand
# new user.
Factory.define :new_user, :class => User do |u|
  u.login 'joeuser'
  u.email 'joeuser@domain.com'
  u.password 'a1b2c3'
  u.password_confirmation 'a1b2c3'
end