class String
  # @return [TrueClass, FalseClass]
  def is_i?
    /\A[-+]?\d+\z/ === self
  end
end