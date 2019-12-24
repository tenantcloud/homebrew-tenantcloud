class Unixodbc < Formula
  desc "ODBC 3 connectivity for UNIX"
  homepage "http://www.unixodbc.org/"
  url "http://10.10.4.242:8081/unixODBC-2.3.7.tar.gz"
  sha256 "45f169ba1f454a72b8fcbb82abd832630a3bf93baa84731cf2949f449e1e3e77"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "c4f375c528496bae444824f4d01922e31a9a8b0c6822cd97da89f5843e740025" => :mojave
    sha256 "6f16f12d3463655c3b3fc8251083f77a31b0a690ecf6ac88f4b0daea2f060044" => :high_sierra
    sha256 "03ba378d971af98d07652f978548ffacb4c155ba11dd36af9d46af36e2d5674b" => :catalina
  end

  depends_on "tenantcloud/tenantcloud/libtool"

  keg_only "shadows system iODBC header files" if MacOS.version < :mavericks

  conflicts_with "virtuoso", :because => "Both install `isql` binaries."

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}",
                          "--enable-static",
                          "--enable-gui=no"
    system "make", "install"
  end

  test do
    system bin/"odbcinst", "-j"
  end
end
