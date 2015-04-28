require "formula"


class Panamax < Formula
  homepage "http://www.panamax.io"
  url "http://download.panamax.io/installer/panamax-0.5.2.tar.gz"
  sha1 "fedd6f8252e30e528805e7a8279f63a002040804"
  def install
    system "./configure", "--prefix=#{prefix}", "--var=#{var}/panamax"
    system "make", "install"
    resource("additional_files").stage { bin.install "panamaxcli-darwin" }
    mv bin/"panamaxcli-darwin",bin/"pmxcli"
  end

  def caveats
    "If upgrading the Panamax Installer, be sure to run 'panamax reinstall' to ensure compatibility with other Panamax components."
  end

  resource "additional_files" do
    url "http://download.panamax.io/panamaxcli/panamaxcli-darwin"
    sha1 "01316f5a61255dd0cd8ce9e74ab0719ac672702c"
  end

  test do
    assert File.exist?("#{prefix}/.panamax")
    assert File.exist?("#{var}/panamax")
    assert_match "#{version}", shell_output("#{prefix}/.panamax/panamax -v").strip
  end
end
