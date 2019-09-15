class Retro68 < Formula
  desc "GCC-based cross-compiler for classic 68K and PPC Macintoshes"
  homepage "https://github.com/easybe/Retro68/"
  url "https://github.com/easybe/Retro68/archive/v2019.9.1.tar.gz"
  sha256 "b749a56cbe77deaf0f0a1c89d37adb92ae839a5e702a17d7bad93fbd04a693aa"

  bottle do
    root_url "https://github.com/easybe/homebrew-retro68/releases/download/v2019.9.1"
    cellar :any_skip_relocation
    sha256 "ad51d12d628d91a2512f2f52d9fbc69d3e15306475ffae279ade9f967fef19a5" => :high_sierra
    sha256 "c277393ba1aafc926ee8f5a9ce90fc65e6a47ac9d9c6e55d7aa6727b4a81b84d" => :mojave
  end

  MPW_URL = "https://staticky.com/mirrors/ftp.apple.com/developer/Tool_Chest/Core_Mac_OS_Tools/MPW_etc./MPW-GM_Images/MPW-GM.img.bin"

  depends_on "bison"
  depends_on "boost"
  depends_on "cmake"
  depends_on "gmp"
  depends_on "libmpc"

  def install
    mkdir "build" do
      system "../interfaces-and-libraries.sh", "download",
             "../InterfacesAndLibraries", Retro68::MPW_URL
      system "../build-toolchain.bash", "--prefix=#{prefix}"
      # Apple's interfaces and libraries may not be redistributed and therefore
      # cannot be part of the bottle.
      system "../interfaces-and-libraries.sh", "remove", prefix
    end
  end

  test do
    system "#{prefix}/libexec/retro68/interfaces-and-libraries.sh", "install",
           prefix, MPW_URL
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
      "#{prefix}/powerpc-apple-macos/cmake/retrocarbon.toolchain.cmake",
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
