class Retro68 < Formula
  desc "GCC-based cross-compiler for classic 68K and PPC Macintoshes"
  homepage "https://github.com/easybe/Retro68/"
  url "https://github.com/easybe/Retro68/archive/v2019.10.0.tar.gz"
  sha256 "5d07174973eab58659697515beefced86b9955390cfddd0e0636ecec7f88b633"

  depends_on "bison"
  depends_on "boost"
  depends_on "cmake"
  depends_on "gmp"
  depends_on "libmpc"

  resource "multiversal" do
    url "https://github.com/easybe/multiversal/archive/v2019.10.0.tar.gz"
    sha256 "fd61ceba2679f4d15cf5009e8fe95ed70a31f02e4bcf37930ee7d4e0"
  end

  def install
    Pathname.new("multiversal").install resource("multiversal")
    mkdir "build" do
      system "../build-toolchain.bash", "--prefix=#{prefix} --no-carbon"
    end
  end

  test do
    (testpath/"CMakeLists.txt").write "add_application(Test test.c CONSOLE)"
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      int main(int argc, char** argv)
      {
        printf("Hello");
        return 0;
      }
    EOS
    cmake_files = [
      "#{prefix}/m68k-apple-macos/cmake/retro68.toolchain.cmake",
      #"#{prefix}/powerpc-apple-macos/cmake/retrocarbon.toolchain.cmake",
      "#{prefix}/powerpc-apple-macos/cmake/retroppc.toolchain.cmake",
    ]
    cmake_files.each do |cmake_file|
      mkdir "build" do
        ENV["CFLAGS"] = nil
        ENV["CPATH"] = nil
        ENV["CPPFLAGS"] = nil
        ENV["CXXFLAGS"] = nil
        ENV["LDFLAGS"] = nil
        system "cmake", "..", "-DCMAKE_TOOLCHAIN_FILE=#{cmake_file}"
        system "make"
      end
      rm_rf "build"
    end
  end
end
