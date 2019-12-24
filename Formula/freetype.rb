class Freetype < Formula
  desc "Software library to render fonts"
  homepage "https://www.freetype.org/"
  url "http://10.10.4.242:8081/freetype-2.10.1.tar.xz"
#  mirror "https://download.savannah.gnu.org/releases/freetype/freetype-2.9.1.tar.bz2"
  sha256 "16dbfa488a21fe827dc27eaf708f42f7aa3bb997d745d31a19781628c36ba26f"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    cellar :any
    sha256 "64d650278af1f74d43165f3943287b42109710e672d2756abaa492f0cc4d52b7" => :mojave
    sha256 "444ef60a543aca6ca26223f46182c914e26d2908f33fca41cb54bcf9a81084a3" => :high_sierra
    sha256 "ddd686141a969caec11ea248324e3736f6db50a54673187be103dde39cb01ebf" => :catalina
  end

  depends_on "tenantcloud/tenantcloud/libpng"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--enable-freetype-config",
                          "--without-harfbuzz"
    system "make"
    system "make", "install"

    inreplace [bin/"freetype-config", lib/"pkgconfig/freetype2.pc"],
      prefix, opt_prefix
  end

  test do
    system bin/"freetype-config", "--cflags", "--libs", "--ftversion",
                                  "--exec-prefix", "--prefix"
  end
end
