class Kismet < Formula
  desc "Wireless network and device detector, sniffer, wardriving tool, and WIDS framework."
  homepage "https://www.kismetwireless.net/"
  url "https://github.com/kismetwireless/kismet/archive/kismet-2020-12-R3.tar.gz"
  sha256 "603d8ef66d96f5ad1d467fa94cc44f04af0c4200cfad9e7e2a25c838bc37bfcf"
  version "2020-12-R3"
  head "https://github.com/kismetwireless/kismet.git"
  license "GPL-2.0-only"

  depends_on "pkg-config" => :build
  depends_on "python@3.9"
  depends_on "libpcap"
  depends_on "protobuf"
  depends_on "protobuf-c"
  depends_on "pcre"
  depends_on "librtlsdr"
  depends_on "libbtbb"
  depends_on "ubertooth"
  depends_on "libusb"
  depends_on "libwebsockets"

  def install
    inreplace "Makefile.in" do |s|
      s.gsub! "-o $(INSTUSR) -g $(SUIDGROUP)", ""
      s.gsub! "-o $(INSTUSR) -g $(INSTGRP)", ""
    end

    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_match "Kismet 2020-00-GIT", shell_output("#{bin}/kismet --version")
  end
end
