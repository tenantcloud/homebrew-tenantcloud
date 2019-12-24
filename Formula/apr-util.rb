class AprUtil < Formula
  desc "Companion library to apr, the Apache Portable Runtime library"
  homepage "https://apr.apache.org/"
   url "http://10.10.4.242:8081/apr-util-1.6.1_3.tar.gz"

  sha256 "5daafb99700b157cbfddb160f90e3151f98647b40351e038edf3e21dc7306416"
  revision 1

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "e4927892e16a3c9cf0d037c1777a6e5728fef2f5abfbc0af3d0d444e9d6a1d2b" => :mojave
    sha256 "1bdf0cda4f0015318994a162971505f9807cb0589a4b0cbc7828531e19b6f739" => :high_sierra
    sha256 "425955a21c3fec8e78f365cd7fc4c6c4ec95d074f720a9b24e8237af90cc4dcc" => :catalina
  end

  keg_only :provided_by_macos, "Apple's CLT package contains apr"

  depends_on "tenantcloud/tenantcloud/apr"
  depends_on "tenantcloud/tenantcloud/openssl"

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
