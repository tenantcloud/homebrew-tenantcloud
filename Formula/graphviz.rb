class Graphviz < Formula
  desc "Graph visualization software from AT&T and Bell Labs"
  homepage "https://www.graphviz.org/"
  # versioned URLs are missing upstream as of 16 Dec 2017
  url "http://10.10.4.242:8081/graphviz-2.40.1.tar.gz"
#  mirror "https://fossies.org/linux/misc/graphviz-2.40.1.tar.gz"
  sha256 "ca5218fade0204d59947126c38439f432853543b0818d9d728c589dfe7f3a421"
  version_scheme 1

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    rebuild 1
    sha256 "668c64749620f556cf7d26ac96088005b4439acd9488be4c640fdc9cfe66d563" => :mojave
    sha256 "b592ce51c2a929c3da82e96ec856571ebfc54cf4dac90c2924cd3845078d7082" => :high_sierra
  end

  head do
    url "https://gitlab.com/graphviz/graphviz.git"

    depends_on "tenantcloud/tenantcloud/autoconf" => :build
    depends_on "tenantcloud/tenantcloud/automake" => :build
    depends_on "tenantcloud/tenantcloud/libtool" => :build
  end

  option "with-app", "Build GraphViz.app (requires full XCode install)"
  option "with-gts", "Build with GNU GTS support (required by prism)"
  option "with-pango", "Build with Pango/Cairo for alternate PDF output"

  deprecated_option "with-pangocairo" => "with-pango"

  depends_on "tenantcloud/tenantcloud/pkg-config" => :build
  depends_on :xcode => :build if build.with? "app"
  depends_on "tenantcloud/tenantcloud/gd"
  depends_on "tenantcloud/tenantcloud/libpng"
  depends_on "tenantcloud/tenantcloud/libtool"
  depends_on "tenantcloud/tenantcloud/gts" => :optional
  depends_on "tenantcloud/tenantcloud/librsvg" => :optional
  depends_on "tenantcloud/tenantcloud/pango" => :optional

  def install
    # Only needed when using superenv, which causes qfrexp and qldexp to be
    # falsely detected as available. The problem is triggered by
    #   args << "-#{ENV["HOMEBREW_OPTIMIZATION_LEVEL"]}"
    # during argument refurbishment of cflags.
    # https://github.com/Homebrew/brew/blob/ab060c9/Library/Homebrew/shims/super/cc#L241
    # https://github.com/Homebrew/legacy-homebrew/issues/14566
    # Alternative fixes include using stdenv or using "xcrun make"
    inreplace "lib/sfio/features/sfio", "lib qfrexp\nlib qldexp\n", "" unless build.head?

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --disable-php
      --disable-swig
      --with-quartz
      --without-freetype2
      --without-qt
      --without-x
    ]
    args << "--with-gts" if build.with? "gts"
    args << "--without-pangocairo" if build.without? "pango"
    args << "--without-rsvg" if build.without? "librsvg"

    if build.head?
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    system "make", "install"

    if build.with? "app"
      cd "macosx" do
        xcodebuild "SDKROOT=#{MacOS.sdk_path}", "-configuration", "Release", "SYMROOT=build", "PREFIX=#{prefix}",
                   "ONLY_ACTIVE_ARCH=YES", "MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}"
      end
      prefix.install "macosx/build/Release/Graphviz.app"
    end

    (bin/"gvmap.sh").unlink
  end

  test do
    (testpath/"sample.dot").write <<~EOS
      digraph G {
        a -> b
      }
    EOS

    system "#{bin}/dot", "-Tpdf", "-o", "sample.pdf", "sample.dot"
  end
end
