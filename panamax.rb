require "formula"


class Panamax < Formula
  homepage "http://www.panamax.io"
  url "http://download.panamax.io/installer/panamax-0.3.3.tar.gz"
  sha1 "db2b8a8b2849a7b66342c1856e106286ae3da9bb"
  def install
    system "./configure", "--prefix=#{prefix}", "--var=#{var}/panamax"
    system "make", "install"
  end

  def caveats
    "If upgrading the Panamax Installer, be sure to run 'panamax reinstall' to ensure compatibility with other Panamax components."
  end

  test do
    assert File.exist?("#{prefix}/.panamax")
    assert File.exist?("#{var}/panamax")
    assert_match "#{version}", shell_output("#{prefix}/.panamax/panamax -v").strip
  end
end
