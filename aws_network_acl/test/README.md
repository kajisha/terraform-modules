# test

## 実行方法
```
cd pytest
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pytest
```

## pytestのoption

- `--no-destroy`
  - 通常はtest完了時にtest用のterraform resourceを削除するが、このoptionを与えると削除しなくなる。
  開発時において、都度削除する時間を節約するためのflag。
