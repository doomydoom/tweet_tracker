class String
  def clean
    self.strip.gsub(' ', '').downcase
  end
end