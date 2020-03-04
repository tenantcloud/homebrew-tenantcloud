class Freetds < Formula
  desc "Libraries to talk to Microsoft SQL Server and Sybase databases"
  homepage "http://www.freetds.org/"
  url "http://10.10.4.242:8081/freetds-1.1.24.tar.gz"
  sha256 "5de0f53ebab6345bb388ce1c7965005d68b121136ebf8e05ce25611fef7527bf"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "363d44ed3a0ec8f9768987bc6d873913dd30818933ea9bb9c290580dbd6d11ab" => :catalina
    sha256 "0af97f13a63bcdc54f9f5963e6a935e2779ae76e11cccfa75b8f60f0affe6574" => :mojave
    sha256 "49347305bf6ae124626f8d74d0660adf73cfee4d36b7cf0b6fbf312041b7aee5" => :high_sierra
  end

  head do
    url "https://github.com/FreeTDS/freetds.git"

    depends_on "tenantcloud/tenantcloud/autoconf" => :build
    depends_on "tenantcloud/tenantcloud/automake" => :build
    depends_on "tenantcloud/tenantcloud/gettext" => :build
    depends_on "tenantcloud/tenantcloud/libtool" => :build
  end

  option "with-msdblib", "Enable Microsoft behavior in the DB-Library API where it diverges from Sybase's"

  depends_on "tenantcloud/tenantcloud/pkg-config" => :build
  depends_on "tenantcloud/tenantcloud/openssl@1.1"
  depends_on "tenantcloud/tenantcloud/unixodbc"

  def install
    args = %W[
      --prefix=#{prefix}
      --with-tdsver=7.3
      --mandir=#{man}
      --sysconfdir=#{etc}
      --with-unixodbc=#{Formula["unixodbc"].opt_prefix}
      --with-openssl=#{Formula["openssl"].opt_prefix}
      --enable-sybase-compat
      --enable-krb5
      --enable-odbc-wide
    ]

    if build.with? "msdblib"
      args << "--enable-msdblib"
    end

    if build.head?
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    system "make"
    ENV.deparallelize # Or fails to install on multi-core machines
    system "make", "install"
  end

  test do
    system "#{bin}/tsql", "-C"
  end
end
