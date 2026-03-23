"""
Environment config: loads variables from config/<env>.json (one file per env in config/).
ENV is chosen at runtime (e.g. --variable ENV:dev). All modules get variables from here.
Values are easy to view and edit in JSON.
"""
import json
import os

_CONFIG_DIR = os.path.dirname(os.path.abspath(__file__))
_ENVIRONMENTS_CACHE = {}


def _load_config_json(env):
    """Load config/<env>.json and return a dict. Uses cache. All values coerced to str for Robot."""
    env = (env or "dev").strip().lower()
    if env in _ENVIRONMENTS_CACHE:
        return _ENVIRONMENTS_CACHE[env]
    config_path = os.path.join(_CONFIG_DIR, f"{env}.json")
    if not os.path.isfile(config_path):
        env = "dev"
        config_path = os.path.join(_CONFIG_DIR, "dev.json")
    with open(config_path, encoding="utf-8") as f:
        data = json.load(f)
    # Coerce all values to string so Robot Framework gets consistent variable types
    result = {k: str(v) for k, v in data.items()}
    _ENVIRONMENTS_CACHE[env] = result
    return result


def get_variables(ENV="dev"):
    """Return a dict of variable names to values for the given environment.
    Used by Robot Framework Variables and by any Python code. Data is read from
    config/<env>.json so each environment is accurate and easy to edit.
    """
    return _load_config_json(ENV)


def _build_environments():
    """Build ENVIRONMENTS dict from all config/*.json files (exclude env_config.py and non-JSON)."""
    envs = {}
    try:
        for name in os.listdir(_CONFIG_DIR):
            if not name.endswith(".json") or name.startswith("_"):
                continue
            env_name = name[:-5]
            path = os.path.join(_CONFIG_DIR, name)
            if os.path.isfile(path):
                envs[env_name] = get_variables(env_name)
    except OSError:
        pass
    return envs if envs else {"dev": get_variables("dev")}


# Expose ENVIRONMENTS for code that still uses ENVIRONMENTS["dev"] etc.
ENVIRONMENTS = _build_environments()
