class GdkPixbuf < Formula
  desc "Toolkit for image loading and pixel buffer manipulation"
  homepage "https://gtk.org"
  url "http://10.10.4.242:8081/gdk-pixbuf-2.38.0.tar.xz"
  sha256 "dd50973c7757bcde15de6bcd3a6d462a445efd552604ae6435a0532fbbadae47"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "f49a95e28e72c80d2376a0028cfe8ea77b8343c1aadb71fbe5ccb5c31100674f" => :mojave
    sha256 "b5fcfc3b0f9217182ead5b34ddb23dfdf5793fd249a813995f64296cff599ffb" => :high_sierra
  end

  depends_on "tenantcloud/tenantcloud/gobject-introspection" => :build
  depends_on "tenantcloud/tenantcloud/meson-internal" => :build
  depends_on "tenantcloud/tenantcloud/ninja" => :build
  depends_on "tenantcloud/tenantcloud/pkg-config" => :build
  depends_on "tenantcloud/tenantcloud/python" => :build
  depends_on "tenantcloud/tenantcloud/glib"
  depends_on "tenantcloud/tenantcloud/jpeg"
  depends_on "tenantcloud/tenantcloud/libpng"
  depends_on "tenantcloud/tenantcloud/libtiff"

  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/3d39ffd/gdk-pixbuf/meson-patches.diff"
    sha256 "eb78bdfd5452c617ea0873629a5ec8f502a986357aa2d1a462dc9f2551b37c38"
  end

  # gdk-pixbuf has an internal version number separate from the overall
  # version number that specifies the location of its module and cache
  # files, this will need to be updated if that internal version number
  # is ever changed (as evidenced by the location no longer existing)
  def gdk_so_ver
    "2.0"
  end

  def gdk_module_ver
    "2.10.0"
  end

  def install
    inreplace "gdk-pixbuf/meson.build",
              "-DGDK_PIXBUF_LIBDIR=\"@0@\"'.format(gdk_pixbuf_libdir)",
              "-DGDK_PIXBUF_LIBDIR=\"@0@\"'.format('#{HOMEBREW_PREFIX}/lib')"

    args = %W[
      --prefix=#{prefix}
      -Dx11=false
      -Ddocs=false
      -Dgir=true
      -Drelocatable=false
      -Dnative_windows_loaders=false
      -Dinstalled_tests=false
      -Dman=false
    ]

    ENV["DESTDIR"] = "/"
    mkdir "build" do
      system "meson", *args, ".."
      system "ninja", "-v"
      system "ninja", "install"
    end

    # Other packages should use the top-level modules directory
    # rather than dumping their files into the gdk-pixbuf keg.
    inreplace lib/"pkgconfig/gdk-pixbuf-#{gdk_so_ver}.pc" do |s|
      libv = s.get_make_var "gdk_pixbuf_binary_version"
      s.change_make_var! "gdk_pixbuf_binarydir",
        HOMEBREW_PREFIX/"lib/gdk-pixbuf-#{gdk_so_ver}"/libv
    end
  end

  # The directory that loaders.cache gets linked into, also has the "loaders"
  # directory that is scanned by gdk-pixbuf-query-loaders in the first place
  def module_dir
    "#{HOMEBREW_PREFIX}/lib/gdk-pixbuf-#{gdk_so_ver}/#{gdk_module_ver}"
  end

  def post_install
    ENV["GDK_PIXBUF_MODULEDIR"] = "#{module_dir}/loaders"
    system "#{bin}/gdk-pixbuf-query-loaders", "--update-cache"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <gdk-pixbuf/gdk-pixbuf.h>
      int main(int argc, char *argv[]) {
        GType type = gdk_pixbuf_get_type();
        return 0;
      }
    EOS
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    libpng = Formula["libpng"]
    pcre = Formula["pcre"]
    flags = (ENV.cflags || "").split + (ENV.cppflags || "").split + (ENV.ldflags || "").split
    flags += %W[
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/gdk-pixbuf-2.0
      -I#{libpng.opt_include}/libpng16
      -I#{pcre.opt_include}
      -D_REENTRANT
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{lib}
      -lgdk_pixbuf-2.0
      -lglib-2.0
      -lgobject-2.0
      -lintl
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
