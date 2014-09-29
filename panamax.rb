require "formula"

class Panamax < Formula
  homepage "http://www.centurylinklabs.com"
  url "http://download.panamax.io/installer/pmx-installer-0.2.2.zip"
  sha1 "b5b00ef1ca37d27dd97d35ebb4ec9280ee8a29d5"

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
