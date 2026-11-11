"""연습문제집 빌드 — src/drills/<이름>/practice.src.md → drills/<이름>/practice.md · answers.md · answers.sql

python3 tools/build_drill.py                 # 전체
python3 tools/build_drill.py shopping-mall   # 하나만

- 각 문제집은 자기 DB를 쓴다: drills/<이름>/setup.sql (생성기: tools/gen_drill_*.py)
- 정답 SQL을 실제로 실행해 기대 결과표를 붙인다 (챕터 실습과 같은 방식)
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import build  # noqa: E402

ROOT = build.ROOT


def build_one(name):
    src = ROOT / "src" / "drills" / name / "practice.src.md"
    out = ROOT / "drills" / name
    setup = (out / "setup.sql").read_text(encoding="utf-8")
    db = re.search(r"CREATE DATABASE (\w+)", setup).group(1)
    text = src.read_text(encoding="utf-8")
    title = text.splitlines()[0].lstrip("# ").strip()

    build.install(setup)
    c = build.conn(db)
    p = build.process(build.strip_tag(build.keep_tag(text, "q"), "a"), c, "practice")
    c.close()
    build.install(setup)
    c = build.conn(db)
    a = build.process(build.keep_tag(build.strip_tag(text, "q"), "a"), c, "answers")
    c.close()
    (out / "practice.md").write_text(p, encoding="utf-8")
    (out / "answers.md").write_text(a.replace(title, title + " — 정답과 해설", 1), encoding="utf-8")
    (out / "answers.sql").write_text(
        build.answers_sql(text, title, db).replace("이 챕터의 setup.sql", "이 폴더의 setup.sql"), encoding="utf-8")
    print("built drills/" + name, f"({db})")


if __name__ == "__main__":
    names = sys.argv[1:] or [d.name for d in sorted((ROOT / "src" / "drills").iterdir()) if d.is_dir()]
    for n in names:
        build_one(n)
