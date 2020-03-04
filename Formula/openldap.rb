class Openldap < Formula
  desc "Open source suite of directory software"
  homepage "https://www.openldap.org/software/"
  url "http://10.10.4.242:8081/openldap-2.4.49.tgz"
  sha256 "d9523ffcab5cd14b709fcf3cb4d04e8bc76bb8970113255f372bc74954c6074d"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "26efb37f53ae1a3815213adf9ab815c66b7197a3d212f994dd4e5b4140cf3e4e" => :catalina
    sha256 "b1572831c24149585e73eaafbc08dc66d9edfca69f72cdeaaabf1e9c4b2ddda1" => :mojave
    sha256 "eb9c40191d88785247026a699bd6fe0e2e9e669395d814d7d1be430843a92b05" => :high_sierra
  end

  keg_only :provided_by_macos

  depends_on "tenantcloud/tenantcloud/openssl@1.1"

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --localstatedir=#{var}
      --enable-accesslog
      --enable-auditlog
      --enable-bdb=no
      --enable-constraint
      --enable-dds
      --enable-deref
      --enable-dyngroup
      --enable-dynlist
      --enable-hdb=no
      --enable-memberof
      --enable-ppolicy
      --enable-proxycache
      --enable-refint
      --enable-retcode
      --enable-seqmod
      --enable-translucent
      --enable-unique
      --enable-valsort
    ]

    system "./configure", *args
    system "make", "install"
    (var/"run").mkpath

    # https://github.com/Homebrew/homebrew-dupes/pull/452
    chmod 0755, Dir[etc/"openldap/*"]
    chmod 0755, Dir[etc/"openldap/schema/*"]
  end

  test do
    system sbin/"slappasswd", "-s", "test"
  end
end
