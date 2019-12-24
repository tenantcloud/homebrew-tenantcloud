class Gettext < Formula
  desc "GNU internationalization (i18n) and localization (l10n) library"
  homepage "https://www.gnu.org/software/gettext/"
  url "http://10.10.4.242:8081/gettext-0.20.1.tar.xz"
#  mirror "https://ftpmirror.gnu.org/gettext/gettext-0.19.8.1.tar.xz"
  sha256 "53f02fbbec9e798b0faaf7c73272f83608e835c6288dd58be6c9bb54624a3800"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "afc6a6120632b98d58b11fab82ae5e081206b89684dd948abf2d29caeb813ffd" => :mojave
    sha256 "99d2dbd4c9ebfe9bf2a64bd99f3a695a18635f0d9110eaff34bab8022abef6a8" => :high_sierra
    sha256 "6354adfc22f1d78b1a671862db906ff1e55482be9c58a6ee6a43245f8895fef2" => :catalina
  end

  keg_only :shadowed_by_macos,
    "macOS provides the BSD gettext library & some software gets confused if both are in the library path"

  # https://savannah.gnu.org/bugs/index.php?46844
  depends_on "tenantcloud/tenantcloud/libxml2" if MacOS.version <= :mountain_lion

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--disable-debug",
                          "--prefix=#{prefix}",
                          "--with-included-gettext",
                          "--with-included-glib",
                          "--with-included-libcroco",
                          "--with-included-libunistring",
                          "--with-emacs",
                          "--with-lispdir=#{elisp}",
                          "--disable-java",
                          "--disable-csharp",
                          # Don't use VCS systems to create these archives
                          "--without-git",
                          "--without-cvs",
                          "--without-xz"
    system "make"
    ENV.deparallelize # install doesn't support multiple make jobs
    system "make", "install"
  end

  test do
    system bin/"gettext", "test"
  end
end
