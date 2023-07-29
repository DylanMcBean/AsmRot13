import os, sys
instruction = 'nasm -f elf64 -o {fn}.o {fn}.asm && ld -m elf_x86_64 -o {fn} {fn}.o && ./{fn} || echo "Exit Code: " $? && rm {fn}.o'

if '-d' in sys.argv: # remove file after build
    instruction += ' && rm {fn}'

os.system(instruction.format(fn=sys.argv[1].split('.')[0]))
