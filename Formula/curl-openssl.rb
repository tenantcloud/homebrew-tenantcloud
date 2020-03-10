class CurlOpenssl < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.haxx.se/"
  url "http://10.10.4.242:8081/curl-7.69.0.tar.bz2"
  sha256 "668d451108a7316cff040b23c79bc766e7ed84122074e44f662b8982f2e76739"
  revision 1

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "c0b351723ccb8b144e1eb3aa23d1f73bce6dd1d4e9f3cd0a87dd7ea26bf797a5" => :catalina
    sha256 "02e3c317b5646f97792c8777b3fe669b185552b5c5ddaa1746ea96d53524fd98" => :mojave
    sha256 "1649addf03756d2c541b1b5e054a1a9002dd81628e758d92d5685b8cf981b449" => :high_sierra
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
