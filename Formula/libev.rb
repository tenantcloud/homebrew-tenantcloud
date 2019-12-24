class Libev < Formula
  desc "Asynchronous event library"
  homepage "http://software.schmorp.de/pkg/libev.html"
  url "http://10.10.4.242:8081/libev-4.31.tar.gz"
#  mirror "https://fossies.org/linux/misc/libev-4.24.tar.gz"
  sha256 "ed855d2b52118e32c0c1a6a32bd18c97f9e6711ca511f5ee12de3b9eccc66e5a"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    cellar :any
    sha256 "ed173bfc28e6632e73b3a9aabcc999fff5cc8aab178ae94ae2a5df16f3660cf0" => :mojave
    sha256 "d6ff53dbbeb1f78dc213e04b76c7ec033b32022017eb4eb213b68f9bb91d0da1" => :high_sierra
    sha256 "3170164f0d6e07e06a0cb579696c8074a1167c15350d2e266ba1744a9e905ab0" => :catalina
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make", "install"

    # Remove compatibility header to prevent conflict with libevent
    (include/"event.h").unlink
  end

  test do
    (testpath/"test.c").write <<~'EOS'
      /* Wait for stdin to become readable, then read and echo the first line. */
      #include <stdio.h>
      #include <stdlib.h>
      #include <unistd.h>
      #include <ev.h>
      ev_io stdin_watcher;
      static void stdin_cb (EV_P_ ev_io *watcher, int revents) {
        char *buf;
        size_t nbytes = 255;
        buf = (char *)malloc(nbytes + 1);
        getline(&buf, &nbytes, stdin);
        printf("%s", buf);
        ev_io_stop(EV_A_ watcher);
        ev_break(EV_A_ EVBREAK_ALL);
      }
      int main() {
        ev_io_init(&stdin_watcher, stdin_cb, STDIN_FILENO, EV_READ);
        ev_io_start(EV_DEFAULT, &stdin_watcher);
        ev_run(EV_DEFAULT, 0);
        return 0;
      }
    EOS
    system ENV.cc, "-I#{include}", "-L#{lib}", "-lev", "-o", "test", "test.c"
    input = "hello, world\n"
    assert_equal input, pipe_output("./test", input, 0)
  end
end
