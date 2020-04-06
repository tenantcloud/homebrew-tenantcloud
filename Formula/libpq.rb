class Libpq < Formula
  desc "Postgres C API library"
  homepage "https://www.postgresql.org/docs/11/static/libpq.html"
  url "http://10.10.4.242:8081/postgresql-12.2.tar.bz2"
  sha256 "ad1dcc4c4fc500786b745635a9e1eba950195ce20b8913f50345bb7d5369b5de"
  revision 1

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "e10afccf526ca2d5af34b944914f2ff5495bcd7c8e1d8873ab25a10047c97e1c" => :catalina
    sha256 "e40e3c169e1e15092bab376299462086b6e556f10b1d01489c4aff4da39cf1d4" => :mojave
    sha256 "098b42897291d8c553a2851d89f54fbcbde7daeb6a0cf93b901fce166960c338" => :high_sierra
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
