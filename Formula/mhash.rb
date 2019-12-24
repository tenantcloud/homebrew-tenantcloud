class Mhash < Formula
  desc "Uniform interface to a large number of hash algorithms"
  homepage "https://mhash.sourceforge.io/"
  url "http://10.10.4.242:8081/mhash-0.9.9.9.tar.gz"
  sha256 "3dcad09a63b6f1f634e64168dd398e9feb9925560f9b671ce52283a79604d13e"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    cellar :any
    sha256 "b4ee65a9ee33f5e19e085c477ec1634e2aa1626331eb2465484713759b264163" => :mojave
    sha256 "82f39af8037f070fafcad0280b151dc58e1b5b8c3ea1fb75f4ee372256d3ad2b" => :high_sierra
    sha256 "d7d0a96656fbae5b279223d120bfe456c775a0c751090049bcf3ffffb2231761" => :catalina
  end

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include "mhash.h"
      int main() {
        MHASH td;
        return 0;
      }
    EOS
    system ENV.cc, "test.cpp", "-L#{lib}", "-lmhash", "-o", "test"
    system "./test"
  end
end
