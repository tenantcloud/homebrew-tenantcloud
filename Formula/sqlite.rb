class Sqlite < Formula
  desc "Command-line interface for SQLite"
  homepage "https://sqlite.org/"
  url "http://10.10.4.242:8081/sqlite-autoconf-3320100.tar.gz"
  version "3.32.1"
  sha256 "486748abfb16abd8af664e3a5f03b228e5f124682b0c942e157644bf6fff7d10"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "faebdccaba17c8d4579a7f72cc1d1874fdd63b8a8d1d21d7c5a2c9585cc59cfa" => :catalina
    sha256 "22e0a663417031dff9bf37b6aa68823c340b8ff688ce1c6c878db4cf5b544d74" => :mojave
    sha256 "72c88000e2cc79db19cb130e031212114c4438729ef3986b0c4e222cbbcf3dbb" => :high_sierra
  end

  keg_only :provided_by_macos, "macOS provides an older sqlite3"

  depends_on "tenantcloud/tenantcloud/readline"

  def install
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_COLUMN_METADATA=1"
    # Default value of MAX_VARIABLE_NUMBER is 999 which is too low for many
    # applications. Set to 250000 (Same value used in Debian and Ubuntu).
    ENV.append "CPPFLAGS", "-DSQLITE_MAX_VARIABLE_NUMBER=250000"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_RTREE=1"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_FTS3=1 -DSQLITE_ENABLE_FTS3_PARENTHESIS=1"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_JSON1=1"

    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --enable-dynamic-extensions
      --enable-readline
      --disable-editline
      --enable-session
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    path = testpath/"school.sql"
    path.write <<~EOS
      create table students (name text, age integer);
      insert into students (name, age) values ('Bob', 14);
      insert into students (name, age) values ('Sue', 12);
      insert into students (name, age) values ('Tim', 13);
      select name from students order by age asc;
    EOS

    names = shell_output("#{bin}/sqlite3 < #{path}").strip.split("\n")
    assert_equal %w[Sue Tim Bob], names
  end
end
