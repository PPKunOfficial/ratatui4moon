// 上游 `canvas/map.rs` 内联测试逐条复刻：strum Display/EnumString 以
// name/from_str 对位；draw_low/draw_high 为 80x40 全幅黄金快照喵。

///|
/// 上游 `map_resolution_to_string` 喵。
test "MapResolution Display" {
  inspect(MapResolution::Low.name(), content="Low")
  inspect(MapResolution::High.name(), content="High")
}

///|
/// 上游 `map_resolution_from_str` 喵。
test "MapResolution EnumString" {
  @debug.assert_eq(MapResolution::from_str("Low"), Some(MapResolution::Low))
  @debug.assert_eq(MapResolution::from_str("High"), Some(MapResolution::High))
  @debug.assert_eq(MapResolution::from_str(""), None)
}

///|
/// 上游 `default` 喵。
test "CanvasMap 缺省为低分辨率 Reset 色" {
  let map = CanvasMap::default()
  @debug.assert_eq(map.resolution, MapResolution::Low)
  @debug.assert_eq(map.color, @core.Reset)
}

///|
/// 上游 `draw_low`：Dot 标记低分辨率世界地图喵。
test "CanvasMap 低分辨率全幅快照" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 80, 40))
  let canvas = Canvas::default()
    .marker(@core.Dot)
    .x_bounds((-180.0, 180.0))
    .y_bounds((-90.0, 90.0))
    .paint(ctx => ctx.draw(CanvasMap::default()))
  canvas.render(buffer.area, buffer)
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "                                                                                ",
      "                               •                                                ",
      "               • •• •••••••• ••   ••••    •••••  ••• ••     •••                 ",
      "             •••••••••••••••       •      ••••      • •   •••••••     •••       ",
      "    • •••• ••••••••••••••• ••     ••  •     •••    ••  ••••    ••  ••••••• •••  ",
      "•••••     •••••••••••• •••• •  ••••••     •••• • ••• •••••                     •",
      "   ••  • •   •••• ••••••••  ••••   ••  • •• •  •••                        •• •••",
      "    •••• •••   •••••• •••••   •       •• ••••••                       • •••••   ",
      "•••••     •••     •  ••   ••         •••••••                          ••  •• •• ",
      "            ••    ••••  •••••          ••       •  • •                ••        ",
      "            •  •    •••••••           •• •••• ••• •• •  ••          • ••        ",
      "            •          ••             ••••••••• • ••             •••• •         ",
      "             ••       ••              • • • •• •                  •••••         ",
      "              ••   •••               •      ••••  •               • •           ",
      "               •  •   ••             •         ••  •• •           •             ",
      "    ••          • •••••••           •           •   •  •   •   •• •             ",
      "                 •••••••••          •           •• •   •  • •• •  ••            ",
      "                    ••  ••          •            •••     •   •••  ••            ",
      "                     •••  • •        •  •         •     ••  •••  •••            ",
      "                      •               •  ••                   • ••              ",
      "                   •  •     •••                • •            •••   •••         ",
      "                                •         •     •              • •    •••       ",
      "  •                                        •    • •                  • • •      ",
      "                       •       •                • •               ••• ••       •",
      "                        •      •          •    • ••              •      •   •   ",
      "                        •    •                   •               •       •      ",
      "                        •   •              •   •                    •           ",
      "                           ••               ••                   ••  ••  •   •  ",
      "                       •  •                                           •••    •• ",
      "                       •  •                                            ••   ••  ",
      "                       • •                                                      ",
      "                       •••••                                                    ",
      "                                                                                ",
      "                          ••                                                    ",
      "                         •••           •       • ••••• • •••• • • •• •• ••      ",
      "            •    • • ••••••        ••••••••• • ••      ••                  •••  ",
      "•    ••• •••• ••••   • •  • ••• • •                                        ••• •",
      "   •• •                •  ••  • ••                                         ••   ",
      "•      •                                                                      • ",
      "                                                                                ",
    ]),
  )
}

///|
/// 上游 `draw_high`：Braille 标记高分辨率世界地图喵。
test "CanvasMap 高分辨率全幅快照" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 80, 40))
  let canvas = Canvas::default()
    .marker(@core.Braille)
    .x_bounds((-180.0, 180.0))
    .y_bounds((-90.0, 90.0))
    .paint(ctx => ctx.draw({ ..CanvasMap::default(), resolution: High }))
  canvas.render(buffer.area, buffer)
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "                                                                                ",
      "                   ⢀⣀⣤⠄⠤⠤⣤⣀⡀⣀⣀⡄⠄⢄⣀⣄⡄⢀⡀                                          ",
      "             ⢀⣀⣤⠰⢤⣼⡯⢽⡟⣀⢶⣺⡛⠁       ⠈⢰⠃⠁    ⢖⣒⣾⡟⠂  ⠈⠛⠁        ⠺⢩⢖⡄                ",
      "            ⡬⢍⣿⣟⣿⣻⣿⣿⣿⡾⣯⡀⠈⠁⠁⢦      ⢀⡿       ⠈       ⢠⢶⠘⠋⡁⣀⢠⠤⠖⠘⠉⠁⠈⠼⡧⡄⣄⡀ ⢫⣗⠒⠆      ",
      "⣓  ⣠⠖⠓⠒⠢⠤⢄⠤⠶⠽⠽⣶⣃⣽⡮⣿⡷⣗⣤⡭⣍⢓⡄ ⠸⣷   ⢀⣀⠿⠇       ⢀⠔⠒⠲⠄⢄⢀⡀⢙⣑⡄⠴⡍⣟⠉          ⠑⠉⠉  ⠑⠐⠦⠤⣤⠤⢞",
      "⠶⢧⣗⢾⡆         ⠈⠈⠁⠈⠉⢀⣹⣶⣩⣽⣐⢮⠃ ⣇ ⢀⡔⠊ ⢰⣖⣲    ⢀⡐⠁⣰⠦ ⢲⣶⠛⠋    ⠐⠋                      ⡤",
      "  ⠉⣮⣀⣀⣴⡤⣠⡀         ⡎ ⠛⢫⠙⢫⢫  ⠈⠦⠼          ⡃⡀⢸⠼⣤⡄                        ⡀⣀⣀⡐⡶⣣⢤⠖⠉",
      "   ⢀⡽⠟⠃  ⠈⠱⡀       ⠙⠢⣀⣨⠆⠈⠁⢧⡀          ⣸⣷ ⢹⣷⣼⣸⠃                       ⢀⡐⢀ ⠁⡚⣨⠆   ",
      "          ⠘⢳⡀        ⠈⠾  ⣀⣀⣽         ⠸⢼⣇⡧⠋⠉⠁                          ⠉⣿  ⠢⠂    ",
      "           ⠈⢻           ⠜⢹⣵⠻⠇         ⠈⢻  ⢀⡀  ⢠⣠⡤ ⢀⢤                  ⢰⣯        ",
      "            ⢼          ⢀⣾⠛⠉          ⠐⡖⠒⡰⢺⣞⣵⡄⢀⣏⡭⣙⡄⢕⢫⡀             ⢀ ⢠⠖⢱⡿⠃       ",
      "            ⠸         ⠠⡎             ⠰⣅⣰⣃⣘⡣⡿⢻⡿⣁⣀  ⠸⣽             ⠐⣿⣽⣫ ⡸⡇        ",
      "             ⠳⣄       ⡰⠃             ⢀⠎⠉  ⢧⡀⣠⣛⠈⢻                  ⢻⠘⢺⡿⠚⠁        ",
      "              ⢻⣇  ⣠⠲⠖⢲⡇              ⡸     ⠉⠃⠈⠉⣿  ⢰⣆              ⢸ ⠈⠁          ",
      "              ⠈⢿⣆ ⡟  ⣘⣻             ⡸          ⢸⢇ ⠈⠯⢿⡒⠲⡀   ⢀⡀    ⣀⢾             ",
      "    ⠈⢳          ⠸⡀⢳⣠⢾⠉⢹⣦⣤⣀          ⡇           ⡿⡄  ⢰⠃ ⠑⡂ ⢠⠏⢣  ⣼⡮⠁⢈⡀            ",
      "                 ⠙⠲⢆⡿⢦⠈⠉⠁⠁          ⡇           ⠱⣇⣀⠼⠃   ⡃⢰⠃ ⠸⢶ ⠘⠄ ⢾⡁            ",
      "                    ⠙⣾⣀⡴⡶⢤⣤         ⢳            ⠻⠵⡆    ⠸⣸   ⢸⡳⡤⠃⢀⡾⣿            ",
      "                     ⠘⢻⠁  ⠈⠦⣄        ⢧⣀⣀⠤⣀        ⢐⠁    ⠈⠩⠆  ⣘⣧⠁ ⡸⡔⢿            ",
      "                      ⡸     ⢨         ⠁  ⠉⡇      ⢀⠎          ⢻⢿⠄⡴⢑⣧⡠⡄           ",
      "                      ⡇     ⠈⠋⠦⡄         ⠈⡆     ⢠⠃            ⢏⡇⢧⣼⣾⣧⣽⣿⠶⢤⡀⣤      ",
      "                      ⣇        ⠈⡇         ⢸     ⢸             ⠈⠶⣦⣄⣋⣁⡀⠸⣵⢠⣻⠋⠷⣄    ",
      "                      ⠰⡀       ⣰⠁         ⢘⠆    ⢸ ⢠⡀              ⠙⠋⢠⠦⡄⣷⠙⠃ ⠙    ",
      "⠄                      ⠣⡀      ⡃          ⢸     ⣸⢡⢾⠆               ⡞⠛⠘⢧⡏⡆   ⠸⠄ ⡤",
      "                        ⠱     ⢠⠃          ⠸⡀   ⢸⠁⢸⢨              ⡤⠚     ⠱⡀  ⢦  ⠁",
      "                        ⠅    ⡖⠉            ⡇   ⡜ ⠸⠔              ⡇       ⢳      ",
      "                        ⡇   ⢀⠃             ⢱⡀ ⢰⠃                 ⣇  ⢀⡀   ⢸      ",
      "                       ⢀⠃  ⡦⠏              ⠈⠷⠖⠃                  ⠾⠴⠊⠁⠹⣦  ⡞    ⣄ ",
      "                       ⢸  ⡤⠃                                          ⠘⢲⠖⠃    ⣽⡆",
      "                       ⢸ ⣸⠁                                            ⠈⠿   ⢀⢼⠏ ",
      "                       ⠞ ⡗                             ⣄                    ⠈⠋  ",
      "                       ⢧⡼⡁⠲⠂                                                    ",
      "                        ⠙⠉                                                      ",
      "                           ⡀                                                    ",
      "                         ⣴⠏⠁                      ⣀⡤⢤⣀⣀  ⢀⣀⣤⣀⣀⡴⣄⡤⢤⣀⠤⠤⠴⣄⣀⡀       ",
      "                 ⣀⣀    ⣠⣿⡍⣆          ⣠⣤⣤⠤⠴⠶⠖⠲⠤⠔⠛⠒⠉   ⠈⠨⣇⠖⠋              ⠈⠉⠓⠢⠤⢄  ",
      "     ⡀ ⣠⠤⠴⠒⠚⠛⠛⠒⠢⠤⠿⠙⠉⠉⠑⢋⣚⣉⠥⠚      ⢀⣀⡠⠟⠁                                      ⡴⠋  ",
      "   ⠐⠶⣛⣫⡤              ⠐⢏⣀⣤⣤ ⣴⣋⢇⢀⣮⡥                                         ⣴⠓   ",
      "⠤⠤⠤⠤⡀⣈⢣⣠⡄                 ⠉⠊⠉⠉⠉                                            ⠈⠓⠆⠤⠤",
      "                                                                                ",
    ]),
  )
}
