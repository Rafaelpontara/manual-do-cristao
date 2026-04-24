#!/usr/bin/env python3
"""
Download da Bíblia completa — Manual do Cristão
Fonte: bible-api.com (tradução Almeida — domínio público, PT-BR)
Endpoint: https://bible-api.com/data/almeida/BOOK_ID/CHAPTER

Execute: python download_bible.py
O arquivo gerado vai para: assets/bible/acf.json
"""

import json, time, os, urllib.request

OUTPUT = "assets/bible/acf.json"

# Todos os 66 livros: (abbrev_app, book_id_api, nome, capitulos)
BOOKS = [
    ("gn",  "GEN", "Gênesis",           50),
    ("ex",  "EXO", "Êxodo",             40),
    ("lv",  "LEV", "Levítico",          27),
    ("nm",  "NUM", "Números",           36),
    ("dt",  "DEU", "Deuteronômio",      34),
    ("js",  "JOS", "Josué",             24),
    ("jz",  "JDG", "Juízes",            21),
    ("rt",  "RUT", "Rute",               4),
    ("1sm", "1SA", "1 Samuel",          31),
    ("2sm", "2SA", "2 Samuel",          24),
    ("1rs", "1KI", "1 Reis",            22),
    ("2rs", "2KI", "2 Reis",            25),
    ("1cr", "1CH", "1 Crônicas",        29),
    ("2cr", "2CH", "2 Crônicas",        36),
    ("ed",  "EZR", "Esdras",            10),
    ("ne",  "NEH", "Neemias",           13),
    ("et",  "EST", "Ester",             10),
    ("jo",  "JOB", "Jó",               42),
    ("sl",  "PSA", "Salmos",           150),
    ("pv",  "PRO", "Provérbios",        31),
    ("ec",  "ECC", "Eclesiastes",       12),
    ("ct",  "SNG", "Cânticos",           8),
    ("is",  "ISA", "Isaías",            66),
    ("jr",  "JER", "Jeremias",          52),
    ("lm",  "LAM", "Lamentações",        5),
    ("ez",  "EZK", "Ezequiel",          48),
    ("dn",  "DAN", "Daniel",            12),
    ("os",  "HOS", "Oséias",            14),
    ("jl",  "JOL", "Joel",               3),
    ("am",  "AMO", "Amós",               9),
    ("ob",  "OBA", "Obadias",            1),
    ("jn",  "JON", "Jonas",              4),
    ("mq",  "MIC", "Miquéias",           7),
    ("na",  "NAM", "Naum",               3),
    ("hc",  "HAB", "Habacuque",          3),
    ("sf",  "ZEP", "Sofonias",           3),
    ("ag",  "HAG", "Ageu",               2),
    ("zc",  "ZEC", "Zacarias",          14),
    ("ml",  "MAL", "Malaquias",          4),
    ("mt",  "MAT", "Mateus",            28),
    ("mc",  "MRK", "Marcos",            16),
    ("lc",  "LUK", "Lucas",             24),
    ("jo2", "JHN", "João",              21),
    ("at",  "ACT", "Atos",              28),
    ("rm",  "ROM", "Romanos",           16),
    ("1co", "1CO", "1 Coríntios",       16),
    ("2co", "2CO", "2 Coríntios",       13),
    ("gl",  "GAL", "Gálatas",            6),
    ("ef",  "EPH", "Efésios",            6),
    ("fp",  "PHP", "Filipenses",         4),
    ("cl",  "COL", "Colossenses",        4),
    ("1ts", "1TH", "1 Tessalonicenses",  5),
    ("2ts", "2TH", "2 Tessalonicenses",  3),
    ("1tm", "1TI", "1 Timóteo",          6),
    ("2tm", "2TI", "2 Timóteo",          4),
    ("tt",  "TIT", "Tito",               3),
    ("fm",  "PHM", "Filemom",            1),
    ("hb",  "HEB", "Hebreus",           13),
    ("tg",  "JAS", "Tiago",              5),
    ("1pe", "1PE", "1 Pedro",            5),
    ("2pe", "2PE", "2 Pedro",            3),
    ("1jo", "1JN", "1 João",             5),
    ("2jo", "2JN", "2 João",             1),
    ("3jo", "3JN", "3 João",             1),
    ("jd",  "JUD", "Judas",              1),
    ("ap",  "REV", "Apocalipse",        22),
]

BASE_URL = "https://bible-api.com/data/almeida"

def fetch_chapter(book_api_id, chapter, retries=5):
    url = f"{BASE_URL}/{book_api_id}/{chapter}"
    for attempt in range(retries):
        try:
            req = urllib.request.Request(
                url,
                headers={"User-Agent": "Mozilla/5.0", "Accept": "application/json"}
            )
            with urllib.request.urlopen(req, timeout=15) as r:
                data = json.loads(r.read().decode("utf-8"))
                verses = data.get("verses", [])
                # Limpa espaços extras que a API inclui
                return [v.get("text", "").strip() for v in verses]
        except Exception as e:
            err = str(e)
            if '429' in err:
                # Rate limit — aguarda mais tempo
                wait = 5 * (attempt + 1)
                print(f" [429 aguardando {wait}s]", end="", flush=True)
                time.sleep(wait)
            elif attempt < retries - 1:
                time.sleep(3 ** attempt)
            else:
                print(f" [FALHOU: {e}]", end="")
    return []

def main():
    print("=" * 55)
    print("  Download da Biblia — bible-api.com (Almeida PT-BR)")
    print("=" * 55)
    print(f"  Destino: {OUTPUT}")
    print(f"  Livros:  {len(BOOKS)}")
    print()

    # Verifica se já existe progresso salvo (retomar download interrompido)
    biblia = []
    start_idx = 0
    progress_file = OUTPUT + ".progress"

    if os.path.exists(progress_file):
        try:
            with open(progress_file, "r", encoding="utf-8") as f:
                biblia = json.load(f)
            start_idx = len(biblia)
            print(f"Retomando de onde parou: {start_idx}/{len(BOOKS)} livros já baixados")
        except:
            biblia = []
            start_idx = 0

    total_books = len(BOOKS)

    for idx in range(start_idx, total_books):
        abbrev, api_id, name, num_caps = BOOKS[idx]
        print(f"[{idx+1:02d}/{total_books}] {name:<22} ", end="", flush=True)

        book_data = {"abbrev": abbrev, "chapters": []}
        failed = 0

        for cap in range(1, num_caps + 1):
            verses = fetch_chapter(api_id, cap)
            if verses:
                book_data["chapters"].append(verses)
                print(".", end="", flush=True)
            else:
                book_data["chapters"].append([])
                failed += 1
                print("x", end="", flush=True)
            time.sleep(1.2)  # respeita rate limit da API

        biblia.append(book_data)
        total_v = sum(len(c) for c in book_data["chapters"])

        if failed == 0:
            print(f" OK ({total_v}v)")
        else:
            print(f" {failed} caps falharam ({total_v}v)")

        # Salva progresso a cada livro (permite retomar se interromper)
        os.makedirs(os.path.dirname(OUTPUT) if os.path.dirname(OUTPUT) else ".", exist_ok=True)
        with open(progress_file, "w", encoding="utf-8") as f:
            json.dump(biblia, f, ensure_ascii=False)

    # Salva arquivo final
    os.makedirs(os.path.dirname(OUTPUT) if os.path.dirname(OUTPUT) else ".", exist_ok=True)
    with open(OUTPUT, "w", encoding="utf-8") as f:
        json.dump(biblia, f, ensure_ascii=False, separators=(",", ":"))

    # Remove arquivo de progresso
    if os.path.exists(progress_file):
        os.remove(progress_file)

    size_kb = os.path.getsize(OUTPUT) / 1024
    total_v = sum(len(c) for b in biblia for c in b["chapters"])
    total_caps = sum(len(b["chapters"]) for b in biblia)

    print()
    print("=" * 55)
    print(f"  Biblia salva em: {OUTPUT}")
    print(f"  {len(biblia)} livros | {total_caps} capitulos | {total_v:,} versiculos")
    print(f"  Tamanho: {size_kb:.0f} KB")
    print()
    print("  Proximo passo — adicione ao pubspec.yaml:")
    print("    flutter:")
    print("      assets:")
    print("        - assets/bible/acf.json")
    print()
    print("  Depois rode: flutter run")
    print("=" * 55)

if __name__ == "__main__":
    main()
