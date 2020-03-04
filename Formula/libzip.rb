class Libzip < Formula
  desc "C library for reading, creating, and modifying zip archives"
  homepage "https://libzip.org/"
  url "http://10.10.4.242:8081/libzip-1.6.1.tar.xz"
  sha256 "705dac7a671b3f440181481e607b0908129a9cf1ddfcba75d66436c0e7d33641"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "d0d5f0722e0914fb33a8e1bc72b879577876a4b8ad554b93b50efc0e2436a591" => :catalina
    sha256 "d3e6626651e816fc0f14800669cdd145f7e4a8e6f75f9a689b65d48a68ce4687" => :mojave
    sha256 "2d973dfbb440bf9569f1b5f9c81d6de52c8a41ba2da64c5cfb1b1d5a408235c8" => :high_sierra
  end

  depends_on "tenantcloud/tenantcloud/cmake" => :build

  conflicts_with "libtcod", :because => "both install `zip.h` header"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    touch "file1"
    system "zip", "file1.zip", "file1"
    touch "file2"
    system "zip", "file2.zip", "file1", "file2"
    assert_match /\+.*file2/, shell_output("#{bin}/zipcmp -v file1.zip file2.zip", 1)
  end
end
