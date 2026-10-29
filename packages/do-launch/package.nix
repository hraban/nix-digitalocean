{ doctl, writeShellApplication }:

writeShellApplication {
  name = "do-launch";
  runtimeInputs = [ doctl ];
  text = builtins.readFile ./do-launch.sh;
}
