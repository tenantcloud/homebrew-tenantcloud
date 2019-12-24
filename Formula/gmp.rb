class Gmp < Formula
  desc "GNU multiple precision arithmetic library"
  homepage "https://gmplib.org/"
  url "http://10.10.4.242:8081/gmp-6.1.2.tar.xz"
#  mirror "https://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.xz"
  sha256 "87b565e89a9a684fe4ebeeddb8399dce2599f9c9049854ca8c0dfbdea0e21912"
  revision 2

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    cellar :any
    sha256 "6802f7bc775422af1438c8004bd4fe31614cc83e52fb4091f5f53fb14562e503" => :mojave
    sha256 "8372dcd88e36997d7aacaffb555709348cc2c57703608b3471cbd71f5054f9ed" => :high_sierra
    sha256 "2409417943fceda33eac12a8229fbf7b990eee18ee341b543be575550a077bb0" => :catalina
  end

  def install
    # Enable --with-pic to avoid linking issues with the static library
    args = %W[--prefix=#{prefix} --enable-cxx --with-pic]
    args << "--build=core2-apple-darwin#{`uname -r`.to_i}" if build.bottle?
    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <gmp.h>
      #include <stdlib.h>
      int main() {
        mpz_t i, j, k;
        mpz_init_set_str (i, "1a", 16);
        mpz_init (j);
        mpz_init (k);
        mpz_sqrtrem (j, k, i);
        if (mpz_get_si (j) != 5 || mpz_get_si (k) != 1) abort();
        return 0;
      }
    EOS

    system ENV.cc, "test.c", "-L#{lib}", "-lgmp", "-o", "test"
    system "./test"

    # Test the static library to catch potential linking issues
    system ENV.cc, "test.c", "#{lib}/libgmp.a", "-o", "test"
    system "./test"
  end
end
