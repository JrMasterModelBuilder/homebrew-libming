class LibmingStable < Formula
  desc "SWF output library"
  homepage "https://github.com/libming/libming"
  url "https://github.com/JrMasterModelBuilder/homebrew-libming/releases/download/sources/libming-ming-0_4_8.tar.gz"
  version "0.4.8"
  sha256 "2a44cc8b7f6506adaa990027397b6e0f60ba0e3c1fe8c9514be5eb8e22b2375c"
  license all_of: ["LGPL-2.1-or-later", "GPL-2.0-or-later"]
  revision 1

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "freetype"
  depends_on "giflib"
  depends_on "libpng"
  depends_on "perl"

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build

  # conflicts_with "libming", because: "homebrew version"
  conflicts_with "libming-head", because: "head version"

  def install
    inreplace "perl_ext/perl_swf.h", "#endif /* PERL_SWF_H_INCLUDED */", <<~'EOS'.strip
      void destroySWFBlock(SWFBlock block);
      void SWFTextField_addUTF8Chars(SWFTextField field, const char *string);
      #endif /* PERL_SWF_H_INCLUDED */
    EOS
    ENV.deparallelize if OS.linux?
    system "autoreconf", "-fiv"
    system "./configure",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--prefix=#{prefix}",
      "--enable-perl"
    system "make", "DEBUG=", "install"
    # Homebrew wants different structure than perl make files.
    system "mkdir", "#{prefix}/share"
    system "mv", "#{prefix}/man", "#{prefix}/share"
  end

  test do
    (testpath/"test.as").write <<~'EOS'
      trace("test");
    EOS
    system "#{bin}/makeswf",
      "-o", testpath/"test.swf",
      "-s", "1x1",
      "-r", "30",
      "-v", "5",
      "-c", "-1",
      "-b", "ffffff",
      testpath/"test.as"
    sha256e = "98fd110da0429afc3ec0b9e0ee52bafe47c5995b5bc4691e4f16d3c9ff22f9a5"
    sha256f = Digest::SHA256.hexdigest File.read(testpath/"test.swf")
    assert_equal sha256e, sha256f
  end
end
