class Pcre < Formula
  desc "Perl compatible regular expressions library"
  homepage "https://www.pcre.org/"
  url "http://10.10.4.242:8081/pcre-8.43.tar.gz"
  sha256 "0b8e7465dc5e98c757cc3650a20a7843ee4c3edf50aaf60bb33fd879690d2c73"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    cellar :any
    sha256 "f848e72c9a6ddfdd4e57d25df859830187cbb8e850996b22a84270a6590f56ff" => :mojave
    sha256 "b904c008c04003c3f40e30c6ee6a3b411aad81aa2f2684db9bf59bccd9d58b01" => :high_sierra
    sha256 "3517eab75bf5bdb7798414d0af2aaaaf43edd248abc960b008d89b0a0958d537" => :catalina
  end

  head do
    url "svn://vcs.exim.org/pcre/code/trunk"

    depends_on "tenantcloud/tenantcloud/autoconf" => :build
    depends_on "tenantcloud/tenantcloud/automake" => :build
    depends_on "tenantcloud/tenantcloud/libtool" => :build
  end

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-utf8",
                          "--enable-pcre8",
                          "--enable-pcre16",
                          "--enable-pcre32",
                          "--enable-unicode-properties",
                          "--enable-pcregrep-libz",
                          "--enable-pcregrep-libbz2",
                          "--enable-jit"
    system "make"
    ENV.deparallelize
    system "make", "test"
    system "make", "install"
  end

  test do
    system "#{bin}/pcregrep", "regular expression", "#{prefix}/README"
  end
end
