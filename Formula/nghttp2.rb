class Nghttp2 < Formula
  desc "HTTP/2 C Library"
  homepage "https://nghttp2.org/"
  url "http://10.10.4.242:8081/nghttp2-1.40.0.tar.xz"
  sha256 "09fc43d428ff237138733c737b29fb1a7e49d49de06d2edbed3bc4cdcee69073"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "3df6011e98f13af091fcc9e4c759d9e9662ee4d9a863d88284e17b461c94be92" => :mojave
    sha256 "9c21365ecf3717afe8fda8307c8b80902d7b1f24275e45b8c8458ecc5e42560c" => :high_sierra
    sha256 "7d8e5ffd4a51ee4c511f19b37d0285880d27239e0880113b6ad1412432aa9d11" => :catalina
  end

  head do
    url "https://github.com/nghttp2/nghttp2.git"

    depends_on "tenantcloud/tenantcloud/autoconf" => :build
    depends_on "tenantcloud/tenantcloud/automake" => :build
    depends_on "tenantcloud/tenantcloud/libtool" => :build
  end

  option "with-python", "Build python3 bindings"

  deprecated_option "with-python3" => "with-python"

  depends_on "tenantcloud/tenantcloud/cunit" => :build
  depends_on "tenantcloud/tenantcloud/pkg-config" => :build
  depends_on "tenantcloud/tenantcloud/sphinx-doc" => :build
  depends_on "tenantcloud/tenantcloud/c-ares"
  depends_on "tenantcloud/tenantcloud/jansson"
  depends_on "tenantcloud/tenantcloud/jemalloc"
  depends_on "tenantcloud/tenantcloud/libev"
  depends_on "tenantcloud/tenantcloud/libevent"
  depends_on "tenantcloud/tenantcloud/libxml2" if MacOS.version <= :lion
  depends_on "tenantcloud/tenantcloud/openssl@1.1"
  depends_on "tenantcloud/tenantcloud/python" => :optional

  resource "Cython" do
    url "http://10.10.4.242:8081/Cython-0.29.1.tar.gz"
    sha256 "18ab7646985a97e02cee72e1ddba2e732d4931d4e1732494ff30c5aa084bfb97"
  end

  # https://github.com/tatsuhiro-t/nghttp2/issues/125
  # Upstream requested the issue closed and for users to use gcc instead.
  # Given this will actually build with Clang with cxx11, just use that.

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-silent-rules
      --enable-app
      --disable-python-bindings
    ]

    # requires thread-local storage features only available in 10.11+
    args << "--disable-threads" if MacOS.version < :el_capitan
    args << "--with-xml-prefix=/usr" if MacOS.version > :lion

    system "autoreconf", "-ivf" if build.head?
    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"

    if build.with? "python"
      pyver = Language::Python.major_minor_version "python3"
      ENV["PYTHONPATH"] = cythonpath = buildpath/"cython/lib/python#{pyver}/site-packages"
      cythonpath.mkpath
      ENV.prepend_create_path "PYTHONPATH", lib/"python#{pyver}/site-packages"

      resource("Cython").stage do
        system "python3", *Language::Python.setup_install_args(buildpath/"cython")
      end

      cd "python" do
        system buildpath/"cython/bin/cython", "nghttp2.pyx"
        system "python3", *Language::Python.setup_install_args(prefix)
      end
    end
  end

  test do
    system bin/"nghttp", "-nv", "https://nghttp2.org"
  end
end
