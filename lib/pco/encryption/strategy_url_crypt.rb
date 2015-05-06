require "URLcrypt"

class StrategyUrlCrypt
  def initialize()
    URLcrypt.key = "984e9002e680dc9b9c2556434c47f7e4782191f52063277901e4a009797652e08f28be069dfb4d4a1e3c9ab09fedab59be2c9b6486748bf44030182815ee4987"
  end

  def encrypt(message)
    URLcrypt.encrypt(message)
  end

  def decrypt(message)
    URLcrypt.decrypt(message)
  end
end
