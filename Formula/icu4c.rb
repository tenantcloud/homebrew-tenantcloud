class Icu4c < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "https://ssl.icu-project.org/"
  url "http://10.10.4.242:8081/icu4c-64_2-src.tgz"
#  mirror "https://github.com/unicode-org/icu/releases/download/release-63-1/icu4c-63_1-src.tgz"
  version "64.2"
  sha256 "627d5d8478e6d96fc8c90fed4851239079a561a6a8b9e48b0892f24e82d31d6c"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    cellar :any
    sha256 "e707bf5e3d0189ede7d941d95a417b5dacad3eac99b9a677042464140f12fa1d" => :mojave
    sha256 "0ac5ee60393d26ec26a915ed957a38a0b2355fe7991f607044edaedd3ff14cc1" => :high_sierra
    sha256 "e9ae7bb5a76b48e82f56bc744eaaa1e9bdb5ca49ea6b5a2e4d52f57ad331f063" => :catalina
  end

  keg_only :provided_by_macos, "macOS provides libicucore.dylib (but nothing else)"

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-samples
      --disable-tests
      --enable-static
      --with-library-bits=64
    ]

    cd "source" do
      system "./configure", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    system "#{bin}/gendict", "--uchars", "/usr/share/dict/words", "dict"
  end
end
