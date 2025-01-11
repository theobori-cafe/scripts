{
  lib,
  stdenv,
  makeWrapper,
  goaccess,
  mariadb,
  postgresql,
  python3,
  python3Packages,
  md2gemini,
}:
stdenv.mkDerivation {
  pname = "scripts";
  version = "0.0.1";

  src = ./.;

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    # Installing the bash scripts
    PREFIX_DIR=$out make install

    # Installing the python script (markdown-convert)
    install -Dm 755 markdown-convert/convert.py $out/bin/convert

    runHook postInstall
  '';

  postFixup = ''
    # Making wrapper to target only the needed scripts by dependencies
    makeWrapper "$out/bin/report-range.sh" "$out/bin/report-range" \
      --prefix PATH : ${lib.makeBinPath [ goaccess ]}

    makeWrapper "$out/bin/backup-docker-db.sh" "$out/bin/backup-docker-db" \
      --prefix PATH : ${
        lib.makeBinPath [
          mariadb
          postgresql
        ]
      }

    wrapProgram "$out/bin/convert" \
      --prefix PATH : ${lib.makeBinPath [ python3 ]} \
      --prefix PYTHONPATH : "${python3Packages.beautifulsoup4}/${python3.sitePackages}" \
      --prefix PYTHONPATH : "${python3Packages.mistune}/${python3.sitePackages}" \
      --prefix PYTHONPATH : "${md2gemini}/lib/python3.10/site-packages"
  '';

  meta = {
    description = "Automations I use within my infrastructure";
    homepage = "https://github.com/theobori-cafe/scripts";
    license = lib.licenses.mit;
  };
}
