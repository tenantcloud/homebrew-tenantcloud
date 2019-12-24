class Autoconf < Formula
  desc "Automatic configure script builder"
  homepage "https://www.gnu.org/software/autoconf"
  url "http://10.10.4.242:8081/autoconf-2.69.tar.gz"
  sha256 "954bd69b391edc12d6a4a51a2dd1476543da5c6bbf05a95b59dc0dd6fd4c2969"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    cellar :any_skip_relocation
    rebuild 4
    sha256 "9724736d34773b6e41e2434ffa28fe79feccccf7b7786e54671441ca75115cdb" => :mojave
    sha256 "63957a3952b7af5496012b3819c9956822fd7d895d63339c23fdc65c502e1a40" => :high_sierra
    sha256 "ca510b350e941fb9395522a03f9d2fb5df276085d806ceead763acb95889a368" => :catalina
  end

  def install
    ENV["PERL"] = "/usr/bin/perl"

    # force autoreconf to look for and use our glibtoolize
    inreplace "bin/autoreconf.in", "libtoolize", "glibtoolize"
    # also touch the man page so that it isn't rebuilt
    inreplace "man/autoreconf.1", "libtoolize", "glibtoolize"

    system "./configure", "--prefix=#{prefix}", "--with-lispdir=#{elisp}"
    system "make", "install"

    rm_f info/"standards.info"
  end

  test do
    cp pkgshare/"autotest/autotest.m4", "autotest.m4"
    system bin/"autoconf", "autotest.m4"
  end
end
