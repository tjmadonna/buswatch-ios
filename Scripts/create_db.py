import argparse
from dataclasses import dataclass
import sqlite3
import json
from typing import List, Optional

from export_stops import Stop


@dataclass
class Route:
    id: str
    title: str
    color: str


def create_connection(db_file: str) -> Optional[sqlite3.Connection]:
    # """create a database connection to the SQLite database
    #     specified by db_file
    # :param db_file: database file
    # :return: Connection object or None
    # """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
        return conn
    except sqlite3.Error as e:
        print(e)

    return conn


def create_table(conn: sqlite3.Connection, create_table_sql: str):
    """create a table from the create_table_sql statement
    :param conn: Connection object
    :param create_table_sql: a CREATE TABLE statement
    :return:
    """
    try:
        conn.execute(create_table_sql)
    except sqlite3.Error as e:
        print(e)


def create_stops(conn: sqlite3.Connection, stops: List[Stop]):
    try:
        stop_tuples = [
            (s.id, s.title, s.latitude, s.longitude, ",".join(s.routes), s.service_type)
            for s in stops
        ]
        conn.executemany(
            "INSERT INTO stops (id, title, latitude, longitude, routes, service_type) values (?, ?, ?, ?, ?, ?);",
            stop_tuples,
        )
    except sqlite3.Error as e:
        print(e)


def create_routes(conn: sqlite3.Connection, routes: List[Route]):
    try:
        routes_tuples = [(r.id, r.title, r.color) for r in routes]
        conn.executemany(
            "INSERT INTO routes (id, title, color) values (?, ?, ?);",
            routes_tuples,
        )
    except sqlite3.Error as e:
        print(e)


def create_migrations(conn: sqlite3.Connection, db_version: int):
    try:
        mig_tuples = [(i,) for i in range(1, db_version + 1)]
        conn.executemany(
            "INSERT INTO grdb_migrations (identifier) values (?);",
            mig_tuples,
        )
    except sqlite3.Error as e:
        print(e)


def create_resource_version(conn: sqlite3.Connection, res_version: int):
    try:
        res_tuples = [(i,) for i in range(1, res_version + 1)]
        conn.executemany(
            "INSERT INTO resource_versions (version) values (?);",
            res_tuples,
        )
    except sqlite3.Error as e:
        print(e)


def run(
    stopsfile: str, routesfile: str, outputfile: str, db_version: int, res_version: int
):
    with open(stopsfile) as stops_file:
        stops = [Stop(**s) for s in json.load(stops_file)]
        filtered = [s for s in stops if s.service_type == 1]

    with open(routesfile) as routes_file:
        routes = [Route(**r) for r in json.load(routes_file)]

    if stops and routes:
        conn = create_connection(outputfile)

        # Migrations
        create_table(
            conn,
            """ CREATE TABLE grdb_migrations (
                identifier TEXT NOT NULL PRIMARY KEY
                );
            """,
        )

        # Routes
        create_table(
            conn,
            """ CREATE TABLE routes (
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                color TEXT NOT NULL
                );
            """,
        )

        # Stops
        create_table(
            conn,
            """ CREATE TABLE stops (
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,       
                latitude REAL NOT NULL,
                longitude REAL NOT NULL,
                routes TEXT,
                service_type INTEGER NOT NULL DEFAULT 0
                );
            """,
        )

        # Resource version
        create_table(
            conn,
            """ CREATE TABLE resource_versions (
                version INTEGER PRIMARY KEY
                );
            """,
        )

        # Favorite stop
        create_table(
            conn,
            """ CREATE TABLE favorite_stops (
                stop_id TEXT PRIMARY KEY,
                FOREIGN KEY (stop_id) REFERENCES stops (id)
                ON UPDATE CASCADE
                ON DELETE CASCADE
                );
            """,
        )

        # Excluded routes
        create_table(
            conn,
            """ CREATE TABLE excluded_routes (
                stop_id TEXT PRIMARY KEY,
                routes TEXT NOT NULL,
                FOREIGN KEY (stop_id) REFERENCES stops (id)
                ON UPDATE CASCADE
                ON DELETE CASCADE
                );
            """,
        )

        create_stops(conn, stops)
        create_routes(conn, routes)
        create_migrations(conn, db_version)
        create_resource_version(conn, res_version)

        conn.commit()
        conn.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="json files into sqlite")
    parser.add_argument(
        "-s",
        "--stopsfile",
        default="./stops.json",
        help="path of the stops json file",
    )
    parser.add_argument(
        "-r",
        "--routesfile",
        default="./routes.json",
        help="path of the routes json file",
    )
    parser.add_argument(
        "-dv",
        "--db_version",
        type=int,
        help="version of the database",
    )
    parser.add_argument(
        "-rv",
        "--res_version",
        type=int,
        help="version of the resources (stops and routes)",
    )
    parser.add_argument(
        "-o",
        "--outputfile",
        default=f"./database.db",
        help="path of the output sqlite file",
    )
    args = parser.parse_args()
    run(
        stopsfile=args.stopsfile,
        routesfile=args.routesfile,
        outputfile=args.outputfile,
        db_version=args.db_version,
        res_version=args.res_version,
    )
