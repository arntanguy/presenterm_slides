{
  description = "CHANGEME";

  inputs.mc-rtc-nix.url = "github:mc-rtc/nixpkgs";

  outputs =
    inputs:
    inputs.mc-rtc-nix.lib.mkFlakoboros inputs (
      { ... }:
      let
        makeSlidePackage =
          slideName:
          {
            stdenv,
            presenterm,
            kitty,
            lib,
            ...
          }:
          stdenv.mkDerivation {
            name = slideName;
            version = "1.0.0";
            nativeBuildInputs = [
              presenterm
              kitty
            ];
            src = lib.cleanSource ./.;
            installPhase = ''
              mkdir -p $out/bin $out/share/slides
              cp -r ./${slideName}/* $out/share/slides/
              cat <<EOF > $out/bin/run-slides
              #!/bin/sh
              exec ${kitty}/bin/kitty ${presenterm}/bin/presenterm -x "$out/share/slides/slides.md" "\$@"
              EOF
              chmod +x $out/bin/run-slides
            '';
            meta.mainProgram = "run-slides";
          };
      in
      {
        rosDistros = [ ];
        packages = {
          journee_departement_rob_2026 = makeSlidePackage "journee_departement_rob_2026";
          nix_workshop_lirmm_2026 = makeSlidePackage "nix_workshop_lirmm_2026";
        };
      }
    );
}
