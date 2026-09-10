local disabled_bindings = {
  "SUPER + RETURN",
  "SUPER + SHIFT + ALT + B",
  "SUPER + SHIFT + N",
  "SUPER + SHIFT + D",
  "SUPER + SHIFT + G",
  "SUPER + SHIFT + W",
  "SUPER + SHIFT + SLASH",
  "SUPER + SHIFT + A",
  "SUPER + SHIFT + ALT + A",
  "SUPER + SHIFT + C",
  "SUPER + SHIFT + Y",
  "SUPER + SHIFT + ALT + G",
  "SUPER + SHIFT + CTRL + G",
  "SUPER + SHIFT + X",
  "SUPER + SHIFT + ALT + X",
  "CTRL + ALT + DELETE",
  "SUPER + CTRL + F",
  "SUPER + ALT + F",
  "SUPER + S",
  "SUPER + ALT + S",
  "SUPER + TAB",
  "SUPER + SHIFT + TAB",
  "SUPER + CTRL + TAB",
  "ALT + TAB",
  "ALT + SHIFT + TAB",
  "SUPER + mouse_down",
  "SUPER + mouse_up",
  "SUPER + G",
  "SUPER + ALT + G",
  "SUPER + ALT + LEFT",
  "SUPER + ALT + RIGHT",
  "SUPER + ALT + UP",
  "SUPER + ALT + DOWN",
  "SUPER + ALT + TAB",
  "SUPER + ALT + SHIFT + TAB",
  "SUPER + ALT + mouse_down",
  "SUPER + ALT + mouse_up",
  "SUPER + ALT + 1",
  "SUPER + ALT + 2",
  "SUPER + ALT + 3",
  "SUPER + ALT + 4",
  "SUPER + ALT + 5",
  "SUPER + CTRL + SPACE",
  "SUPER + SHIFT + CTRL + SPACE",
  "SUPER + BACKSPACE",
  "SUPER + SHIFT + BACKSPACE",
  "SUPER + comma",
  "SUPER + SHIFT + comma",
  "SUPER + CTRL + I",
  "SUPER + CTRL + N",
  "CTRL + F1",
  "CTRL + F2",
  "SHIFT + CTRL + F2",
  "SHIFT + PRINT",
  "SUPER + CTRL + T",
  "SUPER + CTRL + B",
  "SUPER + SHIFT + E",
  "SUPER + SHIFT + P",
  "SUPER + L",
}

for _, keys in ipairs(disabled_bindings) do
  hl.unbind(keys)
end

o.bind("SUPER + SHIFT + T", "Terminal", { omarchy = "terminal" })
o.bind("SUPER + SHIFT + F", "File manager", { omarchy = "nautilus" })
o.bind("SUPER + SHIFT + B", "Browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + E", "Editor", { omarchy = "editor" })
o.bind("SUPER + SHIFT + P", "Activity", { tui = "btop" })
o.bind("SUPER + L", "Lock screen", "omarchy system lock")
o.bind("SUPER + SHIFT + ESCAPE", "Shutdown", "omarchy system shutdown")
o.bind("mouse:276", nil, "omarchy audio output volume raise")
o.bind("mouse:275", nil, "omarchy audio output volume lower")
