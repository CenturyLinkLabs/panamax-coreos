require "formula"


class Panamax < Formula
  homepage "http://www.centurylinklabs.com"
  url "http://download.panamax.io/installer/panamax-0.2.3.zip"
  sha1 "0af40e6e597a21c22dcdf1fd5120597a74ed290e"

  def install
    system "./configure", "--prefix=#{prefix}", "--var=#{var}/panamax"
    system "make", "install"
  end

  def caveats
    "If upgrading the Panamax Installer, be sure to run 'panamax reinstall' to ensure compatibility with other Panamax components."
  end

  test do
    installed = File.exist?("#{prefix}/.panamax")
    assert installed
    assert_equal 0, $?.exitstatus
  end
end
