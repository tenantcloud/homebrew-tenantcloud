class CAres < Formula
  desc "Asynchronous DNS library"
  homepage "https://c-ares.haxx.se/"
  url "http://10.10.4.242:8081/c-ares-1.15.0.tar.gz"
  sha256 "6cdb97871f2930530c97deb7cf5c8fa4be5a0b02c7cea6e7c7667672a39d6852"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    cellar :any
    sha256 "6c1782cd4a17e74f8f7b6258faa754ddcf9bf3a388cb862d6b5da8832668f9ef" => :mojave
    sha256 "45fcb6953de6f43026bc28f3d8798ced5e5a0bbd28c18240fc0e9bc66174fc1e" => :high_sierra
    sha256 "cab176e28c4fb73ab44c4695ad2dfa154f139f27d7db5224fb30726cbf412855" => :catalina
  end

  head do
    url "https://github.com/bagder/c-ares.git"

    depends_on "tenantcloud/tenantcloud/autoconf" => :build
    depends_on "tenantcloud/tenantcloud/automake" => :build
    depends_on "tenantcloud/tenantcloud/libtool" => :build
  end

  def install
    system "./buildconf" if build.head?
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-debug"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <ares.h>
      int main()
      {
        ares_library_init(ARES_LIB_INIT_ALL);
        ares_library_cleanup();
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lcares", "-o", "test"
    system "./test"
  end
end
