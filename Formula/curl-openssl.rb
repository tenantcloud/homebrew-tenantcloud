class CurlOpenssl < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.haxx.se/"
  url "http://10.10.4.242:8081/curl-7.67.0.tar.bz2"
  sha256 "dd5f6956821a548bf4b44f067a530ce9445cc8094fd3e7e3fc7854815858586c"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "84c070944750b1ab555478769569326a5af985de9242b64a4f59041cd51b4a3b" => :mojave
    sha256 "d3cac8f1bd6593c58358e9e7c3b187182f9b7be5ed1edd4f372c4afb83eea052" => :high_sierra
    sha256 "1513f434fa288a92307da632fc73f7e32fbc2f2f03441335415d8573a7205598" => :catalina
  end

  keg_only :provided_by_macos

  depends_on "tenantcloud/tenantcloud/pkg-config" => :build
  depends_on "tenantcloud/tenantcloud/brotli"
  depends_on "tenantcloud/tenantcloud/nghttp2"
  depends_on "tenantcloud/tenantcloud/openldap"
  depends_on "tenantcloud/tenantcloud/openssl"

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
