class Mcrypt < Formula
  desc "Replacement for the old crypt package and crypt(1) command"
  homepage "https://mcrypt.sourceforge.io"
  url "http://10.10.4.242:8081/mcrypt-2.6.8.tar.gz"
  sha256 "5145aa844e54cca89ddab6fb7dd9e5952811d8d787c4f4bf27eb261e6c182098"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    rebuild 2
    sha256 "de99a56fa872e7e30958cb6268af59c03e788791445a8efd71c87ac9efb2da02" => :mojave
    sha256 "892bc8fe3e910389a4499a3466e240740d9eba2eae92974cb0d8c7ba0182d635" => :high_sierra
    sha256 "c9d3313218375e8bca6e22b00fcb47f11550c386ae64422bb59869af161cf6eb" => :catalina
  end

  depends_on "tenantcloud/tenantcloud/mhash"

  resource "libmcrypt" do
    url "http://10.10.4.242:8081/libmcrypt-2.5.8.tar.gz"
    sha256 "e4eb6c074bbab168ac47b947c195ff8cef9d51a211cdd18ca9c9ef34d27a373e"
  end

  # Patch to correct inclusion of malloc function on OSX.
  # Upstream: https://sourceforge.net/p/mcrypt/patches/14/
  patch :DATA

  def install
    resource("libmcrypt").stage do
      system "./configure", "--prefix=#{prefix}",
                            "--mandir=#{man}"
      system "make", "install"
    end

    system "./configure", "--prefix=#{prefix}",
                          "--with-libmcrypt-prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make", "install"
  end

  test do
    (testpath/"test.txt").write <<~EOS
      Hello, world!
    EOS
    system bin/"mcrypt", "--key", "TestPassword", "--force", "test.txt"
    rm "test.txt"
    system bin/"mcrypt", "--key", "TestPassword", "--decrypt", "test.txt.nc"
  end
end

__END__
diff --git a/src/rfc2440.c b/src/rfc2440.c
index 5a1f296..aeb501c 100644
--- a/src/rfc2440.c
+++ b/src/rfc2440.c
@@ -23,7 +23,12 @@
 #include <zlib.h>
 #endif
 #include <stdio.h>
+
+#ifdef __APPLE__
+#include <malloc/malloc.h>
+#else
 #include <malloc.h>
+#endif

 #include "xmalloc.h"
#include "keys.h"
