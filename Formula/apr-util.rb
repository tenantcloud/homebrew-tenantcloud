class AprUtil < Formula
  desc "Companion library to apr, the Apache Portable Runtime library"
  homepage "https://apr.apache.org/"
   url "http://10.10.4.242:8081/apr-util-1.6.1.tar.bz2"

  sha256 "d3e12f7b6ad12687572a3a39475545a072608f4ba03a6ce8a3778f607dd0035b"
  revision 3

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "b3b8376d8f481164a34b891b926ab22acdc2903e77c4cfbc04c0ba6363ca7597" => :mojave
    sha256 "1bdf0cda4f0015318994a162971505f9807cb0589a4b0cbc7828531e19b6f739" => :high_sierra
    sha256 "425955a21c3fec8e78f365cd7fc4c6c4ec95d074f720a9b24e8237af90cc4dcc" => :catalina
  end

  keg_only :provided_by_macos, "Apple's CLT package contains apr"

  depends_on "tenantcloud/tenantcloud/apr"
  depends_on "tenantcloud/tenantcloud/openssl@1.1"

  def install
    # Install in libexec otherwise it pollutes lib with a .exp file.
    system "./configure", "--prefix=#{libexec}",
                          "--with-apr=#{Formula["apr"].opt_prefix}",
                          "--with-crypto",
                          "--with-openssl=#{Formula["openssl"].opt_prefix}"
    system "make"
    system "make", "install"
    bin.install_symlink Dir["#{libexec}/bin/*"]

    rm Dir[libexec/"lib/*.la"]
    rm Dir[libexec/"lib/apr-util-1/*.la"]

    # No need for this to point to the versioned path.
    inreplace libexec/"bin/apu-1-config", libexec, opt_libexec
  end

  test do
    assert_match opt_libexec.to_s, shell_output("#{bin}/apu-1-config --prefix")
  end
end
