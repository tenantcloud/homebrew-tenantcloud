class Jemalloc < Formula
  desc "malloc implementation emphasizing fragmentation avoidance"
  homepage "http://jemalloc.net/"
  url "http://10.10.4.242:8081/jemalloc-5.2.1.tar.bz2"
  sha256 "5396e61cc6103ac393136c309fae09e44d74743c86f90e266948c50f3dbb7268"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    cellar :any
    sha256 "be3515eabe8dcdfe892d259f738b5263ac46721e56b2439c523464607ff552e4" => :mojave
    sha256 "aa1fa19d21dda2217c2d62c43dbee14137dfadb79551513aedb401e9ba150797" => :high_sierra
    sha256 "13080a13f5e1a0699adaed5ba9906616850c2e8a75a829f8be6a2e6183fb16e5" => :catalina
  end

  head do
    url "https://github.com/jemalloc/jemalloc.git", :branch => "dev"

    depends_on "tenantcloud/tenantcloud/autoconf" => :build
    depends_on "tenantcloud/tenantcloud/docbook-xsl" => :build
  end

  def install
    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --with-jemalloc-prefix=
    ]

    if build.head?
      args << "--with-xslroot=#{Formula["docbook-xsl"].opt_prefix}/docbook-xsl"
      system "./autogen.sh", *args
      system "make", "dist"
    else
      system "./configure", *args
    end

    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdlib.h>
      #include <jemalloc/jemalloc.h>
      int main(void) {
        for (size_t i = 0; i < 1000; i++) {
            // Leak some memory
            malloc(i * 100);
        }
        // Dump allocator statistics to stderr
        malloc_stats_print(NULL, NULL, NULL);
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-ljemalloc", "-o", "test"
    system "./test"
  end
end
