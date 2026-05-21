{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  home.username = "fumo";
  home.homeDirectory = "/home/fumo";
  home.stateVersion = "25.11";

  programs.ssh = {
  enable = true;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/fumossh.key"; # Automatically routes this key for GitHub
      };
    };
  };

  programs.git = {
    enable = true;
    signing = {
      key = "35FAC098F119E8FA";
      signByDefault = true;
    };
    settings = {
      user = {
        name = "JuanU";
        email = "juanu@fumoctl.com";
      };
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "dpoggi";
      plugins = [ "git" "sudo" ];
    };
  };

  programs.plasma = {
    enable = true;
    workspace.lookAndFeel = "org.kde.breezedark.desktop";
    panels = [
      {
        location = "bottom";
        floating = true;
        height = 32;
        widgets = [
          {
            kickoff = {
              icon = "nix-snowflake-white";
              sortAlphabetically = true;
            };
          }
          "org.kde.plasma.icontasks"
          "org.kde.plasma.marginsseparator"
          {
            pager = { };
          }
          "org.kde.plasma.systemtray"
          {
            digitalClock = {
              time.format = "24h";
              calendar.firstDayOfWeek = "monday";
            };
          }
          "org.kde.plasma.showdesktop"
        ];
      }
    ];



    shortcuts = {

      kwin."Switch to Desktop 1" = "Meta+1";
      kwin."Switch to Desktop 2" = "Meta+2";
      kwin."Switch to Desktop 3" = "Meta+3";
      kwin."Switch to Desktop 4" = "Meta+4";
      kwin."Switch to Desktop 5" = "Meta+5";
      kwin."Switch to Desktop 6" = "Meta+6";
      kwin."Switch to Desktop 7" = "Meta+7";
      kwin."Switch to Desktop 8" = "Meta+8";
      kwin."Switch to Desktop 9" = "Meta+9";

      kwin."Window to Desktop 1" = "Meta+!";
      kwin."Window to Desktop 2" = "Meta+@";
      kwin."Window to Desktop 3" = "Meta+#";
      kwin."Window to Desktop 4" = "Meta+$";
      kwin."Window to Desktop 5" = "Meta+%";
      kwin."Window to Desktop 6" = "Meta+^";
      kwin."Window to Desktop 7" = "Meta+&";
      kwin."Window to Desktop 8" = "Meta+*";
      kwin."Window to Desktop 9" = "Meta+(";

      "services/brave-browser.desktop"._launch = "Meta+B";
      "services/org.kde.konsole.desktop"._launch = [ "Meta+Return" "Meta+T" ];


    };
    spectacle.shortcuts = {
      captureEntireDesktop = "Meta+Print";
      captureRectangularRegion = "Meta+Shift+Print";
      captureActiveWindow = "Meta+Ctrl+Print";
    };

    configFile = {
      kwinrc.Desktops.Number = 4;
      kwinrc.Desktops.Rows = 1;
    };
  };
}
