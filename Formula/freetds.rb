class Freetds < Formula
  desc "Libraries to talk to Microsoft SQL Server and Sybase databases"
  homepage "http://www.freetds.org/"
  url "http://10.10.4.242:8081/freetds-1.1.36.tar.gz"
  sha256 "1c306e658e10a325eefddfd662cec3a6d9065fe61c515f26d4f1fb6c4c62405d"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "a3e22cf599c870153f33d225e8839078c6c2c759e98f620541aa671f7cdcff89" => :catalina
    sha256 "395b46028182ffba1cf5975272551c440ba6398c1a6c32c6a24eda83105fb612" => :mojave
    sha256 "6df1c0993d1d06beffb798e39382ceb8f820ced333a4dcaf9925d3712d1b56f7" => :high_sierra
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
