class Openssh < Formula
  desc "Farcloser: OpenBSD freely-licensed SSH connectivity tools"
  homepage "https://www.openssh.com/"
  url "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.5p1.tar.gz"
  mirror "https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.5p1.tar.gz"
  version "10.5p1"
  sha256 "d44d28a839ea9daf969cc69150fde59910b2b39361dad81a3bd6cbd19218db11"
  license "SSH-OpenSSH"
  compatibility_version 1

  livecheck do
    url "https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/"
    regex(/href=.*?openssh[._-]v?(\d+(?:\.\d+)+(?:p\d+)?)\.t/i)
  end

  # Please don't resubmit the keychain patch option. It will never be accepted.
  # https://archive.is/hSB6d#10%25

  depends_on "pkgconf" => :build
  depends_on "ldns"
  depends_on "libfido2"

  uses_from_macos "mandoc" => :build
  uses_from_macos "lsof" => :test
  uses_from_macos "libedit"
  uses_from_macos "libxcrypt"

  # Backport for kSBXProfilePureComputation removal
  on_golden_gate :or_newer do
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    patch do
      url "https://github.com/openssh/openssh-portable/commit/d4b4c304a202f5099f2f60be9af9ba266212bb74.patch?full_index=1"
      sha256 "55bd3ca5d1f1ba82279572a357c8d0d72c447668a67fe1d6cf2eee40599c3b2d"
      type :backport
    end
  end

  on_linux do
    depends_on "linux-pam"
    depends_on "zlib-ng-compat"
  end

  resource "com.openssh.sshd.sb" do
    url "https://raw.githubusercontent.com/apple-oss-distributions/OpenSSH/OpenSSH-268.100.4/com.openssh.sshd.sb"
    sha256 "a273f86360ea5da3910cfa4c118be931d10904267605cdd4b2055ced3a829774"
  end

  def install
    ENV.append "CPPFLAGS", "-D__APPLE_SANDBOX_NAMED_EXTERNAL__" if OS.mac?

    # Regenerate configure due to patch
    system "autoreconf", "--force", "--install", "--verbose" if OS.mac? && MacOS.version >= :golden_gate

    args = %W[
      --sysconfdir=#{etc}/ssh
      --with-ldns
      --with-libedit
      --with-pam
      --without-openssl
      --with-security-key-builtin
    ]

    args << "--with-privsep-path=#{var}/lib/sshd" if OS.linux?

    system "./configure", *args, *std_configure_args
    system "make"
    ENV.deparallelize

    ed25519_algos = %w[
      ssh-ed25519-cert-v01@openssh.com
      sk-ssh-ed25519-cert-v01@openssh.com
      ssh-ed25519
      sk-ssh-ed25519@openssh.com
    ].join(",")

    rm "ssh_config"
    touch "ssh_config"
    inreplace "ssh_config", "", "
Host *
  # TODO: challenge these
  Compression no
  ForwardAgent no
  Tunnel no

  # Yubikey and macos integ
  IgnoreUnknown UseKeychain
  UseKeychain yes
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_ed25519_sk

  AddressFamily any
  BatchMode no
  CheckHostIP yes
  ConnectionAttempts 1
  ConnectTimeout 20
  EscapeChar ~
  FingerprintHash sha256
  ForwardX11 no
  ForwardX11Trusted no
  GatewayPorts no
  HashKnownHosts yes
  HostbasedAuthentication no
  KbdInteractiveAuthentication no
  PasswordAuthentication no
  PermitLocalCommand no
  Port 22
  PubkeyAuthentication yes
  StrictHostKeyChecking ask
  CASignatureAlgorithms sk-ssh-ed25519@openssh.com,ssh-ed25519
  HostKeyAlgorithms #{ed25519_algos}
  PubkeyAcceptedAlgorithms #{ed25519_algos}
  KexAlgorithms curve25519-sha256,sntrup761x25519-sha512@openssh.com
  Ciphers aes256-ctr
  MACs hmac-sha2-512-etm@openssh.com
  HostbasedAcceptedAlgorithms #{ed25519_algos}
"

    rm "sshd_config"
    touch "sshd_config"
    inreplace "sshd_config", "", "
AcceptEnv LANG LC_*
AddressFamily any
AllowAgentForwarding no
AllowTcpForwarding no
ClientAliveInterval 300
ClientAliveCountMax 3
Port 22
RekeyLimit 1G 3600
AuthorizedKeysFile	.ssh/authorized_keys
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
GatewayPorts no
HostbasedAuthentication no
IgnoreRhosts yes
IgnoreUserKnownHosts yes
ListenAddress 0.0.0.0
ListenAddress ::
LoginGraceTime 30s
LogLevel INFO
MaxAuthTries 1
MaxSessions 10
MaxStartups 3:100:4
PasswordAuthentication no
PermitEmptyPasswords no
PermitRootLogin no
PermitTunnel no
PermitUserEnvironment no
PrintLastLog no
PrintMotd no
Protocol 2
PubkeyAuthentication yes
AuthorizedKeysCommand none
AuthorizedKeysCommandUser nobody
StrictModes yes
SyslogFacility AUTH
TCPKeepAlive no
UseDNS no
UsePAM yes
X11Forwarding no
X11UseLocalhost yes
PermitTTY yes
VersionAddendum Magnetar/1.0
# Crypto
CASignatureAlgorithms sk-ssh-ed25519@openssh.com,ssh-ed25519
HostKeyAlgorithms #{ed25519_algos}
PubkeyAcceptedAlgorithms #{ed25519_algos}
KexAlgorithms curve25519-sha256,sntrup761x25519-sha512@openssh.com
Ciphers aes256-ctr
MACs hmac-sha2-512-etm@openssh.com
HostbasedAcceptedAlgorithms #{ed25519_algos}
"

    system "make", "install"

    # This was removed by upstream with very little announcement and has
    # potential to break scripts, so recreate it for now.
    # Debian have done the same thing.
    bin.install_symlink bin/"ssh" => "slogin"

    buildpath.install resource("com.openssh.sshd.sb")
    (etc/"ssh").install "com.openssh.sshd.sb" => "org.openssh.sshd.sb"
  end

  test do
    (etc/"ssh").find do |pn|
      next unless pn.file?

      refute_match HOMEBREW_CELLAR.to_s, pn.read
    end

    assert_match "OpenSSH_", shell_output("#{bin}/ssh -V 2>&1")

    port = free_port
    spawn sbin/"sshd", "-D", "-p", port.to_s
    sleep 2
    assert_match "sshd", shell_output("lsof -i :#{port}")
  end
end
