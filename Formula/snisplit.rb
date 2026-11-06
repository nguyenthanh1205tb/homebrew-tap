class Snisplit < Formula
  desc "Bypass SNI-based DPI blocking by splitting the TLS ClientHello"
  homepage "https://github.com/nguyenthanh1205tb/snisplit"
  url "https://github.com/nguyenthanh1205tb/snisplit/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "ae87e44dc0424ab46554708cedfc174ca8fed4fb93ca915cad93cbae173440d9"
  license "MIT"
  head "https://github.com/nguyenthanh1205tb/snisplit.git", branch: "main"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X main.version=v#{version}")
  end

  service do
    run [opt_bin/"snisplit", "run"]
    keep_alive true
    log_path var/"log/snisplit.log"
    error_log_path var/"log/snisplit.log"
  end

  def caveats
    <<~EOS
      Point the blocked hostnames at the proxy (once):
        sudo #{opt_bin}/snisplit hosts install

      Start now and at every login:
        brew services start snisplit

      Linux only - allow ports 443/80 without root (repeat after upgrades):
        sudo setcap cap_net_bind_service=+ep #{bin}/snisplit
    EOS
  end

  test do
    assert_match "snisplit v#{version}", shell_output("#{bin}/snisplit version")
    assert_match "store.steampowered.com", shell_output("#{bin}/snisplit hosts show --file /dev/null")
  end
end
