{
  coreutils,
  doctl,
  writeShellApplication,
}:
writeShellApplication {
  name = "do-upload-image";
  meta.description = "Upload an image from an env-defined URL to Digitalocean";
  runtimeInputs = [ doctl ];
  text = ''
    # shellcheck disable=SC1090
    doctl compute image create "$DO_IMAGE_SLUG-$(${coreutils}/bin/date -u "+%Y%m%dT%H%MZ")" \
          --image-url "$DO_IMAGE_URL" \
          --tag-names nixos \
          --region "$DO_REGION"
  '';
}
