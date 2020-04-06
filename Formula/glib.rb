class Glib < Formula
  desc "Core application library for C"
  homepage "https://developer.gnome.org/glib/"
  url "http://10.10.4.242:8081/glib-2.64.1.tar.xz"
  sha256 "17967603bcb44b6dbaac47988d80c29a3d28519210b28157c2bd10997595bbc7"
  revision 1

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "08a55a8645d8fcea984bacb09c991115fe346a598f33d4fc4a9d583a164921c9" => :catalina
    sha256 "42138d5d30d5eab37f17c75e8b191034c175b615a6777021460365be90b6f49a" => :mojave
    sha256 "3abd649cb9c2c8f0bfb5a21bab86353078dbf2faeb2323f8051236b27c9bc1aa" => :high_sierra
  end

  # autoconf, automake and libtool can be removed when
  # bug 780271 is fixed and gio.patch is modified accordingly
  # depends_on "tenantcloud/tenantcloud/autoconf" => :build
  # depends_on "tenantcloud/tenantcloud/automake" => :build
  # depends_on "tenantcloud/tenantcloud/gtk-doc" => :build
  # depends_on "tenantcloud/tenantcloud/libtool" => :build
  # depends_on "tenantcloud/tenantcloud/pkg-config" => :build
  # depends_on "tenantcloud/tenantcloud/gettext"
  # depends_on "tenantcloud/tenantcloud/libffi"
  # depends_on "tenantcloud/tenantcloud/pcre"
  
  depends_on "tenantcloud/tenantcloud/meson" => :build
  depends_on "tenantcloud/tenantcloud/ninja" => :build
  depends_on "tenantcloud/tenantcloud/pkg-config" => :build
  depends_on "tenantcloud/tenantcloud/gettext"
  depends_on "tenantcloud/tenantcloud/libffi"
  depends_on "tenantcloud/tenantcloud/pcre"
  depends_on "tenantcloud/tenantcloud/python"

  # https://bugzilla.gnome.org/show_bug.cgi?id=673135 Resolved as wontfix,
  # but needed to fix an assumption about the location of the d-bus machine
  # id file.
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/59e4d32/glib/hardcoded-paths.diff"
    sha256 "a4cb96b5861672ec0750cb30ecebe1d417d38052cac12fbb8a77dbf04a886fcb"
  end

  # Revert some bad macOS specific commits
  # https://bugzilla.gnome.org/show_bug.cgi?id=780271
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/5857984/glib/revert-appinfo-contenttype.patch"
    sha256 "88bfc2a69aaeda07c5f057d11e106a97837ff319f8be1f553b8537f3c136f48c"
  end

  def install
    inreplace %w[gio/gdbusprivate.c gio/xdgmime/xdgmime.c glib/gutils.c],
      "@@HOMEBREW_PREFIX@@", HOMEBREW_PREFIX

    # Disable dtrace; see https://trac.macports.org/ticket/30413
    args = %W[
      --disable-maintainer-mode
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-dtrace
      --disable-libelf
      --enable-static
      --prefix=#{prefix}
      --localstatedir=#{var}
      --with-gio-module-dir=#{HOMEBREW_PREFIX}/lib/gio/modules
    ]

    # next two lines can be removed when bug 780271 is fixed and gio.patch
    # is modified accordingly
    ENV["NOCONFIGURE"] = "1"
    system "./autogen.sh"

    system "./configure", *args

    # disable creating directory for GIO_MODULE_DIR, we will do
    # this manually in post_install
    inreplace "gio/Makefile",
              "$(mkinstalldirs) $(DESTDIR)$(GIO_MODULE_DIR)",
              ""

    # ensure giomoduledir contains prefix, as this pkgconfig variable will be
    # used by glib-networking and glib-openssl to determine where to install
    # their modules
    inreplace "gio-2.0.pc",
              "giomoduledir=#{HOMEBREW_PREFIX}/lib/gio/modules",
              "giomoduledir=${prefix}/lib/gio/modules"

    system "make"
    system "make", "install"

    # `pkg-config --libs glib-2.0` includes -lintl, and gettext itself does not
    # have a pkgconfig file, so we add gettext lib and include paths here.
    gettext = Formula["gettext"].opt_prefix
    inreplace lib+"pkgconfig/glib-2.0.pc" do |s|
      s.gsub! "Libs: -L${libdir} -lglib-2.0 -lintl",
              "Libs: -L${libdir} -lglib-2.0 -L#{gettext}/lib -lintl"
      s.gsub! "Cflags: -I${includedir}/glib-2.0 -I${libdir}/glib-2.0/include",
              "Cflags: -I${includedir}/glib-2.0 -I${libdir}/glib-2.0/include -I#{gettext}/include"
    end
  end

  def post_install
    (HOMEBREW_PREFIX/"lib/gio/modules").mkpath
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <string.h>
      #include <glib.h>
      int main(void)
      {
          gchar *result_1, *result_2;
          char *str = "string";
          result_1 = g_convert(str, strlen(str), "ASCII", "UTF-8", NULL, NULL, NULL);
          result_2 = g_convert(result_1, strlen(result_1), "UTF-8", "ASCII", NULL, NULL, NULL);
          return (strcmp(str, result_2) == 0) ? 0 : 1;
      }
    EOS
    system ENV.cc, "-o", "test", "test.c", "-I#{include}/glib-2.0",
                   "-I#{lib}/glib-2.0/include", "-L#{lib}", "-lglib-2.0"
    system "./test"
  end
end
