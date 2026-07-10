cask "captureimage" do
  version "0.1.0"
  sha256 "612f0702a7b372a3619180910b9ee5143a57284d6d41a765fb3c587a7c1cea2f"

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
