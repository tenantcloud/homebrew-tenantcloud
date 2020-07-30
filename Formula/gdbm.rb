class Gdbm < Formula
  desc "GNU database manager"
  homepage "https://www.gnu.org/software/gdbm/"
  url "http://10.10.4.242:8081/gdbm-1.18.1.tar.gz"
#  mirror "https://ftpmirror.gnu.org/gdbm/gdbm-1.18.1.tar.gz"
  sha256 "86e613527e5dba544e73208f42b78b7c022d4fa5a6d5498bf18c8d6f745b91dc"
  license "GPL-3.0"
  revision 1

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    cellar :any
    rebuild 1
    sha256 "f7b5ab7363961fa6defcb66b4ffdf5365264fcb97d35bc413e754f173a3b1912" => :catalina
    sha256 "0f65874bcd50d31aaf8b2e6c8ef414cb65a8d8b9eb6d1fa4ef179c6e0a94983c" => :mojave
    sha256 "4a644af2fcc2781c3a161209deff7b62d760058bc1bac7c4f91a5ce5738f0798" => :high_sierra
  end

  # Use --without-readline because readline detection is broken in 1.13
  # https://github.com/Homebrew/homebrew-core/pull/10903
  def install
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --without-readline
      --prefix=#{prefix}
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    pipe_output("#{bin}/gdbmtool --norc --newdb test", "store 1 2\nquit\n")
    assert_predicate testpath/"test", :exist?
    assert_match /2/, pipe_output("#{bin}/gdbmtool --norc test", "fetch 1\nquit\n")
  end
end
