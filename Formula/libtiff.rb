class Libtiff < Formula
  desc "TIFF library and utilities"
  homepage "http://libtiff.maptools.org/"
  url "http://10.10.4.242:8081/tiff-4.1.0.tar.gz"
#  mirror "https://fossies.org/linux/misc/tiff-4.0.10.tar.gz"
  sha256 "2c52d11ccaf767457db0c46795d9c7d1a8d8f76f68b0b800a3dfe45786b996e4"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    cellar :any
    sha256 "449bd9123e73e4c4eab85b77322d769cc9df0f6adab05e9b9319b012d1215a68" => :catalina
    sha256 "dd060521aa30fb2f4678c9ebab6362104a9a705d098a90eac4059743c93c8c16" => :mojave
    sha256 "577c2754b00fc8a5009e08bfd7af630ab4812250508df20a1c92d3c7ae678b94" => :high_sierra
  end

  depends_on "tenantcloud/tenantcloud/jpeg"

  # Patches are taken from latest Fedora package, which is currently
  # libtiff-4.0.10-1.fc30.src.rpm and whose changelog is available at
  # https://apps.fedoraproject.org/packages/libtiff/changelog/

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-lzma
      --with-jpeg-include-dir=#{Formula["jpeg"].opt_include}
      --with-jpeg-lib-dir=#{Formula["jpeg"].opt_lib}
      --without-x
    ]
    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <tiffio.h>
      int main(int argc, char* argv[])
      {
        TIFF *out = TIFFOpen(argv[1], "w");
        TIFFSetField(out, TIFFTAG_IMAGEWIDTH, (uint32) 10);
        TIFFClose(out);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-ltiff", "-o", "test"
    system "./test", "test.tif"
    assert_match(/ImageWidth.*10/, shell_output("#{bin}/tiffdump test.tif"))
  end
end
