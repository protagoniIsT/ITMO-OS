echo $PWD | grep -q "^$HOME" && echo "$HOME" && exit 0 || echo "Error: Script was not run from home directory." && exit 1
