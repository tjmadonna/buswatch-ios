def normalized_routes(routes: list):
    unique_routes = set(routes)
    normalized_routes = [_split_route(route) for route in unique_routes]
    return sorted(normalized_routes, key=lambda i: (len(i), i), reverse=False)


def _split_route(route):
    route_num = route.split("-")[0]
    if route_num[0] == "0":
        route_num = route_num[1:]
    return route_num


def normalized_str(string: str) -> str:
    return string.strip().title().replace(" - ", "-").replace("+", "And")
