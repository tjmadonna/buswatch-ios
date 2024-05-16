import re
from string import capwords
from typing import Optional


def normalized_routes(routes: list):
    unique_routes = set(routes)
    normalized_routes = [_split_route(route) for route in unique_routes]
    return sorted(normalized_routes, key=lambda i: (len(i), i), reverse=False)


def _split_route(route):
    route_num = route.split("-")[0]
    if route_num[0] == "0":
        route_num = route_num[1:]
    return route_num


def capitalize(s: str, split_sep: str, join_sep: Optional[str] = None) -> str:
    if join_sep is None:
        join_sep = split_sep
    return join_sep.join([capwords(x) for x in s.split(split_sep)])


replace_keywords = {
    " - ": "-",
    "+": "And",
    "mckspt": "McKeesport",
    "Pgh": "Pittsburgh",
    "Shop-n-save": "Shop N Save",
    "Mcoy": "McCoy",
}

capitalize_keywords = [
    "ymca",
    "upmc",
    "ccac",
]


def normalized_str(s: str) -> str:
    s = s.strip()
    if " " in s:
        s = capitalize(s, " ")
    if "-" in s:
        s = capitalize(s, "-")
    if "(" in s:
        s = capitalize(s, "(", " (")
    for k, v in replace_keywords.items():
        s = s.replace(k, v)
    s = re.sub(
        r"((?:^|[\s-])[Mm]c)([a-z]){1}",
        lambda m: m.group(1).title() + m.group(2).title(),
        s,
    )
    s = re.sub(
        rf"((?:^|[\s-]){'|'.join(capitalize_keywords)})",
        lambda m: m.group(1).upper(),
        s,
        flags=re.IGNORECASE,
    )
    return s
