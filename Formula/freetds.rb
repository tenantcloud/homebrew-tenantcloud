class Freetds < Formula
  desc "Libraries to talk to Microsoft SQL Server and Sybase databases"
  homepage "http://www.freetds.org/"
  url "http://10.10.4.242:8081/freetds-1.1.26.tar.gz"
  sha256 "a2134ff1852003c0aeed82bd5f7842233ff287c3a14252b84d2653983aff7da1"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "24d60daf6ab7b2ab0bf424def60709e3013bb8eced3b4a0af9fe60287a82d7cb" => :catalina
    sha256 "ea0ab1838f8acb52d89552c5a8a8c1a8a596f89392a907f21157d5bb2ea96cf6" => :mojave
    sha256 "08f933ed9f847d11c96d67a1aef0eadb81b80e2d283147b8708a9914c55c8e64" => :high_sierra
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
