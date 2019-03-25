class Cairo < Formula
  desc "Vector graphics library with cross-device output support"
  homepage "https://cairographics.org/"
  url "http://10.10.4.242:8081/cairo-1.16.0.tar.xz"
  sha256 "5e7b29b3f113ef870d1e3ecf8adf21f923396401604bda16d44be45e66052331"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "204d0a3df9ebebef6f553b4a583351f14b84ca8682537941f2c04ba971999444" => :mojave
    sha256 "f518c9e6cd207647eedff70720fc99a85eaf143da866f4e679ffb0b6c6c50098" => :high_sierra
  end

  head do
    url "https://anongit.freedesktop.org/git/cairo", :using => :git
    depends_on "tenantcloud/tenantcloud/autoconf" => :build
    depends_on "tenantcloud/tenantcloud/automake" => :build
    depends_on "tenantcloud/tenantcloud/libtool" => :build
  end

  depends_on "tenantcloud/tenantcloud/pkg-config" => :build
  depends_on "tenantcloud/tenantcloud/fontconfig"
  depends_on "tenantcloud/tenantcloud/freetype"
  depends_on "tenantcloud/tenantcloud/glib"
  depends_on "tenantcloud/tenantcloud/libpng"
  depends_on "tenantcloud/tenantcloud/pixman"

  def install
    if build.head?
      ENV["NOCONFIGURE"] = "1"
      system "./autogen.sh"
    end

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-gobject=yes",
                          "--enable-svg=yes",
                          "--enable-tee=yes",
                          "--enable-quartz-image",
                          "--enable-xcb=no",
                          "--enable-xlib=no",
                          "--enable-xlib-xrender=no"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <cairo.h>
      int main(int argc, char *argv[]) {
        cairo_surface_t *surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 600, 400);
        cairo_t *context = cairo_create(surface);
        return 0;
      }
    EOS
    fontconfig = Formula["fontconfig"]
    freetype = Formula["freetype"]
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    libpng = Formula["libpng"]
    pixman = Formula["pixman"]
    flags = %W[
      -I#{fontconfig.opt_include}
      -I#{freetype.opt_include}/freetype2
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/cairo
      -I#{libpng.opt_include}/libpng16
      -I#{pixman.opt_include}/pixman-1
      -L#{lib}
      -lcairo
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
