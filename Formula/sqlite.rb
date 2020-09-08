class Sqlite < Formula
  desc "Command-line interface for SQLite"
  homepage "https://sqlite.org/"
  url "http://10.10.4.242:8081/sqlite-autoconf-3320300.tar.gz"
  version "3.33.0"
  sha256 "106a2c48c7f75a298a7557bcc0d5f4f454e5b43811cc738b7ca294d6956bbb15"
  license "blessing"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "78566572373e0010a52729c1b41f7503f4e86acc67e7a37bafe091a6ddc36147" => :catalina
    sha256 "0d4a34731923310528f3ca79418eb7149cf12eda3b3043e5ba11b040ca5f602f" => :mojave
    sha256 "9fd2f150b96a7ca378f84e09a2715c7a87c1b95a3a3a241a25f57d22ab0be781" => :high_sierra
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
