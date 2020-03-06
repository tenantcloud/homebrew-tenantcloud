class SharedMimeInfo < Formula
  desc "Database of common MIME types"
  homepage "https://wiki.freedesktop.org/www/Software/shared-mime-info"
  url "http://10.10.4.242:8081/shared-mime-info-1.15.tar.xz"
  sha256 "f482b027437c99e53b81037a9843fccd549243fd52145d016e9c7174a4f5db90"

  bottle do
    cellar :any
    sha256 "137dfd734f5e7fe9b9ee80d1efa135f95a3ade95ceab83b2f79cd7ca1fd4d313" => :catalina
    sha256 "1be57687d8aef14d6bc95be0a02a5dfdbce4bf859ea057c93e3ff8545c700fcd" => :mojave
    sha256 "87ec03b8d25d6c3c455c98dbc8d9ac3569df6abaae0c07ad9444a1cfa462cd06" => :high_sierra
  end

  head do
    url "https://gitlab.freedesktop.org/xdg/shared-mime-info.git"
    depends_on "tenantcloud/tenantcloud/autoconf" => :build
    depends_on "tenantcloud/tenantcloud/automake" => :build
    depends_on "tenantcloud/tenantcloud/intltool" => :build
  end

  depends_on "tenantcloud/tenantcloud/intltool" => :build
  depends_on "tenantcloud/tenantcloud/itstool" => :build
  depends_on "tenantcloud/tenantcloud/pkg-config" => :build
  depends_on "tenantcloud/tenantcloud/gettext"
  depends_on "tenantcloud/tenantcloud/glib"

  uses_from_macos "libxml2"

  def install
    # Disable the post-install update-mimedb due to crash
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --disable-update-mimedb
    ]
    if build.head?
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    system "make", "install"
    pkgshare.install share/"mime/packages"
    rmdir share/"mime"
  end

  def post_install
    global_mime = HOMEBREW_PREFIX/"share/mime"
    cellar_mime = share/"mime"

    # Remove bad links created by old libheif postinstall
    rm_rf global_mime if global_mime.symlink?

    if !cellar_mime.exist? || !cellar_mime.symlink?
      rm_rf cellar_mime
      ln_sf global_mime, cellar_mime
    end

    (global_mime/"packages").mkpath
    cp (pkgshare/"packages").children, global_mime/"packages"

    system bin/"update-mime-database", global_mime
  end

  test do
    cp_r share/"mime", testpath
    system bin/"update-mime-database", testpath/"mime"
  end
end
