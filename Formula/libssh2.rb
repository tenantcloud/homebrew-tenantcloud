class Libssh2 < Formula
  desc "C library implementing the SSH2 protocol"
  homepage "https://libssh2.org/"
  url "http://10.10.4.242:8081/libssh2-1.9.0.tar.gz"
  sha256 "d5fb8bd563305fd1074dda90bd053fb2d29fc4bce048d182f96eaa466dfadafd"
  revision 1

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "2c4dcf8149663f9a133deac5bc42ce308d1ced90227cac391ca30b0ab2d381f9" => :catalina
    sha256 "9705f2a153a854b15bff89663eca46dd211f5fc025031b9851d64874f83c8f53" => :mojave
    sha256 "22327eb5bbff660935db0c5106d5a43069ee23e5cb33d5125bad4e144e83ee34" => :high_sierra
  end

  head do
    url "https://github.com/libssh2/libssh2.git"

    depends_on "tenantcloud/tenantcloud/autoconf" => :build
    depends_on "tenantcloud/tenantcloud/automake" => :build
    depends_on "tenantcloud/tenantcloud/libtool" => :build
  end

  depends_on "tenantcloud/tenantcloud/openssl@1.1"

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-examples-build
      --with-openssl
      --with-libz
      --with-libssl-prefix=#{Formula["tenantcloud/tenantcloud/openssl@1.1"].opt_prefix}
    ]

    system "./buildconf" if build.head?
    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <libssh2.h>
      int main(void)
      {
      libssh2_exit();
      return 0;
      }
    EOS

    system ENV.cc, "test.c", "-L#{lib}", "-lssh2", "-o", "test"
    system "./test"
  end
end
