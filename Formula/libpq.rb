class Libpq < Formula
  desc "Postgres C API library"
  homepage "https://www.postgresql.org/docs/11/static/libpq.html"
  url "http://10.10.4.242:8081/postgresql-12.2.tar.bz2"
  sha256 "ad1dcc4c4fc500786b745635a9e1eba950195ce20b8913f50345bb7d5369b5de"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "64bab543c341a2e26246aa434c8ef27c48985f397996a975751f2c5ea91cd3c3" => :catalina
    sha256 "a5018ed3a4e60e321d1d5d10eb87616243e80c81673b4e59bbff294a24f5cef9" => :mojave
    sha256 "9ac9a6f2272f22ae16855337288b156b70ae327624cdf8ddfb73cabd78fe783f" => :high_sierra
  end

  keg_only "conflicts with postgres formula"

  depends_on "tenantcloud/tenantcloud/openssl@1.1"

  def install
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--with-openssl"
    system "make"
    system "make", "-C", "src/bin", "install"
    system "make", "-C", "src/include", "install"
    system "make", "-C", "src/interfaces", "install"
    system "make", "-C", "doc", "install"
  end

  test do
    (testpath/"libpq.c").write <<~EOS
      #include <stdlib.h>
      #include <stdio.h>
      #include <libpq-fe.h>
      int main()
      {
          const char *conninfo;
          PGconn     *conn;
          conninfo = "dbname = postgres";
          conn = PQconnectdb(conninfo);
          if (PQstatus(conn) != CONNECTION_OK) // This should always fail
          {
              printf("Connection to database attempted and failed");
              PQfinish(conn);
              exit(0);
          }
          return 0;
        }
    EOS
    system ENV.cc, "libpq.c", "-L#{lib}", "-I#{include}", "-lpq", "-o", "libpqtest"
    assert_equal "Connection to database attempted and failed", shell_output("./libpqtest")
  end
end
