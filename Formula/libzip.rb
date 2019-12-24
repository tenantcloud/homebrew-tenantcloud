class Libzip < Formula
  desc "C library for reading, creating, and modifying zip archives"
  homepage "https://libzip.org/"
  url "http://10.10.4.242:8081/libzip-1.5.2.tar.gz"
  sha256 "be694a4abb2ffe5ec02074146757c8b56084dbcebf329123c84b205417435e15"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    sha256 "c3527d9364aaca72f5bbd0486962639b421efcbd7ba7209b8a14a7900e52607b" => :mojave
    sha256 "4ffb9ac04f1fc2c98e5ba902999ed6f4bc5d7d9133d22fc183fd8fa13b7fd9be" => :high_sierra
    sha256 "48097805d906d0c6febd72e06e2ba4c7de3fb98408c98538b98a16bf1e7bc066" => :catalina
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
