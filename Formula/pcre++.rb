class Pcrexx < Formula
  desc "C++ wrapper for the Perl Compatible Regular Expressions"
  homepage "https://www.daemon.de/PCRE"
  url "http://10.10.4.242:8081/pcre%2B%2B-0.9.5.tar.gz"
  sha256 "77ee9fc1afe142e4ba2726416239ced66c3add4295ab1e5ed37ca8a9e7bb638a"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    cellar :any
    sha256 "74eb2f78269663a150978c7a221af9bb453c459f14838cbe551f9b25cba222ce" => :mojave
    sha256 "65018b1dd42de0fc89e533f5343754cf8b07e0b989d0fc1820483fd76a36caab" => :high_sierra
  end

  depends_on "tenantcloud/tenantcloud/autoconf" => :build
  depends_on "tenantcloud/tenantcloud/automake" => :build
  depends_on "tenantcloud/tenantcloud/libtool" => :build
  depends_on "tenantcloud/tenantcloud/pcre"

  # Fix building with libc++. Patch sent to maintainer.
  patch :DATA

  def install
    pcre = Formula["pcre"]
    system "autoreconf", "-fvi"
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-pcre-lib=#{pcre.opt_lib}",
                          "--with-pcre-include=#{pcre.opt_include}"
    system "make", "install"

    # Pcre++ ships Pcre.3, which causes a conflict with pcre.3 from pcre
    # in case-insensitive file system. Rename it to pcre++.3 to avoid
    # this problem.
    mv man3/"Pcre.3", man3/"pcre++.3"
  end

  def caveats; <<~EOS
    The man page has been renamed to pcre++.3 to avoid conflicts with
    pcre in case-insensitive file system.  Please use "man pcre++"
    instead.
  EOS
  end
end

__END__
diff --git a/libpcre++/pcre++.h b/libpcre++/pcre++.h
index d80b387..21869fc 100644
--- a/libpcre++/pcre++.h
+++ b/libpcre++/pcre++.h
@@ -47,11 +47,11 @@
 #include <map>
 #include <stdexcept>
 #include <iostream>
+#include <clocale>
 
 
 extern "C" {
   #include <pcre.h>
-  #include <locale.h>
 }
 
namespace pcrepp {
