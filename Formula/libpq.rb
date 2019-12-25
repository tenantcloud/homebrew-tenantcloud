class Libpq < Formula
  desc "Postgres C API library"
  homepage "https://www.postgresql.org/docs/11/static/libpq.html"
  url "http://10.10.4.242:8081/postgresql-12.1.tar.bz2"
  sha256 "a09bf3abbaf6763980d0f8acbb943b7629a8b20073de18d867aecdb7988483ed"
  revision 1

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "5afb0e937bf519808dffe071d58222e5fe7f36e93baa14b7bc7728078ca65845" => :mojave
    sha256 "9c530ec6a94fcd63447daed913e38cd58027655d8a97511391e882f2b39cdc1f" => :high_sierra
    sha256 "7091cf8b116e4320adb38a78a7cfe09676db01c6ab20775039352bcc7627cccb" => :catalina
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
