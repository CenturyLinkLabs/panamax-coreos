require "formula"

class Panamax < Formula
  homepage "http://www.centurylinklabs.com"
  url "http://download.panamax.io/installer/pmx-installer-0.2.0.zip"
  sha1 "d629ebf2758911b8cce65eed7a8d8f5377a459a6"

  def install
    cachedir = HOMEBREW_CACHE + "panamax-#{version}.zip"
    `unzip  -ou #{cachedir}  -d "#{ENV['HOME']}"/.panamax`
    bin.install "panamax"
    opoo "If upgrading the Panamax Installer, be sure to run 'panamax reinstall' to ensure compatibility with other Panamax components."
  end

  test do
     installed = File.exist?(ENV['HOME'] + '/.panamax')
     assert installed
     assert_equal 0, $?.exitstatus
  end

end
