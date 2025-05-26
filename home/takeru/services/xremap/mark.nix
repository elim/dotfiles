{
  default_mode = "mark_unset";

  setMark = [
    { set_mark = true; }
    { set_mode = "mark_set"; }
  ];

  unsetMark = [
    { set_mark = false; }
    { set_mode = "mark_unset"; }
  ];
}
