require "formula"

class Panamax < Formula
  homepage "http://www.centurylinklabs.com"
  url "http://download.panamax.io/installer/pmx-installer-0.1.3.zip"
  sha1 "73dc66759e406ac5f9e8e9327bb16cd9da990824"

  def install
    cachedir = HOMEBREW_CACHE + "panamax-#{version}.zip"
    `unzip  -ou "#{cachedir}"  -d "#{ENV['HOME']}/.panamax"`
    bin.install "panamax"
    opoo "If upgrading the Panamax Installer, be sure to run 'panamax reinstall' to ensure compatibility with other Panamax components."
  end

  test do
     installed = File.exist?(ENV['HOME'] + '/.panamax')
     assert installed
     assert_equal 0, $?.exitstatus
  end

end
