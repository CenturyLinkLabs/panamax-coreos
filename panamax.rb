require "formula"

class Panamax < Formula
  homepage "http://www.centurylinklabs.com"
  url "http://63.128.180.11/installer/pmx-installer-0.0.12.zip"
  sha1 "0b3b572cac6024efe989fd03c2a659fea4daf8fb"

  def install
    cachedir = HOMEBREW_CACHE + "panamax-#{version}.zip"
    cmd = "unzip  -ou #{cachedir}  -d #{ENV['HOME']}/.panamax"
    system "#{cmd}"
    bin.install "panamax"
  end
end
