"""Check that Python functions have one return at most and no process exits."""

import ast
import sys
from pathlib import Path


def python_files(paths: list[str]) -> list[Path]:
    files = []
    for raw_path in paths:
        path = Path(raw_path)
        files.extend(path.rglob("*.py") if path.is_dir() else [path])
    return sorted(files)


def direct_returns(node: ast.AST) -> list[ast.Return]:
    returns = []
    for child in ast.iter_child_nodes(node):
        if isinstance(child, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)):
            continue
        returns.extend(item for item in ast.walk(child) if isinstance(item, ast.Return))
    return returns


def check_file(path: Path) -> list[str]:
    tree = ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
    errors = []
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)) and len(direct_returns(node)) > 1:
            errors.append(f"{path}:{node.lineno}: больше одного return в {node.name}()")
    for node in ast.walk(tree):
        if isinstance(node, ast.Call) and isinstance(node.func, ast.Name) and node.func.id == "exit":
            errors.append(f"{path}:{node.lineno}: запрещён exit()")
        if isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute) and node.func.attr == "exit":
            errors.append(f"{path}:{node.lineno}: запрещён вызов *.exit()")
    return errors


def main() -> None:
    errors = [error for path in python_files(sys.argv[1:]) for error in check_file(path)]
    if errors:
        raise RuntimeError("\n".join(errors))
    print("return/exit: ok")


if __name__ == "__main__":
    main()