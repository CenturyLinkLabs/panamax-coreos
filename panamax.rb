re "formula"

class Panamax < Formula
  homepage "http://www.centurylinklabs.com"
  url "http://download.panamax.io/installer/pmx-installer-0.0.46.zip"
  sha1 "431fc0141d378e7f65026813240ece861fa88227"

  def install
    cachedir = HOMEBREW_CACHE + "panamax-#{version}.zip"
    cmd = "unzip  -ou #{cachedir}  -d #{ENV['HOME']}/.panamax"
    system "#{cmd}"
    bin.install "panamax"
    opoo "Panamax Installer upgraded. Run 'panamax reinstall' to ensure compatibility with other Panamax components."
  end
end
