class Jpeg < Formula
  desc "Image manipulation library"
  homepage "https://www.ijg.org/"
  url "http://10.10.4.242:8081/jpegsrc.v9c.tar.gz"
#  mirror "https://dl.bintray.com/homebrew/mirror/jpeg-9c.tar.gz"
#  mirror "https://fossies.org/linux/misc/jpegsrc.v9c.tar.gz"
  sha256 "650250979303a649e21f87b5ccd02672af1ea6954b911342ea491f351ceb7122"

  bottle do
    root_url "http://10.10.4.242:8081/bottles"
    cellar :any
    sha256 "1daa0fc0c197d96dd4e1afddb9ad576951a15aafd6b85138b8a60817d1d8173c" => :mojave
    sha256 "178200fd8aa50d5db22c5faa4ca403652d2bf912616c34dfbc6b035a456c2fc6" => :high_sierra
    sha256 "b94875481e23ee43f98c5d87085e47821a0100e2d79da309c31303f4c933f076" => :catalina
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/djpeg", test_fixtures("test.jpg")
  end
end
