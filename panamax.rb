require "formula"

class Panamax < Formula
  homepage "http://www.centurylinklabs.com"
  url "http://63.128.180.11/installer/pmx-installer-0.0.32.zip"
  sha1 "0e8d3dc94fbbe795ac205d3c12a250b922bd85c2"

  def install
    cachedir = HOMEBREW_CACHE + "panamax-#{version}.zip"
    cmd = "unzip  -ou #{cachedir}  -d #{ENV['HOME']}/.panamax"
    system "#{cmd}"
    bin.install "panamax"
    opoo "Panamax Installer upgraded. Run 'panamax reinstall' to ensure compatibility with other Panamax components."
  end
end
