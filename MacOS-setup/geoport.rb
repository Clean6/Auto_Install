cask "geoport" do
    version "4.0.2"
    sha256 :no_check

    url "https://github.com/davesc63/GeoPort.git",
        tag:      "v#{version}",
        revision: "HEAD"

    name "GeoPort"
    desc "GeoPort application"
    homepage "https://github.com/davesc63/GeoPort"

    depends_on formula: "cmake"
    depends_on formula: "qt"
    depends_on formula: "boost"
    depends_on macos: ">= :catalina"

    def install
        system "cmake", ".", *std_cmake_args
        system "make"
        prefix.install "GeoPort.app"
    end

    app "GeoPort.app"

    zap trash: [
        "~/Library/Application Support/GeoPort",
        "~/Library/Preferences/com.geoport.app.plist",
        "~/Library/Saved Application State/com.geoport.app.savedState"
    ]
end