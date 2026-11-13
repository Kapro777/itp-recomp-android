"""Intake do dump do ITP: extrai o pacote, lista os módulos do ExeFS e roda o censo de cada um.

Uso: python tools/intake.py <pasta com o .nsp/.xci e o prod.keys> [--out extracted]

Faz, em ordem:
  1. tools/nca_extract.py  -> <out>/exefs/*  (os NSOs) e <out>/romfs.bin
  2. tools/nso.py          -> informação de cada módulo (seções, símbolos, relocações)
  3. tools/analyze.py     -> censo de cada módulo (funções, imports, nvn*, SVCs, atômicos)

Escreve <out>/intake-report.txt. Nenhum arquivo do jogo sai daqui: tudo fica em <out>, que é
ignorado pelo git.
"""
import argparse
import glob
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOOLS = os.path.join(ROOT, 'tools')


def run(cmd, log):
    log.write('$ ' + ' '.join(cmd) + '\n')
    p = subprocess.run(cmd, cwd=TOOLS, capture_output=True, text=True)
    log.write(p.stdout)
    if p.stderr:
        log.write(p.stderr)
    log.write('\n')
    return p


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('folder', help='pasta com o .nsp/.xci e o prod.keys')
    ap.add_argument('--out', default=os.path.join(ROOT, 'extracted'))
    args = ap.parse_args()

    folder = os.path.abspath(args.folder)
    out = os.path.abspath(args.out)

    games = []
    for ext in ('*.nsp', '*.xci', '*.nsz', '*.xcz'):
        games += glob.glob(os.path.join(folder, ext))
    keys = [p for p in glob.glob(os.path.join(folder, '*.keys'))]

    if not games:
        print('nenhum .nsp/.xci encontrado em', folder)
        return 1
    if not keys:
        print('nenhum .keys encontrado em', folder)
        return 1

    os.makedirs(out, exist_ok=True)
    report = os.path.join(out, 'intake-report.txt')
    with open(report, 'w', encoding='utf-8') as log:
        log.write('ITPRecomp - intake do dump\n')
        log.write(f'pasta: {folder}\n')
        log.write(f'jogo:  {os.path.basename(games[0])}\n')
        log.write(f'chaves: {os.path.basename(keys[0])}\n\n')

        p = run([sys.executable, '-I', 'nca_extract.py', keys[0], games[0], out,
                 '--no-romfs', '--romfs-image'], log)
        if p.returncode != 0:
            log.write('!! a extracao falhou\n')

        exefs = os.path.join(out, 'exefs')
        mods = sorted(glob.glob(os.path.join(exefs, '*')))
        log.write(f'módulos no ExeFS: {len(mods)}\n')
        for m in mods:
            name = os.path.basename(m)
            size = os.path.getsize(m)
            log.write(f'  {name:12s} {size:>12,} bytes\n')
            run([sys.executable, '-I', 'nso.py', m], log)
            run([sys.executable, '-I', 'analyze.py', m, '--census'], log)

    print('relatorio:', report)
    print('modulos:', len(glob.glob(os.path.join(out, 'exefs', '*'))))
    return 0


if __name__ == '__main__':
    sys.exit(main())
