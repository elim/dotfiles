self: super: {
  libinput = super.libinput.overrideAttrs (o: {
    mesonFlags = o.mesonFlags ++ [
      "--sysconfdir=/etc"
    ];
  });
}
