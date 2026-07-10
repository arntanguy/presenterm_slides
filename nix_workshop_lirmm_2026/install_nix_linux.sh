if command -v nix >/dev/null 2>&1; then
  echo "Nix is already installed."
else
  # 1. install the right apt package
  sudo apt install -y nix-setup-systemd
  
  # 2. activate the new CLI and flake features
  echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf
  
  # 3. (optional) if you trust us, add our binary caches to avoid recompiling everything
  echo 'extra-substituters = https://gepetto.cachix.org https://attic.iid.ciirc.cvut.cz/ros https://mc-rtc-nix.cachix.org' | sudo tee -a /etc/nix/nix.conf
  echo 'extra-trusted-public-keys = gepetto.cachix.org-1:toswMl31VewC0jGkN6+gOelO2Yom0SOHzPwJMY2XiDY= ros:JR95vUYsShSqfA1VTYoFt1Nz6uXasm5QrcOsGry9f6Q= mc-rtc-nix.cachix.org-1:5M3sLvHXJCep4wc1tQl7QuFWL2eH2I0jkuvWtqJDYQs=' | sudo tee -a /etc/nix/nix.conf
  
  # 4. activate your new nix.conf
  sudo systemctl restart nix-daemon
  
  # 5. allow yourself to use nix
  sudo usermod -aG nix-users $(whoami)
  newgrp nix-users
fi

# 6. test everything is fine
nix run nixpkgs#ponysay Nix works
