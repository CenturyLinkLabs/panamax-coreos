require "formula"

class Panamax < Formula
  homepage "http://www.centurylinklabs.com"
  url "http://download.panamax.io/installer/pmx-installer-0.1.1.zip"
  sha1 "197517bced93f33376f0b70a62c5e1cbc5cc5c81"

  def install
    cachedir = HOMEBREW_CACHE + "panamax-#{version}.zip"
    `unzip  -ou #{cachedir}  -d #{ENV['HOME']}/.panamax`
    bin.install "panamax"
    opoo "If upgrading the Panamax Installer, be sure to run 'panamax reinstall' to ensure compatibility with other Panamax components."
  end

  test do
     installed = File.exist?(ENV['HOME'] + '/.panamax')
     assert installed
     assert_equal 0, $?.exitstatus
  end

end
