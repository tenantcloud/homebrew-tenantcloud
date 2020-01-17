class Imagemagick < Formula
  desc "Tools and libraries to manipulate images in many formats"
  homepage "https://www.imagemagick.org/"
  url "http://10.10.4.242:8081/ImageMagick-7.0.9-16.tar.xz"
  sha256 "22109b84afa2c45eb535ac342b2c9301c2c3cb8c3dc0f7a9af3d89199b289d18"

  bottle do
    sha256 "ea69c9f5535e94249b82190e4988e575309c9de3e31c46891cd2b8dfda5f6d6b" => :catalina
    sha256 "068f6352eb5282f6a1e94a970cfe3a81476a50be28d095a085253dc86b76d44c" => :mojave
    sha256 "9baeddd44639db07ac3a76eee8bdaa2d165f9a08b394ea5ff678a505ade9fb5a" => :high_sierra
  end

  depends_on "pkg-config" => :build
  depends_on "tenantcloud/tenantcloud/freetype"
  depends_on "tenantcloud/tenantcloud/jpeg"
  depends_on "tenantcloud/tenantcloud/libheif"
  depends_on "tenantcloud/tenantcloud/libomp"
  depends_on "tenantcloud/tenantcloud/libpng"
  depends_on "tenantcloud/tenantcloud/libtiff"
  depends_on "tenantcloud/tenantcloud/libtool"
  depends_on "tenantcloud/tenantcloud/little-cms2"
  depends_on "tenantcloud/tenantcloud/openexr"
  depends_on "tenantcloud/tenantcloud/openjpeg"
  depends_on "tenantcloud/tenantcloud/webp"
  depends_on "tenantcloud/tenantcloud/xz"
  uses_from_macos "bzip2"
  uses_from_macos "libxml2"

  skip_clean :la

  def install
    args = %W[
      --disable-osx-universal-binary
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-opencl
      --enable-shared
      --enable-static
      --with-freetype=yes
      --with-modules
      --with-openjp2
      --with-openexr
      --with-webp=yes
      --with-heic=yes
      --without-gslib
      --with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts
      --without-fftw
      --without-pango
      --without-x
      --without-wmf
      --enable-openmp
      ac_cv_prog_c_openmp=-Xpreprocessor\ -fopenmp
      ac_cv_prog_cxx_openmp=-Xpreprocessor\ -fopenmp
      LDFLAGS=-lomp
    ]

    # versioned stuff in main tree is pointless for us
    inreplace "configure", "${PACKAGE_NAME}-${PACKAGE_VERSION}", "${PACKAGE_NAME}"
    system "./configure", *args
    system "make", "install"
  end

  test do
    assert_match "PNG", shell_output("#{bin}/identify #{test_fixtures("test.png")}")
    # Check support for recommended features and delegates.
    features = shell_output("#{bin}/convert -version")
    %w[Modules freetype jpeg png tiff].each do |feature|
      assert_match feature, features
    end
  end
end

