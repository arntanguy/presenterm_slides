{
  description = "CHANGEME";

  inputs.mc-rtc-nix.url = "github:mc-rtc/nixpkgs";

  outputs =
    inputs:
    inputs.mc-rtc-nix.lib.mkFlakoboros inputs (
      { ... }:
      let
        makeSlidePackage =
          slideName: html:
          {
            stdenv,
            presenterm,
            kitty,
            lib,
            buildHtml ? html,
            ...
          }:
          stdenv.mkDerivation {
            name = slideName;
            version = "1.0.0";
            outputs = [ "out" ] ++ lib.optional buildHtml [ "html" ];
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

            ''
            + lib.optionalString buildHtml ''
              mkdir -p $html
              export COLUMNS=120
              export LINES=40
              ${presenterm}/bin/presenterm --export-html -c config.yaml ./${slideName}/slides.md
              cp ./${slideName}/slides.html $html/ || true
            '';
            meta.mainProgram = "run-slides";
          };

        slideNames = [
          "journee_departement_rob_2026"
          "nix_workshop_lirmm_2026"
        ];

        makeBothPackages = slideName: {
          "${slideName}" = makeSlidePackage slideName false;
          "${slideName}_html" = makeSlidePackage slideName true;
        };

        allPackages = builtins.foldl' (acc: slideName: acc // makeBothPackages slideName) { } slideNames;
      in
      {
        rosDistros = [ ];
        packages = allPackages;
      }
    );
}
