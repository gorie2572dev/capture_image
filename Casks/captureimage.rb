cask "captureimage" do
  version "0.1.0"
  sha256 :no_check

  url "https://github.com/gorie2572dev/capture_image/releases/download/v#{version}/CaptureImage-#{version}.zip",
      verified: "github.com/gorie2572dev/capture_image/"
  name "CaptureImage"
  desc "Native macOS area screenshot utility"
  homepage "https://github.com/gorie2572dev/capture_image"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "CaptureImage.app"

  caveats <<~EOS
    CaptureImage needs Screen Recording permission. Enable it in:
      System Settings > Privacy & Security > Screen Recording
  EOS
end
