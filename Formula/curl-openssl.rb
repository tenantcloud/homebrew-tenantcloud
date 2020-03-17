class CurlOpenssl < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.haxx.se/"
  url "http://10.10.4.242:8081/curl-7.69.1.tar.bz2"
  sha256 "2ff5e5bd507adf6aa88ff4bbafd4c7af464867ffb688be93b9930717a56c4de8"
  # revision 1

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "c64c399d3fa8c7963c3d1881bd20467382fe91020b976e0e04e44e37cf8b992b" => :catalina
    sha256 "7ffe9b70aff89a02e532d584c5dbf95720899f7df2e033ae294c46b52fb9984a" => :mojave
    sha256 "da8add26e84654daeb797404c335563e7e932d5e64af6d4d85090b68bf628e3f" => :high_sierra
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
