class Brotli < Formula
  desc "Generic-purpose lossless compression algorithm by Google"
  homepage "https://github.com/google/brotli"
  url "http://10.10.4.242:8081/brotli-v1.0.7.tar.gz"
  sha256 "4c61bfb0faca87219ea587326c467b95acb25555b53d1a421ffa3c8a9296ee2c"
  head "https://github.com/google/brotli.git"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    cellar :any
    sha256 "d2d4f821f8d9c52de15a4d3b5ddeab760ad9ae71105f1c859b7811adff9af9da" => :mojave
    sha256 "700e223c43dff6781343568d3b0838c3ae66381307293c40312c1941b74fb9c6" => :high_sierra
    sha256 "81be7d1d110787a534cd57cc1ec6bb5032d81e3928d9103ce1e654560c6848ca" => :catalina
  end

  depends_on "tenantcloud/tenantcloud/cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "VERBOSE=1"
    system "ctest", "-V"
    system "make", "install"
  end

  test do
    (testpath/"file.txt").write("Hello, World!")
    system "#{bin}/brotli", "file.txt", "file.txt.br"
    system "#{bin}/brotli", "file.txt.br", "--output=out.txt", "--decompress"
    assert_equal (testpath/"file.txt").read, (testpath/"out.txt").read
  end
end
