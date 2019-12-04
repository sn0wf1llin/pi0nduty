import re
import os


COMMANDS_FILE = "commands.txt"
INTERPRETER_PATTERN = r'^\[\w+\]$'
interpreters_names_path = {
    'shell': '/bin/bash -c',
    'perl': '/usr/bin/perl -e'

}

interpreters_commands = {}
interpreter = None

with open(COMMANDS_FILE, 'r') as f:
    for i, l in enumerate(f.readlines()):
        if re.match(INTERPRETER_PATTERN, l):
            interpreter = l[1:-2]
            interpreters_commands[interpreter] = []
            continue

        if interpreter is not None and interpreter in interpreters_commands.keys():
            interpreters_commands[interpreter].append(l.rstrip())

for interp in interpreters_commands.keys():
    commands = interpreters_commands[interp]
    for command in commands:
        os.system("{} \"{}\" >> results.txt ".format(
            interpreters_names_path[interp], command))
