# Config Alias

Override `exec` command to support alias

## Configuration

The config file is located at `addons/sourcemod/configs/configalias.txt`.

Each line in config file will be read as pair of alias and cfg file path.

Example
```
alias = server
```
When `exec alias` is called, `server.cfg` file will be executed.

Blank lines or lines with `#` will be ignored.