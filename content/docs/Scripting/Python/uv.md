---
date: 2023-08-01T21:00:00+08:00
title: 🌅 UV
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Devops
categories:
  - Docs
tags:
  - Scripting
  - Python
  - Repository
---

### Install

```bash
# curl method
curl -LsSf https://astral.sh/uv/install.sh | sh

# Pip method
pip install uv
```

### Quick example

```bash
pyenv install 3.12
pyenv local 3.12
python -m venv .venv
source .venv/bin/activate
pip install pandas
python

# equivalent in uv
uv run --python 3.12 --with pandas python
```

### Usefull

```shell
uv python list --only-installed
uv python install 3.12
uv venv /path/to/environment --python 3.12
uv pip install django
uv pip compile requirements.in -o requirements.txt

uv init myproject
uv sync
uv run manage.py runserver
```

### Run as script

* Put before the `import` statements:

```shell
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
# "ffmpeg-normalize",
# ]
# ///
```

Then can be run with `uv run sync-flickr-dates.py`. `uv` will create a Python 3.12 venv for us. 
For me this is in `~/.cache/uv` (which you can find via `uv cache dir`).

### Sources

[Blog Akrabat](https://akrabat.com/using-uv-as-your-shebang-line/)

[Blog Astral](https://astral.sh/blog/uv-unified-python-packaging)

[Hynek Youtube](https://www.youtube.com/watch?v=8UuW8o4bHbw)

[saaspegasus](https://www.saaspegasus.com/guides/uv-deep-dive/)

[reinforcedknowledge](https://reinforcedknowledge.com/a-comprehensive-guide-to-python-project-management-and-packaging-concepts-illustrated-with-uv-part-i/)

[tuto youtube](https://www.youtube.com/watch?v=qh98qOND6MI)

[tuto youtube](https://www.youtube.com/watch?v=ifj-izwXKRA)

[tuto youtube](https://www.youtube.com/watch?v=jXWIxk2brfk)