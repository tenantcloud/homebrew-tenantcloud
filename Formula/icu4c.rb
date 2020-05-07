class Icu4c < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "https://ssl.icu-project.org/"
  url "http://10.10.4.242:8081/icu4c-66_1-src.tgz"
  version "66.1"
  sha256 "52a3f2209ab95559c1cf0a14f24338001f389615bf00e2585ef3dbc43ecf0a2e"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    cellar :any
    sha256 "f01dbe4266d1180c1da01d973200ed897cfa8ec8bf505c0f57f7f693bc566062" => :catalina
    sha256 "60e51b89507cf03f1d6ed59deda226b600f96f763dea9a415dfa8ebb42c197a0" => :mojave
    sha256 "87f2446c5de0991c6bf959a61e63a746ebb6687f6bd68186ecd74ff6801a41b1" => :high_sierra
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
