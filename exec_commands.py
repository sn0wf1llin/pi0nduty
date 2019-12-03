import re


COMMANDS_FILE = "commands.txt"
INTERPRETER_PATTERN = r'^\[\w+\]$'

interpreters_commands = {}
interpreter = None

with open(COMMANDS_FILE, 'r') as f:
    for i, l in enumerate(f.readlines()):
        if interpreter is not None and interpreter in interpreters_commands.keys():
            interpreters_commands[interpreter].append(l.rstrip())

        if re.match(INTERPRETER_PATTERN, l):
            interpreter = l[1:-2]
            interpreters_commands[interpreter] = []
for k, v in interpreters_commands.items():
    print("{}:{}".format(k, v))
