class Pcre2 < Formula
  desc "Perl compatible regular expressions library with a new API"
  homepage "https://www.pcre.org/"
  url "http://10.10.4.242:8081/pcre2-10.32.tar.bz2"
  sha256 "f29e89cc5de813f45786580101aaee3984a65818631d4ddbda7b32f699b87c2e"
  head "svn://vcs.exim.org/pcre2/code/trunk"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    cellar :any
    sha256 "4ab53b8ef4ba5c9100b115cebcd0d510f8613a799598f232209f31066d1cbf8e" => :mojave
    sha256 "b331ad445f1f5b0cfb2600c3a3b379d4908e12ec536e0004130ec13d979255d0" => :high_sierra
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-pcre2-16",
                          "--enable-pcre2-32",
                          "--enable-pcre2grep-libz",
                          "--enable-pcre2grep-libbz2",
                          "--enable-jit"
    system "make"
    system "make", "install"
  end

  test do
    system bin/"pcre2grep", "regular expression", prefix/"README"
  end
end
