class PkgConfig < Formula
  desc "Manage compile and link flags for libraries"
  homepage "https://freedesktop.org/wiki/Software/pkg-config/"
  url "http://10.10.4.242:8081/pkg-config-0.29.2.tar.gz"
#  mirror "https://dl.bintray.com/homebrew/mirror/pkg-config-0.29.2.tar.gz"
#  mirror "http://fco.it.distfiles.macports.org/mirrors/macports-distfiles/pkgconfig/pkg-config-0.29.2.tar.gz"
  sha256 "6fc69c01688c9458a57eb9a1664c9aba372ccda420a02bf4429fe610e7e7d591"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    rebuild 1
    sha256 "c0a6927c8e404f6db8b14d6644a218b22ddb0d27be1fa0a69d15bf0d9a6875ae" => :catalina
    sha256 "85e5bbffb3424f22cd1bf54b69161110481bab100f9abea54e0a0f00fcf761b9" => :mojave
    sha256 "f1b29fb5388dccab0fcaf665ab43d308ee51816b24262417bf83a686b6e308ae" => :high_sierra
  end

  def install
    pc_path = %W[
      #{HOMEBREW_PREFIX}/lib/pkgconfig
      #{HOMEBREW_PREFIX}/share/pkgconfig
      /usr/local/lib/pkgconfig
      /usr/lib/pkgconfig
      #{HOMEBREW_LIBRARY}/Homebrew/os/mac/pkgconfig/#{MacOS.version}
    ].uniq.join(File::PATH_SEPARATOR)

    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--disable-host-tool",
                          "--with-internal-glib",
                          "--with-pc-path=#{pc_path}"
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    system "#{bin}/pkg-config", "--libs", "libpcre"
  end
end
