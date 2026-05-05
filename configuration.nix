{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  nixpkgs.overlays = [
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = prev.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    })
  ];

  boot.loader.limine.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.unstable.linuxPackages_xanmod_latest;
  boot.kernelModules = [ "ntsync" ];

  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642; # SteamOS default
  };

  systemd.settings.Manager.DefaultLimitNOFILE = "1048576";
  systemd.user.extraConfig = "DefaultLimitNOFILE=1048576";
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-"; # "-" sets both soft and hard limits
      item = "nofile";
      value = "1048576";
    }
  ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall = {
    allowedTCPPortRanges = [{ from = 1714; to = 1764; }];
    allowedUDPPortRanges = [{ from = 1714; to = 1764; }];
  };
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  systemd.package = pkgs.systemd.override { withUserDb = false; };
  services.userdbd.enable = lib.mkForce false;

  security.rtkit.enable = true; # Realtime priority for audio

  services.pulseaudio.enable = false; # Disable PulseAudio in favor of PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.xserver = {
    enable = true; # Required for X11 layout configuration
    xkb.layout = "us";
    xkb.variant = "altgr-intl";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for Steam/Wine
    extraPackages = [
      pkgs.unstable.lsfg-vk
    ];
  };

  ## NVIDIA
  #services.xserver.videoDrivers = [ "modesetting" "nvidia" ];
  #hardware.nvidia = {
  #  modesetting.enable = true;
  #  open = true;
  #  nvidiaSettings = true;
  #  #Comment these when not using dual gpus on laptops
  #  prime = {
  #   offload.enable = true;
  #    offload.enableOffloadCmd = true; # This creates the `nvidia-offload` script
  #    # Replace these with the corresponding value from the lspci command ```nix-shell -p pciutils --run "lspci"```
  #    #intelBusId = "PCI:0:2:0"; 
  #    amdgpuBusId = "PCI:66:0:0";
  #    nvidiaBusId = "PCI:64:0:0";
  #  };
  #};


  #Power Profiles Daemon
  services.power-profiles-daemon.enable = true;

  ## TUXEDO Drivers (Disable Power Profiles Daemon when using this)
  #hardware.tuxedo-drivers.enable = true;
  #hardware.tuxedo-rs = {
  #  enable = true;
  #  tailor-gui.enable = true;
  #};   

  # GPU Daemon (Overclocking/Fan control)
  services.lact.enable = true;

  time.timeZone = "America/Asuncion";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocales = [ "ja_JP.UTF-8/UTF-8" ];
  };

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.kdeconnect.enable = true;

  users.users.fumo = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = with pkgs; [

    ];
  };

  environment.systemPackages = with pkgs; [
    nixd
    nixpkgs-fmt
    vim
    wget
    git
    file
    sbctl
    dnsmasq
    gnupg
    waypipe
    unstable.brave
    unstable.antigravity-fhs
    _7zz
    unrar
    fastfetch
    thunderbird
    kdePackages.kamoso
    mpv
    appimage-run
    mangohud
    goverlay
    lact
    unstable.lsfg-vk-ui
    ethtool
    pciutils
    mesa-demos
    unstable.renpy
    (pkgs.unstable.heroic.override {
      extraPkgs = p: [
        pkgs.unstable.gamescope
        pkgs.unstable.gamemode
      ];
    })
    unstable.haskellPackages.misfortune
    unstable.cowsay
    unstable.lolcat
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
  };

  programs.firefox.enable = true;

  programs.gamescope.enable = true;
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  services.flatpak.enable = true;
  services.flatpak.packages = [
    "io.gitlab.librewolf-community"
    "org.garudalinux.firedragon"
    "com.usebottles.bottles"
    "org.qbittorrent.qBittorrent"
    "com.github.tchx84.Flatseal"
    "com.discordapp.Discord"
    "com.protonvpn.www"
    "com.stremio.Stremio"
    "com.vysp3r.ProtonPlus"
    "net.retrodeck.retrodeck"
    "org.vinegarhq.Sober"
    "com.obsproject.Studio"
    "website.i2pd.i2pd"
  ];
  # Dynamically linked executables
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [

  ];

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      ipafont
      kochi-substitute
      liberation_ttf
      nerd-fonts.symbols-only
      nerd-fonts.ubuntu-mono
      nerd-fonts.ubuntu
      nerd-fonts.hack
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono

    ];
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true; # TPM support for Windows 11 VMs
        vhostUserPackages = with pkgs; [ virtiofsd ];
      };
    };
    podman = {
      enable = true;
      dockerCompat = true; # Aliases docker -> podman
      defaultNetwork.settings.dns_enabled = true;
    };
  };
  programs.virt-manager.enable = true;
  services.spice-vdagentd.enable = true; # Clipboard sharing with VMs

  documentation.man.generateCaches = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";

}
