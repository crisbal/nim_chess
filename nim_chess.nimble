# Package

version       = "0.1.0"
author        = "Cristian Baldi"
description   = "Chess library for Nim"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["nim_chess", "chess_engine"]


# Dependencies

requires "nim >= 1.4.2"
