require "formula"


class Panamax < Formula
  homepage "http://www.centurylinklabs.com"
  url "http://download.panamax.io/installer/panamax-0.3.0.tar.gz"
  sha1 "d4079e9b5326eb7a5adee581fa246f453bb4ada8"

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
