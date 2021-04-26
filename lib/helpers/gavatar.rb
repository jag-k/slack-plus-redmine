# @param [String] email
# @return String
def gavatar(email)
  hash = email.downcase.to_md5
  "https://www.gravatar.com/avatar/#{hash}?rating=PG&size=50&default=monsterid"
end