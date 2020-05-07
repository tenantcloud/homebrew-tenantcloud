class CurlOpenssl < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.haxx.se/"
  url "http://10.10.4.242:8081/curl-7.70.0.tar.xz"
  sha256 "032f43f2674008c761af19bf536374128c16241fb234699a55f9fb603fcfbae7"
  # revision 1

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "734a899fd8b639b876c781e416a2f4ebdb45a02cf81e7f33f38993798831cf4d" => :catalina
    sha256 "e5b1c91159e5a5a72a12e5d5cf3881871f5d610e780e21a4d43e1194c05a52af" => :mojave
    sha256 "716b806b016469c364078fd25b8c0fef88873a01c2074fa24b54ba388b548ee2" => :high_sierra
  end

  keg_only :provided_by_macos

  depends_on "tenantcloud/tenantcloud/pkg-config" => :build
  depends_on "tenantcloud/tenantcloud/brotli"
  depends_on "tenantcloud/tenantcloud/nghttp2"
  depends_on "tenantcloud/tenantcloud/openldap"
  depends_on "tenantcloud/tenantcloud/openssl@1.1"
  depends_on "tenantcloud/tenantcloud/c-ares"
  depends_on "tenantcloud/tenantcloud/libssh2"
  depends_on "tenantcloud/tenantcloud/rtmpdump"
  depends_on "tenantcloud/tenantcloud/libidn"
  depends_on "tenantcloud/tenantcloud/libmetalink"
 
  def install
    # Allow to build on Lion, lowering from the upstream setting of 10.8
    ENV.append_to_cflags "-mmacosx-version-min=10.7" if MacOS.version <= :lion

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --disable-ares
      --with-ca-bundle=#{etc}/openssl/cert.pem
      --with-ca-path=#{etc}/openssl/certs
      --with-gssapi
      --without-libidn2
      --without-libmetalink
      --without-librtmp
      --without-libssh2
      --with-ssl=#{Formula["openssl"].opt_prefix}
    ]

    system "./configure", *args
    system "make", "install"
    libexec.install "lib/mk-ca-bundle.pl"
  end

  test do
    # Fetch the curl tarball and see that the checksum matches.
    # This requires a network connection, but so does Homebrew in general.
    filename = (testpath/"test.tar.gz")
    system "#{bin}/curl", "-L", stable.url, "-o", filename
    filename.verify_checksum stable.checksum

    system libexec/"mk-ca-bundle.pl", "test.pem"
    assert_predicate testpath/"test.pem", :exist?
    assert_predicate testpath/"certdata.txt", :exist?
  end
end
