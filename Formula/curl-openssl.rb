class CurlOpenssl < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.haxx.se/"
  url "http://10.10.4.242:8081/curl-7.68.0.tar.bz2"
  sha256 "dd5f6956821a548bf4b44f067a530ce9445cc8094fd3e7e3fc7854815858586c"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
   sha256 "c4dd2e8a36d2e4487d9d8c483d42be8b2aa3c5a0a326c10b35aeca82fccd8c0f" => :catalina
    sha256 "1ef15e091d6e7071a0864195f371d297c0e2bbc39e58b5e0e193de924e4528a0" => :mojave
    sha256 "736aca75c77ed54e1c15ede808b0630afa9bd1e166c6262a2223f673a51cac9d" => :high_sierra
  end

  keg_only :provided_by_macos

  depends_on "tenantcloud/tenantcloud/pkg-config" => :build
  depends_on "tenantcloud/tenantcloud/brotli"
  depends_on "tenantcloud/tenantcloud/nghttp2"
  depends_on "tenantcloud/tenantcloud/openldap"
  depends_on "tenantcloud/tenantcloud/openssl@1.1"

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
