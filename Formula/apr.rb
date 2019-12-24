class Apr < Formula
  desc "Apache Portable Runtime library"
  homepage "https://apr.apache.org/"
  url "http://10.10.4.242:8081/apr-1.7.0.tar.bz2"
  sha256 "e2e148f0b2e99b8e5c6caa09f6d4fb4dd3e83f744aa72a952f94f5a14436f7ea"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    cellar :any
    sha256 "0111bfb48f0a020292bd503c2c8e1b374f9ea844c3cc32a0b35a670234adc055" => :mojave
    sha256 "314c8ebd08304a0f7dcebe3ca7fe5cc6b1c283b744f12d19d0931b91fac4fe20" => :high_sierra
    sha256 "277c42fcf2f5ca298a14279d1325f58da89ee4ec2132b3ccca9bf8dfdc354c48" => :catalina
  end

  keg_only :provided_by_macos, "Apple's CLT package contains apr"

  def install
    ENV["SED"] = "sed" # prevent libtool from hardcoding sed path from superenv

    # https://bz.apache.org/bugzilla/show_bug.cgi?id=57359
    # The internal libtool throws an enormous strop if we don't do...
    ENV.deparallelize

    # Stick it in libexec otherwise it pollutes lib with a .exp file.
    system "./configure", "--prefix=#{libexec}"
    system "make", "install"
    bin.install_symlink Dir["#{libexec}/bin/*"]

    rm Dir[libexec/"lib/*.la"]

    # No need for this to point to the versioned path.
    inreplace libexec/"bin/apr-1-config", libexec, opt_libexec
  end

  test do
    assert_match opt_libexec.to_s, shell_output("#{bin}/apr-1-config --prefix")
  end
end
