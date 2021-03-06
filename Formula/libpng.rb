class Libpng < Formula
  desc "Library for manipulating PNG images"
  homepage "http://www.libpng.org/pub/png/libpng.html"
  url "http://10.10.4.242:8081/libpng-1.6.37.tar.xz"
#  mirror "https://sourceforge.mirrorservice.org/l/li/libpng/libpng16/1.6.36/libpng-1.6.36.tar.xz"
  sha256 "505e70834d35383537b6491e7ae8641f1a4bed1876dbfe361201fc80868d88ca"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    cellar :any
    sha256 "7f6ac019c4413445dfa4d5ccbecfde564bf50b66ea32668bc360ad6edc78707d" => :mojave
    sha256 "b79c005157a135c42d42fbd7bf2f13537964a24225cc2bae51dd97908799fe08" => :high_sierra
    sha256 "c8e74da602c21f978cd7ee3d489979b4fc6681e71f678a1d99012943ee3a909f" => :catalina
  end

  head do
    url "https://github.com/glennrp/libpng.git"

    depends_on "tenantcloud/tenantcloud/autoconf" => :build
    depends_on "tenantcloud/tenantcloud/automake" => :build
    depends_on "tenantcloud/tenantcloud/libtool" => :build
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "test"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <png.h>
      int main()
      {
        png_structp png_ptr;
        png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
        png_destroy_write_struct(&png_ptr, (png_infopp)NULL);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lpng", "-o", "test"
    system "./test"
  end
end
