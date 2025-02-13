-- initialize starship prompt
load(io.popen("starship init cmd"):read("*a"))()
