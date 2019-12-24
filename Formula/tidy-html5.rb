class TidyHtml5 < Formula
  desc "Granddaddy of HTML tools, with support for modern standards"
  homepage "https://www.html-tidy.org/"
  url "http://10.10.4.242:8081/tidy-html5-5.6.0.tar.gz"
  sha256 "08a63bba3d9e7618d1570b4ecd6a7daa83c8e18a41c82455b6308bc11fe34958"
  head "https://github.com/htacg/tidy-html5.git", :branch => "next"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    cellar :any
    sha256 "bd3ca7dc82a913c8576716cbcc957260251132f6dd7b8c526c9ef0c4674faf0f" => :mojave
    sha256 "af9633f1578980fe3d4351c3d71b4b83cc79f814d87310e4b7d05830c53c9621" => :high_sierra
    sha256 "fb2134180fbdb92cc10f3fad33c769073adceb7796e465db7dbc3778f7d3547a" => :catalina
  end

  depends_on "tenantcloud/tenantcloud/cmake" => :build

  def install
    cd "build/cmake"
    system "cmake", "../..", *std_cmake_args
    system "make"
    system "make", "install"
  end

  test do
    output = pipe_output(bin/"tidy -q", "<!doctype html><title></title>")
    assert_match /^<!DOCTYPE html>/, output
    assert_match /HTML Tidy for HTML5/, output
  end
end
